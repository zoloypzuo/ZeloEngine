// MeshSceneSimple.cpp
// created on 2021/12/16
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "MeshSceneSimple.h"

#include "Core/Resource/ResourceManager.h"
#include "Core/Scene/SceneManager.h"

#include "Renderer/OpenGL/Drawable/MeshScene/Buffer/GLIndirectCommandBufferDSA.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Buffer/GLShaderStorageBufferDSA.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Buffer/GLUniformBufferDSA.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Buffer/GLVertexArrayDSA.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Material/Material.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Scene/SceneGraph.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Texture/GLTexture.h"
#include "Renderer/OpenGL/Drawable/MeshScene/VtxData/DrawData.h"
#include "Renderer/OpenGL/Drawable/MeshScene/VtxData/Mesh.h"
#include "Renderer/OpenGL/Drawable/MeshScene/VtxData/MeshData.h"

using namespace Zelo::Core::RHI;
using namespace Zelo::Core::Resource;

namespace Zelo::Renderer::OpenGL {

const static BufferLayout s_BufferLayout(
        {
                BufferElement(EBufferDataType::Float3, "position"),
                BufferElement(EBufferDataType::Float2, "texCoord"),
                BufferElement(EBufferDataType::Float3, "normal")
        });

const GLuint kBufferIndex_PerFrameUniforms = 0;
const GLuint kBufferIndex_ModelMatrices = 1;
const GLuint kBufferIndex_Materials = 2;

static uint64_t getTextureHandleBindless(uint64_t idx, const std::vector<GLTexture> &textures) {
    if (idx == INVALID_TEXTURE) return 0;

    return textures[idx].getHandleBindless();
}

namespace {
struct PerFrameData {
    mat4 view;
    mat4 proj;
    vec4 cameraPos;
};
const GLsizeiptr kUniformBufferSize = sizeof(PerFrameData);
}

struct MeshSceneSimple::Impl {
#pragma region static
    // mesh
    MeshData meshData_;
    // scene
    SceneGraph scene_;
    // material
    std::vector<MaterialDescription> materials_;
#pragma endregion static

#pragma region runtime
    // material
    std::vector<GLTexture> allMaterialTextures_;
    std::vector<DrawData> drawDataList;

    // buffer
    GLVertexArrayDSA vao;

    std::unique_ptr<GLShaderStorageBufferDSA> bufferMaterials_;
    std::unique_ptr<GLShaderStorageBufferDSA> bufferModelMatrices_;

    std::unique_ptr<GLIndirectCommandBufferCountDSA> bufferIndirect_;

    std::unique_ptr<GLUniformBufferDSA> perFrameDataBuffer{};
#pragma endregion runtime

    Impl(const std::string &sceneFile, const std::string &meshFile, const std::string &materialFile);

    ~Impl() = default;

    void render() const;

