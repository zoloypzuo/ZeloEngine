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

#include "Renderer/OpenGL/Buffer/GLUniformBuffer.h"

using namespace Zelo::Core::RHI;

namespace Zelo::Renderer::OpenGL {
class GLBuffer {
public:
    GLBuffer(uint32_t size, const void *data, uint32_t flags) {
        glCreateBuffers(1, &m_RendererID);
        glNamedBufferStorage(m_RendererID, size, data, flags);
    }

    ~GLBuffer() {
        glDeleteBuffers(1, &m_RendererID);
    }

    uint32_t getHandle() const { return m_RendererID; }

    virtual void bind() const { glBindBuffer(static_cast<GLenum>(getType()), m_RendererID); }

    virtual void unbind() const { glBindBuffer(static_cast<GLenum>(getType()), 0); }

    virtual GLBufferType getType() const = 0;

protected:
    uint32_t m_RendererID{};
};

class GLVertexBufferImmutable : public VertexBuffer, public GLBuffer {
public:
    GLVertexBufferImmutable(uint32_t size, const void *data, uint32_t flags) :
            GLBuffer(size, data, flags) {}

    ~GLVertexBufferImmutable() override = default;

    void bind() const override { GLBuffer::bind(); }

    void unbind() const override { GLBuffer::unbind(); }

    uint32_t getHandle() const override { return m_RendererID; }

    GLBufferType getType() const override { return GLBufferType::ARRAY_BUFFER; }
};

class GLIndexBufferImmutable : public IndexBuffer, public GLBuffer {
public:
    GLIndexBufferImmutable(uint32_t size, const void *data, uint32_t flags) :
            GLBuffer(size, data, flags) {}

    ~GLIndexBufferImmutable() override = default;

    void bind() const override { GLBuffer::bind(); }

    void unbind() const override { GLBuffer::unbind(); }

    uint32_t getHandle() const override { return m_RendererID; }

    GLBufferType getType() const override { return GLBufferType::ELEMENT_ARRAY_BUFFER; }

    uint32_t getCount() const override { return 0; }
};

struct DrawElementsIndirectCommand {
    GLuint count_;
    GLuint instanceCount_;
    GLuint firstIndex_;
    GLuint baseVertex_;
    GLuint baseInstance_;
};

class GLIndirectCommandBuffer : public GLBuffer {
public:
    GLIndirectCommandBuffer(uint32_t size, const void *data, uint32_t flags, GLsizei numCommands) :
            GLBuffer(size, data, flags) {

        drawCommandBuffer.resize(size);

        // store the number of draw commands in the very beginning of the buffer
        memcpy(drawCommandBuffer.data(), &numCommands, sizeof(GLsizei));

        auto *startOffset = drawCommandBuffer.data() + sizeof(GLsizei);
        commandQueue = std::launder(reinterpret_cast<DrawElementsIndirectCommand *>(startOffset));
    }

    void bind() const override {
        glBindBuffer(GL_DRAW_INDIRECT_BUFFER, m_RendererID);
        glBindBuffer(GL_PARAMETER_BUFFER, m_RendererID);
    }

    ~GLIndirectCommandBuffer() = default;

    GLBufferType getType() const override { return GLBufferType::DRAW_INDIRECT_BUFFER; }

    void sendBlocks() {
        glNamedBufferSubData(m_RendererID, 0, drawCommandBuffer.size(), drawCommandBuffer.data());
    }

    DrawElementsIndirectCommand *getCommandQueue() const { return commandQueue; }

private:
    // num of commands, followed by command queue
    std::vector<uint8_t> drawCommandBuffer;
    // start offset of command queue
    DrawElementsIndirectCommand *commandQueue;
};


class GLShaderStorageBuffer : public GLBuffer {
public:
    // pass data = null, flag = GL_DYNAMIC_STORAGE_BIT, and upload data later by sendBlocks
    GLShaderStorageBuffer(uint32_t size, const void *data = nullptr, uint32_t flags = GL_DYNAMIC_STORAGE_BIT) :
            GLBuffer(size, data, flags) {}

    ~GLShaderStorageBuffer();

    void bind(uint32_t bindingPoint);

    void unbind() const override;

    GLBufferType getType() const override { return GLBufferType::SHADER_STORAGE_BUFFER; }

    template<typename T>
    void sendBlocks(T *data, size_t size) const;

