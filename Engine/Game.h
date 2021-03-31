// Game.h
// created on 2021/3/28
// author @zoloypzuo

#ifndef ZELOENGINE_GAME_H
#define ZELOENGINE_GAME_H

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"

class Entity;

class Game : public Singleton<Game>, IRuntimeModule {
public:
    Game();

    ~Game() override;

    void initialize() override;

    void finalize() override;

    void update() override;

public:
    static Game &getSingleton();

    static Game *getSingletonPtr();

    std::shared_ptr<Entity> getRootNode();

    void addToScene(std::shared_ptr<Entity> entity);

private:
    class Impl;

    std::shared_ptr<Entity> rootScene;
};


#endif //ZELOENGINE_GAME_H