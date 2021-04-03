// Engine.h
// created on 2021/3/28
// author @zoloypzuo

#ifndef ZELOENGINE_ENGINE_H
#define ZELOENGINE_ENGINE_H

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"
#include "Game.h"

class Engine : public Singleton<Engine> {
public:
    Engine(Game * game);

    virtual ~Engine();

    void start();

    const std::chrono::microseconds &getDeltaTime();

public:
    static Engine *getSingletonPtr();

private:
    class Impl;

    std::shared_ptr<Impl> pImpl_;
};


#endif //ZELOENGINE_ENGINE_H