// MeshScene.cpp.cc
// created on 2021/12/16
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "MeshScene.h"

#include "Core/Resource/ResourceManager.h"
#include "Core/Scene/SceneManager.h"

#include "Renderer/OpenGL/Buffer/GLVertexArray.h"
#include "Renderer/OpenGL/Buffer/GLShaderStorageBufferDSA.h"
#include "Renderer/OpenGL/Buffer/GLUniformBuffer.h"
#include "Renderer/OpenGL/Buffer/GLVertexArrayDSA.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Material/Material.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Scene/Scene.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Texture/GLTexture.h"
#include "Renderer/OpenGL/Drawable/MeshScene/VtxData/DrawData.h"
#include "Renderer/OpenGL/Drawable/MeshScene/VtxData/Mesh.h"
#include "Renderer/OpenGL/Drawable/MeshScene/VtxData/MeshData.h"

using namespace Zelo::Core::RHI;

namespace Zelo::Renderer::OpenGL {

const static BufferLayout s_BufferLayout(
        {
                BufferElement(EBufferDataType::Float3, "position"),
                BufferElement(EBufferDataType::Float2, "texCoord"),
                BufferElement(EBufferDataType::Float3, "normal")
        });

const uint32_t kBufferIndex_ModelMatrices = 1;
const uint32_t kBufferIndex_Materials = 2;

static uint64_t getTextureHandleBindless(uint64_t idx, const std::vector<GLTexture> &textures) {
    if (idx == INVALID_TEXTURE) return 0;

    return textures[idx].getHandleBindless();
}

static std::string ZELO_PATH(const std::string &fileName) {
    auto *resourcem = Zelo::Core::Resource::ResourceManager::getSingletonPtr();
    return resourcem->resolvePath(fileName).string();
}

struct PerFrameData {
    mat4 view;
    mat4 proj;
    vec4 cameraPos;
};
const GLsizeiptr kUniformBufferSize = sizeof(PerFrameData);

struct MeshScene::Impl {
    // scene
    std::vector<GLTexture> allMaterialTextures_;

    MeshFileHeader header_{};
    MeshData meshData_;

    Scene scene_;
    std::vector<MaterialDescription> materials_;
    std::vector<DrawData> shapes_;

    // gl
    GLVertexArrayDSA m_vao;

    std::unique_ptr<GLShaderStorageBufferDSA> bufferMaterials_;
    std::unique_ptr<GLShaderStorageBufferDSA> bufferModelMatrices_;

    std::unique_ptr<GLIndirectCommandBuffer> bufferIndirect_;

    std::unique_ptr<GLUniformBuffer> perFrameDataBuffer{};

    Impl(const std::string &sceneFile, const std::string &meshFile, const std::string &materialFile);

    ~Impl() = default;

    void render() const;

