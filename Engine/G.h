// G.h
// created on 2022/1/10
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Foundation/ZeloEvent.h"
#include "Engine.h"

#include <deque>

namespace Zelo {
class G {
public:
    static Core::EventSystem::Event<uint32_t> s_FrameStartEvent;
    static Core::EventSystem::Event<uint32_t> s_FrameEndEvent;
    static std::deque<std::unique_ptr<Engine>> s_EngineList;
};
}
