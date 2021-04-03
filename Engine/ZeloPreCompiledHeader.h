//
// Created by zoloypzuo on 2021/3/28.
//

#ifndef ZELOENGINE_ZELOPRECOMPILEDHEADER_H
#define ZELOENGINE_ZELOPRECOMPILEDHEADER_H

#include "ZeloPlatform.h"
// This ignores all warnings raised inside External headers
#pragma warning(push, 0)

#include <spdlog/spdlog.h>
#include <spdlog/fmt/ostr.h>

#pragma warning(pop)

#include "G.h"
#include "Mathf.h"

#ifdef ZELO_PLATFORM_WINDOWS

//#include <Windows.h> TODO pch

#endif

// debug break
#ifdef ZELO_DEBUG
  #if defined(ZELO_PLATFORM_WINDOWS)
    #define ZELO_DEBUGBREAK() __debugbreak()
  #elif defined(ZELO_PLATFORM_LINUX)
    #include <signal.h>
    #define ZELO_DEBUGBREAK() raise(SIGTRAP)
  #else
    #error "Platform doesn't support debugbreak yet!"
  #endif
  #define ZELO_ENABLE_ASSERTS
#else
  #define ZELO_DEBUGBREAK()
#endif


#endif //ZELOENGINE_ZELOPRECOMPILEDHEADER_H
