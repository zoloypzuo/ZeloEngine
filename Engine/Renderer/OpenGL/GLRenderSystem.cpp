// GLRenderSystem.cpp
// created on 2021/3/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLRenderSystem.h"
#include "GLUtil.h"
#include "Core/Game/Game.h"
#include "Core/Window/Window.h"
#include "Renderer/OpenGL/Pipeline/ForwardRenderer.h"

using namespace Zelo::Core::RHI;
using namespace Zelo::Renderer::OpenGL;

void GLRenderSystem::initialize() {
    ::loadGL();
    ::initDebugCallback();

    m_renderer = std::make_unique<ForwardRenderer>();
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

    const auto &sceneManager = Game::getSingletonPtr();

    if (sceneManager->getActiveCamera()) {
        auto scene = sceneManager->getRootNode();
        m_renderer->render(*scene);
    }
}

GLRenderSystem::GLRenderSystem() = default;

GLRenderSystem::~GLRenderSystem() = default;

void GLRenderSystem::setDrawSize(const glm::ivec2 &size) {
    this->m_width = size.x;
    this->m_height = size.y;

    setViewport(0, 0, this->m_width, this->m_height);
}

#include "Renderer/OpenGL/GLRenderCommand.inl"
