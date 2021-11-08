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

#include "Core/Parser/MeshLoader.h"

#include "Core/RHI/RenderSystem.h"

using namespace Zelo::Core::OS::TimeSystem;
using namespace Zelo::Core::LuaScript;
using namespace Zelo::Core::RHI;
using namespace Zelo::Renderer::OpenGL;
using namespace Zelo::Parser;
using namespace Zelo::Core::ECS;

void Game::update() {
    rootScene->updateAll(Time::getSingletonPtr()->getDeltaTime());
}

template<> Game *Singleton<Game>::msSingleton = nullptr;

Game *Game::getSingletonPtr() {
    return msSingleton;
}

Game::Game() = default;

Game::~Game() = default;

void Game::initialize() {
    rootScene = std::make_unique<Entity>(m_entityGuidCounter);
}

void Game::finalize() {

}

std::shared_ptr<Entity> Game::getRootNode() {
    return rootScene;
}

Entity *Game::CreateEntity() {
    m_entityGuidCounter++; // acc guid counter
    const auto &entity = std::make_shared<Entity>(m_entityGuidCounter);
    rootScene->addChild(entity);

    entity->ComponentAddedEvent += std::bind(&Game::onComponentAdded, this, std::placeholders::_1);
    entity->ComponentRemovedEvent += std::bind(&Game::onComponentRemoved, this, std::placeholders::_1);

    return entity.get();
}

Zelo::GUID_t Game::SpawnPrefab(const std::string &name) {
    auto &L = LuaScriptManager::getSingleton();
    sol::table prefab = L["Prefabs"][name];
    sol::protected_function fn(prefab["fn"], L["GlobalErrorHandler"]);
    auto functionResult = fn();
    if (!functionResult.valid()) {
        // call failed
        sol::error err = functionResult;
        ZELO_ASSERT(false, err.what());
        return 0;
    }
    // call succeeded
    sol::table entityScript = functionResult;
    Entity &entity = entityScript["entity"];
    return entity.GetGUID();
}

// TODO fix sol base class 
void Game::SetActiveCamera(PerspectiveCamera *camera) {
    RenderSystem::getSingletonPtr()->setActiveCamera(camera);
}

void Game::onComponentAdded(Zelo::Core::ECS::Component &component) {
    if (auto *result = dynamic_cast<MeshRenderer *>(&component)) {
        m_fastAccessComponents.meshRenderers.push_back(result);
    }
    if (auto *result = dynamic_cast<Camera *>(&component)) {
        m_fastAccessComponents.cameras.push_back(result);
    }
    if (auto *result = dynamic_cast<LightPlain *>(&component)) {
        m_fastAccessComponents.lights.push_back(result);
    }
}

void Game::onComponentRemoved(Zelo::Core::ECS::Component &component) {
    if (auto *result = dynamic_cast<MeshRenderer *>(&component)) {
        Zelo::Erase(m_fastAccessComponents.meshRenderers, result);
    }
    if (auto *result = dynamic_cast<Camera *>(&component)) {
        Zelo::Erase(m_fastAccessComponents.cameras, result);
    }
    if (auto *result = dynamic_cast<LightPlain *>(&component)) {
        Zelo::Erase(m_fastAccessComponents.lights, result);
    }
}
