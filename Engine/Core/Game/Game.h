// Game.h
// created on 2021/3/28
// author @zoloypzuo
#ifndef ZELOENGINE_GAME_H
#define ZELOENGINE_GAME_H

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"
#include "Core/RHI/Object/Camera.h"
#include "Core/ECS/Entity.h"

class Game : public Singleton<Game>, public IRuntimeModule {
public:
    Game();

    ~Game() override;

    void initialize() override;

    void finalize() override;

    void update() override;

public:
    static Game *getSingletonPtr();

public:
    std::shared_ptr<Zelo::Core::ECS::Entity> getRootNode();

public:
    Zelo::GUID_t SpawnPrefab(const std::string &name);

    Zelo::Core::ECS::Entity *CreateEntity();

    void SetActiveCamera(PerspectiveCamera *camera);

private:
    std::shared_ptr<Zelo::Core::ECS::Entity> rootScene{};
    Zelo::GUID_t m_entityGuidCounter{};
};

#endif //ZELOENGINE_GAME_H