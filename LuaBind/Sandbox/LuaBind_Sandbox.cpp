// LuaBind_Sandbox.cpp
// created on 2021/12/5
// author @zoloypzuo
#include "Engine.h"

#include "Craft//CraftPlugin.h"
#include "GLSLBook/GLSLBookPlugins.h"
#include "_Template//TemplatePlugins.h"

using namespace Zelo;

void LuaBind_Sandbox(sol::state &luaState) {
// @formatter:off
luaState.new_usertype<EdgePipelinePlugin>("EdgePipelinePlugin",sol::base_classes, sol::bases<Plugin>());
luaState.new_usertype<BlurPipelinePlugin>("BlurPipelinePlugin",sol::base_classes, sol::bases<Plugin>());
luaState.new_usertype<BloomPipelinePlugin>("BloomPipelinePlugin",sol::base_classes, sol::bases<Plugin>());
luaState.new_usertype<ShadowMapPipelinePlugin>("ShadowMapPipelinePlugin",sol::base_classes, sol::bases<Plugin>());
luaState.new_usertype<CraftPlugin>("CraftPlugin",sol::base_classes, sol::bases<Plugin>());
luaState.new_usertype<TemplatePlugin>("TemplatePlugin",sol::base_classes, sol::bases<Plugin>());
// @formatter:on
}