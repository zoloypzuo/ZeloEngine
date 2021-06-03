// RenderCommand.h
// created on 2021/6/3
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"


class RenderCommand {
public:
    virtual void Init() = 0;

    virtual void SetViewport(uint32_t x, uint32_t y, uint32_t width, uint32_t height) = 0;

    virtual void SetClearColor(const glm::vec4 &color) = 0;

    virtual void Clear() = 0;

    virtual void DrawIndexed(const Ref<VertexArray> &vertexArray, uint32_t indexCount) = 0;

};


