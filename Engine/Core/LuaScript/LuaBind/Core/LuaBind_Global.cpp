// LuaBind_Global.cpp
// created on 2021/8/6
// author @zoloypzuo
#include "Engine.h"
#include "Core/LuaScript/LuaScriptManager.h"
#include "Core/Resource/ResourceManager.h"
#include "_Template//TemplatePlugins.h"
#include "GLSLBook/GLSLBookPlugins.h"
#include "Craft//CraftPlugin.h"
#include "GRCookbook/GRCookbookPlugins.h"
#include "GRCookbook/FinalScenePlugin.h"

using namespace Zelo::Core::LuaScript;
using namespace Zelo::Core::Resource;

void LuaBind_Global(sol::state &luaState) {
// @formatter:off
luaState.new_usertype<Plugin>("Plugin",
"__Dummy", []{}
);
luaState.new_usertype<EdgePipelinePlugin>("EdgePipelinePlugin",
sol::base_classes, sol::bases<Plugin>(),
"__Dummy", []{}
);
luaState.new_usertype<BlurPipelinePlugin>("BlurPipelinePlugin",
sol::base_classes, sol::bases<Plugin>(),
"__Dummy", []{}
);
luaState.new_usertype<BloomPipelinePlugin>("BloomPipelinePlugin",
sol::base_classes, sol::bases<Plugin>(),
"__Dummy", []{}
);
luaState.new_usertype<ShadowMapPipelinePlugin>("ShadowMapPipelinePlugin",
sol::base_classes, sol::bases<Plugin>(),
"__Dummy", []{}
);
luaState.new_usertype<CraftPlugin>("CraftPlugin",
sol::base_classes, sol::bases<Plugin>(),
"__Dummy", []{}
);
luaState.new_usertype<Ch5MeshRendererPlugin>("Ch5MeshRendererPlugin",
sol::base_classes, sol::bases<Plugin>(),
"__Dummy", []{}
);
luaState.new_usertype<TemplatePlugin>("TemplatePlugin",
sol::base_classes, sol::bases<Plugin>(),
"__Dummy", []{}
);
luaState.new_usertype<Ch6PBRPlugin>("Ch6PBRPlugin",
sol::base_classes, sol::bases<Plugin>(),
"__Dummy", []{}
);
luaState.new_usertype<Ch7LargeScenePlugin>("Ch7LargeScenePlugin",
sol::base_classes, sol::bases<Plugin>(),
"__Dummy", []{}
);
luaState.new_usertype<FinalScene::Ch10FinalPlugin>("Ch10FinalPlugin",
sol::base_classes, sol::bases<Plugin>(),
"__Dummy", []{}
);
luaState.set("SCRIPT_DIR", ResourceManager::getSingletonPtr()->getScriptDir().string());
luaState.set("RESOURCE_DIR", ResourceManager::getSingletonPtr()->getResourceDir().string());
luaState.set_function("print", LuaScriptManager::luaPrint);
luaState.set_function("install", [](Plugin *plugin) { Zelo::Engine::getSingletonPtr()->installPlugin(plugin); });
// @formatter:on
}
