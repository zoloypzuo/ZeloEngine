// MeshSceneFinalFinal.cpp.cc
// created on 2021/12/18
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "MeshSceneFinal.h"

#include "Core/Resource/ResourceManager.h"
#include "Core/Scene/SceneManager.h"
#include "Core/RHI/RenderSystem.h"

#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"

#include "Renderer/OpenGL/Drawable/MeshScene/GLSkyboxRenderer.h"

#include "Renderer/OpenGL/Drawable/MeshScene/Buffer/GLAtomicCounterDSA.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Buffer/GLFramebufferDSA.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Buffer/GLIndirectCommandBufferDSA.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Buffer/GLShaderStorageBufferDSA.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Buffer/GLUniformBufferDSA.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Buffer/GLVertexArrayDSA.h"

#include "Renderer/OpenGL/Drawable/MeshScene/Scene/SceneGraph.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Material/Material.h"
#include "Renderer/OpenGL/Drawable/MeshScene/VtxData/MeshData.h"
#include "Renderer/OpenGL/Drawable/MeshScene/VtxData/DrawData.h"

#include <taskflow/taskflow.hpp>
#include <stb_image.h>

using namespace Zelo::Core::RHI;

namespace Zelo::Renderer::OpenGL {

struct PerFrameData {
    glm::mat4 view;
    glm::mat4 proj;
    glm::mat4 light;
    vec4 cameraPos;
    vec4 frustumPlanes[6];
    vec4 frustumCorners[8];
    uint32_t numShapesToCull;
};

struct TransparentFragment {
    float R, G, B, A;
    float Depth;
    glm::uint32_t Next;
};

struct SSAOParams {
    float scale_ = 1.5f;
    float bias_ = 0.15f;
    float zNear = 0.1f;
    float zFar = 1000.0f;
    float radius = 0.05f;
    float attScale = 1.01f;
    float distScale = 0.6f;
} g_SSAOParams;

static_assert(sizeof(SSAOParams) <= sizeof(PerFrameData));

struct HDRParams {
    float exposure_ = 0.9f;
    float maxWhite_ = 1.17f;
    float bloomStrength_ = 1.1f;
    float adaptationSpeed_ = 0.1f;
} g_HDRParams;

static_assert(sizeof(HDRParams) <= sizeof(PerFrameData));

const GLuint kBufferIndex_PerFrameUniforms = 0;
const GLuint kBufferIndex_ModelMatrices = 1;
const GLuint kBufferIndex_Materials = 2;

const GLuint kBufferIndex_BoundingBoxes = kBufferIndex_PerFrameUniforms + 1;
const GLuint kBufferIndex_DrawCommands = kBufferIndex_PerFrameUniforms + 2;
const GLuint kBufferIndex_NumVisibleMeshes = kBufferIndex_PerFrameUniforms + 3;

const GLuint kBufferIndex_OitAtomicCounter = 0;

const GLuint kMaxNumObjects = 128 * 1024;
const GLsizeiptr kUniformBufferSize = sizeof(PerFrameData);
const GLsizeiptr kBoundingBoxesBufferSize = sizeof(BoundingBox) * kMaxNumObjects;

const glm::uint32_t kMaxOITFragments = 16 * 1024 * 1024;
const GLuint kBufferIndex_TransparencyLists = kBufferIndex_Materials + 1;

const static BufferLayout s_BufferLayout(
        {
                BufferElement(EBufferDataType::Float3, "position"),
                BufferElement(EBufferDataType::Float2, "texCoord"),
                BufferElement(EBufferDataType::Float3, "normal")
        });

static std::string ZELO_PATH(const std::string &fileName) {
    auto *resourcem = Zelo::Core::Resource::ResourceManager::getSingletonPtr();
    return resourcem->resolvePath(fileName).string();
}

static uint64_t getTextureHandleBindless(uint64_t idx, const std::vector<GLTexture> &textures) {
    if (idx == INVALID_TEXTURE) return 0;

    return textures[idx].getHandleBindless();
}

static uint64_t getTextureHandleBindless(uint64_t idx, const std::vector<std::shared_ptr<GLTexture>> &textures) {
    if (idx == INVALID_TEXTURE) return 0;

    return textures[idx]->getHandleBindless();
}

struct MeshSceneFinal::Impl {
#pragma region scene
    struct LoadedImageData {
        int index_ = 0;
        int w_ = 0;
        int h_ = 0;
        const uint8_t *img_ = nullptr;
    };

