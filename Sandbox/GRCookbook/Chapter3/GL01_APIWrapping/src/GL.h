#pragma once

#include "glcorearb.h"

using PFNGETGLPROC = void* (const char*);

struct GL4API
{
#	include "GLAPI.h"
};

namespace GL
{
    #include "GLAPI_.h"
}

void GetAPI4(GL4API* api, PFNGETGLPROC GetGLProc);
void InjectAPITracer4(GL4API* api);
