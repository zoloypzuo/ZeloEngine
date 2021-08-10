// LuaBind_Game.cpp
// created on 2021/8/9
// author @zoloypzuo
#include <sol/sol.hpp>
#include "Core/Game/Game.h"

void LuaBind_Game(sol::state &luaState) {
// @formatter:off
luaState.new_usertype<Game>("Sim"
,"CreateEntity", [](){ return Game::getSingletonPtr()->CreateEntity(); }
,"SpawnPrefab", [](const std::string &name){ return Game::getSingletonPtr()->SpawnPrefab(name); }
,"RegisterPrefab", [](const std::string &name, sol::table& assets, sol::table& deps){ return Game::getSingletonPtr()->RegisterPrefab(name, assets, deps); }
);

luaState.set("TheSim", Game::getSingletonPtr());
// @formatter: on
}
