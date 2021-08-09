// LuaBind_Global.cpp
// created on 2021/8/6
// author @zoloypzuo
#include "Core/LuaScript/LuaScriptManager.h"
#include "Core/Resource/ResourceManager.h"
#include "Core/Game/Game.h"

using namespace Zelo::Core::Resource;
using namespace Zelo::Core::LuaScript;

void LuaBind_Global(sol::state &luaState){
    set("SCRIPT_DIR", ResourceManager::getSingletonPtr()->getScriptDir().string());
    luaState.set_function("print", LuaScriptManager::luaPrint);
}
