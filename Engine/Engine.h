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

#include "Window.h"
#include "Game.h"
#include "Renderer/OpenGL/GLManager.h"
#include "Renderer/OpenGL/ForwardRenderer.h"
#include "Util/whereami.h"


class Engine : public Singleton<Engine>, public IRuntimeModule {
public:
    explicit Engine(Game *game);

    ~Engine() override;

    void start();

    const std::chrono::microseconds &getDeltaTime();

    Window *getWindow();

    INIReader *getConfig();

    std::filesystem::path getEngineDir();

    std::filesystem::path getAssetDir();

public:
    static Engine *getSingletonPtr();

public:
    std::unique_ptr<Window> m_window;
    std::unique_ptr<Game> m_game;
    std::unique_ptr<GLManager> m_glManager;
    std::unique_ptr<Renderer> m_renderer;
    std::unique_ptr<INIReader> m_config;
    std::chrono::high_resolution_clock::time_point m_time, m_lastTime;
    std::chrono::microseconds m_deltaTime{};
    std::filesystem::path m_engineDir{};
    bool m_fireRay{};

public:
    void initialize() override;

    void finalize() override;

    void update() override;

private:
    void initConfig();
};

#endif //ZELOENGINE_ENGINE_H