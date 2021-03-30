// GLManager.cpp
// created on 2021/3/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLManager.h"

class GLManager::Impl : public IRuntimeModule {
public:
    ~Impl() override;

    int width{}, height{};

    GLuint lineBuffer{};
    GLuint VertexArrayID{};
    Renderer *m_renderer;
//    std::unique_ptr<SimpleRenderer> m_simpleRenderer;

//    std::shared_ptr<Camera> m_activeCamera;
//
//    std::vector<std::shared_ptr<DirectionalLight>> m_directionalLights;
//    std::vector<std::shared_ptr<PointLight>> m_pointLights;
//    std::vector<std::shared_ptr<SpotLight>> m_spotLights;
public:
    Impl(Renderer *renderer, const glm::ivec2 &windowSize)
            : m_renderer(renderer), width(windowSize.x), height(windowSize.y) {
    }

    void initialize() override {
#ifndef ANDROID
        glewExperimental = GL_TRUE;
        GLenum err = glewInit();

        if (GLEW_OK != err) {
            spdlog::error("GLEW failed to initalize: {}", glewGetErrorString(err));
        }

        spdlog::info("Status: Using GLEW {}", glewGetString(GLEW_VERSION));
#endif
//    m_simpleRenderer = std::make_unique<SimpleRenderer>();

        glClearColor(0.0f, 0.5f, 0.5f, 1.0f);

        glClearDepthf(1.0f);
        glEnable(GL_DEPTH_TEST);
        glDepthFunc(GL_LESS);

        glEnable(GL_CULL_FACE);

        setDrawSize(glm::ivec2(width, height));

        glGenBuffers(1, &lineBuffer);
    }

    void finalize() override {
        glDeleteBuffers(1, &lineBuffer);
    }

    void update() override {

    }

    void setDrawSize(const glm::ivec2 &size);
};

void GLManager::Impl::setDrawSize(const glm::ivec2 &size) {
    width = size.x;
    height = size.y;
    glViewport(0, 0, width, height);
}

GLManager::Impl::~Impl() {

}

GLManager::GLManager(Renderer *renderer, const glm::ivec2 &windowSize)
        : mImpl(std::make_unique<Impl>(renderer, windowSize)) {
    mImpl->initialize();
}

GLManager::~GLManager() = default;

void GLManager::setDrawSize(const glm::ivec2 &size) {
    mImpl->setDrawSize(size);
}

void GLManager::bindRenderTarget() const {
//    glBindTexture(GL_TEXTURE_2D, 0);
//    glBindFramebuffer(GL_FRAMEBUFFER, 0);
//    glViewport(0, 0, this->width, this->height);
}

//void GLManager::setActiveCamera(std::shared_ptr<Camera> camera) {
//    m_activeCamera = camera;
//}
//
//void GLManager::addDirectionalLight(std::shared_ptr<DirectionalLight> light) {
//    m_directionalLights.push_back(light);
//}
//
//void GLManager::removeDirectionalLight(std::shared_ptr<DirectionalLight> light) {
//    m_directionalLights.erase(std::remove(m_directionalLights.begin(), m_directionalLights.end(), light),
//                              m_directionalLights.end());
//}
//
//void GLManager::addPointLight(std::shared_ptr<PointLight> light) {
//    m_pointLights.push_back(light);
//}
//
//void GLManager::removePointLight(std::shared_ptr<PointLight> light) {
//    m_pointLights.erase(std::remove(m_pointLights.begin(), m_pointLights.end(), light), m_pointLights.end());
//}
//
//void GLManager::addSpotLight(std::shared_ptr<SpotLight> light) {
//    m_spotLights.push_back(light);
//}
//
//void GLManager::removeSpotLight(std::shared_ptr<SpotLight> light) {
//    m_spotLights.erase(std::remove(m_spotLights.begin(), m_spotLights.end(), light), m_spotLights.end());
//}
//
//glm::mat4 GLManager::getViewMatrix() {
//    return m_activeCamera->getViewMatrix();
//}
//
//glm::mat4 GLManager::getProjectionMatrix() {
//    return m_activeCamera->getProjectionMatrix();
//}
//
//void GLManager::drawLine(Line line) {
//    m_simpleRenderer->renderLine(line, m_activeCamera);
//}

//void GLManager::drawEntity(Entity *entity) {
//    glEnable(GL_BLEND);
//    glBlendFunc(GL_ONE, GL_ONE);
//    glDepthMask(GL_FALSE);
//    glDepthFunc(GL_EQUAL);
//
//    m_simpleRenderer->render(*entity, m_activeCamera, m_pointLights, m_directionalLights, m_spotLights);
//
//    glDepthFunc(GL_LESS);
//    glDepthMask(GL_TRUE);
//    glDisable(GL_BLEND);
//}

void GLManager::renderScene(Entity *scene) {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

//    m_renderer->render(*scene, m_activeCamera, m_pointLights, m_directionalLights, m_spotLights);
}

template<> GLManager *Singleton<GLManager>::msSingleton = nullptr;

GLManager *GLManager::getSingletonPtr() {
    return msSingleton;
}