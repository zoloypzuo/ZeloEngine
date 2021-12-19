// SimplePipeline.cpp
// created on 2021/11/21
// author @zoloypzuo
#include "SimplePipeline.h"

#include "Core/RHI/MeshRenderer.h"
#include "Core/RHI/RenderSystem.h"
#include "Core/Scene/SceneManager.h"

using namespace Zelo;
using namespace Zelo::Core::RHI;
using namespace Zelo::Core::Scene;

namespace Zelo::Renderer::OpenGL {
SimplePipeline::SimplePipeline() = default;

SimplePipeline::~SimplePipeline() = default;

void SimplePipeline::render(const Zelo::Core::ECS::Entity &scene) const {
    RenderSystem::getSingletonPtr()->clear(true, true, false);

    const auto &camera = SceneManager::getSingletonPtr()->getActiveCamera();
    m_simpleShader->bind();

    m_simpleShader->setUniformMatrix4f("World", glm::mat4());
    m_simpleShader->setUniformMatrix4f("View", camera->getViewMatrix());
    m_simpleShader->setUniformMatrix4f("Proj", camera->getProjectionMatrix());

    const auto &meshRenderers = SceneManager::getSingletonPtr()->getFastAccessComponents().meshRenderers;
    for (const auto &meshRenderer: meshRenderers) {
        if (!meshRenderer->getOwner()->IsActive()) { continue; }
        m_simpleShader->setUniformMatrix4f("World", meshRenderer->getOwner()->getWorldMatrix());
        meshRenderer->GetMesh().render();
    }
}

void SimplePipeline::renderLine(const Line &line) const {
    const auto &camera = SceneManager::getSingletonPtr()->getActiveCamera();

    m_simpleShader->bind();
    m_simpleShader->setUniformMatrix4f("World", glm::mat4());
    m_simpleShader->setUniformMatrix4f("View", camera->getViewMatrix());
    m_simpleShader->setUniformMatrix4f("Proj", camera->getProjectionMatrix());

    line.render();
}

void SimplePipeline::initialize() {
    m_simpleShader = std::make_unique<GLSLShaderProgram>("simple.lua");
    m_simpleShader->link();
}
}