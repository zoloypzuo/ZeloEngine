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


#endif //ZELOENGINE_ZELOPRECOMPILEDHEADER_H
