// GRCookbookPlugins.cpp
// created on 2021/11/30
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GRCookbookPlugins.h"

#include "Core/Input/Input.h"
#include "Core/Scene/SceneManager.h"
#include "Core/Resource/ResourceManager.h"

// assimp
#include <assimp/scene.h>
#include <assimp/postprocess.h>
#include <assimp/cimport.h>

using namespace glm;

#define RES_PREFIX "deps/src/glTF-Sample-Models/2.0/DamagedHelmet/glTF/"

struct PerFrameData {
    mat4 view;
    mat4 proj;
    vec4 cameraPos;
};

static std::string ZELO_PATH(const std::string &fileName) {
    auto *resourcem = Zelo::Core::Resource::ResourceManager::getSingletonPtr();
    return resourcem->resolvePath(fileName).string();
}

const std::string &Ch5MeshRendererPlugin::getName() const {
    static std::string s = "Ch5MeshRendererPlugin";
    return s;
}

void Ch5MeshRendererPlugin::install() {

}

void Ch5MeshRendererPlugin::uninstall() {

}

const GLsizeiptr kUniformBufferSize = sizeof(PerFrameData);

void Ch5MeshRendererPlugin::initialize() {
    Zelo::Core::Scene::SceneManager::getSingletonPtr()->clear();
    Zelo::Core::RHI::RenderSystem::getSingletonPtr()->resetRenderPipeline();

    // load avatar
    Zelo::Core::LuaScript::LuaScriptManager::getSingletonPtr()->luaCall("LoadAvatar");

    // shader
    m_meshShader = std::make_unique<GLSLShaderProgram>("mesh_inst.glsl");
    m_meshShader->link();

    // UBO
    perFrameDataBuffer = std::make_unique<GLBuffer>(kUniformBufferSize, nullptr, GL_DYNAMIC_STORAGE_BIT);
    glBindBufferRange(GL_UNIFORM_BUFFER, 0, perFrameDataBuffer->getHandle(), 0, kUniformBufferSize);

    // mesh
    MeshData meshData;
    header = loadMeshData(ZELO_PATH("data/meshes/test.meshes").c_str(), meshData);

    mesh = std::make_unique<GLMesh1>(header, meshData.meshes_.data(), meshData.indexData_.data(),
                                     meshData.vertexData_.data());

    // bind entity
    auto *scenem = Zelo::Core::Scene::SceneManager::getSingletonPtr();
    entity = scenem->CreateEntity();

    // init render
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_DEPTH_TEST);
}

void Ch5MeshRendererPlugin::update() {
    Plugin::update();
}

void Ch5MeshRendererPlugin::render() {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    const mat4 m = entity->getWorldMatrix();
    modelMatrices = std::make_unique<GLBuffer>(sizeof(mat4), value_ptr(m), GL_DYNAMIC_STORAGE_BIT);
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 2, modelMatrices->getHandle());

    auto *camera = Zelo::Core::Scene::SceneManager::getSingletonPtr()->getActiveCamera();
    if (!camera) { return; }
    const mat4 p = camera->getProjectionMatrix();
    const mat4 view = camera->getViewMatrix();
    const vec3 viewPos = camera->getOwner()->getPosition();

    const PerFrameData perFrameData = {view, p, glm::vec4(viewPos, 1.0f)};
    glNamedBufferSubData(perFrameDataBuffer->getHandle(), 0, kUniformBufferSize, &perFrameData);

    glEnable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
    m_meshShader->bind();
    mesh->draw(header);
}

const std::string &Ch6PBRPlugin::getName() const {
    static std::string s = "Ch6PBRPlugin";
    return s;
}

void Ch6PBRPlugin::install() {

}

void Ch6PBRPlugin::uninstall() {

}

