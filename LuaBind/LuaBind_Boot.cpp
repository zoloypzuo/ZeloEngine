// LuaBind_PreMain.cpp
// created on 2021/12/12
// author @zoloypzuo
#include <sol/sol.hpp>

#include "Core/LuaScript/LuaScriptManager.h"
#include "Core/OS/Window.h"
#include "Core/Resource/ResourceManager.h"
#include "Foundation/ZeloPlugin.h"

using namespace Zelo;
using namespace Zelo::Core::LuaScript;
using namespace Zelo::Core::Resource;

void LuaBind_Boot(sol::state &luaState) {
    luaState.new_usertype<Plugin>("Plugin");

    luaState.set("CONFIG_DIR", ResourceManager::getSingletonPtr()->getConfigDir().string());
    luaState.set("SCRIPT_DIR", ResourceManager::getSingletonPtr()->getScriptDir().string());
    luaState.set("RESOURCE_DIR", ResourceManager::getSingletonPtr()->getResourceDir().string());

    luaState.set_function("print", LuaScriptManager::luaLogDebug);
    luaState.set_function("logDebug", LuaScriptManager::luaLogDebug);
    luaState.set_function("logError", LuaScriptManager::luaLogError);
    luaState.set_function("Quit", []() { Zelo::Core::OS::Window::getSingletonPtr()->setQuit(); });
}
