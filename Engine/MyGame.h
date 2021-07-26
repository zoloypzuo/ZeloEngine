// MyGame.h
// created on 2021/4/10
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"
#include "Core/Game/Game.h"

class MyGame : public Game {
public:
    void initialize() override;

    std::shared_ptr<PerspectiveCamera> primary_camera;
    std::shared_ptr<PerspectiveCamera> primary_camera2;
};

