// GLBuffer.cpp.cc
// created on 2021/6/6
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLBuffer.h"

namespace Zelo {

/////////////////////////////////////////////////////////////////////////////
// VertexBuffer /////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////
GLVertexBuffer::GLVertexBuffer() {
    ZELO_PROFILE_FUNCTION();

    glGenBuffers(1, &m_RendererID);
}

GLVertexBuffer::GLVertexBuffer(uint32_t size) {
    ZELO_PROFILE_FUNCTION();

    glCreateBuffers(1, &m_RendererID);
    glBindBuffer(GL_ARRAY_BUFFER, m_RendererID);
    glBufferData(GL_ARRAY_BUFFER, size, nullptr, GL_DYNAMIC_DRAW);
}

GLVertexBuffer::GLVertexBuffer(float *vertices, uint32_t size) {
    ZELO_PROFILE_FUNCTION();

    glCreateBuffers(1, &m_RendererID);
    glBindBuffer(GL_ARRAY_BUFFER, m_RendererID);
    glBufferData(GL_ARRAY_BUFFER, size, vertices, GL_STATIC_DRAW);
}

GLVertexBuffer::~GLVertexBuffer() {
    ZELO_PROFILE_FUNCTION();

    glDeleteBuffers(1, &m_RendererID);
}

void GLVertexBuffer::bind() const {
    ZELO_PROFILE_FUNCTION();

    glBindBuffer(GL_ARRAY_BUFFER, m_RendererID);
}

void GLVertexBuffer::unbind() const {
    ZELO_PROFILE_FUNCTION();

    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

void GLVertexBuffer::setData(const void *data, uint32_t size) {
    glBindBuffer(GL_ARRAY_BUFFER, m_RendererID);
    glBufferSubData(GL_ARRAY_BUFFER, 0, size, data);
}


/////////////////////////////////////////////////////////////////////////////
// IndexBuffer //////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////

GLIndexBuffer::GLIndexBuffer(uint32_t *indices, uint32_t count)
        : m_Count(count) {
    ZELO_PROFILE_FUNCTION();

    glCreateBuffers(1, &m_RendererID);

    // GL_ELEMENT_ARRAY_BUFFER is not valid without an actively bound VAO
    // Binding with GL_ARRAY_BUFFER allows the data to be loaded regardless of VAO state.
    glBindBuffer(GL_ARRAY_BUFFER, m_RendererID);
    glBufferData(GL_ARRAY_BUFFER, count * sizeof(uint32_t), indices, GL_STATIC_DRAW);
}

GLIndexBuffer::~GLIndexBuffer() {
    ZELO_PROFILE_FUNCTION();

    glDeleteBuffers(1, &m_RendererID);
}

void GLIndexBuffer::bind() const {
    ZELO_PROFILE_FUNCTION();

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, m_RendererID);
}

void GLIndexBuffer::unbind() const {
    ZELO_PROFILE_FUNCTION();

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
}

}