void Ch6PBRPlugin::initialize() {
    Zelo::Core::Scene::SceneManager::getSingletonPtr()->clear();
    Zelo::Core::RHI::RenderSystem::getSingletonPtr()->resetRenderPipeline();

    // load avatar
    Zelo::Core::LuaScript::LuaScriptManager::getSingletonPtr()->luaCall("LoadAvatar");

    // shader
    m_meshShader = std::make_unique<GLSLShaderProgram>("pbr.glsl");
    m_meshShader->link();

    // UBO
    perFrameDataBuffer = std::make_unique<GLBuffer>(kUniformBufferSize, nullptr, GL_DYNAMIC_STORAGE_BIT);
    glBindBufferRange(GL_UNIFORM_BUFFER, 0, perFrameDataBuffer->getHandle(), 0, kUniformBufferSize);

    // mesh
    loadMesh(ZELO_PATH(RES_PREFIX "DamagedHelmet.gltf"));

    // tex
    loadTex();

    // bind entity
    auto *scenem = Zelo::Core::Scene::SceneManager::getSingletonPtr();
    entity = scenem->CreateEntity();

    // set transform
    entity->getTransform().setScale(vec3(3.0f));
    entity->getTransform().setRotation(vec3(1.0f, 0.0f, 0.0f), glm::radians(90.0f));

    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_DEPTH_TEST);
}


void Ch6PBRPlugin::loadMesh(const std::string &meshPath) {
    const aiScene *scene = aiImportFile(meshPath.c_str(), aiProcess_Triangulate);

    ZELO_ASSERT(scene && scene->HasMeshes());

    struct VertexData {
        vec3 pos;
        vec3 n;
        vec2 tc;
    };

    std::vector<VertexData> vertices;
    std::vector<uint32_t> indices;
    {
        const aiMesh *pAiMesh = scene->mMeshes[0];
        for (unsigned i = 0; i != pAiMesh->mNumVertices; i++) {
            const aiVector3D v = pAiMesh->mVertices[i];
            const aiVector3D n = pAiMesh->mNormals[i];
            const aiVector3D t = pAiMesh->mTextureCoords[0][i];
            vertices.push_back({vec3(v.x, v.y, v.z), vec3(n.x, n.y, n.z), vec2(t.x, 1.0f - t.y)});
        }
        for (unsigned i = 0; i != pAiMesh->mNumFaces; i++) {
            for (unsigned j = 0; j != 3; j++)
                indices.push_back(pAiMesh->mFaces[i].mIndices[j]);
        }
        aiReleaseImport(scene);
    }

    const size_t kSizeIndices = sizeof(uint32_t) * indices.size();
    const size_t kSizeVertices = sizeof(VertexData) * vertices.size();

    mesh = std::make_unique<GLMeshPVP>(indices.data(), (uint32_t) kSizeIndices,
                                       (float *) vertices.data(), (uint32_t) kSizeVertices);
}

void Ch6PBRPlugin::update() {
    Plugin::update();
}

void Ch6PBRPlugin::render() {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    const mat4 m = entity->getWorldMatrix();
    modelMatrices = std::make_unique<GLBuffer>(sizeof(mat4), value_ptr(m), GL_DYNAMIC_STORAGE_BIT);
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 2, modelMatrices->getHandle());

    auto *camera = Zelo::Core::Scene::SceneManager::getSingletonPtr()->getActiveCamera();
    if (!camera) { return; }
    const mat4 p = camera->getProjectionMatrix();
    const mat4 view = camera->getViewMatrix();
    const vec3 viewPos = camera->getOwner()->getPosition();

    const PerFrameData perFrameData = {view, p, glm::vec4(viewPos, 1.0f)};
    glNamedBufferSubData(perFrameDataBuffer->getHandle(), 0, kUniformBufferSize, &perFrameData);

    glEnable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
    m_meshShader->bind();
    mesh->draw();
}

