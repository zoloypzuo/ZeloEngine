// LuaBind.cpp
// created on 2021/7/31
// author @zoloypzuo
#include <sol/sol.hpp>

void LuaBind_Global(sol::state &luaState);

void LuaBind_Entity(sol::state &luaState);

void LuaBind_Main(sol::state &luaState) {
    LuaBind_Global(luaState);
    LuaBind_Entity(luaState);
}