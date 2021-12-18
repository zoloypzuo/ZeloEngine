// GLUniformBufferDSA.h
// created on 2021/10/28
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "GLBufferDSA.h"  // GLBufferDSABase

class GLSLShaderProgram;

namespace Zelo::Renderer::OpenGL {
class GLUniformBufferDSA : public GLBufferDSABase {
public:
    explicit GLUniformBufferDSA(
            uint32_t bindingPoint, uint32_t size, const void *data = nullptr, uint32_t flags = GL_DYNAMIC_STORAGE_BIT);

    ~GLUniformBufferDSA();

    GLBufferType getType() const override { return GLBufferType::UNIFORM_BUFFER; }

    template<typename T>
    void sendBlocks(const T &data);
};

template<typename T>
void GLUniformBufferDSA::sendBlocks(const T &data) {
    glNamedBufferSubData(m_RendererID, 0, sizeof(T), &data);
}
}