void Ch6PBRPlugin::loadTex() {
    texAO = std::make_unique<GLTexture>(GL_TEXTURE_2D, ZELO_PATH(RES_PREFIX "Default_AO.jpg").c_str());
    texEmissive = std::make_unique<GLTexture>(GL_TEXTURE_2D, ZELO_PATH(RES_PREFIX "Default_emissive.jpg").c_str());
    texAlbedo = std::make_unique<GLTexture>(GL_TEXTURE_2D, ZELO_PATH(RES_PREFIX "Default_albedo.jpg").c_str());
    texMeR = std::make_unique<GLTexture>(GL_TEXTURE_2D, ZELO_PATH(RES_PREFIX "Default_metalRoughness.jpg").c_str());
    texNormal = std::make_unique<GLTexture>(GL_TEXTURE_2D, ZELO_PATH(RES_PREFIX "Default_normal.jpg").c_str());

    const GLuint textures[] = {texAO->getHandle(),
                               texEmissive->getHandle(),
                               texAlbedo->getHandle(),
                               texMeR->getHandle(),
                               texNormal->getHandle()};
    glBindTextures(0, sizeof(textures) / sizeof(GLuint), textures);

    // cube map
    envMap = std::make_unique<GLTexture>(GL_TEXTURE_CUBE_MAP, ZELO_PATH("data/piazza_bologni_1k.hdr").c_str());
    envMapIrradiance = std::make_unique<GLTexture>(GL_TEXTURE_CUBE_MAP,
                                                   ZELO_PATH("data/piazza_bologni_1k_irradiance.hdr").c_str());
    const GLuint envMaps[] = {envMap->getHandle(), envMapIrradiance->getHandle()};
    glBindTextures(5, 2, envMaps);

    // BRDF LUT
    brdfLUT = std::make_unique<GLTexture>(GL_TEXTURE_2D, ZELO_PATH("data/brdfLUT.ktx").c_str());
    glBindTextureUnit(7, brdfLUT->getHandle());
}

const std::string &Ch7LargeScenePlugin::getName() const {
    static std::string s = "Ch7LargeScenePlugin";
    return s;
}

void Ch7LargeScenePlugin::install() {

}

void Ch7LargeScenePlugin::uninstall() {

}

void Ch7LargeScenePlugin::initialize() {
    Zelo::Core::Scene::SceneManager::getSingletonPtr()->clear();
    Zelo::Core::RHI::RenderSystem::getSingletonPtr()->resetRenderPipeline();

    // load avatar
    Zelo::Core::LuaScript::LuaScriptManager::getSingletonPtr()->luaCall("LoadAvatar");

    // shader
    m_meshShader = std::make_unique<GLSLShaderProgram>("mesh.glsl");
    m_meshShader->link();

    // UBO
    perFrameDataBuffer = std::make_unique<GLBuffer>(kUniformBufferSize, nullptr, GL_DYNAMIC_STORAGE_BIT);
    glBindBufferRange(GL_UNIFORM_BUFFER, 0, perFrameDataBuffer->getHandle(), 0, kUniformBufferSize);

    // mesh
    sceneData1 = std::make_unique<GLSceneData>(ZELO_PATH("data/meshes/test.meshes").c_str(),
                                               ZELO_PATH("data/meshes/test.scene").c_str(),
                                               ZELO_PATH("data/meshes/test.materials").c_str());
    sceneData2 = std::make_unique<GLSceneData>(ZELO_PATH("data/meshes/test2.meshes").c_str(),
                                               ZELO_PATH("data/meshes/test2.scene").c_str(),
                                               ZELO_PATH("data/meshes/test2.materials").c_str());

    mesh1 = std::make_unique<GLMesh2>(*sceneData1);
    mesh2 = std::make_unique<GLMesh2>(*sceneData2);

    // bind entity
    auto *scenem = Zelo::Core::Scene::SceneManager::getSingletonPtr();
    entity = scenem->CreateEntity();
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);

    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_DEPTH_TEST);
}

void Ch7LargeScenePlugin::update() {
    Plugin::update();
}

