// GLRenderSystem.cpp
// created on 2021/3/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLRenderSystem.h"

#include "Core/Scene/SceneManager.h"
#include "Core/OS/Window.h"
#include "Core/LuaScript/LuaScriptManager.h"

#include "Renderer/OpenGL/GLUtil.h"
#include "Renderer/OpenGL/GLLoader.h"
#include "Renderer/OpenGL/Pipeline/ForwardStandardPipeline.h"

using namespace Zelo::Core::RHI;
using namespace Zelo::Core::OS;
using namespace Zelo::Core::Scene;
using namespace Zelo::Core::LuaScript;
using namespace Zelo::Renderer::OpenGL;


GLRenderSystem::GLRenderSystem() : m_config(
        LuaScriptManager::getSingletonPtr()->loadConfig<RenderSystemConfig>("render_system_config.lua")) {}

GLRenderSystem::~GLRenderSystem() = default;

void GLRenderSystem::initialize() {
    ::initGLTracerLogger();

    ::loadGL();

    if (m_config.debug) {
        ::initDebugCallback();
    }

    m_renderPipeline = std::make_unique<ForwardStandardPipeline>();
    m_renderPipeline->initialize();

    setClearColor({0.0f, 0.0f, 0.0f, 1.0f});

    setCapabilityEnabled(ERenderCapability::DEPTH_TEST, true);
    setDepthAlgorithm(EComparaisonAlgorithm::LESS);
    setCapabilityEnabled(ERenderCapability::MULTISAMPLE, true);
    setCapabilityEnabled(ERenderCapability::CULL_FACE, true);

    pushView(Window::getSingletonPtr());
}

void GLRenderSystem::update() {
    const auto &sceneManager = SceneManager::getSingletonPtr();

    if (m_renderPipeline && !m_viewStack.empty()) {  // render only if pipeline and view exists
        m_renderPipeline->preRender();

        if (sceneManager->getActiveCamera()) {
            auto scene = sceneManager->getRootNode();
            m_renderPipeline->render(*scene);
        }
    }
}

void GLRenderSystem::applyCurrentView() {
    auto *view = m_viewStack.back();
    setViewport(0, 0, view->getWidth(), view->getHeight());
}

void GLRenderSystem::pushView(Core::Interface::IView *view) {
    m_viewStack.push_back(view);
    applyCurrentView();
}

void GLRenderSystem::popView() {
    m_viewStack.pop_back();
    applyCurrentView();
}

#include "Renderer/OpenGL/GLRenderCommand.inl"
