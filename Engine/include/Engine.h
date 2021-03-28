// Engine.h
// created on 2021/3/28
// author @zoloypzuo

#ifndef ZELOENGINE_ENGINE_H
#define ZELOENGINE_ENGINE_H

#include "ZeloPrerequisites.h"


class Engine {
public:
    Engine();

    virtual ~Engine();

    void start();

    virtual void start_script();

private:
    class Impl;
    std::shared_ptr<Impl> pImpl_;
};


#endif //ZELOENGINE_ENGINE_H