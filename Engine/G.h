// G.h
// created on 2022/1/10
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Foundation/ZeloEvent.h"
#include "Engine.h"

#include <deque>

namespace Zelo {
namespace G {
extern Core::EventSystem::Event<uint32_t> s_FrameStartEvent;
extern Core::EventSystem::Event<uint32_t> s_FrameEndEvent;
extern std::deque<std::unique_ptr<Engine>> s_EngineList;


};
}
