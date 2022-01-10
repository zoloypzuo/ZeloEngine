// G.h
// created on 2022/1/10
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Foundation/ZeloEvent.h"

namespace Zelo {
class G {
public:
    static Core::EventSystem::Event<uint32_t> s_FrameStartEvent;
    static Core::EventSystem::Event<uint32_t> s_FrameEndEvent;
};
}
