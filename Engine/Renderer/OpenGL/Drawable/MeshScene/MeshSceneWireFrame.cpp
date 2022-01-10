// MeshSceneWireFrame.cpp.cc
// created on 2021/12/16
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "MeshSceneWireFrame.h"

#include "Core/Resource/ResourceManager.h"
#include "Core/Scene/SceneManager.h"

#include "Renderer/OpenGL/Drawable/MeshScene/Buffer/GLIndirectCommandBufferDSA.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Buffer/GLShaderStorageBufferDSA.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Buffer/GLUniformBufferDSA.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Buffer/GLVertexArrayDSA.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Texture/GLTexture.h"
#include "Renderer/OpenGL/Drawable/MeshScene/VtxData/Mesh.h"
#include "Renderer/OpenGL/Drawable/MeshScene/VtxData/MeshData.h"

using namespace Zelo::Core::RHI;
using namespace Zelo::Core::Resource;

namespace Zelo::Renderer::OpenGL {

namespace {
const BufferLayout s_BufferLayout(
        {
                BufferElement(EBufferDataType::Float3, "position"),
                BufferElement(EBufferDataType::Float2, "texCoord"),
                BufferElement(EBufferDataType::Float3, "normal")
        });

const GLuint kBufferIndex_PerFrameUniforms = 0;
const GLuint kBufferIndex_ModelMatrices = 2;

struct PerFrameData {
    glm::mat4 view;
    glm::mat4 proj;
    vec4 cameraPos;
};
const GLsizeiptr kUniformBufferSize = sizeof(PerFrameData);
}

struct MeshSceneWireFrame::Impl {
    // mesh
    MeshData meshData_;

    // buffer
    GLVertexArrayDSA vao;

    std::unique_ptr<GLShaderStorageBufferDSA> bufferModelMatrices_;

    std::unique_ptr<GLIndirectCommandBufferCountDSA> bufferIndirect_;

    std::unique_ptr<GLUniformBufferDSA> perFrameDataBuffer{};

    explicit Impl(const std::string &meshFile);

    ~Impl() = default;

    void render() const;

    int getDrawCount() const;
};

MeshSceneWireFrame::Impl::Impl(const std::string &meshFile) {
    {
        // load mesh
        loadMeshData(meshFile.c_str(), meshData_);
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
        const auto numCommands = (GLsizei) meshData_.meshCount();
        bufferIndirect_ = std::make_unique<GLIndirectCommandBufferCountDSA>(numCommands);
        // prepare indirect commands buffer
        auto *cmd = bufferIndirect_->getCommandQueue();
        for (size_t i = 0; i != numCommands; i++) {
            auto &mesh = meshData_.meshes_[i];
            *cmd++ = {
                    mesh.getLODIndicesCount(0),
                    1,
                    mesh.indexOffset,
                    mesh.vertexOffset,
                    0
            };
        }

        bufferIndirect_->sendBlocks();
    }

    // bufferModelMatrices_
    {
        const glm::mat4 m(glm::scale(glm::mat4(1.0f), glm::vec3(2.0f)));
        bufferModelMatrices_ = std::make_unique<GLShaderStorageBufferDSA>(
                uint32_t(sizeof(glm::mat4)), glm::value_ptr(m), GL_DYNAMIC_STORAGE_BIT);
    }

    // perFrameDataBuffer
    {
        perFrameDataBuffer = std::make_unique<GLUniformBufferDSA>(
                kBufferIndex_PerFrameUniforms, uint32_t(sizeof(PerFrameData)));
    }
}

int MeshSceneWireFrame::Impl::getDrawCount() const { return (int) meshData_.meshCount(); }

void MeshSceneWireFrame::Impl::render() const {
    // perFrameDataBuffer
    {
        auto *camera = Zelo::Core::Scene::SceneManager::getSingletonPtr()->getActiveCamera();
        if (!camera) { return; }
        const glm::mat4 p = camera->getProjectionMatrix();
        const glm::mat4 view = camera->getViewMatrix();
        const vec3 viewPos = camera->getOwner()->getPosition();

        const PerFrameData perFrameData = {view, p, glm::vec4(viewPos, 1.0f)};
        perFrameDataBuffer->sendBlocks(perFrameData);
    }

    // draw call
    vao.bind();
    bufferModelMatrices_->bind(kBufferIndex_ModelMatrices);
    bufferIndirect_->bind();
    const void *startOffset = (const void *) sizeof(GLsizei); // NOLINT(performance-no-int-to-ptr)
    glMultiDrawElementsIndirectCount(GL_TRIANGLES, GL_UNSIGNED_INT, startOffset, 0, getDrawCount(), 0);
}

MeshSceneWireFrame::MeshSceneWireFrame(const std::string &meshFile) {
    pimpl = std::make_shared<Impl>(ZELO_PATH(meshFile));
}

MeshSceneWireFrame::~MeshSceneWireFrame() = default;

void MeshSceneWireFrame::render() {
    pimpl->render();
}
}