// Renderer.h
// created on 2021/4/3
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "Core/ECS/Entity.h"
#include "Core/RHI/Object/Camera.h"

class Renderer {
public:
    virtual ~Renderer() = default;

    virtual void initialize() = 0;

    virtual void render(const Zelo::Core::ECS::Entity &scene) const = 0;
};
