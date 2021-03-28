// Game.cpp
// created on 2021/3/28
// author @zoloypzuo

#include "Game.h"

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

void Game::initialize() {

}

void Game::finalize() {

}

void Game::update() {

}

template<> Game *Singleton<Game>::msSingleton = nullptr;

Game &Game::getSingleton() {
    assert(msSingleton);
    return *msSingleton;
}

Game *Game::getSingletonPtr() {
    return msSingleton;
}
