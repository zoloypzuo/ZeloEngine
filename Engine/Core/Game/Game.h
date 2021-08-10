// Game.h
// created on 2021/3/28
// author @zoloypzuo

#ifndef ZELOENGINE_GAME_H
#define ZELOENGINE_GAME_H

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"
#include "Core/RHI/Object/Camera.h"
#include "Core/ECS/Entity.h"

#include <sol/sol.hpp>

class Game : public Singleton<Game>, public IRuntimeModule {
public:
    Game();

    ~Game() override;

    void initialize() override;

    void finalize() override;

    void update() override;

    void SpawnPrefab(const std::string &name);

    void RegisterPrefab(const std::string &name, sol::table &assets, sol::table &deps);

public:
    static Game *getSingletonPtr();

    std::shared_ptr<Entity> getRootNode();

    void addToScene(const std::shared_ptr<Entity> &entity);

    Entity *CreateEntity();

private:
    std::shared_ptr<Entity> rootScene{};
    int m_entityGuid{};
};

#endif //ZELOENGINE_GAME_H