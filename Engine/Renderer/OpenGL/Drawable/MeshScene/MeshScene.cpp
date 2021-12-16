// MeshScene.cpp.cc
// created on 2021/12/16
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "MeshScene.h"

#include "Core/RHI/Buffer/Vertex.h"
#include "Core/Interface/IMeshData.h"
#include "Renderer/OpenGL/Buffer/GLBuffer.h"  // GLBufferImmutable
#include "Renderer/OpenGL/Buffer/GLVertexArray.h"
#include "Renderer/OpenGL/Buffer/GLShaderStorageBuffer.h"

// TODO
//#include "../../../../../Sandbox/GRCookbook/Resource/GLSceneData.h"
//#include "../../../../../Sandbox/GRCookbook/Material/Material.h"

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

struct MeshScene::Impl {

    GLsizei m_count{};
    GLVertexArray m_vao{};

    std::unique_ptr<GLIndirectCommandBuffer> bufferIndirect_;

    GLShaderStorageBuffer bufferMaterials_;
    GLShaderStorageBuffer bufferModelMatrices_;

//    std::vector<GLTexture> allMaterialTextures_;
//
//    MeshFileHeader header_;
//    MeshData meshData_;
//
//    Scene scene_;
//    std::vector<MaterialDescription> materials_;
//    std::vector<DrawData> shapes_;


    explicit Impl(GLSceneData &data) :
            m_count(data.shapes_.size()),
            bufferMaterials_(Core::RHI::EAccessSpecifier::STREAM_DRAW),
            bufferModelMatrices_(Core::RHI::EAccessSpecifier::STREAM_DRAW) {

        auto bufferVertices_ = std::make_shared<GLVertexBufferImmutable>(
                data.header_.vertexDataSize, data.meshData_.vertexData_.data(), 0);
        auto bufferIndices_ = std::make_shared<GLIndexBufferImmutable>(
                data.header_.indexDataSize, data.meshData_.indexData_.data(), 0);
        bufferVertices_->setLayout(s_BufferLayout);
        m_vao.addVertexBuffer(bufferVertices_);
        m_vao.setIndexBuffer(bufferIndices_);

        bufferIndirect_ = std::make_unique<GLIndirectCommandBuffer>(
                sizeof(DrawElementsIndirectCommand) * data.shapes_.size() + sizeof(GLsizei),
                nullptr, GL_DYNAMIC_STORAGE_BIT, m_count);
        // prepare indirect commands buffer
        auto *cmd = bufferIndirect_->getCommandQueue();
        for (size_t i = 0; i != data.shapes_.size(); i++) {
            const uint32_t meshIdx = data.shapes_[i].meshIndex;
            const uint32_t lod = data.shapes_[i].LOD;
            *cmd++ = {
                    data.meshData_.meshes_[meshIdx].getLODIndicesCount(lod),
                    1,
                    data.shapes_[i].indexOffset,
                    data.shapes_[i].vertexOffset,
                    data.shapes_[i].materialIndex
            };
        }
        bufferMaterials_.sendBlocks<MaterialDescription>(data.materials_);

        std::vector<glm::mat4> matrices(data.shapes_.size());
        size_t i = 0;
        for (const auto &c: data.shapes_) {
            matrices[i] = data.scene_.globalTransform_[c.transformIndex];
            i++;
        }
        bufferModelMatrices_.sendBlocks<glm::mat4>(data.shapes_);
    }

    ~Impl() = default;

    void render() {
        m_vao.bind();
        bufferMaterials_.bind(kBufferIndex_Materials);
        bufferModelMatrices_.bind(kBufferIndex_ModelMatrices);
        bufferIndirect_->bind();
        glMultiDrawElementsIndirectCount(
                GL_TRIANGLES, GL_UNSIGNED_INT,
                (const void *) sizeof(GLsizei), 0, m_count, 0);
    }
};

MeshScene::MeshScene() {
    GLSceneData s("", "", "");
    pimpl = std::make_shared<Impl>(s);
}

void MeshScene::render() const {
    pimpl->render();
}

MeshScene::~MeshScene() {

}
