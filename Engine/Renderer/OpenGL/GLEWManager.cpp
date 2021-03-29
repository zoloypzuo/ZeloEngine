// GLEWManager.cpp
// created on 2021/3/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLEWManager.h"

#ifndef ANDROID

#include <gl/glew.h>

#endif

GLEWManager::GLEWManager() {
#ifndef ANDROID
    glewExperimental = GL_TRUE;
    GLenum err = glewInit();

    if (GLEW_OK != err) {
        spdlog::error("GLEW failed to initalize: %s", glewGetErrorString(err));
    }

    spdlog::info("Status: Using GLEW %s", glewGetString(GLEW_VERSION));
#endif
}

GLEWManager::~GLEWManager() = default;
