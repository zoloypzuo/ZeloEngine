// RenderCommand.h
// created on 2021/6/3
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"

// TODO 看需要扩展和实现渲染命令
class RenderCommand {
public:
    virtual void SetViewport(uint32_t x, uint32_t y, uint32_t width, uint32_t height) = 0;

    virtual void SetClearColor(const glm::vec4 &color) = 0;

    virtual void Clear() = 0;

//    virtual void DrawIndexed(const Ref<VertexArray> &vertexArray, uint32_t indexCount) = 0;

};


