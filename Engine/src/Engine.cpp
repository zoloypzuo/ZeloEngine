// Engine.cpp
// created on 2021/3/28
// author @zoloypzuo

#include "Engine.h"

class Engine::Impl : public IRuntimeModule {
public:
    void initialize() override;

    void finalize() override;

    void update() override;

public:
    bool quit{};
};

void Engine::Impl::initialize() {

}

void Engine::Impl::finalize() {

}

void Engine::Impl::update() {

}


void Engine::start() {
    pImpl_->initialize();
    start_script();
    while (!pImpl_->quit) {
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

