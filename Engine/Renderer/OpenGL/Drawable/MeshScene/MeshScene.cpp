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
#include "Core/Scene/SceneManager.h"

using namespace Zelo::Core::RHI;

namespace Zelo::Renderer::OpenGL {
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

class GLSceneData {
public:
    GLSceneData(
            const char *meshFile,
            const char *sceneFile,
            const char *materialFile);

    std::vector<GLTexture> allMaterialTextures_;

    MeshFileHeader header_;
    MeshData meshData_;

    Scene scene_;
    std::vector<MaterialDescription> materials_;
    std::vector<DrawData> shapes_;

    void loadScene(const char *sceneFile);
};


GLSceneData::GLSceneData(
        const char *meshFile,
        const char *sceneFile,
        const char *materialFile) {
    header_ = loadMeshData(meshFile, meshData_);
    loadScene(sceneFile);

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

void GLSceneData::loadScene(const char *sceneFile) {
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
}


GLSceneData *g_SceneData;


struct PerFrameData {
    mat4 view;
    mat4 proj;
    vec4 cameraPos;
};
const GLsizeiptr kUniformBufferSize = sizeof(PerFrameData);

std::unique_ptr<GLBufferImmutable> perFrameDataBuffer{};

struct MeshScene::Impl {
    GLuint vao_{};
    uint32_t numIndices_;

    GLBufferImmutable bufferIndices_;
    GLBufferImmutable bufferVertices_;
    GLBufferImmutable bufferMaterials_;

    GLBufferImmutable bufferIndirect_;

    GLBufferImmutable bufferModelMatrices_;

    explicit Impl() :
            numIndices_(g_SceneData->header_.indexDataSize / sizeof(uint32_t)),
            bufferIndices_(g_SceneData->header_.indexDataSize, g_SceneData->meshData_.indexData_.data(), 0),
            bufferVertices_(g_SceneData->header_.vertexDataSize, g_SceneData->meshData_.vertexData_.data(), 0),
            bufferMaterials_(sizeof(MaterialDescription) * g_SceneData->materials_.size(),
                             g_SceneData->materials_.data(), 0),
            bufferIndirect_(sizeof(DrawElementsIndirectCommand) * g_SceneData->shapes_.size() + sizeof(GLsizei),
                            nullptr, GL_DYNAMIC_STORAGE_BIT),
            bufferModelMatrices_(sizeof(glm::mat4) * g_SceneData->shapes_.size(), nullptr, GL_DYNAMIC_STORAGE_BIT) {

        glCreateVertexArrays(1, &vao_);
        glVertexArrayElementBuffer(vao_, bufferIndices_.getHandle());
        glVertexArrayVertexBuffer(vao_, 0, bufferVertices_.getHandle(), 0, sizeof(vec3) + sizeof(vec3) + sizeof(vec2));
        // position
        glEnableVertexArrayAttrib(vao_, 0);
        glVertexArrayAttribFormat(vao_, 0, 3, GL_FLOAT, GL_FALSE, 0);
        glVertexArrayAttribBinding(vao_, 0, 0);
        // uv
        glEnableVertexArrayAttrib(vao_, 1);
        glVertexArrayAttribFormat(vao_, 1, 2, GL_FLOAT, GL_FALSE, sizeof(vec3));
        glVertexArrayAttribBinding(vao_, 1, 0);
        // normal
        glEnableVertexArrayAttrib(vao_, 2);
        glVertexArrayAttribFormat(vao_, 2, 3, GL_FLOAT, GL_TRUE, sizeof(vec3) + sizeof(vec2));
        glVertexArrayAttribBinding(vao_, 2, 0);

        std::vector<uint8_t> drawCommands;

        drawCommands.resize(sizeof(DrawElementsIndirectCommand) * g_SceneData->shapes_.size() + sizeof(GLsizei));

        // store the number of draw commands in the very beginning of the buffer
        const GLsizei numCommands = (GLsizei) g_SceneData->shapes_.size();
        memcpy(drawCommands.data(), &numCommands, sizeof(numCommands));

        DrawElementsIndirectCommand *cmd = std::launder(
                reinterpret_cast<DrawElementsIndirectCommand *>(drawCommands.data() + sizeof(GLsizei))
        );

        // prepare indirect commands buffer
        for (size_t i = 0; i != g_SceneData->shapes_.size(); i++) {
            const uint32_t meshIdx = g_SceneData->shapes_[i].meshIndex;
            const uint32_t lod = g_SceneData->shapes_[i].LOD;
            *cmd++ = {
                    g_SceneData->meshData_.meshes_[meshIdx].getLODIndicesCount(lod),
                    1,
                    g_SceneData->shapes_[i].indexOffset,
                    g_SceneData->shapes_[i].vertexOffset,
                    g_SceneData->shapes_[i].materialIndex
            };
        }

        glNamedBufferSubData(bufferIndirect_.getHandle(), 0, drawCommands.size(), drawCommands.data());

        std::vector<glm::mat4> matrices(g_SceneData->shapes_.size());
        size_t i = 0;
        for (const auto &c: g_SceneData->shapes_)
            matrices[i++] = g_SceneData->scene_.globalTransform_[c.transformIndex];

        glNamedBufferSubData(bufferModelMatrices_.getHandle(), 0, matrices.size() * sizeof(mat4), matrices.data());
    }

    ~Impl() = default;

    void render() {
        auto *camera = Zelo::Core::Scene::SceneManager::getSingletonPtr()->getActiveCamera();
        if (!camera) { return; }
        const mat4 p = camera->getProjectionMatrix();
        const mat4 view = camera->getViewMatrix();
        const vec3 viewPos = camera->getOwner()->getPosition();

        const PerFrameData perFrameData = {view, p, glm::vec4(viewPos, 1.0f)};
        glNamedBufferSubData(perFrameDataBuffer->getHandle(), 0, kUniformBufferSize, &perFrameData);

//        glEnable(GL_DEPTH_TEST);
//        glDisable(GL_BLEND);

        glBindVertexArray(vao_);
        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, kBufferIndex_Materials, bufferMaterials_.getHandle());
        glBindBufferBase(GL_SHADER_STORAGE_BUFFER, kBufferIndex_ModelMatrices, bufferModelMatrices_.getHandle());
        glBindBuffer(GL_DRAW_INDIRECT_BUFFER, bufferIndirect_.getHandle());
        glBindBuffer(GL_PARAMETER_BUFFER, bufferIndirect_.getHandle());
        glMultiDrawElementsIndirectCount(GL_TRIANGLES, GL_UNSIGNED_INT, (const void *) sizeof(GLsizei), 0,
                                         (GLsizei) g_SceneData->shapes_.size(), 0);
    }
};

MeshScene::MeshScene() {
    auto x = ZELO_PATH("data/meshes/test.meshes");
    auto y = ZELO_PATH("data/meshes/test.scene");
    auto z = ZELO_PATH("data/meshes/test.materials");

    g_SceneData = new GLSceneData(x.c_str(), y.c_str(), z.c_str());

    // UBO
    perFrameDataBuffer = std::make_unique<GLBufferImmutable>(kUniformBufferSize, nullptr, GL_DYNAMIC_STORAGE_BIT);
    glBindBufferRange(GL_UNIFORM_BUFFER, 0, perFrameDataBuffer->getHandle(), 0, kUniformBufferSize);

//    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
//    glEnable(GL_DEPTH_TEST);
    pimpl = std::make_shared<Impl>();
}

MeshScene::~MeshScene() = default;

void MeshScene::render() const {
    pimpl->render();
}
}

// VAO
// SSBO UBO
