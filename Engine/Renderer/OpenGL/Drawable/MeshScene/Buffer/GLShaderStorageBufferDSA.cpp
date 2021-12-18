// GLShaderStorageBufferDSA.cpp.cc
// created on 2021/12/17
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLShaderStorageBufferDSA.h"

namespace Zelo::Renderer::OpenGL{
GLShaderStorageBufferDSA::~GLShaderStorageBufferDSA() = default;

void GLShaderStorageBufferDSA::bind(uint32_t bindingPoint) {
    m_bindingPoint = bindingPoint;
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, bindingPoint, m_RendererID);
}

void GLShaderStorageBufferDSA::unbind() const {
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, m_bindingPoint, 0);
}
}