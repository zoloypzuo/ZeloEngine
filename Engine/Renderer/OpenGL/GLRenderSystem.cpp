// GLRenderSystem.cpp
// created on 2021/3/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLRenderSystem.h"

#include "Core/Scene/SceneManager.h"
#include "Core/Window/Window.h"

#include "Renderer/OpenGL/GLUtil.h"
#include "Renderer/OpenGL/GLLoader.h"
#include "Renderer/OpenGL/Pipeline/ForwardStandardPipeline.h"

using namespace Zelo::Core::RHI;
using namespace Zelo::Core::Scene;
using namespace Zelo::Renderer::OpenGL;

GLRenderSystem::GLRenderSystem(const INIReader::Section &config) : m_config(config) {}

GLRenderSystem::~GLRenderSystem() = default;

void GLRenderSystem::initialize() {
    ::loadGL();

    if (m_config.GetBoolean("debug")) {
        ::initDebugCallback();
    }

    m_renderPipeline = std::make_unique<ForwardStandardPipeline>();
    m_renderPipeline->initialize();

    setClearColor({0.0f, 0.0f, 0.0f, 1.0f});

    setCapabilityEnabled(ERenderCapability::DEPTH_TEST, true);
    setDepthAlgorithm(EComparaisonAlgorithm::LESS);
    setCapabilityEnabled(ERenderCapability::MULTISAMPLE, true);
    setCapabilityEnabled(ERenderCapability::CULL_FACE, true);

    auto windowSize = Window::getSingletonPtr()->getDrawableSize();

    Window::getSingletonPtr()->WindowEvent.AddListener([this](SDL_Event *pEvent) {
        auto &event = *pEvent;
        switch (event.type) {
            case SDL_WINDOWEVENT:
                if (event.window.event == SDL_WINDOWEVENT_RESIZED) {
                    onResize({event.window.data1, event.window.data2});
                }
                break;
        }
    });
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

void GLRenderSystem::onResize(const glm::ivec2 &size) {
    m_width = size.x;
    m_height = size.y;

    setViewport(0, 0, m_width, m_height);
}

#include "Renderer/OpenGL/GLRenderCommand.inl"
