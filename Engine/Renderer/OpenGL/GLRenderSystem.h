// GLRenderSystem.h
// created on 2021/3/29
// author @zoloypzuo

#ifndef ZELOENGINE_GLRENDERSYSTEM_H
#define ZELOENGINE_GLRENDERSYSTEM_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Foundation/ZeloSingleton.h"

#include "Core/RHI/RenderCommand.h"
#include "Core/RHI/RenderSystem.h"
#include "Core/RHI/RenderPipeline.h"
#include "Core/RHI/Resource/MeshManager.h"
#include "Core/RHI/Object/ACamera.h"
#include "Core/Parser/IniReader.h"
#include "Core/Interface/IView.h"

#include "Config/RenderSystemConfig.h"

namespace Zelo::Renderer::OpenGL {
class GLRenderSystem : public Core::RHI::RenderSystem {
public:
    GLRenderSystem();

    ~GLRenderSystem() override;

    void initialize() override;

    void update() override;

    void pushView(Core::Interface::IView *view) override;

    void popView() override;

protected:
    void applyCurrentView();

private:
    int m_width{};
    int m_height{};

    std::vector<Core::Interface::IView *> m_viewStack;

    RenderSystemConfig &m_config;

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

    bool getBool(uint32_t/*GLenum*/ parameter) override;

    bool getBool(uint32_t/*GLenum*/ parameter, uint32_t index) override;

    int getInt(uint32_t/*GLenum*/ parameter) override;

    int getInt(uint32_t/*GLenum*/ parameter, uint32_t index) override;

    float getFloat(uint32_t/*GLenum*/ parameter) override;

    float getFloat(uint32_t/*GLenum*/ parameter, uint32_t index) override;

    double getDouble(uint32_t/*GLenum*/ parameter) override;

    double getDouble(uint32_t/*GLenum*/ parameter, uint32_t index) override;

    int64_t getInt64(uint32_t/*GLenum*/ parameter) override;

    int64_t getInt64(uint32_t/*GLenum*/ parameter, uint32_t index) override;

    std::string getString(uint32_t/*GLenum*/ parameter) override;

    std::string getString(uint32_t/*GLenum*/ parameter, uint32_t index) override;

    uint8_t fetchGLState() override;

    void applyStateMask(uint8_t mask) override;
};
}
#endif //ZELOENGINE_GLRENDERSYSTEM_H