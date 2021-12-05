// LuaBind.cpp
// created on 2021/7/31
// author @zoloypzuo
#include <sol/sol.hpp>

void LuaBind_Core(sol::state &luaState);

void LuaBind_Sandbox(sol::state &luaState);

void LuaBind_ImGui(sol::state &luaState);

extern "C" {
LUALIB_API int luaopen_bit(lua_State *L);
}

void LuaBind_Main(sol::state &luaState) {
    LuaBind_ImGui(luaState);
    LuaBind_Core(luaState);
    LuaBind_Sandbox(luaState);

    luaState.require("bit", luaopen_bit);
}