// ZeloGLPrerequisites.h
// created on 2021/6/3
// author @zoloypzuo
#pragma once

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