    int getDrawCount() const;
};

MeshSceneSimple::Impl::Impl(const std::string &sceneFile, const std::string &meshFile, const std::string &materialFile) {
    {
        // load mesh
        loadMeshData(meshFile.c_str(), meshData_);

        // load scene
        loadScene(sceneFile.c_str(), scene_);

        // construct draw data buffer
        auto &materialForNode = scene_.materialForNode_;
        for (const auto &c: scene_.meshes_) {
            if (auto material = materialForNode.find(c.first); material != materialForNode.end()) {
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

        // load material
        std::vector<std::string> textureFiles;
        loadMaterials(materialFile.c_str(), materials_, textureFiles);

        // construct material runtime
        for (const auto &tf: textureFiles) {
            allMaterialTextures_.emplace_back(GL_TEXTURE_2D, ZELO_PATH(tf).c_str());
        }

        for (auto &mtl: materials_) {
            mtl.ambientOcclusionMap_ = getTextureHandleBindless(mtl.ambientOcclusionMap_, allMaterialTextures_);
            mtl.emissiveMap_ = getTextureHandleBindless(mtl.emissiveMap_, allMaterialTextures_);
            mtl.albedoMap_ = getTextureHandleBindless(mtl.albedoMap_, allMaterialTextures_);
            mtl.metallicRoughnessMap_ = getTextureHandleBindless(mtl.metallicRoughnessMap_, allMaterialTextures_);
            mtl.normalMap_ = getTextureHandleBindless(mtl.normalMap_, allMaterialTextures_);
        }
    }

    // vao
    {
        auto bufferIndices_ = std::make_shared<GLIndexBufferDSA>(
                meshData_.indexDataSize(), meshData_.indexData_.data(), 0);
        auto bufferVertices_ = std::make_shared<GLVertexBufferDSA>(
                meshData_.vertexDataSize(), meshData_.vertexData_.data(), 0);

        bufferVertices_->setLayout(s_BufferLayout);
        vao.addVertexBuffer(bufferVertices_);
        vao.setIndexBuffer(bufferIndices_);
    }

    // bufferIndirect_
    {
        bufferIndirect_ = std::make_unique<GLIndirectCommandBufferCountDSA>(drawDataList.size());
        // prepare indirect commands buffer
        auto *cmd = bufferIndirect_->getCommandQueue();
        for (size_t i = 0; i != drawDataList.size(); i++) {
            const uint32_t meshIdx = drawDataList[i].meshIndex;
            const uint32_t lod = drawDataList[i].LOD;
            *cmd++ = {
                    meshData_.meshes_[meshIdx].getLODIndicesCount(lod),
                    1,
                    drawDataList[i].indexOffset,
                    drawDataList[i].vertexOffset,
                    drawDataList[i].materialIndex
            };
        }

        bufferIndirect_->sendBlocks();
    }

    // bufferMaterials_
    {
        bufferMaterials_ = std::make_unique<GLShaderStorageBufferDSA>(
                uint32_t(materials_.size() * sizeof(MaterialDescription)),
                materials_.data(), 0
        );
    }

    // bufferModelMatrices_
    {
        bufferModelMatrices_ = std::make_unique<GLShaderStorageBufferDSA>(
                uint32_t(drawDataList.size() * sizeof(glm::mat4)), nullptr, GL_DYNAMIC_STORAGE_BIT);
        std::vector<glm::mat4> matrices(drawDataList.size());
        size_t i = 0;
        for (const auto &c: drawDataList) {
            matrices[i++] = scene_.globalTransform_[c.transformIndex];
        }

        bufferModelMatrices_->sendBlocks(matrices);
    }

    // perFrameDataBuffer
    {
        perFrameDataBuffer = std::make_unique<GLUniformBufferDSA>(
                kBufferIndex_PerFrameUniforms, uint32_t(sizeof(PerFrameData)));
    }
}

int MeshSceneSimple::Impl::getDrawCount() const { return drawDataList.size(); }

void MeshSceneSimple::Impl::render() const {
    // perFrameDataBuffer
    {
        auto *camera = Zelo::Core::Scene::SceneManager::getSingletonPtr()->getActiveCamera();
        if (!camera) { return; }
        const mat4 p = camera->getProjectionMatrix();
        const mat4 view = camera->getViewMatrix();
        const vec3 viewPos = camera->getOwner()->getPosition();

        const PerFrameData perFrameData = {view, p, glm::vec4(viewPos, 1.0f)};
        perFrameDataBuffer->sendBlocks(perFrameData);
    }

    // draw call
    vao.bind();
    bufferMaterials_->bind(kBufferIndex_Materials);
    bufferModelMatrices_->bind(kBufferIndex_ModelMatrices);
    bufferIndirect_->bind();
    const void *startOffset = (const void *) sizeof(GLsizei); // NOLINT(performance-no-int-to-ptr)
    glMultiDrawElementsIndirectCount(GL_TRIANGLES, GL_UNSIGNED_INT, startOffset, 0, getDrawCount(), 0);
}

MeshSceneSimple::MeshSceneSimple(const std::string &sceneFile, const std::string &meshFile, const std::string &materialFile) {
    pimpl = std::make_shared<Impl>(
            ZELO_PATH(sceneFile), ZELO_PATH(meshFile), ZELO_PATH(materialFile));
}

MeshSceneSimple::~MeshSceneSimple() = default;

void MeshSceneSimple::render() {
    pimpl->render();
}
}