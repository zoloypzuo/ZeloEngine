// GLRenderSystem.h
// created on 2021/3/29
// author @zoloypzuo

#ifndef ZELOENGINE_GLRENDERSYSTEM_H
#define ZELOENGINE_GLRENDERSYSTEM_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "ZeloSingleton.h"

#include "Renderer.h"
#include "ForwardRenderer.h"
#include "GLSLShaderProgram.h"
#include "MeshManager.h"
#include "Core/ECS/Entity.h"
#include "Core/Window/Window.h"
#include "Camera.h"
#include "Light.h"
#include "Line.h"
#include "Core/RHI/RenderCommand.h"
#include "Core/RHI/RenderSystem.h"

namespace Zelo::Renderer::OpenGL {
class GLRenderSystem : public Core::RHI::RenderSystem {
public:
    GLRenderSystem(Renderer *renderer, const glm::ivec2 &windowSize);

    ~GLRenderSystem();

    void setDrawSize(const glm::ivec2 &size);

    void bindRenderTarget() const;

    void renderScene(Entity *entity);

    void setActiveCamera(std::shared_ptr<Camera> camera);

    void addDirectionalLight(const std::shared_ptr<DirectionalLight> &light);

    void addPointLight(const std::shared_ptr<PointLight> &light);

    void addSpotLight(const std::shared_ptr<SpotLight> &light);

    void removeDirectionalLight(const std::shared_ptr<DirectionalLight> &light);

    void removePointLight(const std::shared_ptr<PointLight> &light);

    void removeSpotLight(const std::shared_ptr<SpotLight> &light);

    glm::mat4 getViewMatrix();

    glm::mat4 getProjectionMatrix();

    void drawEntity(Entity *entity);

    void drawLine(const Line &line);

    int m_width{};
    int m_height{};

    GLuint lineBuffer{};
    GLuint VertexArrayID{};

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

public:
private:
    Renderer *m_renderer;
    std::unique_ptr<SimpleRenderer> m_simpleRenderer;
    std::unique_ptr<MeshManager> m_meshManager;

    std::shared_ptr<Camera> m_activeCamera;

    std::vector<std::shared_ptr<DirectionalLight>> m_directionalLights;
    std::vector<std::shared_ptr<PointLight>> m_pointLights;
    std::vector<std::shared_ptr<SpotLight>> m_spotLights;
};
}
#endif //ZELOENGINE_GLRENDERSYSTEM_H