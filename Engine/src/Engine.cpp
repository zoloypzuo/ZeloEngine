// Engine.cpp
// created on 2021/3/28
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Engine.h"
#include "Window.h"

class Engine::Impl : public IRuntimeModule {
public:
    bool m_quit{};
    std::unique_ptr<Window> m_window;

public:
    void initialize() override;

    void finalize() override;

    void update() override;

};

void Engine::Impl::initialize() {
    m_window = std::make_unique<Window>();
}

void Engine::Impl::finalize() {

}

void Engine::Impl::update() {
    m_window->update();
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

