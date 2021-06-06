// GLManager.h
// created on 2021/3/29
// author @zoloypzuo

#ifndef ZELOENGINE_GLMANAGER_H
#define ZELOENGINE_GLMANAGER_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "ZeloSingleton.h"

#include "Renderer.h"
#include "ForwardRenderer.h"
#include "GLSLShaderProgram.h"
#include "MeshManager.h"
#include "Entity.h"
#include "Core/Window/Window.h"
#include "Camera.h"
#include "Light.h"
#include "Line.h"
#include "Core/RHI/RenderCommand.h"

class GLManager : public Singleton<GLManager>, public RenderCommand {
public:
    GLManager(Renderer *renderer, const glm::ivec2 &windowSize);

    ~GLManager();

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

public:
    void SetViewport(uint32_t x, uint32_t y, uint32_t width, uint32_t height) override;

    void SetClearColor(const glm::vec4 &color) override;

    void Clear() override;

public:
    static GLManager *getSingletonPtr();

private:
    Renderer *m_renderer;
    std::unique_ptr<SimpleRenderer> m_simpleRenderer;
    std::unique_ptr<MeshManager> m_meshManager;

    std::shared_ptr<Camera> m_activeCamera;

    std::vector<std::shared_ptr<DirectionalLight>> m_directionalLights;
    std::vector<std::shared_ptr<PointLight>> m_pointLights;
    std::vector<std::shared_ptr<SpotLight>> m_spotLights;
};

#endif //ZELOENGINE_GLMANAGER_H