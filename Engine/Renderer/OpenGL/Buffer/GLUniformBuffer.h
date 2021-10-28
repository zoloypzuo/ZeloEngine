// GLUniformBuffer.h
// created on 2021/10/28
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

class GLSLShaderProgram;

namespace Zelo {
enum class EAccessSpecifier {
    STREAM_DRAW = 0x88E0,
    STREAM_READ = 0x88E1,
    STREAM_COPY = 0x88E2,
    DYNAMIC_DRAW = 0x88E8,
    DYNAMIC_READ = 0x88E9,
    DYNAMIC_COPY = 0x88EA,
    STATIC_DRAW = 0x88E4,
    STATIC_READ = 0x88E5,
    STATIC_COPY = 0x88E6
};

class UniformBuffer {
public:

    explicit UniformBuffer(size_t size, uint32_t bindingPoint = 0, uint32_t offset = 0,
                           EAccessSpecifier accessSpecifier = EAccessSpecifier::DYNAMIC_DRAW);

    ~UniformBuffer();

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