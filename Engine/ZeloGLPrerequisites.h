// ZeloGLPrerequisites.h
// created on 2021/6/3
// author @zoloypzuo
#pragma once

#include "Foundation/ZeloPlatform.h"  // ZELO_PLATFORM_WINDOWS

#ifdef ZELO_PLATFORM_WINDOWS

// include windows before glad to fix:
// warning C4005: 'APIENTRY': macro redefinition
#include "Foundation/ZeloWindows.h"

#endif

#ifdef ZELO_GL_TRACER

#include "Renderer/OpenGL/Tracer/GLTracer.h"

#else

#include <glad/glad.h>

#endif

#define FORCE_DEDICATED_GPU \
extern "C"\
{\
    __declspec(dllexport) unsigned long NvOptimusEnablement = 0x00000001;\
}

namespace GL {
inline void EnableVertexAttribArray(GLuint index) {
    if (index >= GL_MAX_VERTEX_ATTRIBS) return;
    glEnableVertexAttribArray(index);
}

inline void DisableVertexAttribArray(GLuint index) {
    if (index >= GL_MAX_VERTEX_ATTRIBS) return;
    glDisableVertexAttribArray(index);
}

inline void
VertexAttribPointer(GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const void *pointer) {
    if (index >= GL_MAX_VERTEX_ATTRIBS) return;
    glVertexAttribPointer(index, size, type, normalized, stride, pointer);
}
}
