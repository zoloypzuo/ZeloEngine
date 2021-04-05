// Engine.h
// created on 2021/3/28
// author @zoloypzuo

#ifndef ZELOENGINE_ENGINE_H
#define ZELOENGINE_ENGINE_H

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"
#include "Game.h"
#include "Window.h"
#include "Util/IniReader.h"


class Engine : public Singleton<Engine> {
public:
    explicit Engine(Game *game);

    virtual ~Engine();

    void start();

    const std::chrono::microseconds &getDeltaTime();

    Window *getWindow();

    INIReader *getConfig();

    std::filesystem::path getEngineDir();

    std::filesystem::path getAssetDir();

public:
    static Engine *getSingletonPtr();

private:
    class Impl;

    std::shared_ptr<Impl> pImpl_;
};


#endif //ZELOENGINE_ENGINE_H