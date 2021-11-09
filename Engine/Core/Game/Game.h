// Game.h
// created on 2021/3/28
// author @zoloypzuo
#ifndef ZELOENGINE_GAME_H
#define ZELOENGINE_GAME_H

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"
#include "Core/RHI/Object/Camera.h"
#include "Core/ECS/Entity.h"
#include "Core/RHI/Object/ALight.h"

namespace Zelo::Core::Scene {
// TODO move namespace Zelo::Core::Game
// TODO rename to Scene
class Game : public Singleton<Game>, public IRuntimeModule {
public:
    struct FastAccessComponents {
        std::vector<MeshRenderer *> meshRenderers;
        std::vector<Camera *> cameras;
        std::vector<RHI::ALight *> lights;
    };

public:
    Game();

    ~Game() override;

    void initialize() override;

    void finalize() override;

    void update() override;

public:
    static Game *getSingletonPtr();

public:
    std::shared_ptr<ECS::Entity> getRootNode();

    const FastAccessComponents &getFastAccessComponents() const { return m_fastAccessComponents; }

public:
    GUID_t SpawnPrefab(const std::string &name);

    ECS::Entity *CreateEntity();

    void SetActiveCamera(PerspectiveCamera *camera);

    Camera *getActiveCamera() const { return m_activeCamera; }

private:
    void onComponentAdded(ECS::Component &component);

    void onComponentRemoved(ECS::Component &component);

private:
    std::shared_ptr<ECS::Entity> rootScene{};
    GUID_t m_entityGuidCounter{};

    FastAccessComponents m_fastAccessComponents;
    Camera *m_activeCamera{};
};
}

#endif //ZELOENGINE_GAME_H