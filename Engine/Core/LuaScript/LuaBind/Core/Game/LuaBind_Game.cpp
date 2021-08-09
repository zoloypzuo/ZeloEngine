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
// TODO pimpl
// TODO 维护prefab表，先调用fn，再用asset去构造Renderer组件
//,"RegisterPrefab", [](const std::string &name){ return Game::getSingletonPtr()->SpawnPrefab(name); }
);

luaState.set("TheSim", Game::getSingletonPtr());
// @formatter: on
}
