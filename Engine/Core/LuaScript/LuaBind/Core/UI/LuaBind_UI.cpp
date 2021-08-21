// LuaBind_UI.cpp
// created on 2021/8/9
// author @zoloypzuo
#include <sol/sol.hpp>
#include "Core/UI/UIManager.h"

using namespace Zelo::Core::UI;

void LuaBind_UI(sol::state &luaState) {
// @formatter:off
luaState.new_enum<UIManager::EStyle>("EStyle",{
{"IM_CLASSIC_STYLE",UIManager::EStyle::IM_CLASSIC_STYLE},
{"IM_DARK_STYLE",   UIManager::EStyle::IM_DARK_STYLE},
{"IM_LIGHT_STYLE",  UIManager::EStyle::IM_LIGHT_STYLE},
{"DUNE_DARK",       UIManager::EStyle::DUNE_DARK},
{"ALTERNATIVE_DARK",UIManager::EStyle::ALTERNATIVE_DARK}
});

luaState.new_usertype<UIManager>("UIManager",
"GetSingletonPtr", &UIManager::getSingletonPtr,
"ApplyStyle", &UIManager::ApplyStyle,
"Dummy", []{}
);

// @formatter: on
}
