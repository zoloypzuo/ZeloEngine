#pragma once

#include "glcorearb.h"

using PFNGETGLPROC = void* (const char*);


namespace GL
{
    #include "GLAPI_.h"
}

void LoadAPITracer(PFNGETGLPROC GetGLProc);
