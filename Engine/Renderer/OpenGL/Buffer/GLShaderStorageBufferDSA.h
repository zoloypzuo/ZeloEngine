// GLShaderStorageBufferDSA.h
// created on 2021/12/17
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Renderer/OpenGL/Buffer/GLBufferDSA.h"  // GLBufferDSABase

namespace Zelo::Renderer::OpenGL {
class GLShaderStorageBuffer : public GLBufferDSABase {
public:
    // pass data = null, flag = GL_DYNAMIC_STORAGE_BIT, and upload data later by sendBlocks
    explicit GLShaderStorageBuffer(uint32_t size, const void *data = nullptr, uint32_t flags = GL_DYNAMIC_STORAGE_BIT) :
            GLBufferDSABase(size, data, flags) {}

    ~GLShaderStorageBuffer();

    void bind(uint32_t bindingPoint);

    void unbind() const override;

    GLBufferType getType() const override { return GLBufferType::SHADER_STORAGE_BUFFER; }

    template<typename T>
    void sendBlocks(T *data, size_t size) const;

    template<typename T>
    void sendBlocks(std::vector<T> data) const;

private:
    uint32_t m_bindingPoint = 0;
};

GLShaderStorageBuffer::~GLShaderStorageBuffer() {
    glDeleteBuffers(1, &m_RendererID);
}

void GLShaderStorageBuffer::bind(uint32_t bindingPoint) {
    m_bindingPoint = bindingPoint;
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, bindingPoint, m_RendererID);
}

void GLShaderStorageBuffer::unbind() const {
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, m_bindingPoint, 0);
}

template<typename T>
inline void GLShaderStorageBuffer::sendBlocks(T *data, size_t size) const {
    glNamedBufferSubData(m_RendererID, 0, size, data);
}

template<typename T>
void GLShaderStorageBuffer::sendBlocks(std::vector<T> data) const {
    sendBlocks(data.data(), data.size() * sizeof(T));
}
}