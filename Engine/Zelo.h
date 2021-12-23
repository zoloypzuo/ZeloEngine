//
// Created by zuoyiping01 on 2021/4/2.
//

#ifndef ZELOENGINE_ZELO_H
#define ZELOENGINE_ZELO_H

#include "Foundation/ZeloPlatform.h"  // ZELO_PLATFORM_WINDOWS

#ifdef ZELO_PLATFORM_WINDOWS

// include windows before glad to fix:
// warning C4005: 'APIENTRY': macro redefinition
#include "Foundation/ZeloWindows.h"

#endif

// INCLUDE HEADERS HERE
#include "Engine.h"

#endif //ZELOENGINE_ZELO_H
