// LuaBind_Game.cpp
// created on 2021/8/9
// author @zoloypzuo
#include <sol/sol.hpp>
#include "Core/Game/Game.h"

void LuaBind_Game(sol::state &luaState) {
// @formatter:off
luaState.new_usertype<Game>("Game",
"CreateEntity", &Game::CreateEntity,
"SpawnPrefab", &Game::SpawnPrefab,
"GetSingletonPtr", &Game::getSingletonPtr,
"Dummy", []{}
);

luaState.set("TheSim", Game::getSingletonPtr());
// @formatter: on
}
