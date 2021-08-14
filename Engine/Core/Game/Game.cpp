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

std::shared_ptr<Entity> Game::getRootNode() {
    return rootScene;
}

Entity *Game::CreateEntity() {
    m_entityGuid++; // acc guid counter
    const auto &entity = std::make_shared<Entity>(m_entityGuid);
    rootScene->addChild(entity);
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
        sol::optional<sol::table> meshGenAsset = assets["mesh_gen"];
        if(meshGenAsset.has_value()){
            std::string meshGenFile = assets["mesh_gen"]["file"];
            
            auto planeMeshGen = Plane();
            auto planeMesh = std::make_shared<GLMesh>(planeMeshGen);
            
            std::string diffuseTexName = assets["diffuse"]["file"];
            std::string normalTexName = assets["normal"]["file"];
            std::string specularTexName = assets["specular"]["file"];

            auto brickMat = std::make_shared<GLMaterial>(
                std::make_shared<GLTexture>(Zelo::Resource(diffuseTexName)),
                std::make_shared<GLTexture>(Zelo::Resource(normalTexName)),
                std::make_shared<GLTexture>(Zelo::Resource(specularTexName))
            );
            
            entity.addComponent<MeshRenderer>(planeMesh, brickMat);
        }

        sol::optional<sol::table> meshAsset = assets["mesh"];
        if(meshAsset.has_value()){
            std::string meshAssetFile = assets["mesh"]["file"];
            MeshLoader meshLoader(meshAssetFile);
            auto meshRenderDataList = meshLoader.getMeshRendererData();
            for(auto &meshRenderData: meshRenderDataList){
                entity.addComponent<MeshRenderer>(meshRenderData.mesh, meshRenderData.material);
            }
        }
        
        return entity.GetGUID();
    }
    else {
        // Call failed
        sol::error err = result;
        ZELO_ASSERT(false, err.what()); 
    }
    return 0;
}

// TODO fix sol base class 
void Game::SetActiveCamera(PerspectiveCamera *camera){
    RenderSystem::getSingletonPtr()->setActiveCamera(camera);
}
