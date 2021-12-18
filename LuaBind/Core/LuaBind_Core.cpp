// LuaBind_Core.cpp
// created on 2021/8/6
// author @zoloypzuo
#include <sol/sol.hpp>

void LuaBind_Entity(sol::state &luaState);

void LuaBind_RHI(sol::state &luaState);

void LuaBind_Scene(sol::state &luaState);

void LuaBind_UI(sol::state &luaState);

void LuaBind_Core(sol::state &luaState) {
    LuaBind_Entity(luaState);
    LuaBind_RHI(luaState);
    LuaBind_Scene(luaState);
    LuaBind_UI(luaState);
}
