// RenderSystemConfig.h
// created on 2021/12/12
// author @zoloypzuo
#pragma once

enum class ERenderSystem {
    OpenGL,
    D3D12
};

struct RenderSystemConfig {
    bool debug = true;
    ERenderSystem renderSystem = ERenderSystem::OpenGL;
};

