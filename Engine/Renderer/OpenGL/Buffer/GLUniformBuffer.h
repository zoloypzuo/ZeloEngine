// GLUniformBuffer.h
// created on 2021/10/28
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/RHI/Const/EAccessSpecifier.h"

class GLSLShaderProgram;

namespace Zelo {

class GLUniformBuffer {
public:

    explicit GLUniformBuffer(size_t size, uint32_t bindingPoint = 0, uint32_t offset = 0,
                             Core::RHI::EAccessSpecifier accessSpecifier = Core::RHI::EAccessSpecifier::DYNAMIC_DRAW);

    ~GLUniformBuffer();

    void Bind() const;

    void Unbind();

    template<typename T>
    void SetSubData(const T &data, size_t offset);

    template<typename T>
    void SetSubData(const T &data, std::reference_wrapper<size_t> offsetInOut);

    uint32_t GetID() const;

    static void BindBlockToShader(GLSLShaderProgram &shader, uint32_t uniformBlockLocation, uint32_t bindingPoint = 0);

    static void BindBlockToShader(GLSLShaderProgram &shader, const std::string &name, uint32_t bindingPoint = 0);

    static uint32_t GetBlockLocation(GLSLShaderProgram &shader, const std::string &name);

private:
    uint32_t m_bufferID{};
};
}

#include "GLUniformBuffer.inl"