    template<typename T>
    void sendBlocks(std::vector<T> data) const;

private:
    uint32_t m_bindingPoint = 0;
    Core::RHI::EAccessSpecifier m_accessSpecifier;
};

GLShaderStorageBuffer::~GLShaderStorageBuffer() {
    glDeleteBuffers(1, &m_RendererID);
}

void GLShaderStorageBuffer::bind(uint32_t bindingPoint) {
    m_bindingPoint = bindingPoint;
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, bindingPoint, m_RendererID);
}

void GLShaderStorageBuffer::unbind() const {
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, m_bindingPoint, 0);
}

template<typename T>
inline void GLShaderStorageBuffer::sendBlocks(T *data, size_t size) const {
    glNamedBufferSubData(m_RendererID, 0, size, data);
}

template<typename T>
void GLShaderStorageBuffer::sendBlocks(std::vector<T> data) const {
    sendBlocks(data.data(), data.size() * sizeof(T));
}

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

std::unique_ptr<GLUniformBuffer> perFrameDataBuffer{};

struct MeshScene::Impl {

    GLVertexArrayDSA m_vao;

    std::unique_ptr<GLShaderStorageBuffer> bufferMaterials_;
    std::unique_ptr<GLShaderStorageBuffer> bufferModelMatrices_;

    std::unique_ptr<GLIndirectCommandBuffer> bufferIndirect_;

    explicit Impl() {

        auto bufferIndices_ = std::make_shared<GLIndexBufferImmutable>(
                g_SceneData->header_.indexDataSize, g_SceneData->meshData_.indexData_.data(), 0);
        auto bufferVertices_ = std::make_shared<GLVertexBufferImmutable>(
                g_SceneData->header_.vertexDataSize, g_SceneData->meshData_.vertexData_.data(), 0);

        bufferVertices_->setLayout(s_BufferLayout);
        m_vao.addVertexBuffer(bufferVertices_);
        m_vao.setIndexBuffer(bufferIndices_);

        // bufferIndirect_
        {
            bufferIndirect_ = std::make_unique<GLIndirectCommandBuffer>(
                    sizeof(DrawElementsIndirectCommand) * g_SceneData->shapes_.size() + sizeof(GLsizei),
                    nullptr, GL_DYNAMIC_STORAGE_BIT, g_SceneData->shapes_.size());
            // prepare indirect commands buffer
            auto *cmd = bufferIndirect_->getCommandQueue();
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

            bufferIndirect_->sendBlocks();
        }

        // bufferMaterials_
        {
            bufferMaterials_ = std::make_unique<GLShaderStorageBuffer>(
                    g_SceneData->materials_.size() * sizeof(MaterialDescription),
                    g_SceneData->materials_.data(), 0
            );
        }

        // bufferModelMatrices_
        {
            bufferModelMatrices_ = std::make_unique<GLShaderStorageBuffer>(
                    g_SceneData->shapes_.size() * sizeof(glm::mat4), nullptr, GL_DYNAMIC_STORAGE_BIT);
            std::vector<glm::mat4> matrices(g_SceneData->shapes_.size());
            size_t i = 0;
            for (const auto &c: g_SceneData->shapes_) {
                matrices[i++] = g_SceneData->scene_.globalTransform_[c.transformIndex];
            }

            bufferModelMatrices_->sendBlocks(matrices);
        }

    }

    ~Impl() = default;

    void render() {
        auto *camera = Zelo::Core::Scene::SceneManager::getSingletonPtr()->getActiveCamera();
        if (!camera) { return; }
        const mat4 p = camera->getProjectionMatrix();
        const mat4 view = camera->getViewMatrix();
        const vec3 viewPos = camera->getOwner()->getPosition();

        const PerFrameData perFrameData = {view, p, glm::vec4(viewPos, 1.0f)};
        size_t startOffset = 0;
        perFrameDataBuffer->setSubData(perFrameData, std::ref(startOffset));

        m_vao.bind();
        bufferMaterials_->bind(kBufferIndex_Materials);
        bufferModelMatrices_->bind(kBufferIndex_ModelMatrices);
        bufferIndirect_->bind();
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
    perFrameDataBuffer = std::make_unique<GLUniformBuffer>(
            sizeof(PerFrameData), 0, 0, Core::RHI::EAccessSpecifier::STREAM_DRAW);

    pimpl = std::make_shared<Impl>();
}

MeshScene::~MeshScene() = default;

void MeshScene::render() const {
    pimpl->render();
}
}