void Ch7LargeScenePlugin::render() {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    const mat4 m = entity->getWorldMatrix();
    modelMatrices = std::make_unique<GLBuffer>(sizeof(mat4), value_ptr(m), GL_DYNAMIC_STORAGE_BIT);
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 2, modelMatrices->getHandle());

    auto *camera = Zelo::Core::Scene::SceneManager::getSingletonPtr()->getActiveCamera();
    if (!camera) { return; }
    const mat4 p = camera->getProjectionMatrix();
    const mat4 view = camera->getViewMatrix();
    const vec3 viewPos = camera->getOwner()->getPosition();

    const PerFrameData perFrameData = {view, p, glm::vec4(viewPos, 1.0f)};
    glNamedBufferSubData(perFrameDataBuffer->getHandle(), 0, kUniformBufferSize, &perFrameData);

    glEnable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
    m_meshShader->bind();
    mesh1->draw();
    mesh2->draw();
}

namespace FinalScene {
struct PerFrameData {
    mat4 view;
    mat4 proj;
    mat4 light;
    vec4 cameraPos;
    vec4 frustumPlanes[6];
    vec4 frustumCorners[8];
    uint32_t numShapesToCull;
};

const GLuint kBufferIndex_BoundingBoxes = kBufferIndex_PerFrameUniforms + 1;
const GLuint kBufferIndex_DrawCommands = kBufferIndex_PerFrameUniforms + 2;
const GLuint kBufferIndex_NumVisibleMeshes = kBufferIndex_PerFrameUniforms + 3;

const GLuint kMaxNumObjects = 128 * 1024;
const GLsizeiptr kUniformBufferSize = sizeof(PerFrameData);
const GLsizeiptr kBoundingBoxesBufferSize = sizeof(BoundingBox) * kMaxNumObjects;

struct Ch10FinalPlugin::Impl {
    struct TransparentFragment {
        float R, G, B, A;
        float Depth;
        uint32_t Next;
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

    const uint32_t kMaxOITFragments = 16 * 1024 * 1024;
    const GLuint kBufferIndex_TransparencyLists = kBufferIndex_Materials + 1;

    explicit Impl(Ch10FinalPlugin &parent);

    ~Impl() = default;

    Ch10FinalPlugin &m_parent;

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

    int width = 1280;
    int height = 720;
    GLSkyboxRenderer skybox;
    GLSceneDataLazy sceneData;
    GLMesh9<GLSceneDataLazy> mesh;
    GLTexture rotationPattern;
    GLIndirectBuffer meshesOpaque;
    GLIndirectBuffer meshesTransparent;
    GLFramebuffer opaqueFramebuffer;
    GLFramebuffer framebuffer;
    GLFramebuffer luminance;
    GLFramebuffer brightPass;
    GLFramebuffer bloom1;
    GLFramebuffer bloom2;
    GLFramebuffer ssao;
    GLFramebuffer blur;
    GLFramebuffer shadowMap;

    GLBuffer oitAtomicCounter;
    GLBuffer oitTransparencyLists;
    GLTexture oitHeads;

    BoundingBox bigBox{};
    std::vector<GLTexture *> luminances;  // [2]

    GLBuffer perFrameDataBuffer;
    GLBuffer boundingBoxesBuffer;
    GLBuffer numVisibleMeshesBuffer;

    GLuint luminance1x1;
    GLTexture luminance1;
    GLTexture luminance2;

    GLsync fenceCulling = nullptr;
    volatile uint32_t *numVisibleMeshesPtr;

    bool g_EnableGPUCulling = true;
    bool g_FreezeCullingView = false;
    bool g_DrawOpaque = true;
    bool g_DrawTransparent = true;
    bool g_DrawGrid = true;
    bool g_EnableSSAO = true;
    bool g_EnableBlur = true;
    bool g_EnableHDR = true;
    bool g_DrawBoxes = false;
    bool g_EnableShadows = true;
    bool g_ShowLightFrustum = false;
    float g_LightTheta = 0.0f;
    float g_LightPhi = 0.0f;

    void clearTransparencyBuffers() const;

