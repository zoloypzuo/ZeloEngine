// GLVertexArray.cpp.cc
// created on 2021/6/6
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLVertexArray.h"
#include "Renderer/OpenGL/GLUtil.h"

namespace Zelo {

GLVertexArray::GLVertexArray() {
    ZELO_PROFILE_FUNCTION();

    glGenVertexArrays(1, &m_RendererID);
}

GLVertexArray::~GLVertexArray() {
    ZELO_PROFILE_FUNCTION();

    glDeleteVertexArrays(1, &m_RendererID);
}

void GLVertexArray::bind() const {
    ZELO_PROFILE_FUNCTION();

    glBindVertexArray(m_RendererID);
}

void GLVertexArray::unbind() const {
    ZELO_PROFILE_FUNCTION();

    glBindVertexArray(0);
}

void GLVertexArray::addVertexBuffer(const std::shared_ptr<VertexBuffer> &vertexBuffer) {
    ZELO_PROFILE_FUNCTION();

    ZELO_CORE_ASSERT(!vertexBuffer->getLayout().getElements().empty(), "Vertex Buffer has no layout!");

    this->bind();
    vertexBuffer->bind();

    const auto &layout = vertexBuffer->getLayout();
    for (const auto &element : layout) {
        GLuint index{};
        GLint size{};
        GLenum type{};
        GLboolean normalized{};
        GLsizei stride{};
        const void *pointer{};

        index = m_VertexBufferIndex;
        size = static_cast<GLint>(element.getComponentCount());
        type = ShaderDataTypeToOpenGLBaseType(element.Type);
        normalized = element.Normalized ? GL_TRUE : GL_FALSE;
        stride = static_cast<GLsizei>(layout.getStride());
        pointer = (const void *) element.Offset;

        switch (element.Type) {
            case ShaderDataType::Float:
            case ShaderDataType::Float2:
            case ShaderDataType::Float3:
            case ShaderDataType::Float4:
            case ShaderDataType::UByte:{
                glEnableVertexAttribArray(index);
                glVertexAttribPointer(index, size, type, normalized, stride, pointer);
                index++;

                m_VertexBufferIndex = index;
                break;
            }
            case ShaderDataType::Int:
            case ShaderDataType::Int2:
            case ShaderDataType::Int3:
            case ShaderDataType::Int4:
            case ShaderDataType::Bool: {
                glEnableVertexAttribArray(index);
                glVertexAttribIPointer(index, size, type, stride, pointer);
                index++;

                m_VertexBufferIndex = index;
                break;
            }
            case ShaderDataType::Mat3:
            case ShaderDataType::Mat4: {
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
    ZELO_PROFILE_FUNCTION();

    glBindVertexArray(m_RendererID);
    indexBuffer->bind();

    m_IndexBuffer = indexBuffer;
}

}