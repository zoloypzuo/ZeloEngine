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

void GLUniformBuffer::Bind() const {
    glBindBuffer(GL_UNIFORM_BUFFER, m_bufferID);
}

void GLUniformBuffer::Unbind() {
    glBindBuffer(GL_UNIFORM_BUFFER, 0);
}

GLuint GLUniformBuffer::GetID() const {
    return m_bufferID;
}

void GLUniformBuffer::BindBlockToShader(GLSLShaderProgram &shader,
                                        uint32_t uniformBlockLocation, uint32_t bindingPoint) {
    glUniformBlockBinding(shader.getHandle(), uniformBlockLocation, bindingPoint);
}

void GLUniformBuffer::BindBlockToShader(GLSLShaderProgram &shader, const std::string &name,
                                        uint32_t bindingPoint) {
    glUniformBlockBinding(shader.getHandle(), GetBlockLocation(shader, name), bindingPoint);
}

uint32_t GLUniformBuffer::GetBlockLocation(GLSLShaderProgram &shader, const std::string &name) {
    return glGetUniformBlockIndex(shader.getHandle(), name.c_str());
}