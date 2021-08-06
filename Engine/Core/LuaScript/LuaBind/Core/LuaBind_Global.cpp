// LuaBind_Global.cpp
// created on 2021/8/6
// author @zoloypzuo
#include "Core/LuaScript/LuaScriptManager.h"
using namespace Zelo::Core::LuaScript;

void LuaBind_Global(sol::state &luaState){
    luaState.set_function("print", LuaScriptManager::luaPrint);
}
