// GLUniformBufferDSA.h
// created on 2021/10/28
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/RHI/Const/EAccessSpecifier.h"

class GLSLShaderProgram;

namespace Zelo {

class GLUniformBufferDSA {
public:

    explicit GLUniformBufferDSA(size_t size, uint32_t bindingPoint = 0, uint32_t offset = 0,
                             Core::RHI::EAccessSpecifier accessSpecifier = Core::RHI::EAccessSpecifier::DYNAMIC_DRAW);

    ~GLUniformBufferDSA();

    void bind() const;

    void unbind();

    template<typename T>
    void setSubData(const T &data, size_t offset);

    template<typename T>
    void setSubData(const T &data, std::reference_wrapper<size_t> offsetInOut);

    uint32_t getHandle() const;

    static void bindBlockToShader(const GLSLShaderProgram &shader,
                                  uint32_t uniformBlockLocation,
                                  uint32_t bindingPoint = 0);

    static void bindBlockToShader(const GLSLShaderProgram &shader, const std::string &name, uint32_t bindingPoint = 0);

    static uint32_t getBlockLocation(const GLSLShaderProgram &shader, const std::string &name);

private:
    uint32_t m_bufferID{};
};

template<typename T>
inline void GLUniformBufferDSA::setSubData(const T &data, size_t offsetInOut) {
    bind();
    glBufferSubData(GL_UNIFORM_BUFFER, offsetInOut, sizeof(T), std::addressof(data));
    unbind();
}

template<typename T>
inline void GLUniformBufferDSA::setSubData(const T &data, std::reference_wrapper<size_t> offsetInOut) {
    bind();
    size_t dataSize = sizeof(T);
    glBufferSubData(GL_UNIFORM_BUFFER, offsetInOut.get(), dataSize, std::addressof(data));
    offsetInOut.get() += dataSize;
    unbind();
}
}

