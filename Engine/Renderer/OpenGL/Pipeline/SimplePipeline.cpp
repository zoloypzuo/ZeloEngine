// SimplePipeline.cpp
// created on 2021/11/21
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "SimplePipeline.h"
#include "Core/Scene/SceneManager.h"

using namespace Zelo;
using namespace Zelo::Core::RHI;
using namespace Zelo::Core::Scene;

namespace Zelo::Renderer::OpenGL {
SimplePipeline::SimplePipeline() = default;

SimplePipeline::~SimplePipeline() = default;

void SimplePipeline::render(const Zelo::Core::ECS::Entity &scene) const {
//    m_simpleShader->bind();
//
//    m_simpleShader->setUniformMatrix4f("World", glm::mat4());
//    m_simpleShader->setUniformMatrix4f("View", activeCamera->getViewMatrix());
//    m_simpleShader->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());
//
//    scene.renderAll(m_simpleShader.get());
}

void SimplePipeline::renderLine(const Line &line, const std::shared_ptr<Camera> &activeCamera) const {
    m_simpleShader->bind();

    m_simpleShader->setUniformMatrix4f("World", glm::mat4());
    m_simpleShader->setUniformMatrix4f("View", activeCamera->getViewMatrix());
    m_simpleShader->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());

    line.render(m_simpleShader.get());
}

void SimplePipeline::initialize() {
    m_simpleShader = std::make_unique<GLSLShaderProgram>("Shader/simple.lua");
    m_simpleShader->link();
}
}