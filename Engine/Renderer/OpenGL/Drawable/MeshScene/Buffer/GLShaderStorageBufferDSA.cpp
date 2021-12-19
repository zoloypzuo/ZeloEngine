// GLShaderStorageBufferDSA.cpp.cc
// created on 2021/12/17
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLShaderStorageBufferDSA.h"

namespace Zelo::Renderer::OpenGL {
GLShaderStorageBufferDSA::GLShaderStorageBufferDSA(uint32_t size, const void *data, uint32_t flags) :
        GLBufferDSABase(size, data, flags) {}


GLBufferType GLShaderStorageBufferDSA::getType() const { return GLBufferType::SHADER_STORAGE_BUFFER; }

uint32_t *GLShaderStorageBufferDSA::getMappedPtr() const {
    return (uint32_t *) glMapNamedBuffer(m_RendererID, GL_READ_WRITE);
}
}