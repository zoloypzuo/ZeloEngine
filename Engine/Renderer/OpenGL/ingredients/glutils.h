#pragma once

#include "cookbookogl.h"
#include "ZeloPlatform.h"

namespace GLUtils
{
    int checkForOpenGLError(const char *, int);
    
    void dumpGLInfo(bool dumpExtensions = false);
    
    void ZELO_CALLBACK debugCallback(GLenum source, GLenum type, GLuint id,
                                     GLenum severity, GLsizei length, const GLchar * msg, const void * param );
}
