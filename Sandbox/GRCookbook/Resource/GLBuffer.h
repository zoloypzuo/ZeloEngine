// GLBuffer.h
// created on 2021/11/30
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

class GLBuffer
{
public:
    GLBuffer(GLsizeiptr size, const void* data, GLbitfield flags);
    ~GLBuffer();

    GLuint getHandle() const { return handle_; }

private:
    GLuint handle_;
};
