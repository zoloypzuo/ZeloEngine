// Game.cpp
// created on 2021/3/28
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Game.h"
#include "Core/OS/Time.h"
#include "Core/LuaScript/LuaScriptManager.h"

#include "Core/RHI/MeshGen/Plane.h"
#include "Renderer/OpenGL/Drawable/MeshRenderer.h"
#include "Renderer/OpenGL/Resource/GLMesh.h"
#include "Renderer/OpenGL/Resource/GLMaterial.h"

using namespace Zelo::Core::OS::TimeSystem;
using namespace Zelo::Core::LuaScript;
using namespace Zelo::Core::RHI;
using namespace Zelo::Renderer::OpenGL;

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
    auto &L = LuaScriptManager::getSingleton();
    sol::table prefab = L["Prefabs"][name];
    sol::protected_function fn(prefab["fn"], L["GlobalErrorHandler"]);

    sol::protected_function_result result = fn();
    if (result.valid()) {
        // Call succeeded
        sol::table entityScript = result;
        Entity & entity = entityScript["entity"];
        
        sol::table assets = prefab["assets"];
        std::string diffuseTexName = assets["diffuse"]["file"];
        std::string normalTexName = assets["normal"]["file"];
        std::string specularTexName = assets["specular"]["file"];

        auto planeMeshGen = Plane();
        
        auto planeMesh = std::make_shared<GLMesh>(planeMeshGen);
        auto brickMat = std::make_shared<GLMaterial>(
            std::make_shared<GLTexture>(Zelo::Resource(diffuseTexName)),
            std::make_shared<GLTexture>(Zelo::Resource(normalTexName)),
            std::make_shared<GLTexture>(Zelo::Resource(specularTexName)));

        entity.addComponent<MeshRenderer>(planeMesh, brickMat);
        return entity.GetGUID();
    }
    else {
        // Call failed
        sol::error err = result;
        std::string what = err.what();
        spdlog::error(what);
    }
    return 0;
}
