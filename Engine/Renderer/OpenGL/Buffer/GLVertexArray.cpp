// GLVertexArray.cpp
// created on 2021/6/6
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLVertexArray.h"
#include "Renderer/OpenGL/GLUtil.h"
#include "Core/RHI/Const/EShaderType.h"
#include"Core/RHI/Const/EBufferDataType.h"

using namespace Zelo::Core::RHI;


GLenum BufferDataTypeToOpenGLBaseType(const EBufferDataType &type) {
    switch (type) {
        case EBufferDataType::Float:
            return GL_FLOAT;
        case EBufferDataType::Float2:
            return GL_FLOAT;
        case EBufferDataType::Float3:
            return GL_FLOAT;
        case EBufferDataType::Float4:
            return GL_FLOAT;
        case EBufferDataType::UByte:
            return GL_UNSIGNED_BYTE;
        case EBufferDataType::Mat3:
            return GL_FLOAT;
        case EBufferDataType::Mat4:
            return GL_FLOAT;
        case EBufferDataType::Int:
            return GL_INT;
        case EBufferDataType::Int2:
            return GL_INT;
        case EBufferDataType::Int3:
            return GL_INT;
        case EBufferDataType::Int4:
            return GL_INT;
        case EBufferDataType::Bool:
            return GL_BOOL;
        default:
            break;
    }

    ZELO_CORE_ASSERT(false, "Unknown ShaderDataType!");
    return 0;
}

namespace Zelo {

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

void GLVertexArrayDSA::addVertexBuffer(const std::shared_ptr<VertexBuffer> &vertexBuffer) {
    setbuf(stdout, NULL);
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
            case EBufferDataType::Float:
            case EBufferDataType::Float2:
            case EBufferDataType::Float3:
            case EBufferDataType::Float4:
            case EBufferDataType::UByte: {
                glEnableVertexArrayAttrib(m_RendererID, index);
                glVertexArrayAttribFormat(m_RendererID, index, size, type, normalized, pointer);
                glVertexArrayAttribBinding(m_RendererID, index, 0);
                index++;

                m_VertexBufferIndex = index;
                break;
            }
            case EBufferDataType::Int:
            case EBufferDataType::Int2:
            case EBufferDataType::Int3:
            case EBufferDataType::Int4:
            case EBufferDataType::Bool: {
                glEnableVertexArrayAttrib(m_RendererID, index);
                glVertexArrayAttribIFormat(m_RendererID, index, size, type, pointer);
                glVertexArrayAttribBinding(m_RendererID, index, 0);
                index++;

                m_VertexBufferIndex = index;
                break;
            }
            case EBufferDataType::Mat3:
            case EBufferDataType::Mat4: {
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

void GLVertexArrayDSA::setIndexBuffer(const std::shared_ptr<IndexBuffer> &indexBuffer) {
    glVertexArrayElementBuffer(m_RendererID, indexBuffer->getHandle());

    m_IndexBuffer = indexBuffer;
}
}