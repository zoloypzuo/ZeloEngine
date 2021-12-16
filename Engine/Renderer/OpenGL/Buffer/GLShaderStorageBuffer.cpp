// GLShaderStorageBuffer.cpp
// created on 2021/10/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLShaderStorageBuffer.h"

using namespace Zelo;

GLShaderStorageBuffer::GLShaderStorageBuffer(Core::RHI::EAccessSpecifier accessSpecifier) {
    glGenBuffers(1, &m_bufferID);
    glBindBuffer(GL_SHADER_STORAGE_BUFFER, m_bufferID);
    glBufferData(GL_SHADER_STORAGE_BUFFER, 0, nullptr, static_cast<GLenum>(accessSpecifier));
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 0, m_bufferID);
}

GLShaderStorageBuffer::~GLShaderStorageBuffer() {
    glDeleteBuffers(1, &m_bufferID);
}

void GLShaderStorageBuffer::bind(uint32_t bindingPoint) {
    m_bindingPoint = bindingPoint;
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, bindingPoint, m_bufferID);
}

void GLShaderStorageBuffer::unbind() const {
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, m_bindingPoint, 0);
}
