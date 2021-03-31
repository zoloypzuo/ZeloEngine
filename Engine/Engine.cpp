// Engine.cpp
// created on 2021/3/28
// author @zoloypzuo

#include "ZeloPreCompiledHeader.h"
#include "Engine.h"
#include "Window.h"
#include "Game.h"
#include "Renderer/OpenGL/GLManager.h"
#include "Renderer/OpenGL/ForwardRenderer.h"

class Engine::Impl : public IRuntimeModule {
public:
    std::unique_ptr<Window> m_window;
    std::unique_ptr<Game> m_game;
    std::unique_ptr<GLManager> m_glManager;
    std::unique_ptr<Renderer> m_renderer;
    std::chrono::high_resolution_clock::time_point m_time, m_lastTime;
    std::chrono::microseconds m_deltaTime{};

public:
    void initialize() override;

    void finalize() override;

    void update() override;

};

void Engine::Impl::initialize() {
    spdlog::set_level(spdlog::level::debug);
    m_window = std::make_unique<Window>();
    m_renderer = std::make_unique<ForwardRenderer>();
    m_glManager = std::make_unique<GLManager>(m_renderer.get(), m_window->getDrawableSize());
    m_renderer->initialize();
    m_game = std::make_unique<Game>();
    // TODO init gui
    // m_guiManager = std::make_unique<GuiManager>(getDrawableSize(), getDisplaySize(), getSDLWindow());
    m_window->makeCurrentContext();
    m_time = std::chrono::high_resolution_clock::now();
}

void Engine::Impl::finalize() {

}

void Engine::Impl::update() {
    m_lastTime = m_time;
    m_time = std::chrono::high_resolution_clock::now();
    m_deltaTime = std::chrono::duration_cast<std::chrono::microseconds>(m_time - m_lastTime);

    m_window->update();
    m_game->update();
    m_glManager->renderScene(m_game->getRootNode().get());
    m_window->swapBuffer();
}


void Engine::start() {
    pImpl_->initialize();
    start_script();
    while (!pImpl_->m_window->shouldQuit()) {
        pImpl_->update();
    }
}

void Engine::start_script() {

}

Engine::Engine() :
        pImpl_(std::make_shared<Impl>()) {

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

