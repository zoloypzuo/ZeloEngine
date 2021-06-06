// GLVertexArray.cpp.cc
// created on 2021/6/6
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLVertexArray.h"
#include "Renderer/OpenGL/GLUtil.h"

namespace Zelo {

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

    ZELO_CORE_ASSERT(!vertexBuffer->getLayout().getElements().empty(), "Vertex Buffer has no layout!");

    glBindVertexArray(m_RendererID);
    vertexBuffer->bind();

    const auto &layout = vertexBuffer->getLayout();
    for (const auto &element : layout) {
        switch (element.Type) {
            case ShaderDataType::Float:
            case ShaderDataType::Float2:
            case ShaderDataType::Float3:
            case ShaderDataType::Float4: {
                glEnableVertexAttribArray(m_VertexBufferIndex);
                glVertexAttribPointer(
                        m_VertexBufferIndex,
                        element.getComponentCount(),
                        ShaderDataTypeToOpenGLBaseType(element.Type),
                        element.Normalized ? GL_TRUE : GL_FALSE,
                        layout.getStride(),
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
                glVertexAttribIPointer(
                        m_VertexBufferIndex,
                        element.getComponentCount(),
                        ShaderDataTypeToOpenGLBaseType(element.Type),
                        layout.getStride(),
                        (const void *) element.Offset);
                m_VertexBufferIndex++;
                break;
            }
            case ShaderDataType::Mat3:
            case ShaderDataType::Mat4: {
                uint8_t count = element.getComponentCount();
                for (uint8_t i = 0; i < count; i++) {
                    glEnableVertexAttribArray(m_VertexBufferIndex);
                    glVertexAttribPointer(
                            m_VertexBufferIndex,
                            count,
                            ShaderDataTypeToOpenGLBaseType(element.Type),
                            element.Normalized ? GL_TRUE : GL_FALSE,
                            layout.getStride(),
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
    indexBuffer->bind();

    m_IndexBuffer = indexBuffer;
}

}