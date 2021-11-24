// GLRenderSystem.cpp
// created on 2021/3/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLRenderSystem.h"
#include "GLUtil.h"
#include "Core/Scene/SceneManager.h"
#include "Core/Window/Window.h"
#include "Renderer/OpenGL/Pipeline/ForwardPipeline.h"

using namespace Zelo::Core::RHI;
using namespace Zelo::Core::Scene;
using namespace Zelo::Renderer::OpenGL;

void GLRenderSystem::initialize() {
    ::loadGL();

    if (m_config.GetBoolean("debug")) {
        ::initDebugCallback();
    }

    m_renderPipeline = std::make_unique<ForwardPipeline>();
    m_renderPipeline->initialize();

    setClearColor({0.0f, 0.0f, 0.0f, 1.0f});

    setCapabilityEnabled(ERenderCapability::DEPTH_TEST, true);
    setDepthAlgorithm(EComparaisonAlgorithm::LESS);
    setCapabilityEnabled(ERenderCapability::MULTISAMPLE, true);
    setCapabilityEnabled(ERenderCapability::CULL_FACE, true);

    auto windowSize = Window::getSingletonPtr()->getDrawableSize();
    setDrawSize(windowSize);
}

void GLRenderSystem::update() {
    const auto &sceneManager = SceneManager::getSingletonPtr();

    if (m_renderPipeline) {  // pipeline can be null
        m_renderPipeline->preRender();

        if (sceneManager->getActiveCamera()) {
            auto scene = sceneManager->getRootNode();
            m_renderPipeline->render(*scene);
        }
    }
}

GLRenderSystem::GLRenderSystem(const INIReader::Section &config) : m_config(config) {}

GLRenderSystem::~GLRenderSystem() = default;

void GLRenderSystem::setDrawSize(const glm::ivec2 &size) {
    this->m_width = size.x;
    this->m_height = size.y;

    setViewport(0, 0, this->m_width, this->m_height);
}

#include "Renderer/OpenGL/GLRenderCommand.inl"
