// GLRenderSystem.cpp
// created on 2021/3/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLRenderSystem.h"
#include "GLUtil.h"
#include "Core/Game/Game.h"
#include "Core/Window/Window.h"

using namespace Zelo::Core::RHI;
using namespace Zelo::Renderer::OpenGL;

void GLRenderSystem::initialize() {
    initGL();
    ::initDebugCallback();

    m_renderer = nullptr;
    m_simpleRenderer = std::make_unique<SimpleRenderer>();
    m_simpleRenderer->initialize();
    m_meshManager = std::make_unique<MeshManager>();

    setClearColor({0.0f, 0.0f, 0.0f, 1.0f});

    setCapabilityEnabled(ERenderingCapability::DEPTH_TEST, true);
    setDepthAlgorithm(EComparaisonAlgorithm::LESS);
    setCapabilityEnabled(ERenderingCapability::MULTISAMPLE, true);
    setCapabilityEnabled(ERenderingCapability::CULL_FACE, true);

    auto windowSize = Window::getSingletonPtr()->getDrawableSize();
    setDrawSize(windowSize);

}

void GLRenderSystem::initGL() const {// Load the OpenGL functions.
    spdlog::info("start initializing GLAD");
    if (!gladLoadGLLoader((GLADloadproc) SDL_GL_GetProcAddress)) {
        spdlog::error("GLAD failed to initialize");
        ZELO_ASSERT(false, "GLAD failed to initialize");
    }

    dumpGLInfo();
}


void GLRenderSystem::update() {
    renderScene(Game::getSingletonPtr()->getRootNode().get());
}

GLRenderSystem::GLRenderSystem() = default;

GLRenderSystem::~GLRenderSystem() = default;

void GLRenderSystem::setDrawSize(const glm::ivec2 &size) {
    this->m_width = size.x;
    this->m_height = size.y;

    glViewport(0, 0, this->m_width, this->m_height);
}

void GLRenderSystem::bindRenderTarget() const {
    glBindTexture(GL_TEXTURE_2D, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    glViewport(0, 0, this->m_width, this->m_height);
}

void GLRenderSystem::setActiveCamera(std::shared_ptr<Camera> camera) {
    m_activeCamera = std::move(camera);
}

void GLRenderSystem::addDirectionalLight(const std::shared_ptr<DirectionalLight> &light) {
    m_directionalLights.push_back(light);
}

void GLRenderSystem::removeDirectionalLight(const std::shared_ptr<DirectionalLight> &light) {
    m_directionalLights.erase(std::remove(m_directionalLights.begin(), m_directionalLights.end(), light),
                              m_directionalLights.end());
}

void GLRenderSystem::addPointLight(const std::shared_ptr<PointLight> &light) {
    m_pointLights.push_back(light);
}

void GLRenderSystem::removePointLight(const std::shared_ptr<PointLight> &light) {
    m_pointLights.erase(std::remove(m_pointLights.begin(), m_pointLights.end(), light), m_pointLights.end());
}

void GLRenderSystem::addSpotLight(const std::shared_ptr<SpotLight> &light) {
    m_spotLights.push_back(light);
}

void GLRenderSystem::removeSpotLight(const std::shared_ptr<SpotLight> &light) {
    m_spotLights.erase(std::remove(m_spotLights.begin(), m_spotLights.end(), light), m_spotLights.end());
}

glm::mat4 GLRenderSystem::getViewMatrix() {
    return m_activeCamera->getViewMatrix();
}

glm::mat4 GLRenderSystem::getProjectionMatrix() {
    return m_activeCamera->getProjectionMatrix();
}

void GLRenderSystem::drawEntity(Entity *entity) {
    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE);
    glDepthMask(GL_FALSE);
    glDepthFunc(GL_EQUAL);

    m_simpleRenderer->render(*entity, m_activeCamera, m_pointLights, m_directionalLights, m_spotLights);

    glDepthFunc(GL_LESS);
    glDepthMask(GL_TRUE);
    glDisable(GL_BLEND);
}

void GLRenderSystem::renderScene(Entity *scene) {
    clear(true, true, false);

    m_renderer->render(*scene, m_activeCamera, m_pointLights, m_directionalLights, m_spotLights);
}

#include "Renderer/OpenGL/GLRenderCommand.inl"