    std::shared_ptr<GLTexture> dummyTexture_;

    std::vector<std::string> textureFiles_;
    std::vector<LoadedImageData> loadedFiles_;
    std::mutex loadedFilesMutex_;
    std::vector<std::shared_ptr<GLTexture>> allMaterialTextures_;

    MeshFileHeader header_;
    MeshData meshData_;

    SceneGraph scene_;
    std::vector<MaterialDescription> materialsLoaded_; // materials loaded from scene
    std::vector<MaterialDescription> materials_; // materials uploaded to GPU buffers
    std::vector<DrawData> drawDataList;

    tf::Taskflow taskflow_;
    tf::Executor executor_;

    void updateMaterials();

    bool uploadLoadedTextures();

#pragma endregion scene

#pragma region buffer

    void updateMaterialsBuffer();

    void draw(const GLIndirectCommandBufferDSA &buffer) const;

    GLVertexArrayDSA vao;

    std::unique_ptr<GLShaderStorageBufferDSA> bufferMaterials_;
    std::unique_ptr<GLShaderStorageBufferDSA> bufferModelMatrices_;

    std::unique_ptr<GLIndirectCommandBufferDSA> bufferIndirect_;

#pragma endregion buffer

#pragma region shader
    std::unique_ptr<GLSLShaderProgram> progGrid{};
    std::unique_ptr<GLSLShaderProgram> program{};
    std::unique_ptr<GLSLShaderProgram> programOIT{};
    std::unique_ptr<GLSLShaderProgram> progCombineOIT{};
    std::unique_ptr<GLSLShaderProgram> programCulling{};
    std::unique_ptr<GLSLShaderProgram> progSSAO{};
    std::unique_ptr<GLSLShaderProgram> progCombineSSAO{};
    std::unique_ptr<GLSLShaderProgram> progBlurX{};
    std::unique_ptr<GLSLShaderProgram> progBlurY{};
    std::unique_ptr<GLSLShaderProgram> progCombineHDR{};
    std::unique_ptr<GLSLShaderProgram> progToLuminance{};
    std::unique_ptr<GLSLShaderProgram> progBrightPass{};
    std::unique_ptr<GLSLShaderProgram> progAdaptation{};
    std::unique_ptr<GLSLShaderProgram> progShadowMap{};
#pragma endregion shader

    int width = 1280;
    int height = 720;
    GLSkyboxRenderer skybox;
    GLTexture rotationPattern;
    std::unique_ptr<GLIndirectCommandBufferDSA> meshesOpaque;
    std::unique_ptr<GLIndirectCommandBufferDSA> meshesTransparent;

#pragma region framebuffer
    GLFramebufferDSA opaqueFramebuffer;
    GLFramebufferDSA framebuffer;
    GLFramebufferDSA luminance;
    GLFramebufferDSA brightPass;
    GLFramebufferDSA bloom1;
    GLFramebufferDSA bloom2;
    GLFramebufferDSA ssao;
    GLFramebufferDSA blur;
    GLFramebufferDSA shadowMap;
#pragma endregion framebuffer

    GLAtomicCounterDSA oitAtomicCounter;
    GLShaderStorageBufferDSA oitTransparencyLists;
    GLTexture oitHeads;

    std::vector<BoundingBox> reorderedBoxes;
    BoundingBox bigBox{};
    std::vector<GLTexture *> luminances;  // [2]

    GLUniformBufferDSA perFrameDataBuffer;
    GLShaderStorageBufferDSA boundingBoxesBuffer;
    GLShaderStorageBufferDSA numVisibleMeshesBuffer;

    GLuint luminance1x1{};
    GLTexture luminance1;
    GLTexture luminance2;

    GLsync fenceCulling = nullptr;
    volatile glm::uint32_t *numVisibleMeshesPtr;

    bool g_EnableGPUCulling = false;
    bool g_FreezeCullingView = false;
    bool g_DrawOpaque = true;
    bool g_DrawTransparent = true;
    bool g_DrawGrid = false;
    bool g_EnableSSAO = true;
    bool g_EnableBlur = true;
    bool g_EnableHDR = true;
    bool g_EnableShadows = true;
    float g_LightTheta = 0.0f;
    float g_LightPhi = 0.0f;

