// D3D12RenderSystem.h
// created on 2022/1/17
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Foundation/ZeloSingleton.h"

#include "Core/RHI/RenderCommand.h"
#include "Core/RHI/RenderSystem.h"
#include "Core/RHI/RenderPipeline.h"
#include "Core/RHI/Resource/MeshManager.h"
#include "Core/RHI/Object/ACamera.h"
#include "Core/Parser/IniReader.h"
#include "Core/Interface/IView.h"

#include "Config/RenderSystemConfig.h"

namespace Zelo::Renderer::D3D12 {
class D3D12RenderSystem : public Core::RHI::RenderSystem {
public:
    D3D12RenderSystem();

    ~D3D12RenderSystem() override;

    void initialize() override;

    void update() override;

    void pushView(Core::Interface::IView *view) override;

    void popView() override;

private:
    struct Impl;
    std::shared_ptr<Impl> pimpl;

public: // RenderCommand
    void setViewport(int32_t x, int32_t y, int32_t width, int32_t height) override;

    void setClearColor(const glm::vec4 &color) override;

    void clear(bool colorBuffer, bool depthBuffer, bool stencilBuffer) override;

    void setCapabilityEnabled(Core::RHI::ERenderCapability capability, bool value) override;

    bool getCapabilityEnabled(Core::RHI::ERenderCapability capability) override;

    void setStencilAlgorithm(Core::RHI::EComparaisonAlgorithm algorithm, int32_t reference, uint32_t mask) override;

    void setDepthAlgorithm(Core::RHI::EComparaisonAlgorithm algorithm) override;

    void setStencilMask(uint32_t mask) override;

    void setStencilOperations(Core::RHI::EOperation stencilFail, Core::RHI::EOperation depthFail,
                              Core::RHI::EOperation bothPass) override;

    void setCullFace(Core::RHI::ECullFace cullFace) override;

    void setDepthWriting(bool enable) override;

    void setColorWriting(bool enableRed, bool enableGreen, bool enableBlue, bool enableAlpha) override;

    void setColorWriting(bool enable) override;

    void readPixels(uint32_t x, uint32_t y, uint32_t width, uint32_t height,
                    Core::RHI::EPixelDataFormat format, Core::RHI::EPixelDataType type,
                    void *data) override;

    bool getBool(uint32_t parameter) override;

    bool getBool(uint32_t parameter, uint32_t index) override;

    int getInt(uint32_t parameter) override;

    int getInt(uint32_t parameter, uint32_t index) override;

    float getFloat(uint32_t parameter) override;

    float getFloat(uint32_t parameter, uint32_t index) override;

    double getDouble(uint32_t parameter) override;

    double getDouble(uint32_t parameter, uint32_t index) override;

    int64_t getInt64(uint32_t parameter) override;

    int64_t getInt64(uint32_t parameter, uint32_t index) override;

    std::string getString(uint32_t parameter) override;

    std::string getString(uint32_t parameter, uint32_t index) override;

    uint8_t fetchGLState() override;

    void applyStateMask(uint8_t mask) override;
};
}
