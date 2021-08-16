// ZeloGLPrerequisites.h
// created on 2021/6/3
// author @zoloypzuo
#pragma once

#include <glad/glad.h>

#define FORCE_DEDICATED_GPU \
extern "C"\
{\
    __declspec(dllexport) unsigned long NvOptimusEnablement = 0x00000001;\
}
