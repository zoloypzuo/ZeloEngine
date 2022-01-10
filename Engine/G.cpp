// G.cpp
// created on 2022/1/10
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "G.h"

using namespace Zelo;
using namespace Zelo::Core::EventSystem;

Event<uint32_t> G::s_FrameStartEvent;
Event<uint32_t> G::s_FrameEndEvent;
