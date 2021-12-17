// GLShaderStorageBuffer.h
// created on 2021/10/29
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

namespace Zelo {
template<typename T>
inline void GLShaderStorageBuffer::sendBlocks(T *data, size_t size) const {
    glBindBuffer(GL_SHADER_STORAGE_BUFFER, m_bufferID);
    glBufferData(GL_SHADER_STORAGE_BUFFER, size, data, GL_DYNAMIC_DRAW);
    glBindBuffer(GL_SHADER_STORAGE_BUFFER, 0);
}

template<typename T>
void GLShaderStorageBuffer::sendBlocks(std::vector<T> data) const {
    sendBlocks(data.data(), data.size() * sizeof(T));
}
}
