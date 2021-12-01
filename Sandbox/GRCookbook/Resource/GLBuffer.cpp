// GLBuffer.cpp
// created on 2021/11/30
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLBuffer.h"


GLBuffer::GLBuffer(GLsizeiptr size, const void* data, GLbitfield flags)
{
    glCreateBuffers(1, &handle_);
    glNamedBufferStorage(handle_, size, data, flags);
}

GLBuffer::~GLBuffer()
{
    glDeleteBuffers(1, &handle_);
}
