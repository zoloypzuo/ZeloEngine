// GLManager.cpp
// created on 2021/3/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLManager.h"
#include "GLUtil.h"

GLManager::GLManager(Renderer *renderer, const glm::ivec2 &windowSize) {
#ifndef ANDROID
    // Load the OpenGL functions.
    spdlog::info("start initializing GLAD");
    if (!gladLoadGLLoader((GLADloadproc) SDL_GL_GetProcAddress)) {
        spdlog::error("GLAD failed to initialize");
        ZELO_ASSERT(false, "GLAD failed to initialize");
    }

    dumpGLInfo();
#endif

#ifndef __APPLE__
    int flags{};
    glGetIntegerv(GL_CONTEXT_FLAGS, &flags);
    if (flags & GL_CONTEXT_FLAG_DEBUG_BIT && glDebugMessageCallback) {
        // initialize debug output 
        spdlog::debug("GL debug context initialized, hook glDebugMessageCallback");
        glDebugMessageCallback(debugCallback, NULL);
        glDebugMessageControl(GL_DONT_CARE, GL_DONT_CARE, GL_DONT_CARE, 0, NULL, GL_TRUE);
        glDebugMessageInsert(GL_DEBUG_SOURCE_APPLICATION, GL_DEBUG_TYPE_MARKER, 0,
                             GL_DEBUG_SEVERITY_NOTIFICATION, -1, "Start debugging");
    }
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
    this->m_width = size.x;
    this->m_height = size.y;

    glViewport(0, 0, this->m_width, this->m_height);
}

void GLManager::bindRenderTarget() const {
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glViewport(0, 0, this->m_width, this->m_height);
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

void GLManager::clear() {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}

void GLManager::setClearColor(const glm::vec4 &color) {
    glClearColor(color.r, color.g, color.b, color.a);
}

void GLManager::setViewport(int32_t x, int32_t y, int32_t width, int32_t height) {
    glViewport(x, y, width, height);
}

void GLManager::drawIndexed(const Ref<Zelo::VertexArray> &vertexArray, int32_t indexCount) {
    int32_t count = indexCount ? indexCount : vertexArray->getIndexBuffer()->getCount();
    glDrawElements(GL_TRIANGLES, count, GL_UNSIGNED_INT, nullptr);
    glBindTexture(GL_TEXTURE_2D, 0);
}

void GLManager::drawArray(const Ref<Zelo::VertexArray> &vertexArray, int32_t start, int32_t count) {
    count = count ? count : vertexArray->getIndexBuffer()->getCount();
    glDrawArrays(GL_TRIANGLES, start, count);
}

void GLManager::setBlendEnabled(bool enabled) {
    if (enabled)
        glEnable(GL_BLEND);
    else
        glDisable(GL_BLEND);
}

void GLManager::setBlendFunc() {
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
}

void GLManager::setCullFaceEnabled(bool enabled) {
    if (enabled)
        glEnable(GL_CULL_FACE);
    else
        glDisable(GL_CULL_FACE);
}

void GLManager::setDepthTestEnabled(bool enabled) {
    if (enabled)
        glEnable(GL_DEPTH_TEST);
    else
        glDisable(GL_DEPTH_TEST);
}
