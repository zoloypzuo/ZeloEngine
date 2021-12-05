// LuaBind_Core.cpp
// created on 2021/8/6
// author @zoloypzuo
#include "Engine.h"
#include "Core/LuaScript/LuaScriptManager.h"
#include "Core/Resource/ResourceManager.h"


using namespace Zelo::Core::LuaScript;
using namespace Zelo::Core::Resource;


void LuaBind_Entity(sol::state &luaState);

void LuaBind_Game(sol::state &luaState);

void LuaBind_UI(sol::state &luaState);

void LuaBind_ImGui(sol::state &luaState);

void LuaBind_Core(sol::state &luaState) {
// @formatter:off
luaState.new_usertype<Plugin>("Plugin",
"__Dummy", []{}
);

luaState.set("SCRIPT_DIR", ResourceManager::getSingletonPtr()->getScriptDir().string());
luaState.set("RESOURCE_DIR", ResourceManager::getSingletonPtr()->getResourceDir().string());
luaState.set_function("print", LuaScriptManager::luaPrint);
luaState.set_function("install", [](Plugin *plugin) { Zelo::Engine::getSingletonPtr()->installPlugin(plugin); });
// @formatter:on

    LuaBind_Entity(luaState);
    LuaBind_Game(luaState);
    LuaBind_UI(luaState);
    LuaBind_ImGui(luaState);
}