    glm::mat4 g_CullingView{};

    void clearTransparencyBuffers() const {
        const uint32_t minusOne = 0xFFFFFFFF;
        glClearTexImage(oitHeads.getHandle(), 0, GL_RED_INTEGER, GL_UNSIGNED_INT, &minusOne);
        oitAtomicCounter.sendZero();
    }

    Impl(const std::string &meshFile,
         const std::string &sceneFile,
         const std::string &materialFile,
         const std::string &dummyTextureFile);

    ~Impl() = default;

    void render();

};

void MeshSceneFinal::Impl::updateMaterials() {
    const size_t numMaterials = materialsLoaded_.size();

    materials_.resize(numMaterials);

    for (size_t i = 0; i != numMaterials; i++) {
        const auto &in = materialsLoaded_[i];
        auto &out = materials_[i];
        out = in;
        out.ambientOcclusionMap_ = getTextureHandleBindless(in.ambientOcclusionMap_, allMaterialTextures_);
        out.emissiveMap_ = getTextureHandleBindless(in.emissiveMap_, allMaterialTextures_);
        out.albedoMap_ = getTextureHandleBindless(in.albedoMap_, allMaterialTextures_);
        out.metallicRoughnessMap_ = getTextureHandleBindless(in.metallicRoughnessMap_, allMaterialTextures_);
        out.normalMap_ = getTextureHandleBindless(in.normalMap_, allMaterialTextures_);
    }
}

bool MeshSceneFinal::Impl::uploadLoadedTextures() {
    LoadedImageData data;

    {
        std::lock_guard lock(loadedFilesMutex_);

        if (loadedFiles_.empty())
            return false;

        data = loadedFiles_.back();

        loadedFiles_.pop_back();
    }

    allMaterialTextures_[data.index_] = std::make_shared<GLTexture>(data.w_, data.h_, data.img_);

    stbi_image_free((void *) data.img_);

    updateMaterials();

    return true;
}

void MeshSceneFinal::Impl::updateMaterialsBuffer() {
    glNamedBufferSubData(bufferMaterials_->getHandle(), 0, sizeof(MaterialDescription) * materials_.size(),
                         materials_.data());
}

void MeshSceneFinal::Impl::draw(const GLIndirectCommandBufferDSA &buffer) const {

    vao.bind();
    bufferMaterials_->bind(kBufferIndex_Materials);
    bufferModelMatrices_->bind(kBufferIndex_ModelMatrices);
    buffer.bind();

    auto numDrawCommands = (GLsizei) buffer.getDrawCount();
    glMultiDrawElementsIndirect(GL_TRIANGLES, GL_UNSIGNED_INT, nullptr, numDrawCommands, 0);
}


MeshSceneFinal::Impl::Impl(
        const std::string &meshFile,
        const std::string &sceneFile,
        const std::string &materialFile,
        const std::string &dummyTextureFile) :
        rotationPattern(GL_TEXTURE_2D, ZELO_PATH("data/rot_texture.bmp").c_str()),
        opaqueFramebuffer(width, height, GL_RGBA16F, GL_DEPTH_COMPONENT24),
        framebuffer(width, height, GL_RGBA16F, GL_DEPTH_COMPONENT24),
        luminance(64, 64, GL_RGBA16F, 0),
        brightPass(256, 256, GL_RGBA16F, 0),
        bloom1(256, 256, GL_RGBA16F, 0),
        bloom2(256, 256, GL_RGBA16F, 0),
        ssao(1024, 1024, GL_RGBA8, 0),
        blur(1024, 1024, GL_RGBA8, 0),
        shadowMap(8192, 8192, GL_R8, GL_DEPTH_COMPONENT24),
        oitTransparencyLists(sizeof(TransparentFragment) * kMaxOITFragments, nullptr, GL_DYNAMIC_STORAGE_BIT),
        oitHeads(GL_TEXTURE_2D, width, height, GL_R32UI),

        skybox(ZELO_PATH("data/immenstadter_horn_2k.hdr").c_str(),
               ZELO_PATH("data/immenstadter_horn_2k_irradiance.hdr").c_str(),
               ZELO_PATH("data/brdfLUT.ktx").c_str()),

