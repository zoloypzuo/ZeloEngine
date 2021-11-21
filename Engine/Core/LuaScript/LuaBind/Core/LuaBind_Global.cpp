// LuaBind_Global.cpp
// created on 2021/8/6
// author @zoloypzuo
#include "Core/LuaScript/LuaScriptManager.h"
#include "Core/Resource/ResourceManager.h"
#include "Engine.h"
#include "GLSLBook/GLSLBookPlugins.h"

using namespace Zelo::Core::LuaScript;
using namespace Zelo::Core::Resource;

void LuaBind_Global(sol::state &luaState) {
luaState.new_usertype<Plugin>("Plugin",
"__Dummy", []{}
);
luaState.new_usertype<PostEffectPlugin>("PostEffectPlugin",
sol::base_classes, sol::bases<Plugin>(),
"__Dummy", []{}
);
luaState.set("SCRIPT_DIR", ResourceManager::getSingletonPtr()->getScriptDir().string());
luaState.set("RESOURCE_DIR", ResourceManager::getSingletonPtr()->getResourceDir().string());
luaState.set_function("print", LuaScriptManager::luaPrint);
luaState.set_function("install", [](Plugin *plugin) { Zelo::Engine::getSingletonPtr()->installPlugin(plugin); });
}
