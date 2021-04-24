// GLManager.cpp
// created on 2021/3/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLManager.h"

#include <utility>


GLManager::GLManager(Renderer *renderer, const glm::ivec2 &windowSize) {
#ifndef ANDROID
    spdlog::info("start initializing GLEW");
    glewExperimental = GL_TRUE;
    GLenum err = glewInit();

    if (GLEW_OK != err) {
        spdlog::error("GLEW failed to initialize: {}", glewGetErrorString(err));
    }

    spdlog::info("GLEW Version: {}", glewGetString(GLEW_VERSION));
#endif
    m_renderer = renderer;
    m_simpleRenderer = std::make_unique<SimpleRenderer>();
    m_simpleRenderer->initialize();
    m_meshManager = std::make_unique<MeshManager>();

    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);

    glClearDepthf(1.0f);
    glEnable(GL_DEPTH_TEST);
    glDepthFunc(GL_LESS);

    glEnable(GL_MULTISAMPLE); // Enabled by default on some drivers, but not all so always enable to make sure

    glEnable(GL_CULL_FACE);

    setDrawSize(windowSize);

    glGenBuffers(1, &lineBuffer);
}

GLManager::~GLManager() {
    glDeleteBuffers(1, &lineBuffer);
}

void GLManager::setDrawSize(const glm::ivec2 &size) {
    this->width = size.x;
    this->height = size.y;

    glViewport(0, 0, this->width, this->height);
}

void GLManager::bindRenderTarget() const {
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glViewport(0, 0, this->width, this->height);
}

void GLManager::setActiveCamera(std::shared_ptr<Camera> camera) {
    m_activeCamera = std::move(camera);
}

void GLManager::addDirectionalLight(const std::shared_ptr<DirectionalLight> &light) {
    m_directionalLights.push_back(light);
}

void GLManager::removeDirectionalLight(const std::shared_ptr<DirectionalLight> &light) {
    m_directionalLights.erase(std::remove(m_directionalLights.begin(), m_directionalLights.end(), light),
                              m_directionalLights.end());
}

void GLManager::addPointLight(const std::shared_ptr<PointLight> &light) {
    m_pointLights.push_back(light);
}

void GLManager::removePointLight(const std::shared_ptr<PointLight> &light) {
    m_pointLights.erase(std::remove(m_pointLights.begin(), m_pointLights.end(), light), m_pointLights.end());
}

void GLManager::addSpotLight(const std::shared_ptr<SpotLight> &light) {
    m_spotLights.push_back(light);
}

void GLManager::removeSpotLight(const std::shared_ptr<SpotLight> &light) {
    m_spotLights.erase(std::remove(m_spotLights.begin(), m_spotLights.end(), light), m_spotLights.end());
}

glm::mat4 GLManager::getViewMatrix() {
    return m_activeCamera->getViewMatrix();
}

glm::mat4 GLManager::getProjectionMatrix() {
    return m_activeCamera->getProjectionMatrix();
}

void GLManager::drawLine(const Line &line) {
    m_simpleRenderer->renderLine(line, m_activeCamera);
}

void GLManager::drawEntity(Entity *entity) {
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE);
    glDepthMask(GL_FALSE);
    glDepthFunc(GL_EQUAL);

    m_simpleRenderer->render(*entity, m_activeCamera, m_pointLights, m_directionalLights, m_spotLights);

    glDepthFunc(GL_LESS);
    glDepthMask(GL_TRUE);
    glDisable(GL_BLEND);
}

void GLManager::renderScene(Entity *scene) {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    m_renderer->render(*scene, m_activeCamera, m_pointLights, m_directionalLights, m_spotLights);
}


template<> GLManager *Singleton<GLManager>::msSingleton = nullptr;

GLManager *GLManager::getSingletonPtr() {
    return msSingleton;
}