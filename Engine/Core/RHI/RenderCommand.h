// RenderCommand.h
// created on 2021/6/3
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"
#include "Core/RHI/VertexArray.h"
#include "Core/RHI/Const/ERenderingCapability.h"

namespace Zelo::Core::RHI {
// TODO 看需要扩展和实现渲染命令
class RenderCommand {
public:
    virtual void setViewport(int32_t x, int32_t y, int32_t width, int32_t height) = 0;

    virtual void setClearColor(const glm::vec4 &color) = 0;

    virtual void clear(bool colorBuffer, bool depthBuffer, bool stencilBuffer) = 0;

    virtual void drawIndexed(const Ref<VertexArray> &vertexArray, int32_t indexCount) = 0;

    virtual void drawArray(const Ref<VertexArray> &vertexArray, int32_t start, int32_t count) = 0;

    virtual void setBlendEnabled(bool enabled) = 0;

    virtual void setBlendFunc() = 0;

    virtual void setCullFaceEnabled(bool enabled) = 0;

    virtual void setDepthTestEnabled(bool enabled) = 0;

    virtual void setCapabilityEnabled(ERenderingCapability capability, bool value) = 0;

    virtual bool getCapabilityEnabled(ERenderingCapability capability) = 0;

    virtual void 
};
}

