// LuaBind_Config.cpp.cc
// created on 2021/12/11
// author @zoloypzuo
#include <sol/sol.hpp>
#include <refl.hpp>

#include "Core/LuaScript/LuaScriptManager.h"

#include "Config/WindowConfig.h"

REFL_AUTO(type(WindowConfig), field(title), field(window_x), field(window_y), field(
        windowed_width), field(windowed_height), field(fullscreen_width), field(fullscreen_height),
          field(refresh_rate), field(fullscreen), field(vsync))

void LuaBind_Config(sol::state &luaState) {
    auto *L = static_cast<Zelo::Core::LuaScript::LuaScriptManager *>(&luaState);
    L->registerType<WindowConfig>();
}