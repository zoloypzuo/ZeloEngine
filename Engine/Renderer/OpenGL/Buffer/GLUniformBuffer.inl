// GLUniformBuffer.h
// created on 2021/10/28
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

namespace Zelo {
template<typename T>
inline void GLUniformBuffer::setSubData(const T &data, size_t offsetInOut) {
    bind();
    glBufferSubData(GL_UNIFORM_BUFFER, offsetInOut, sizeof(T), std::addressof(data));
    unbind();
}

template<typename T>
inline void GLUniformBuffer::setSubData(const T &data, std::reference_wrapper<size_t> offsetInOut) {
    bind();
    size_t dataSize = sizeof(T);
    glBufferSubData(GL_UNIFORM_BUFFER, offsetInOut.get(), dataSize, std::addressof(data));
    offsetInOut.get() += dataSize;
    unbind();
}
}
