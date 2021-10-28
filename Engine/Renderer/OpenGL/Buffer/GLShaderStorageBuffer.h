// GLShaderStorageBuffer.h
// created on 2021/10/29
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/RHI/Const/EAccessSpecifier.h"

namespace Zelo {
class GLShaderStorageBuffer {
public:

    explicit GLShaderStorageBuffer(Core::RHI::EAccessSpecifier accessSpecifier);

    ~GLShaderStorageBuffer();

    void Bind(uint32_t bindingPoint);

    void Unbind() const;

    template<typename T>
    void SendBlocks(T *data, size_t size);

private:
    uint32_t m_bufferID{};
    uint32_t m_bindingPoint = 0;
};
}

#include "GLShaderStorageBuffer.inl"