    int getDrawCount() const;
};

MeshScene::Impl::Impl(const std::string &sceneFile, const std::string &meshFile, const std::string &materialFile) {
    {
        header_ = loadMeshData(meshFile.c_str(), meshData_);
        ::loadScene(sceneFile.c_str(), scene_);

        // prepare draw data buffer
        for (const auto &c: scene_.meshes_) {
            auto material = scene_.materialForNode_.find(c.first);
            if (material != scene_.materialForNode_.end()) {
                shapes_.push_back(
                        DrawData{
                                c.second,
                                material->second,
                                0,
                                meshData_.meshes_[c.second].indexOffset,
                                meshData_.meshes_[c.second].vertexOffset,
                                c.first
                        });
            }
        }

        // force recalculation of all global transformations
        markAsChanged(scene_, 0);
        recalculateGlobalTransforms(scene_);

        std::vector<std::string> textureFiles;
        loadMaterials(materialFile.c_str(), materials_, textureFiles);

        for (const auto &f: textureFiles) {
            allMaterialTextures_.emplace_back(GL_TEXTURE_2D, ZELO_PATH(f).c_str());
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
                header_.indexDataSize, meshData_.indexData_.data(), 0);
        auto bufferVertices_ = std::make_shared<GLVertexBufferDSA>(
                header_.vertexDataSize, meshData_.vertexData_.data(), 0);

        bufferVertices_->setLayout(s_BufferLayout);
        m_vao.addVertexBuffer(bufferVertices_);
        m_vao.setIndexBuffer(bufferIndices_);
    }

    // bufferIndirect_
    {
        bufferIndirect_ = std::make_unique<GLIndirectCommandBuffer>(
                sizeof(DrawElementsIndirectCommand) * shapes_.size() + sizeof(GLsizei),
                nullptr, GL_DYNAMIC_STORAGE_BIT, shapes_.size());
        // prepare indirect commands buffer
        auto *cmd = bufferIndirect_->getCommandQueue();
        for (size_t i = 0; i != shapes_.size(); i++) {
            const uint32_t meshIdx = shapes_[i].meshIndex;
            const uint32_t lod = shapes_[i].LOD;
            *cmd++ = {
                    meshData_.meshes_[meshIdx].getLODIndicesCount(lod),
                    1,
                    shapes_[i].indexOffset,
                    shapes_[i].vertexOffset,
                    shapes_[i].materialIndex
            };
        }

        bufferIndirect_->sendBlocks();
    }

    // bufferMaterials_
    {
        bufferMaterials_ = std::make_unique<GLShaderStorageBufferDSA>(
                materials_.size() * sizeof(MaterialDescription),
                materials_.data(), 0
        );
    }

    // bufferModelMatrices_
    {
        bufferModelMatrices_ = std::make_unique<GLShaderStorageBufferDSA>(
                shapes_.size() * sizeof(glm::mat4), nullptr, GL_DYNAMIC_STORAGE_BIT);
        std::vector<glm::mat4> matrices(shapes_.size());
        size_t i = 0;
        for (const auto &c: shapes_) {
            matrices[i++] = scene_.globalTransform_[c.transformIndex];
        }

        bufferModelMatrices_->sendBlocks(matrices);
    }

    // perFrameDataBuffer
    {
        perFrameDataBuffer = std::make_unique<GLUniformBuffer>(
                sizeof(PerFrameData), 0, 0, Core::RHI::EAccessSpecifier::STREAM_DRAW);
    }
}

int MeshScene::Impl::getDrawCount() const { return shapes_.size(); }

void MeshScene::Impl::render() const {
    // perFrameDataBuffer
    {
        auto *camera = Zelo::Core::Scene::SceneManager::getSingletonPtr()->getActiveCamera();
        if (!camera) { return; }
        const mat4 p = camera->getProjectionMatrix();
        const mat4 view = camera->getViewMatrix();
        const vec3 viewPos = camera->getOwner()->getPosition();

        const PerFrameData perFrameData = {view, p, glm::vec4(viewPos, 1.0f)};
        size_t startOffset = 0;
        perFrameDataBuffer->setSubData(perFrameData, std::ref(startOffset));
    }

    // draw call
    m_vao.bind();
    bufferMaterials_->bind(kBufferIndex_Materials);
    bufferModelMatrices_->bind(kBufferIndex_ModelMatrices);
    bufferIndirect_->bind();
    const void *startOffset = (const void *) sizeof(GLsizei); // NOLINT(performance-no-int-to-ptr)
    glMultiDrawElementsIndirectCount(GL_TRIANGLES, GL_UNSIGNED_INT, startOffset, 0, getDrawCount(), 0);
}

MeshScene::MeshScene(const std::string &sceneFile, const std::string &meshFile, const std::string &materialFile) {
    pimpl = std::make_shared<Impl>(
            ZELO_PATH(sceneFile), ZELO_PATH(meshFile), ZELO_PATH(materialFile));
}

MeshScene::~MeshScene() = default;

void MeshScene::render() const {
    pimpl->render();
}

}