// MeshScene.cpp.cc
// created on 2021/12/16
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "MeshScene.h"

#include "Core/RHI/Buffer/Vertex.h"
#include "Core/Resource/ResourceManager.h"

#include "Renderer/OpenGL/Buffer/GLBuffer.h"  // GLBufferImmutable
#include "Renderer/OpenGL/Buffer/GLVertexArray.h"
#include "Renderer/OpenGL/Buffer/GLShaderStorageBuffer.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Material/Material.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Scene/Scene.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Texture/GLTexture.h"
#include "Renderer/OpenGL/Drawable/MeshScene/VtxData/DrawData.h"
#include "Renderer/OpenGL/Drawable/MeshScene/VtxData/Mesh.h"
#include "Renderer/OpenGL/Drawable/MeshScene/VtxData/MeshData.h"

using namespace Zelo::Core::RHI;
using namespace Zelo::Renderer::OpenGL;

struct DrawElementsIndirectCommand {
    GLuint count_;
    GLuint instanceCount_;
    GLuint firstIndex_;
    GLuint baseVertex_;
    GLuint baseInstance_;
};

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

struct MeshScene::Impl {
    GLsizei m_count{};
    GLVertexArray m_vao{};

    std::unique_ptr<GLIndirectCommandBuffer> bufferIndirect_;

    GLShaderStorageBuffer bufferMaterials_;  // Matrices
    GLShaderStorageBuffer bufferModelMatrices_;  // Materials

    std::vector<GLTexture> allMaterialTextures_;

    MeshFileHeader header_;
    MeshData meshData_;

    Scene scene_;
    std::vector<MaterialDescription> materials_;
    std::vector<DrawData> shapes_;

    explicit Impl() :
            bufferMaterials_(Core::RHI::EAccessSpecifier::STREAM_DRAW),
            bufferModelMatrices_(Core::RHI::EAccessSpecifier::STREAM_DRAW) {

        {
            const char *meshFile;
            const char *sceneFile;
            const char *materialFile;
            auto p = ZELO_PATH("data/meshes/test.meshes");
            meshFile = p.c_str();
            auto q = ZELO_PATH("data/meshes/test.scene");
            sceneFile = q.c_str();
            auto r = ZELO_PATH("data/meshes/test.materials");
            materialFile = r.c_str();
            header_ = loadMeshData(meshFile, meshData_);
            ::loadScene(sceneFile, scene_);

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
            loadMaterials(materialFile, materials_, textureFiles);

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

        m_count = shapes_.size();

        {
            auto bufferVertices_ = std::make_shared<GLVertexBufferImmutable>(
                    header_.vertexDataSize, meshData_.vertexData_.data(), 0);
            auto bufferIndices_ = std::make_shared<GLIndexBufferImmutable>(
                    header_.indexDataSize, meshData_.indexData_.data(), 0);
            bufferVertices_->setLayout(s_BufferLayout);
            m_vao.addVertexBuffer(bufferVertices_);
            m_vao.setIndexBuffer(bufferIndices_);
        }

        {
            bufferIndirect_ = std::make_unique<GLIndirectCommandBuffer>(
                    sizeof(DrawElementsIndirectCommand) * shapes_.size() + sizeof(GLsizei),
                    nullptr, GL_DYNAMIC_STORAGE_BIT, m_count);
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
            bufferMaterials_.sendBlocks<MaterialDescription>(materials_);
        }

        {
            std::vector<glm::mat4> matrices(shapes_.size());
            size_t i = 0;
            for (const auto &c: shapes_) {
                matrices[i] = scene_.globalTransform_[c.transformIndex];
                i++;
            }
            bufferModelMatrices_.sendBlocks<glm::mat4>(matrices);
        }
    }

    ~Impl() = default;

    void render() {
        m_vao.bind();
        bufferMaterials_.bind(kBufferIndex_Materials);
        bufferModelMatrices_.bind(kBufferIndex_ModelMatrices);
        bufferIndirect_->bind();
        const void *pStart = (const void *) sizeof(GLsizei); // NOLINT(performance-no-int-to-ptr)
        glMultiDrawElementsIndirectCount(GL_TRIANGLES, GL_UNSIGNED_INT, pStart, 0, m_count, 0);
    }
};

MeshScene::MeshScene() {
    pimpl = std::make_shared<Impl>();
}

MeshScene::~MeshScene() = default;

void MeshScene::render() const {
    pimpl->render();
}
