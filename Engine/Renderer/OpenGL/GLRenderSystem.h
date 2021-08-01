// GLRenderSystem.h
// created on 2021/3/29
// author @zoloypzuo

#ifndef ZELOENGINE_GLRENDERSYSTEM_H
#define ZELOENGINE_GLRENDERSYSTEM_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "ZeloSingleton.h"

#include "Core/RHI/RenderCommand.h"
#include "Core/RHI/RenderSystem.h"
#include "Renderer.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"
#include "Renderer/OpenGL/Resource/MeshManager.h"
#include "Renderer/OpenGL/Camera.h"
#include "Renderer/OpenGL/Light.h"

namespace Zelo::Renderer::OpenGL {
class GLRenderSystem : public Core::RHI::RenderSystem {
public:
    GLRenderSystem();

    ~GLRenderSystem() override;

    void initialize() override;

    void update() override;

    void setDrawSize(const glm::ivec2 &size);

    void setActiveCamera(std::shared_ptr<Camera> camera);

    void addDirectionalLight(const std::shared_ptr<DirectionalLight> &light);

    void addPointLight(const std::shared_ptr<PointLight> &light);

    void addSpotLight(const std::shared_ptr<SpotLight> &light);

    void removeDirectionalLight(const std::shared_ptr<DirectionalLight> &light);

    void removePointLight(const std::shared_ptr<PointLight> &light);

    void removeSpotLight(const std::shared_ptr<SpotLight> &light);

    glm::mat4 getViewMatrix();

    glm::mat4 getProjectionMatrix();

    int m_width{};
    int m_height{};

public: // RenderCommand
    void setViewport(int32_t x, int32_t y, int32_t width, int32_t height) override;

    void setClearColor(const glm::vec4 &color) override;

    void clear(bool colorBuffer, bool depthBuffer, bool stencilBuffer) override;

    void drawIndexed(const Ref<Zelo::VertexArray> &vertexArray, int32_t indexCount) override;

    void drawArray(const Ref<Zelo::VertexArray> &vertexArray, int32_t start, int32_t count) override;

    // TODO remove it
    void setBlendEnabled(bool enabled) override;

    // TODO remove it
    void setBlendFunc() override;

    // TODO remove it
    void setCullFaceEnabled(bool enabled) override;

    // TODO remove it
    void setDepthTestEnabled(bool enabled) override;

    void setCapabilityEnabled(Core::RHI::ERenderingCapability capability, bool value) override;

    bool getCapabilityEnabled(Core::RHI::ERenderingCapability capability) override;

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

private:
    class Renderer *m_renderer{};

    std::unique_ptr<MeshManager> m_meshManager;

    std::shared_ptr<Camera> m_activeCamera;

    std::vector<std::shared_ptr<DirectionalLight>> m_directionalLights;
    std::vector<std::shared_ptr<PointLight>> m_pointLights;
    std::vector<std::shared_ptr<SpotLight>> m_spotLights;

    uint8_t m_state{};
};
}
#endif //ZELOENGINE_GLRENDERSYSTEM_H