// SceneManager.cpp
// created on 2021/3/28
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "SceneManager.h"
#include "Core/OS/Time.h"
#include "Core/RHI/MeshGen/Plane.h"
#include "Renderer/OpenGL/Drawable/MeshRenderer.h"
#include "Core/RHI/Object/ALight.h"

using namespace Zelo::Core::OS;
using namespace Zelo::Core::LuaScript;
using namespace Zelo::Core::RHI;
using namespace Zelo::Core::ECS;
using namespace Zelo::Core::Scene;
using namespace Zelo::Renderer::OpenGL;

template<> SceneManager *Singleton<SceneManager>::msSingleton = nullptr;

namespace Zelo::Core::Scene {
void SceneManager::update() {
    m_rootScene->updateAll(Time::getSingletonPtr()->getDeltaTime());
}

SceneManager *SceneManager::getSingletonPtr() {
    return msSingleton;
}

SceneManager::SceneManager() = default;

SceneManager::~SceneManager() = default;

void SceneManager::initialize() {
    m_rootScene = std::make_unique<Entity>(m_entityGuidCounter);
}

void SceneManager::finalize() {

}

std::shared_ptr<Entity> SceneManager::getRootNode() {
    return m_rootScene;
}

void SceneManager::clear() {
    m_rootScene->getChildren().clear();
}

Entity *SceneManager::CreateEntity() {
    m_entityGuidCounter++; // acc guid counter
    const auto &entity = std::make_shared<Entity>(m_entityGuidCounter);
    m_rootScene->addChild(entity);

    entity->ComponentAddedEvent += std::bind(&SceneManager::onComponentAdded, this, std::placeholders::_1);
    entity->ComponentRemovedEvent += std::bind(&SceneManager::onComponentRemoved, this, std::placeholders::_1);

    return entity.get();
}

Zelo::GUID_t SceneManager::SpawnPrefab(const std::string &name) {
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

const SceneManager::FastAccessComponents &SceneManager::getFastAccessComponents() const {
    return m_fastAccessComponents;
}

ACamera *SceneManager::getActiveCamera() const {
    // try user assigned camera
    if (m_activeCamera) {
        return m_activeCamera;
    }
    // fallback to search camera in scene
    const auto &cameras = m_fastAccessComponents.cameras;
    if (const auto &it = Zelo::FindIf(cameras, [](auto p) { return p != nullptr; }); it != cameras.end()) {
        return *it;
    }
    // failed
    return nullptr;
}

// TODO fix sol base class 
void SceneManager::SetActiveCamera(PerspectiveCamera *camera) {
    m_activeCamera = camera;
}

ALight *SceneManager::getMainDirectionalLight() const {
    for (const auto &light: m_fastAccessComponents.lights) {
        if (light->GetType() == ELightType::DIRECTIONAL) {
            return light;
        }
    }
    return nullptr;
}

void SceneManager::onComponentAdded(Zelo::Core::ECS::Component &component) {
    if (auto *result = dynamic_cast<MeshRenderer *>(&component)) {
        m_fastAccessComponents.meshRenderers.push_back(result);
    }
    if (auto *result = dynamic_cast<ACamera *>(&component)) {
        m_fastAccessComponents.cameras.push_back(result);
    }
    if (auto *result = dynamic_cast<ALight *>(&component)) {
        m_fastAccessComponents.lights.push_back(result);
    }
}

void SceneManager::onComponentRemoved(Zelo::Core::ECS::Component &component) {
    if (auto *result = dynamic_cast<MeshRenderer *>(&component);
            !m_fastAccessComponents.meshRenderers.empty() && result) {
        Zelo::Erase(m_fastAccessComponents.meshRenderers, result);
    }
    if (auto *result = dynamic_cast<ACamera *>(&component);
            !m_fastAccessComponents.cameras.empty() && result) {
        Zelo::Erase(m_fastAccessComponents.cameras, result);
        if (m_activeCamera == result) {
            m_activeCamera = nullptr;
        }
    }
    if (auto *result = dynamic_cast<ALight *>(&component);
            !m_fastAccessComponents.lights.empty() && result) {
        Zelo::Erase(m_fastAccessComponents.lights, result);
    }
}
}