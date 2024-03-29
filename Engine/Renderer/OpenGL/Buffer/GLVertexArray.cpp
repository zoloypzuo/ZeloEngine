// GLVertexArray.cpp
// created on 2021/6/6
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLVertexArray.h"
#include "Renderer/OpenGL/GLUtil.h"

using namespace Zelo::Core::RHI;

namespace Zelo::Renderer::OpenGL {
GLVertexArray::GLVertexArray() {
    glGenVertexArrays(1, &m_RendererID);
}

GLVertexArray::~GLVertexArray() {
    glDeleteVertexArrays(1, &m_RendererID);
}

void GLVertexArray::bind() const {
    glBindVertexArray(m_RendererID);
}

void GLVertexArray::unbind() const {
    glBindVertexArray(0);
}

void GLVertexArray::addVertexBuffer(const std::shared_ptr<VertexBuffer> &vertexBuffer) {
    ZELO_CORE_ASSERT(!vertexBuffer->getLayout().getElements().empty(), "Vertex Buffer has no layout!");

    bind();
    vertexBuffer->bind();

    const auto &layout = vertexBuffer->getLayout();
    for (const auto &element: layout) {
        GLuint index{};
        GLint size{};
        GLenum type{};
        GLboolean normalized{};
        GLsizei stride{};
        const void *pointer{};

        index = m_VertexBufferIndex;
        size = static_cast<GLint>(element.getComponentCount());
        type = BufferDataTypeToOpenGLBaseType(element.Type);
        normalized = element.Normalized ? GL_TRUE : GL_FALSE;
        stride = static_cast<GLsizei>(layout.getStride());
        pointer = (const void *) element.Offset;

        switch (element.Type) {
            case EBufferDataType::Float:
            case EBufferDataType::Float2:
            case EBufferDataType::Float3:
            case EBufferDataType::Float4:
            case EBufferDataType::UByte: {
                glEnableVertexAttribArray(index);
                glVertexAttribPointer(index, size, type, normalized, stride, pointer);
                index++;

                m_VertexBufferIndex = index;
                break;
            }
            case EBufferDataType::Int:
            case EBufferDataType::Int2:
            case EBufferDataType::Int3:
            case EBufferDataType::Int4:
            case EBufferDataType::Bool: {
                glEnableVertexAttribArray(index);
                glVertexAttribIPointer(index, size, type, stride, pointer);
                index++;

                m_VertexBufferIndex = index;
                break;
            }
            case EBufferDataType::Mat3:
            case EBufferDataType::Mat4: {
                for (auto i = 0; i < size; i++) {
                    glEnableVertexAttribArray(index);
                    glVertexAttribPointer(index, size, type, normalized, stride, pointer);
                    glVertexAttribDivisor(index, 1);
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

void GLVertexArray::setIndexBuffer(const std::shared_ptr<IndexBuffer> &indexBuffer) {
    bind();
    indexBuffer->bind();

    m_IndexBuffer = indexBuffer;
}
}