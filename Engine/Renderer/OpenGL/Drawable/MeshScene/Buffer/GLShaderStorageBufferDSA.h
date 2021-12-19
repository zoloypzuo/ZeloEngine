// GLShaderStorageBufferDSA.h
// created on 2021/12/17
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "GLBufferDSA.h"  // GLBufferDSABase

namespace Zelo::Renderer::OpenGL {
class GLShaderStorageBufferDSA : public GLBufferDSABase {
public:
    // pass data = null, flag = GL_DYNAMIC_STORAGE_BIT, and upload data later by sendBlocks
    explicit GLShaderStorageBufferDSA(
            uint32_t size, const void *data = nullptr, uint32_t flags = GL_DYNAMIC_STORAGE_BIT);

    GLBufferType getType() const override;

    uint32_t *getMappedPtr() const;

    template<typename T>
    void sendBlocks(T *data, size_t size) const;

    template<typename T>
    void sendBlocks(std::vector<T> data) const;
};

template<typename T>
inline void GLShaderStorageBufferDSA::sendBlocks(T *data, size_t size) const {
    glNamedBufferSubData(m_RendererID, 0, size, data);
}

template<typename T>
void GLShaderStorageBufferDSA::sendBlocks(std::vector<T> data) const {
    sendBlocks(data.data(), data.size() * sizeof(T));
}
}