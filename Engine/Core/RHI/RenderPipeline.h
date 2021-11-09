// Renderer.h
// created on 2021/4/3
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "Core/ECS/Entity.h"
#include "Core/RHI/Object/Camera.h"

namespace Zelo::Core::RHI {
class RenderPipeline {
public:
    virtual ~RenderPipeline() = default;

    virtual void initialize() = 0;

    virtual void render(const Core::ECS::Entity &scene) const = 0;
};
}