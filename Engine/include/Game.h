// Game.h
// created on 2021/3/28
// author @zoloypzuo

#ifndef ZELOENGINE_GAME_H
#define ZELOENGINE_GAME_H

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"

class Entity;

class Game : public Singleton<Game> {
public:
    Game();

    ~Game();

    void update();

public:
    static Game &getSingleton();

    static Game *getSingletonPtr();

    std::shared_ptr<Entity> getRootNode();

    virtual void init_script();

private:
    class Impl;

    std::unique_ptr<Impl> pImpl_;
};


#endif //ZELOENGINE_GAME_H