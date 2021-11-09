// LuaBind_Game.cpp
// created on 2021/8/9
// author @zoloypzuo
#include <sol/sol.hpp>
#include "Core/Scene/SceneManager.h"

using namespace Zelo::Core::Scene;

void LuaBind_Game(sol::state &luaState) {
// @formatter:off
luaState.new_usertype<SceneManager>("Game",
"CreateEntity", &SceneManager::CreateEntity,
"SpawnPrefab", &SceneManager::SpawnPrefab,
"GetSingletonPtr", &SceneManager::getSingletonPtr,
"SetActiveCamera", &SceneManager::SetActiveCamera,
"__Dummy", []{}
);
// @formatter: on
}
