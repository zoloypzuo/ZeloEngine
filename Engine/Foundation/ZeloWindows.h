#pragma once

#include "Foundation/ZeloPlatform.h"  // ZELO_PLATFORM_WINDOWS

#ifdef ZELO_PLATFORM_WINDOWS

// include windows before glad to fix:
// warning C4005: 'APIENTRY': macro redefinition
#ifndef NOMINMAX
#define NOMINMAX
#endif

#include <windows.h>

#endif