    void render();
};

Ch10FinalPlugin::Impl::Impl(Ch10FinalPlugin &parent) :
        m_parent(parent),
        sceneData(
                ZELO_PATH("data/meshes/bistro_all.meshes").c_str(),
                ZELO_PATH("data/meshes/bistro_all.scene").c_str(),
                ZELO_PATH("data/meshes/bistro_all.materials").c_str(),
                ZELO_PATH("data/const1.bmp").c_str()),
        mesh(sceneData),
        rotationPattern(GL_TEXTURE_2D, ZELO_PATH("data/rot_texture.bmp").c_str()),
        meshesOpaque(sceneData.shapes_.size()),
        meshesTransparent(sceneData.shapes_.size()),
        opaqueFramebuffer(width, height, GL_RGBA16F, GL_DEPTH_COMPONENT24),
        framebuffer(width, height, GL_RGBA16F, GL_DEPTH_COMPONENT24),
        luminance(64, 64, GL_RGBA16F, 0),
        brightPass(256, 256, GL_RGBA16F, 0),
        bloom1(256, 256, GL_RGBA16F, 0),
        bloom2(256, 256, GL_RGBA16F, 0),
        ssao(1024, 1024, GL_RGBA8, 0),
        blur(1024, 1024, GL_RGBA8, 0),
        shadowMap(8192, 8192, GL_R8, GL_DEPTH_COMPONENT24),
        oitAtomicCounter(sizeof(uint32_t), nullptr, GL_DYNAMIC_STORAGE_BIT),
        oitTransparencyLists(sizeof(TransparentFragment) * kMaxOITFragments, nullptr, GL_DYNAMIC_STORAGE_BIT),
        oitHeads(GL_TEXTURE_2D, width, height, GL_R32UI),

        skybox(ZELO_PATH("data/immenstadter_horn_2k.hdr").c_str(),
               ZELO_PATH("data/immenstadter_horn_2k_irradiance.hdr").c_str(),
               ZELO_PATH("data/brdfLUT.ktx").c_str()),

