// GLRenderSystem.cpp
// created on 2021/3/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLRenderSystem.h"
#include "GLUtil.h"
#include "Core/Game/Game.h"
#include "Core/Window/Window.h"
#include "Renderer/OpenGL/Pipeline/Shadow//ForwardShadowMapPcf.h"

using namespace Zelo::Core::RHI;
using namespace Zelo::Renderer::OpenGL;

void GLRenderSystem::initialize() {
    ::loadGL();
    ::initDebugCallback();

    m_renderer = std::make_unique<ForwardShadowMapPcf>();
    m_renderer->initialize();

    setClearColor({0.0f, 0.0f, 0.0f, 1.0f});

    setCapabilityEnabled(ERenderingCapability::DEPTH_TEST, true);
    setDepthAlgorithm(EComparaisonAlgorithm::LESS);
    setCapabilityEnabled(ERenderingCapability::MULTISAMPLE, true);
    setCapabilityEnabled(ERenderingCapability::CULL_FACE, true);

    auto windowSize = Window::getSingletonPtr()->getDrawableSize();
    setDrawSize(windowSize);
}

void GLRenderSystem::update() {
    clear(true, true, false);

    if (m_activeCamera){
        auto scene = Game::getSingletonPtr()->getRootNode();
        m_renderer->render(*scene, m_activeCamera, m_pointLights, m_directionalLights, m_spotLights);
    }
}

GLRenderSystem::GLRenderSystem() = default;

GLRenderSystem::~GLRenderSystem() = default;

void GLRenderSystem::setDrawSize(const glm::ivec2 &size) {
    this->m_width = size.x;
    this->m_height = size.y;

    setViewport(0, 0, this->m_width, this->m_height);
}

glm::mat4 GLRenderSystem::getViewMatrix() {
    return m_activeCamera->getViewMatrix();
}

glm::mat4 GLRenderSystem::getProjectionMatrix() {
    return m_activeCamera->getProjectionMatrix();
}

#include "Renderer/OpenGL/GLRenderCommand.inl"
