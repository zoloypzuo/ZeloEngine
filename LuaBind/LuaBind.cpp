// LuaBind.cpp
// created on 2021/7/31
// author @zoloypzuo
#include <sol/sol.hpp>

void LuaBind_Config(sol::state &luaState);

void LuaBind_Core(sol::state &luaState);

void LuaBind_Sandbox(sol::state &luaState);

void LuaBind_ThirdParty(sol::state &luaState);

void LuaBind_Main(sol::state &luaState) {
    LuaBind_Config(luaState);
    LuaBind_ThirdParty(luaState);
    LuaBind_Core(luaState);
    LuaBind_Sandbox(luaState);
}