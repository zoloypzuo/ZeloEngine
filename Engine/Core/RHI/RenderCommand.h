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

    virtual void setStencilAlgorithm(EComparaisonAlgorithm algorithm, int32_t reference, uint32_t mask) = 0;

    virtual void setDepthAlgorithm(EComparaisonAlgorithm algorithm) = 0;

    virtual void setStencilMask(uint32_t mask) = 0;

    virtual void setStencilOperations(EOperation stencilFail, EOperation depthFail, EOperation bothPass) = 0;

    virtual void setCullFace(ECullFace cullFace) = 0;

    virtual void setDepthWriting(bool enable) = 0;

    virtual void setColorWriting(bool enableRed, bool enableGreen, bool enableBlue, bool enableAlpha) = 0;

    virtual void setColorWriting(bool enable) = 0;

    virtual void readPixels(uint32_t x, uint32_t y, uint32_t width, uint32_t height,
                            EPixelDataFormat format, EPixelDataType type,
                            void *data) = 0;

    virtual bool getBool(uint32_t/*GLenum*/ parameter) = 0;

    virtual bool getBool(uint32_t/*GLenum*/ parameter, uint32_t index) = 0;

    virtual int getInt(uint32_t/*GLenum*/ parameter) = 0;

    virtual int getInt(uint32_t/*GLenum*/ parameter, uint32_t index) = 0;

    virtual float getFloat(uint32_t/*GLenum*/ parameter) = 0;

    virtual float getFloat(uint32_t/*GLenum*/ parameter, uint32_t index) = 0;

    virtual double getDouble(uint32_t/*GLenum*/ parameter) = 0;

    virtual double getDouble(uint32_t/*GLenum*/ parameter, uint32_t index) = 0;

    virtual int64_t getInt64(uint32_t/*GLenum*/ parameter) = 0;

    virtual int64_t getInt64(uint32_t/*GLenum*/ parameter, uint32_t index) = 0;

    virtual std::string getString(uint32_t/*GLenum*/ parameter) = 0;

    virtual std::string getString(uint32_t/*GLenum*/ parameter, uint32_t index) = 0;

//    virtual void Draw(Resources::IMesh& mesh, EPrimitiveMode primitiveMode = EPrimitiveMode::TRIANGLES, uint32_t instances = 1)=0;
    virtual uint8_t fetchGLState() = 0;

    virtual void applyStateMask(uint8_t mask) = 0;

    virtual void setState(uint8_t state) = 0;
};
}

