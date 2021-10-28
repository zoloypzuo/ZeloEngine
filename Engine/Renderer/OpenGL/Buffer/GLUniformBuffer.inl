// GLUniformBuffer.h
// created on 2021/10/28
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

namespace Zelo {
template<typename T>
inline void GLUniformBuffer::SetSubData(const T &data, size_t offsetInOut) {
    Bind();
    glBufferSubData(GL_UNIFORM_BUFFER, offsetInOut, sizeof(T), std::addressof(data));
    Unbind();
}

template<typename T>
inline void GLUniformBuffer::SetSubData(const T &data, std::reference_wrapper <size_t> offsetInOut) {
    Bind();
    size_t dataSize = sizeof(T);
    glBufferSubData(GL_UNIFORM_BUFFER, offsetInOut.get(), dataSize, std::addressof(data));
    offsetInOut.get() += dataSize;
    Unbind();
}
}