        perFrameDataBuffer(kUniformBufferSize, nullptr, GL_DYNAMIC_STORAGE_BIT),
        boundingBoxesBuffer(kBoundingBoxesBufferSize, nullptr, GL_DYNAMIC_STORAGE_BIT),
        numVisibleMeshesBuffer(sizeof(uint32_t), nullptr,
                               GL_MAP_READ_BIT | GL_MAP_WRITE_BIT | GL_MAP_PERSISTENT_BIT | GL_MAP_COHERENT_BIT),
        // ping-pong textures for light adaptation
        luminance1(GL_TEXTURE_2D, 1, 1, GL_RGBA16F),
        luminance2(GL_TEXTURE_2D, 1, 1, GL_RGBA16F) {

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


    glBindBufferRange(GL_UNIFORM_BUFFER, kBufferIndex_PerFrameUniforms, perFrameDataBuffer.getHandle(), 0,
                      kUniformBufferSize);

    numVisibleMeshesPtr = (uint32_t *) glMapNamedBuffer(numVisibleMeshesBuffer.getHandle(), GL_READ_WRITE);
    assert(numVisibleMeshesPtr);

//    ImGuiGLRenderer rendererUI;
//    CanvasGL canvas;

    auto isTransparent = [this](const DrawElementsIndirectCommand &c) {
        const auto mtlIndex = c.baseInstance_ & 0xffff;
        const auto &mtl = this->sceneData.materials_[mtlIndex];
        return (mtl.flags_ & sMaterialFlags_Transparent) > 0;
    };

    mesh.bufferIndirect_.selectTo(meshesOpaque, [&isTransparent](const DrawElementsIndirectCommand &c) -> bool {
        return !isTransparent(c);
    });
    mesh.bufferIndirect_.selectTo(meshesTransparent, [&isTransparent](const DrawElementsIndirectCommand &c) -> bool {
        return isTransparent(c);
    });

    // create a texture view into the last mip-level (1x1 pixel) of our luminance framebuffer

    glGenTextures(1, &luminance1x1);
    glTextureView(luminance1x1, GL_TEXTURE_2D, luminance.getTextureColor().getHandle(), GL_RGBA16F, 6, 1, 0, 1);

    luminances = {&luminance1, &luminance2};
    const vec4 brightPixel(vec3(50.0f), 1.0f);
    glTextureSubImage2D(luminance1.getHandle(), 0, 0, 0, 1, 1, GL_RGBA, GL_FLOAT, glm::value_ptr(brightPixel));


    glBindImageTexture(0, oitHeads.getHandle(), 0, GL_FALSE, 0, GL_READ_WRITE, GL_R32UI);
    glBindBufferBase(GL_ATOMIC_COUNTER_BUFFER, 0, oitAtomicCounter.getHandle());

    std::vector<BoundingBox> reorderedBoxes;
    reorderedBoxes.reserve(sceneData.shapes_.size());

    // pretransform bounding boxes to world space
    for (const auto &c: sceneData.shapes_) {
        const mat4 model = sceneData.scene_.globalTransform_[c.transformIndex];
        reorderedBoxes.push_back(sceneData.meshData_.boxes_[c.meshIndex]);
        reorderedBoxes.back().transform(model);
    }
    glNamedBufferSubData(boundingBoxesBuffer.getHandle(), 0, reorderedBoxes.size() * sizeof(BoundingBox),
                         reorderedBoxes.data());

    bigBox = reorderedBoxes.front();
    for (const auto &b: reorderedBoxes) {
        bigBox.combinePoint(b.min_);
        bigBox.combinePoint(b.max_);
    }

    const GLint swizzleMask[] = {GL_RED, GL_RED, GL_RED, GL_ONE};
    glTextureParameteriv(shadowMap.getTextureColor().getHandle(), GL_TEXTURE_SWIZZLE_RGBA, swizzleMask);
    glTextureParameteriv(shadowMap.getTextureDepth().getHandle(), GL_TEXTURE_SWIZZLE_RGBA, swizzleMask);

}

void Ch10FinalPlugin::Impl::clearTransparencyBuffers() const {
    const uint32_t minusOne = 0xFFFFFFFF;
    const uint32_t zero = 0;
    glClearTexImage(oitHeads.getHandle(), 0, GL_RED_INTEGER, GL_UNSIGNED_INT, &minusOne);
    glNamedBufferSubData(oitAtomicCounter.getHandle(), 0, sizeof(uint32_t), &zero);
}

void Ch10FinalPlugin::Impl::render() {
    if (sceneData.uploadLoadedTextures()) {
        mesh.updateMaterialsBuffer(sceneData);
    }

    GLuint opaqueFboHandle = opaqueFramebuffer.getHandle();
    glClearNamedFramebufferfv(opaqueFboHandle, GL_COLOR, 0, glm::value_ptr(vec4(0.0f, 0.0f, 0.0f, 1.0f)));
    glClearNamedFramebufferfi(opaqueFboHandle, GL_DEPTH_STENCIL, 0, 1.0f, 0);


    auto *camera = Zelo::Core::Scene::SceneManager::getSingletonPtr()->getActiveCamera();
    if (!camera) { return; }
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
        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, kBufferIndex_BoundingBoxes, boundingBoxesBuffer.getHandle());
        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, kBufferIndex_NumVisibleMeshes, numVisibleMeshesBuffer.getHandle());

