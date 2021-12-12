// LuaBind_PreMain.cpp
// created on 2021/12/12
// author @zoloypzuo
#include <sol/sol.hpp>

#include "Foundation/ZeloPlugin.h"
#include "Core/Resource/ResourceManager.h"
#include "Core/LuaScript/LuaScriptManager.h"
#include "Engine.h"

using namespace Zelo;
using namespace Zelo::Core::LuaScript;
using namespace Zelo::Core::Resource;

void LuaBind_PreMain(sol::state &luaState) {
// @formatter:off
luaState.new_usertype<Plugin>("Plugin");

luaState.set("CONFIG_DIR", ResourceManager::getSingletonPtr()->getConfigDir().string());
luaState.set("SCRIPT_DIR", ResourceManager::getSingletonPtr()->getScriptDir().string());
luaState.set("RESOURCE_DIR", ResourceManager::getSingletonPtr()->getResourceDir().string());
luaState.set_function("print", LuaScriptManager::luaPrint);
luaState.set_function("install", [](Plugin *plugin) { Engine::getSingletonPtr()->installPlugin(plugin); });
// @formatter:on
}
