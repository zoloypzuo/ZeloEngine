// GLVertexArray.h
// created on 2021/12/17
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLVertexArrayDSA.h"

#include "Renderer/OpenGL/GLUtil.h"
#include "GLVertexArray.h"

namespace Zelo::Renderer::OpenGL {
GLVertexArrayDSA::GLVertexArrayDSA() {
    glCreateVertexArrays(1, &m_RendererID);
}

GLVertexArrayDSA::~GLVertexArrayDSA() {
    glDeleteVertexArrays(1, &m_RendererID);
}

void GLVertexArrayDSA::bind() const {
    glBindVertexArray(m_RendererID);
}

void GLVertexArrayDSA::unbind() const {
    glBindVertexArray(0);
}

void GLVertexArrayDSA::addVertexBuffer(const std::shared_ptr<Zelo::VertexBuffer> &vertexBuffer) {
    ZELO_CORE_ASSERT(!vertexBuffer->getLayout().getElements().empty(), "Vertex Buffer has no layout!");

    const auto &layout = vertexBuffer->getLayout();

    glVertexArrayVertexBuffer(m_RendererID, 0, vertexBuffer->getHandle(), 0, layout.getStride());

    for (const auto &element: layout) {
        GLuint index{};
        GLint size{};
        GLenum type{};
        GLboolean normalized{};
        GLsizei stride{};
        GLuint pointer{};

        index = m_VertexBufferIndex;
        size = static_cast<GLint>(element.getComponentCount());
        type = BufferDataTypeToOpenGLBaseType(element.Type);
        normalized = element.Normalized ? GL_TRUE : GL_FALSE;
        stride = static_cast<GLsizei>(layout.getStride());
        pointer = element.Offset;

        switch (element.Type) {
            case Zelo::Core::RHI::EBufferDataType::Float:
            case Zelo::Core::RHI::EBufferDataType::Float2:
            case Zelo::Core::RHI::EBufferDataType::Float3:
            case Zelo::Core::RHI::EBufferDataType::Float4:
            case Zelo::Core::RHI::EBufferDataType::UByte: {
                glEnableVertexArrayAttrib(m_RendererID, index);
                glVertexArrayAttribFormat(m_RendererID, index, size, type, normalized, pointer);
                glVertexArrayAttribBinding(m_RendererID, index, 0);
                index++;

                m_VertexBufferIndex = index;
                break;
            }
            case Zelo::Core::RHI::EBufferDataType::Int:
            case Zelo::Core::RHI::EBufferDataType::Int2:
            case Zelo::Core::RHI::EBufferDataType::Int3:
            case Zelo::Core::RHI::EBufferDataType::Int4:
            case Zelo::Core::RHI::EBufferDataType::Bool: {
                glEnableVertexArrayAttrib(m_RendererID, index);
                glVertexArrayAttribIFormat(m_RendererID, index, size, type, pointer);
                glVertexArrayAttribBinding(m_RendererID, index, 0);
                index++;

                m_VertexBufferIndex = index;
                break;
            }
            case Zelo::Core::RHI::EBufferDataType::Mat3:
            case Zelo::Core::RHI::EBufferDataType::Mat4: {
                for (auto i = 0; i < size; i++) {
                    ZELO_CORE_ASSERT(false, "Not implemented!");
                    index++;
                }

                m_VertexBufferIndex = index;
                break;
            }
            default:
                ZELO_CORE_ASSERT(false, "Unknown ShaderDataType!");
        }
    }

    m_VertexBuffers.push_back(vertexBuffer);
}

void GLVertexArrayDSA::setIndexBuffer(const std::shared_ptr<Zelo::IndexBuffer> &indexBuffer) {
    glVertexArrayElementBuffer(m_RendererID, indexBuffer->getHandle());

    m_IndexBuffer = indexBuffer;
}
}