        perFrameData.numShapesToCull = g_EnableGPUCulling ? (uint32_t) meshesOpaque.drawCommands_.size() : 0u;
        glNamedBufferSubData(perFrameDataBuffer.getHandle(), 0, kUniformBufferSize, &perFrameData);
        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, kBufferIndex_DrawCommands, meshesOpaque.getHandle());
        glDispatchCompute(1 + (GLuint) meshesOpaque.drawCommands_.size() / 64, 1, 1);

        perFrameData.numShapesToCull = g_EnableGPUCulling ? (uint32_t) meshesTransparent.drawCommands_.size() : 0u;
        glNamedBufferSubData(perFrameDataBuffer.getHandle(), 0, kUniformBufferSize, &perFrameData);
        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, kBufferIndex_DrawCommands, meshesTransparent.getHandle());
        glDispatchCompute(1 + (GLuint) meshesTransparent.drawCommands_.size() / 64, 1, 1);

        glMemoryBarrier(GL_COMMAND_BARRIER_BIT | GL_SHADER_STORAGE_BARRIER_BIT | GL_CLIENT_MAPPED_BUFFER_BARRIER_BIT);
        fenceCulling = glFenceSync(GL_SYNC_GPU_COMMANDS_COMPLETE, 0);
    }

    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, kBufferIndex_TransparencyLists, oitTransparencyLists.getHandle());

    // 1. Render shadow map
    if (g_EnableShadows) {
        glDisable(GL_BLEND);
        glEnable(GL_DEPTH_TEST);
        // Calculate light parameters
        const PerFrameData perFrameDataShadows = {lightView, lightProj};
        glNamedBufferSubData(perFrameDataBuffer.getHandle(), 0, kUniformBufferSize, &perFrameDataShadows);
        glClearNamedFramebufferfv(shadowMap.getHandle(), GL_COLOR, 0, glm::value_ptr(vec4(0.0f, 0.0f, 0.0f, 1.0f)));
        glClearNamedFramebufferfi(shadowMap.getHandle(), GL_DEPTH_STENCIL, 0, 1.0f, 0);
        shadowMap.bind();
        progShadowMap->bind();
        mesh.draw(mesh.bufferIndirect_.drawCommands_.size());
        shadowMap.unbind();
        perFrameData.light = lightProj * lightView;
        glBindTextureUnit(4, shadowMap.getTextureDepth().getHandle());
    } else {
        // disable shadows
        perFrameData.light = mat4(0.0f);
    }
    glNamedBufferSubData(perFrameDataBuffer.getHandle(), 0, kUniformBufferSize, &perFrameData);

    // 1. Render scene
    opaqueFramebuffer.bind();
    glDisable(GL_BLEND);
    glEnable(GL_DEPTH_TEST);
    // 1.0 Cube map
    skybox.draw();
    // 1.1 Bistro
    if (g_DrawOpaque) {
        program->bind();
        mesh.draw(meshesOpaque.drawCommands_.size(), &meshesOpaque);
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
        mesh.draw(meshesTransparent.drawCommands_.size(), &meshesTransparent);
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
        glNamedBufferSubData(perFrameDataBuffer.getHandle(), 0, sizeof(g_SSAOParams), &g_SSAOParams);
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
        glNamedBufferSubData(perFrameDataBuffer.getHandle(), 0, sizeof(g_HDRParams), &g_HDRParams);
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
}


const std::string &Ch10FinalPlugin::getName() const {
    static std::string s = "Ch10FinalPlugin";
    return s;
}

void Ch10FinalPlugin::install() {

}

void Ch10FinalPlugin::uninstall() {

}

void Ch10FinalPlugin::initialize() {
    Zelo::Core::Scene::SceneManager::getSingletonPtr()->clear();
    Zelo::Core::RHI::RenderSystem::getSingletonPtr()->resetRenderPipeline();

    // load avatar
    Zelo::Core::LuaScript::LuaScriptManager::getSingletonPtr()->luaCall("LoadAvatar");

    pimpl = std::make_shared<Impl>(*this);

    // bind entity
    auto *scenem = Zelo::Core::Scene::SceneManager::getSingletonPtr();
    entity = scenem->CreateEntity();

    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_DEPTH_TEST);
}

void Ch10FinalPlugin::update() {
    Plugin::update();
}

void Ch10FinalPlugin::render() {
    pimpl->render();
}
}