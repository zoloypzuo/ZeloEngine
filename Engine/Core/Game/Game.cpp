// Game.cpp
// created on 2021/3/28
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Game.h"
#include "Core/OS/Time.h"
#include "Core/LuaScript/LuaScriptManager.h"

using namespace Zelo::Core::OS::TimeSystem;
using namespace Zelo::Core::LuaScript;

void Game::update() {
    rootScene->updateAll(Input::getSingletonPtr(), Time::getSingletonPtr()->getDeltaTime());
}

template<> Game *Singleton<Game>::msSingleton = nullptr;

Game *Game::getSingletonPtr() {
    return msSingleton;
}

Game::Game() = default;

Game::~Game() = default;

void Game::initialize() {
    rootScene = std::make_unique<Entity>();
}

void Game::finalize() {

}

void Game::addToScene(const std::shared_ptr<Entity> &entity) {
    rootScene->addChild(entity);
}

std::shared_ptr<Entity> Game::getRootNode() {
    return rootScene;
}

Entity *Game::CreateEntity() {
    m_entityGuid++; // acc guid counter
    const auto &entity = std::make_shared<Entity>(m_entityGuid);
    addToScene(entity);
    return entity.get();
}

int Game::SpawnPrefab(const std::string &name) {
    sol::state &L = LuaScriptManager::getSingleton();
    if(!L["PrefabExists"](name)){
        L["LoadPrefabFile"](name);
    }
//    Entity * entity = L["CallPrefabFn"](name);
    auto * entity = CreateEntity();
    // TODO mesh renderer
    auto prefab = m_luaPrefabMap.find(name)->second;
    auto &assets = prefab.assets;
    auto asset1 = assets[1];
    std::string file = asset1["file"];
    auto asset2 = assets[1];
    auto asset3 = assets[1];
    return entity->GetGUID();
}

void Game::RegisterPrefab(const std::string &name, sol::table &assets, sol::table &deps) {
    m_luaPrefabMap.emplace(name, LuaPrefab{name, assets, deps});
}

