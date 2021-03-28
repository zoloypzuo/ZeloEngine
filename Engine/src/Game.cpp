// Game.cpp
// created on 2021/3/28
// author @zoloypzuo

#include "Game.h"

class Entity;

class Game::Impl : public IRuntimeModule {
public:
    void initialize() override;

    void finalize() override;

    void update() override;

public:
    std::shared_ptr<Entity> root;
};

void Game::Impl::initialize() {

}

void Game::Impl::finalize() {

}

void Game::Impl::update() {

}


void Game::update() {
    pImpl_->update();
}

template<> Game *Singleton<Game>::msSingleton = nullptr;

Game &Game::getSingleton() {
    assert(msSingleton);
    return *msSingleton;
}

Game *Game::getSingletonPtr() {
    return msSingleton;
}

std::shared_ptr<Entity> Game::getRootNode() {
    return std::shared_ptr<Entity>();
}

Game::Game() : pImpl_(std::make_unique<Impl>()) {
    pImpl_->initialize();
}

Game::~Game() {
    pImpl_->finalize();
}
