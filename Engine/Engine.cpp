// Engine.cpp
// created on 2021/3/28
// author @zoloypzuo

#include "ZeloPreCompiledHeader.h"
#include "Engine.h"
#include "Window.h"
#include "Game.h"
#include "Renderer/OpenGL/GLManager.h"
#include "Renderer/OpenGL/ForwardRenderer.h"
#include "Util/whereami.h"

class Engine::Impl : public IRuntimeModule {
public:
    std::unique_ptr<Window> m_window;
    std::unique_ptr<Game> m_game;
    std::unique_ptr<GLManager> m_glManager;
    std::unique_ptr<Renderer> m_renderer;
    std::unique_ptr<INIReader> m_bootConfig;
    std::chrono::high_resolution_clock::time_point m_time, m_lastTime;
    std::chrono::microseconds m_deltaTime{};
    bool m_fireRay{};

public:
    explicit Impl(Game *game);

    void initialize() override;

    void finalize() override;

    void update() override;

private:
    void initBootConfig();

};

void Engine::Impl::initialize() {
    // init config and logger first
    spdlog::set_level(spdlog::level::debug);
    initBootConfig();

    m_window = std::make_unique<Window>();
    m_renderer = std::make_unique<ForwardRenderer>();
    m_glManager = std::make_unique<GLManager>(m_renderer.get(), m_window->getDrawableSize());
    m_renderer->initialize();
//    m_game = std::make_unique<Game>(); game is newed by app
    m_game->initialize();
    m_game->getRootNode()->registerWithEngineAll(Engine::getSingletonPtr());

    m_window->initialize();  // init gui
    m_window->makeCurrentContext();

    m_window->getInput()->registerKeyToAction(SDLK_F1, "propertyEditor");
//    m_window->getInput()->registerKeyToAction(SDLK_F2, "fullscreenToggle");

    m_window->getInput()->registerButtonToAction(SDL_BUTTON_LEFT, "fireRay");

    m_window->getInput()->bindAction("propertyEditor", IE_PRESSED, [this]() {
        m_window->getGuiManager()->togglePropertyEditor();
    });

    // do not toggle fullscreen
//    m_window->getInput()->bindAction("fullscreenToggle", IE_PRESSED, [this]() {
//        m_window->toggleFullscreen();
//        m_glManager->setDrawSize(m_window->getDrawableSize());
//    });

    m_window->getInput()->bindAction("fireRay", IE_PRESSED, [this]() {
        m_fireRay = true;
    });

    m_window->getInput()->bindAction("fireRay", IE_RELEASED, [this]() {
        m_fireRay = false;
    });

    m_time = std::chrono::high_resolution_clock::now();
}

void Engine::Impl::initBootConfig() {
    int length = wai_getExecutablePath(nullptr, 0, nullptr);
    char *path = new char[length + 1];
    wai_getExecutablePath(path, length, &length);
    path[length] = '\0';
    this->m_bootConfig = std::make_unique<INIReader>((std::string(path) + "/Config/" + "EngineBootConfig.ini"));
}

void Engine::Impl::finalize() {

}

void Engine::Impl::update() {
    m_lastTime = m_time;
    m_time = std::chrono::high_resolution_clock::now();
    m_deltaTime = std::chrono::duration_cast<std::chrono::microseconds>(m_time - m_lastTime);

    m_window->update();
    m_window->getGuiManager()->tick(m_deltaTime);
    m_game->update();
    m_glManager->renderScene(m_game->getRootNode().get());
    m_window->getGuiManager()->render(m_game->getRootNode().get());
    m_window->swapBuffer();
}

Engine::Impl::Impl(Game *game) {
    m_game = std::unique_ptr<Game>(game);
}


void Engine::start() {
    ZELO_PROFILE_BEGIN_SESSION("Startup", "ZeloProfile-Startup.json");
    pImpl_->initialize();
    ZELO_PROFILE_END_SESSION();

    ZELO_PROFILE_BEGIN_SESSION("Runtime", "ZeloProfile-Runtime.json");
    while (!pImpl_->m_window->shouldQuit()) {
        pImpl_->update();
    }
    ZELO_PROFILE_END_SESSION();

    ZELO_PROFILE_BEGIN_SESSION("Shutdown", "ZeloProfile-Shutdown.json");
    pImpl_->finalize();
    ZELO_PROFILE_END_SESSION();
}

Engine::Engine(Game *game) :
        pImpl_(std::make_shared<Impl>(game)) {

}

Engine::~Engine() {
    pImpl_->finalize();
}

template<> Engine *Singleton<Engine>::msSingleton = nullptr;

Engine *Engine::getSingletonPtr() {
    return msSingleton;
}

const std::chrono::microseconds &Engine::getDeltaTime() {
    return pImpl_->m_deltaTime;
}

Window *Engine::getWindow() {
    return pImpl_->m_window.get();
}

INIReader *Engine::getBootConfig() {
    return pImpl_->m_bootConfig.get();
}

