// FinalScenePlugin.h
// created on 2021/11/30
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

#include "Foundation/ZeloPlugin.h"


namespace FinalScene {
class Ch10FinalPlugin : public Plugin {
public:

public:
    const std::string &getName() const override;;

    void install() override;

    void uninstall() override;

    void initialize() override;

    void update() override;

    void render() override;

private:
    struct Impl;
    std::shared_ptr<Impl> pimpl{};

    Zelo::Core::ECS::Entity *entity{};
};
}
