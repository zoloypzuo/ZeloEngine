// GLUniformBuffer.cpp
// created on 2021/10/28
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLUniformBuffer.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"

using namespace Zelo;
using namespace Zelo::Core::RHI;

GLUniformBuffer::GLUniformBuffer(size_t size, uint32_t bindingPoint, uint32_t offset,
                                 EAccessSpecifier accessSpecifier) {
    glGenBuffers(1, &m_bufferID);
    glBindBuffer(GL_UNIFORM_BUFFER, m_bufferID);
    glBufferData(GL_UNIFORM_BUFFER, size, NULL, static_cast<GLint>(accessSpecifier));
    glBindBuffer(GL_UNIFORM_BUFFER, 0);
    glBindBufferRange(GL_UNIFORM_BUFFER, bindingPoint, m_bufferID, offset, size);
}

GLUniformBuffer::~GLUniformBuffer() {
    glDeleteBuffers(1, &m_bufferID);
}

void GLUniformBuffer::bind() const {
    glBindBuffer(GL_UNIFORM_BUFFER, m_bufferID);
}

void GLUniformBuffer::unbind() {
    glBindBuffer(GL_UNIFORM_BUFFER, 0);
}

GLuint GLUniformBuffer::getHandle() const {
    return m_bufferID;
}

void GLUniformBuffer::bindBlockToShader(const GLSLShaderProgram &shader,
                                        uint32_t uniformBlockLocation,
                                        uint32_t bindingPoint) {
    glUniformBlockBinding(shader.getHandle(), uniformBlockLocation, bindingPoint);
}

void GLUniformBuffer::bindBlockToShader(const GLSLShaderProgram &shader,
                                        const std::string &name,
                                        uint32_t bindingPoint) {
    glUniformBlockBinding(shader.getHandle(), getBlockLocation(shader, name), bindingPoint);
}

uint32_t GLUniformBuffer::getBlockLocation(const GLSLShaderProgram &shader, const std::string &name) {
    return glGetUniformBlockIndex(shader.getHandle(), name.c_str());
}