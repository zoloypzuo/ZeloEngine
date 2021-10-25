// LuaBind_Global.cpp
// created on 2021/8/6
// author @zoloypzuo
#include "Core/LuaScript/LuaScriptManager.h"
#include "Core/Resource/ResourceManager.h"

using namespace Zelo::Core::LuaScript;
using namespace Zelo::Core::Resource;

void LuaBind_Global(sol::state &luaState) {
    luaState.set("SCRIPT_DIR", ResourceManager::getSingletonPtr()->getScriptDir().string());
    luaState.set("RESOURCE_DIR", ResourceManager::getSingletonPtr()->getResourceDir().string());
    luaState.set_function("print", LuaScriptManager::luaPrint);
}
