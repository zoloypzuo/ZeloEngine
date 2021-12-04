// LuaBind.cpp
// created on 2021/7/31
// author @zoloypzuo
#include <sol/sol.hpp>

void LuaBind_Global(sol::state &luaState);

void LuaBind_Entity(sol::state &luaState);

void LuaBind_Game(sol::state &luaState);

void LuaBind_UI(sol::state &luaState);

void LuaBind_ImGui(sol::state &luaState);

extern "C" {
LUALIB_API int luaopen_bit(lua_State *L);
}

void LuaBind_Main(sol::state &luaState) {
    LuaBind_Global(luaState);
    LuaBind_Entity(luaState);
    LuaBind_Game(luaState);
    LuaBind_UI(luaState);
    LuaBind_ImGui(luaState);

    luaState.require("bit", luaopen_bit);
}