// GLVertexArray.cpp.cc
// created on 2021/6/6
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLVertexArray.h"

namespace Zelo {

static GLenum ShaderDataTypeToOpenGLBaseType(ShaderDataType type) {
    switch (type) {
        case ShaderDataType::Float:
            return GL_FLOAT;
        case ShaderDataType::Float2:
            return GL_FLOAT;
        case ShaderDataType::Float3:
            return GL_FLOAT;
        case ShaderDataType::Float4:
            return GL_FLOAT;
        case ShaderDataType::Mat3:
            return GL_FLOAT;
        case ShaderDataType::Mat4:
            return GL_FLOAT;
        case ShaderDataType::Int:
            return GL_INT;
        case ShaderDataType::Int2:
            return GL_INT;
        case ShaderDataType::Int3:
            return GL_INT;
        case ShaderDataType::Int4:
            return GL_INT;
        case ShaderDataType::Bool:
            return GL_BOOL;
        default:
            break;
    }

    ZELO_CORE_ASSERT(false, "Unknown ShaderDataType!");
    return 0;
}

GLVertexArray::GLVertexArray() {
    ZELO_PROFILE_FUNCTION();

    glCreateVertexArrays(1, &m_RendererID);
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

    ZELO_CORE_ASSERT(vertexBuffer->GetLayout().GetElements().size(), "Vertex Buffer has no layout!");

    glBindVertexArray(m_RendererID);
    vertexBuffer->Bind();

    const auto &layout = vertexBuffer->GetLayout();
    for (const auto &element : layout) {
        switch (element.Type) {
            case ShaderDataType::Float:
            case ShaderDataType::Float2:
            case ShaderDataType::Float3:
            case ShaderDataType::Float4: {
                glEnableVertexAttribArray(m_VertexBufferIndex);
                glVertexAttribPointer(m_VertexBufferIndex,
                                      element.GetComponentCount(),
                                      ShaderDataTypeToOpenGLBaseType(element.Type),
                                      element.Normalized ? GL_TRUE : GL_FALSE,
                                      layout.GetStride(),
                                      (const void *) element.Offset);
                m_VertexBufferIndex++;
                break;
            }
            case ShaderDataType::Int:
            case ShaderDataType::Int2:
            case ShaderDataType::Int3:
            case ShaderDataType::Int4:
            case ShaderDataType::Bool: {
                glEnableVertexAttribArray(m_VertexBufferIndex);
                glVertexAttribIPointer(m_VertexBufferIndex,
                                       element.GetComponentCount(),
                                       ShaderDataTypeToOpenGLBaseType(element.Type),
                                       layout.GetStride(),
                                       (const void *) element.Offset);
                m_VertexBufferIndex++;
                break;
            }
            case ShaderDataType::Mat3:
            case ShaderDataType::Mat4: {
                uint8_t count = element.GetComponentCount();
                for (uint8_t i = 0; i < count; i++) {
                    glEnableVertexAttribArray(m_VertexBufferIndex);
                    glVertexAttribPointer(m_VertexBufferIndex,
                                          count,
                                          ShaderDataTypeToOpenGLBaseType(element.Type),
                                          element.Normalized ? GL_TRUE : GL_FALSE,
                                          layout.GetStride(),
                                          (const void *) (element.Offset + sizeof(float) * count * i));
                    glVertexAttribDivisor(m_VertexBufferIndex, 1);
                    m_VertexBufferIndex++;
                }
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
    indexBuffer->Bind();

    m_IndexBuffer = indexBuffer;
}

}