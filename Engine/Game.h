// Game.h
// created on 2021/3/28
// author @zoloypzuo

#ifndef ZELOENGINE_GAME_H
#define ZELOENGINE_GAME_H

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"
#include "Renderer/OpenGL/Camera.h"

class Entity;

class Game : public Singleton<Game>, IRuntimeModule {
public:
    Game();

    ~Game() override;

    void initialize() override;

    void finalize() override;

    void update() override;

public:
    static Game *getSingletonPtr();

    std::shared_ptr<Entity> getRootNode();

    void addToScene(const std::shared_ptr<Entity> &entity);

private:
    class Impl;

    std::shared_ptr<Entity> rootScene;
    std::shared_ptr<PerspectiveCamera> primary_camera;
    std::shared_ptr<PerspectiveCamera> primary_camera2;
};


#endif //ZELOENGINE_GAME_H