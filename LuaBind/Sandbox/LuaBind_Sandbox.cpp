// LuaBind_Sandbox.cpp
// created on 2021/12/5
// author @zoloypzuo
#include "Engine.h"
#include "Core/LuaScript/LuaScriptManager.h"
#include "Core/Resource/ResourceManager.h"

#include "_Template//TemplatePlugins.h"
#include "GLSLBook/GLSLBookPlugins.h"
#include "Craft//CraftPlugin.h"
#include "GRCookbook/GRCookbookPlugins.h"
#include "GRCookbook/FinalScenePlugin.h"

using namespace Zelo;

void LuaBind_Sandbox(sol::state &luaState) {
// @formatter:off
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
// @formatter:on
}