        perFrameDataBuffer(kBufferIndex_PerFrameUniforms, kUniformBufferSize),
        boundingBoxesBuffer(kBoundingBoxesBufferSize, nullptr, GL_DYNAMIC_STORAGE_BIT),
        numVisibleMeshesBuffer(sizeof(uint32_t), nullptr,
                               GL_MAP_READ_BIT | GL_MAP_WRITE_BIT | GL_MAP_PERSISTENT_BIT | GL_MAP_COHERENT_BIT),
        // ping-pong textures for light adaptation
        luminance1(GL_TEXTURE_2D, 1, 1, GL_RGBA16F),
        luminance2(GL_TEXTURE_2D, 1, 1, GL_RGBA16F) {

    // scene
    {

        dummyTexture_ = std::make_shared<GLTexture>(GL_TEXTURE_2D, dummyTextureFile.c_str());

        header_ = loadMeshData(meshFile.c_str(), meshData_);
        // load scene
        {
            ::Zelo::Renderer::OpenGL::loadScene(sceneFile.c_str(), scene_);

            // prepare draw data buffer
            for (const auto &c: scene_.meshes_) {
                auto material = scene_.materialForNode_.find(c.first);
                if (material != scene_.materialForNode_.end()) {
                    drawDataList.emplace_back(
                            c.second,
                            material->second,
                            0,
                            meshData_.meshes_[c.second].indexOffset,
                            meshData_.meshes_[c.second].vertexOffset,
                            c.first
                    );
                }
            }

            // force recalculation of all global transformations
            markAsChanged(scene_, 0);
            recalculateGlobalTransforms(scene_);
        }
        loadMaterials(materialFile.c_str(), materialsLoaded_, textureFiles_);

        for (auto &f: textureFiles_) {
            f = ZELO_PATH(f);
        }

        // apply a dummy textures to everything
        for (const auto &f: textureFiles_) {
            allMaterialTextures_.emplace_back(dummyTexture_);
        }

        updateMaterials();

        loadedFiles_.reserve(textureFiles_.size());

        taskflow_.for_each_index(0u, (uint32_t) textureFiles_.size(), 1u, [this](int idx) {
                                     int w, h;
                                     const uint8_t *img = stbi_load(this->textureFiles_[idx].c_str(), &w, &h, nullptr, STBI_rgb_alpha);
                                     if (img) {
                                         std::lock_guard lock(loadedFilesMutex_);
                                         loadedFiles_.emplace_back(LoadedImageData{idx, w, h, img});
                                     }
                                 }
        );

        executor_.run(taskflow_);
    }

    // vao
    {
        auto bufferIndices_ = std::make_shared<GLIndexBufferDSA>(
                header_.indexDataSize, meshData_.indexData_.data(), 0);
        auto bufferVertices_ = std::make_shared<GLVertexBufferDSA>(
                header_.vertexDataSize, meshData_.vertexData_.data(), 0);

        bufferVertices_->setLayout(s_BufferLayout);
        vao.addVertexBuffer(bufferVertices_);
        vao.setIndexBuffer(bufferIndices_);
    }

    // bufferIndirect_
    {
        bufferIndirect_ = std::make_unique<GLIndirectCommandBufferDSA>(drawDataList.size());
        // prepare indirect commands buffer
        for (size_t i = 0; i != drawDataList.size(); i++) {
            const uint32_t meshIdx = drawDataList[i].meshIndex;
            const uint32_t lod = drawDataList[i].LOD;
            bufferIndirect_->getCommandQueue()[i] = {
                    meshData_.meshes_[meshIdx].getLODIndicesCount(lod),
                    1,
                    drawDataList[i].indexOffset,
                    drawDataList[i].vertexOffset,
                    drawDataList[i].materialIndex + (uint32_t(i) << 16)  // NOTE HERE
            };
        }

        bufferIndirect_->sendBlocks();
    }

    // bufferMaterials_
    {
        bufferMaterials_ = std::make_unique<GLShaderStorageBufferDSA>(
                materials_.size() * sizeof(MaterialDescription),
                materials_.data(), GL_DYNAMIC_STORAGE_BIT
        );
    }

    // bufferModelMatrices_
    {
        // can be merged into bufferIndirect_ loop
        bufferModelMatrices_ = std::make_unique<GLShaderStorageBufferDSA>(
                drawDataList.size() * sizeof(glm::mat4), nullptr, GL_DYNAMIC_STORAGE_BIT);
        std::vector<glm::mat4> matrices(drawDataList.size());
        size_t i = 0;
        for (const auto &c: drawDataList) {
            matrices[i++] = scene_.globalTransform_[c.transformIndex];
        }

        bufferModelMatrices_->sendBlocks(matrices);
    }

    // shader
    progGrid = std::make_unique<GLSLShaderProgram>("grid.glsl");
    program = std::make_unique<GLSLShaderProgram>("scene_IBL.glsl");
    programOIT = std::make_unique<GLSLShaderProgram>("mesh_oit.glsl");
    progCombineOIT = std::make_unique<GLSLShaderProgram>("oit.glsl");
    programCulling = std::make_unique<GLSLShaderProgram>("frustum_culling.glsl");
    progSSAO = std::make_unique<GLSLShaderProgram>("ssao.glsl");
    progCombineSSAO = std::make_unique<GLSLShaderProgram>("ssao_combine.glsl");
    progBlurX = std::make_unique<GLSLShaderProgram>("blurx.glsl");
    progBlurY = std::make_unique<GLSLShaderProgram>("blury.glsl");
    progCombineHDR = std::make_unique<GLSLShaderProgram>("hdr/hdr.glsl");
    progToLuminance = std::make_unique<GLSLShaderProgram>("hdr/to_luminance.glsl");
    progBrightPass = std::make_unique<GLSLShaderProgram>("hdr/bright_pass.glsl");
    progAdaptation = std::make_unique<GLSLShaderProgram>("hdr/adaptation.glsl");
    progShadowMap = std::make_unique<GLSLShaderProgram>("shadow.glsl");

    numVisibleMeshesPtr = numVisibleMeshesBuffer.getMappedPtr();
    assert(numVisibleMeshesPtr);

    auto *camera = Zelo::Core::Scene::SceneManager::getSingletonPtr()->getActiveCamera();
    g_CullingView = camera->getViewMatrix();

    // meshesOpaque meshesTransparent
    {
        auto isTransparent = [this](const DrawElementsIndirectCommand &c) {
            const auto mtlIndex = c.baseInstance_ & 0xffff;
            const auto &mtl = this->materials_[mtlIndex];
            return (mtl.flags_ & sMaterialFlags_Transparent) > 0;
        };

        const auto &commandQueue = bufferIndirect_->getCommandQueue();
        std::vector<DrawElementsIndirectCommand> opaqueCommandQueue{};
        std::vector<DrawElementsIndirectCommand> transparentCommandQueue{};
        for (const auto &c: commandQueue) {
            if (isTransparent(c)) {
                transparentCommandQueue.emplace_back(c);
            } else {
                opaqueCommandQueue.emplace_back(c);
            }
        }

        meshesOpaque = std::make_unique<GLIndirectCommandBufferDSA>(opaqueCommandQueue);
        meshesTransparent = std::make_unique<GLIndirectCommandBufferDSA>(transparentCommandQueue);
    }

    // create a texture view into the last mip-level (1x1 pixel) of our luminance framebuffer

    glGenTextures(1, &luminance1x1);
    glTextureView(luminance1x1, GL_TEXTURE_2D, luminance.getTextureColor().getHandle(), GL_RGBA16F, 6, 1, 0, 1);

    luminances = {&luminance1, &luminance2};
    const vec4 brightPixel(vec3(50.0f), 1.0f);
    glTextureSubImage2D(luminance1.getHandle(), 0, 0, 0, 1, 1, GL_RGBA, GL_FLOAT, glm::value_ptr(brightPixel));


    glBindImageTexture(0, oitHeads.getHandle(), 0, GL_FALSE, 0, GL_READ_WRITE, GL_R32UI);
    oitAtomicCounter.bind(kBufferIndex_OitAtomicCounter);

    {
        reorderedBoxes.reserve(drawDataList.size());

        // pretransform bounding boxes to world space
        for (const auto &c: drawDataList) {
            const mat4 model = scene_.globalTransform_[c.transformIndex];
            reorderedBoxes.push_back(meshData_.boxes_[c.meshIndex]);
            reorderedBoxes.back().transform(model);
        }
        boundingBoxesBuffer.sendBlocks(reorderedBoxes);

        bigBox = reorderedBoxes.front();
        for (const auto &b: reorderedBoxes) {
            bigBox.combinePoint(b.min_);
            bigBox.combinePoint(b.max_);
        }
    }

    const GLint swizzleMask[] = {GL_RED, GL_RED, GL_RED, GL_ONE};
    glTextureParameteriv(shadowMap.getTextureColor().getHandle(), GL_TEXTURE_SWIZZLE_RGBA, swizzleMask);
    glTextureParameteriv(shadowMap.getTextureDepth().getHandle(), GL_TEXTURE_SWIZZLE_RGBA, swizzleMask);
}

void MeshSceneFinal::Impl::render() {
    if (uploadLoadedTextures()) {
        updateMaterialsBuffer();
    }

    GLuint opaqueFboHandle = opaqueFramebuffer.getHandle();
    glClearNamedFramebufferfv(opaqueFboHandle, GL_COLOR, 0, glm::value_ptr(vec4(0.0f, 0.0f, 0.0f, 1.0f)));
    glClearNamedFramebufferfi(opaqueFboHandle, GL_DEPTH_STENCIL, 0, 1.0f, 0);

    auto *camera = Zelo::Core::Scene::SceneManager::getSingletonPtr()->getActiveCamera();

    if (!g_FreezeCullingView) {
        // update cull view
        g_CullingView = camera->getViewMatrix();
    }

    const mat4 proj = camera->getProjectionMatrix();
    const mat4 view = camera->getViewMatrix();
    const vec3 viewPos = camera->getOwner()->getPosition();

    // calculate light parameters for shadow mapping
    const glm::mat4 rot1 = glm::rotate(mat4(1.f), glm::radians(g_LightTheta), glm::vec3(0, 0, 1));
    const glm::mat4 rot2 = glm::rotate(rot1, glm::radians(g_LightPhi), glm::vec3(1, 0, 0));
    const vec3 lightDir = glm::normalize(vec3(rot2 * vec4(0.0f, -1.0f, 0.0f, 1.0f)));
    const mat4 lightView = glm::lookAt(glm::vec3(0.0f), lightDir, vec3(0, 0, 1));
    const BoundingBox box = bigBox.getTransformed(lightView);
    const mat4 lightProj = glm::ortho(box.min_.x, box.max_.x, box.min_.y, box.max_.y, -box.max_.z, -box.min_.z);

    PerFrameData perFrameData = {
            view,
            proj,
            lightProj * lightView,
            glm::vec4(viewPos, 1.0f),
    };

    getFrustumPlanes(proj * view, perFrameData.frustumPlanes);
    getFrustumCorners(proj * view, perFrameData.frustumCorners);

    clearTransparencyBuffers();

    // cull
    {
        *numVisibleMeshesPtr = 0;
        programCulling->bind();
        glMemoryBarrier(GL_BUFFER_UPDATE_BARRIER_BIT);
        boundingBoxesBuffer.bind(kBufferIndex_BoundingBoxes);
        numVisibleMeshesBuffer.bind(kBufferIndex_NumVisibleMeshes);

        perFrameData.numShapesToCull = g_EnableGPUCulling ? (uint32_t) meshesOpaque->getDrawCount() : 0u;
        perFrameDataBuffer.sendBlocks(perFrameData);
        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, kBufferIndex_DrawCommands, meshesOpaque->getHandle());
        glDispatchCompute(1 + (GLuint) meshesOpaque->getDrawCount() / 64, 1, 1);

        perFrameData.numShapesToCull = g_EnableGPUCulling ? (uint32_t) meshesTransparent->getDrawCount() : 0u;
        perFrameDataBuffer.sendBlocks(perFrameData);
        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, kBufferIndex_DrawCommands, meshesTransparent->getHandle());
        glDispatchCompute(1 + (GLuint) meshesTransparent->getDrawCount() / 64, 1, 1);

        glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_CLIENT_MAPPED_BUFFER_BARRIER_BIT);
        fenceCulling = glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0);
    }

    oitTransparencyLists.bind(kBufferIndex_TransparencyLists);

    // 1. Render shadow map
    if (g_EnableShadows) {
        glDisable(GL_BLEND);
        glEnable(GL_DEPTH_TEST);
        // Calculate light parameters
        const PerFrameData perFrameDataShadows = {lightView, lightProj};
        perFrameDataBuffer.sendBlocks(perFrameDataShadows);
        glClearNamedFramebufferfv(shadowMap.getHandle(), GL_COLOR, 0, glm::value_ptr(vec4(0.0f, 0.0f, 0.0f, 1.0f)));
        glClearNamedFramebufferfi(shadowMap.getHandle(), GL_DEPTH_STENCIL, 0, 1.0f, 0);
        shadowMap.bind();
        progShadowMap->bind();
        draw(*bufferIndirect_);
        shadowMap.unbind();
        perFrameData.light = lightProj * lightView;
        glBindTextureUnit(4, shadowMap.getTextureDepth().getHandle());
    } else {
        // disable shadows
        perFrameData.light = mat4(0.0f);
    }
    perFrameDataBuffer.sendBlocks(perFrameData);

    // 1. Render scene
    opaqueFramebuffer.bind();
    glDisable(GL_BLEND);
    glEnable(GL_DEPTH_TEST);
    // 1.0 Cube map
    skybox.draw();
    // 1.1 Bistro
    if (g_DrawOpaque) {
        program->bind();
        draw(*meshesOpaque);
    }
    if (g_DrawGrid) {
        glEnable(GL_BLEND);
        progGrid->bind();
        glDrawArraysInstancedBaseInstance(GL_TRIANGLES, 0, 6, 1, 0);
        glDisable(GL_BLEND);
    }
    if (g_DrawTransparent) {
        glBindImageTexture(0, oitHeads.getHandle(), 0, GL_FALSE, 0, GL_READ_WRITE, GL_R32UI);
        glDepthMask(GL_FALSE);
        glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);
        programOIT->bind();
        draw(*meshesTransparent);
        glFlush();
        glMemoryBarrier(GL_SHADER_STORAGE_BARRIER_BIT);
        glDepthMask(GL_TRUE);
        glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);
    }
    opaqueFramebuffer.unbind();
    // SSAO
    if (g_EnableSSAO) {
        glDisable(GL_DEPTH_TEST);
        glClearNamedFramebufferfv(ssao.getHandle(), GL_COLOR, 0, glm::value_ptr(vec4(0.0f, 0.0f, 0.0f, 1.0f)));
        perFrameDataBuffer.sendBlocks(g_SSAOParams);
        ssao.bind();
        progSSAO->bind();
        glBindTextureUnit(0, opaqueFramebuffer.getTextureDepth().getHandle());
        glBindTextureUnit(1, rotationPattern.getHandle());
        glDrawArrays(GL_TRIANGLES, 0, 6);
        ssao.unbind();
        if (g_EnableBlur) {
            // Blur X
            blur.bind();
            progBlurX->bind();
            glBindTextureUnit(0, ssao.getTextureColor().getHandle());
            glDrawArrays(GL_TRIANGLES, 0, 6);
            blur.unbind();
            // Blur Y
            ssao.bind();
            progBlurY->bind();
            glBindTextureUnit(0, blur.getTextureColor().getHandle());
            glDrawArrays(GL_TRIANGLES, 0, 6);
            ssao.unbind();
        }
        glClearNamedFramebufferfv(framebuffer.getHandle(), GL_COLOR, 0, glm::value_ptr(vec4(0.0f, 0.0f, 0.0f, 1.0f)));
        framebuffer.bind();
        progCombineSSAO->bind();
        glBindTextureUnit(0, opaqueFramebuffer.getTextureColor().getHandle());
        glBindTextureUnit(1, ssao.getTextureColor().getHandle());
        glDrawArrays(GL_TRIANGLES, 0, 6);
        framebuffer.unbind();
    } else {
        glBlitNamedFramebuffer(opaqueFramebuffer.getHandle(), framebuffer.getHandle(), 0, 0, width, height, 0, 0, width,
                               height, GL_COLOR_BUFFER_BIT, GL_LINEAR);
    }
    // combine OIT
    opaqueFramebuffer.bind();
    glDisable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
    progCombineOIT->bind();
    glBindTextureUnit(0, framebuffer.getTextureColor().getHandle());
    glDrawArrays(GL_TRIANGLES, 0, 6);
    opaqueFramebuffer.unbind();
    glBlitNamedFramebuffer(opaqueFramebuffer.getHandle(), framebuffer.getHandle(), 0, 0, width, height, 0, 0, width,
                           height, GL_COLOR_BUFFER_BIT, GL_LINEAR);
    //
    // HDR pipeline
    //
    // pass HDR params to shaders
    if (g_EnableHDR) {
        perFrameDataBuffer.sendBlocks(g_HDRParams);
        // 2.1 Downscale and convert to luminance
        luminance.bind();
        progToLuminance->bind();
        glBindTextureUnit(0, framebuffer.getTextureColor().getHandle());
        glDrawArrays(GL_TRIANGLES, 0, 6);
        luminance.unbind();
        glGenerateTextureMipmap(luminance.getTextureColor().getHandle());
        // 2.2 Light adaptation
        glMemoryBarrier(GL_SHADER_IMAGE_ACCESS_BARRIER_BIT);
        progAdaptation->bind();
        glBindImageTexture(0, luminances[0]->getHandle(), 0, GL_TRUE, 0, GL_READ_ONLY, GL_RGBA16F);
        glBindImageTexture(1, luminance1x1, 0, GL_TRUE, 0, GL_READ_ONLY, GL_RGBA16F);
        glBindImageTexture(2, luminances[1]->getHandle(), 0, GL_TRUE, 0, GL_WRITE_ONLY, GL_RGBA16F);
        glDispatchCompute(1, 1, 1);
        glMemoryBarrier(GL_TEXTURE_FETCH_BARRIER_BIT);
        // 2.3 Extract bright areas
        brightPass.bind();
        progBrightPass->bind();
        glBindTextureUnit(0, framebuffer.getTextureColor().getHandle());
        glDrawArrays(GL_TRIANGLES, 0, 6);
        brightPass.unbind();
        glBlitNamedFramebuffer(brightPass.getHandle(), bloom2.getHandle(), 0, 0, 256, 256, 0, 0, 256, 256,
                               GL_COLOR_BUFFER_BIT, GL_LINEAR);
        for (int i = 0; i != 4; i++) {
            // 2.4 Blur X
            bloom1.bind();
            progBlurX->bind();
            glBindTextureUnit(0, bloom2.getTextureColor().getHandle());
            glDrawArrays(GL_TRIANGLES, 0, 6);
            bloom1.unbind();
            // 2.5 Blur Y
            bloom2.bind();
            progBlurY->bind();
            glBindTextureUnit(0, bloom1.getTextureColor().getHandle());
            glDrawArrays(GL_TRIANGLES, 0, 6);
            bloom2.unbind();
        }
        // 3. Apply tone mapping
        glViewport(0, 0, width, height);
        progCombineHDR->bind();
        glBindTextureUnit(0, framebuffer.getTextureColor().getHandle());
        glBindTextureUnit(1, luminances[1]->getHandle());
        glBindTextureUnit(2, bloom2.getTextureColor().getHandle());
        glDrawArrays(GL_TRIANGLES, 0, 6);
    } else {
        glBlitNamedFramebuffer(framebuffer.getHandle(), 0, 0, 0, width, height, 0, 0, width, height,
                               GL_COLOR_BUFFER_BIT, GL_LINEAR);
    }

    // wait for compute shader results to become visible
    if (g_EnableGPUCulling && fenceCulling) {
        for (;;) {
            const GLenum res = glClientWaitSync(fenceCulling, GL_SYNC_FLUSH_COMMANDS_BIT, 1000);
            if (res == GL_ALREADY_SIGNALED || res == GL_CONDITION_SATISFIED) break;
        }
        glDeleteSync(fenceCulling);
    }

    // swap current and adapter luminances
    std::swap(luminances[0], luminances[1]);
}

MeshSceneFinal::MeshSceneFinal(const std::string &meshFile,
                               const std::string &sceneFile,
                               const std::string &materialFile,
                               const std::string &dummyTextureFile) {
    pimpl = std::make_shared<Impl>(ZELO_PATH(meshFile),
                                   ZELO_PATH(sceneFile),
                                   ZELO_PATH(materialFile),
                                   ZELO_PATH(dummyTextureFile));
}

MeshSceneFinal::~MeshSceneFinal() = default;

void MeshSceneFinal::render() {
    pimpl->render();
}
}