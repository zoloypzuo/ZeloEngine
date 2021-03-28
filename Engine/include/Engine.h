// Engine.h
// created on 2021/3/28
// author @zoloypzuo

#ifndef ZELOENGINE_ENGINE_H
#define ZELOENGINE_ENGINE_H


class Engine {
public:
    Engine() = default;

    virtual ~Engine() = default;

    void start();

    virtual void start_script();
};


#endif //ZELOENGINE_ENGINE_H