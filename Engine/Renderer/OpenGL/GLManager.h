// GLManager.h
// created on 2021/3/29
// author @zoloypzuo

#ifndef ZELOENGINE_GLMANAGER_H
#define ZELOENGINE_GLMANAGER_H

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"

#if defined(GLES2)
#include <GLES2/gl2.h>
#elif defined(GLES3)
#include <GLES3/gl3.h>
#else

#include <glad/glad.h>

#endif

#include "Renderer.h"
#include "ForwardRenderer.h"
#include "Shader.h"
#include "MeshManager.h"
#include "Entity.h"
#include "Window.h"
#include "Camera.h"
#include "Light.h"
#include "Line.h"

class GLManager : public Singleton<GLManager> {
public:
    GLManager(Renderer *renderer, const glm::ivec2 &windowSize);

    ~GLManager();

    void setDrawSize(const glm::ivec2 &size);

    void bindRenderTarget() const;

    void renderScene(Entity *entity);

    void setActiveCamera(std::shared_ptr<Camera> camera);

    void addDirectionalLight(const std::shared_ptr<DirectionalLight>& light);

    void addPointLight(const std::shared_ptr<PointLight>& light);

    void addSpotLight(const std::shared_ptr<SpotLight>& light);

    void removeDirectionalLight(const std::shared_ptr<DirectionalLight>& light);

    void removePointLight(const std::shared_ptr<PointLight>& light);

    void removeSpotLight(const std::shared_ptr<SpotLight>& light);

    glm::mat4 getViewMatrix();

    glm::mat4 getProjectionMatrix();

    void drawEntity(Entity *entity);

    void drawLine(const Line& line);

    int width{};
    int height{};

    GLuint lineBuffer{};
    GLuint VertexArrayID{};

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