// GLMesh9.cpp
// created on 2021/12/1
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLMesh9.h"

GLIndirectBuffer::GLIndirectBuffer(size_t maxDrawCommands)
        : bufferIndirect_(sizeof(DrawElementsIndirectCommand) * maxDrawCommands, nullptr, GL_DYNAMIC_STORAGE_BIT)
        , drawCommands_(maxDrawCommands)
{}

GLuint GLIndirectBuffer::getHandle() const { return bufferIndirect_.getHandle(); }

void GLIndirectBuffer::uploadIndirectBuffer() {
    glNamedBufferSubData(bufferIndirect_.getHandle(), 0, sizeof(DrawElementsIndirectCommand) * drawCommands_.size(), drawCommands_.data());
}

void
GLIndirectBuffer::selectTo(GLIndirectBuffer &buf, const std::function<bool(const DrawElementsIndirectCommand &)> &pred) {
    buf.drawCommands_.clear();
    for (const auto& c : drawCommands_)
    {
        if (pred(c))
            buf.drawCommands_.push_back(c);
    }
    buf.uploadIndirectBuffer();
}
