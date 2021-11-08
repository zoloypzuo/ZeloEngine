// ForwardRenderer.cpp
// created on 2021/3/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ForwardRenderer.h"
#include "Core/Game/Game.h"
#include "Core/RHI/RenderSystem.h"

using namespace Zelo;

SimpleRenderer::SimpleRenderer() = default;

SimpleRenderer::~SimpleRenderer() = default;

void SimpleRenderer::render(const Zelo::Core::ECS::Entity &scene, Camera *activeCamera,
                            const std::vector<std::shared_ptr<PointLight>> &pointLights,
                            const std::vector<std::shared_ptr<DirectionalLight>> &directionalLights,
                            const std::vector<std::shared_ptr<SpotLight>> &spotLights) const {
    m_simple->bind();

    m_simple->setUniformMatrix4f("World", glm::mat4());
    m_simple->setUniformMatrix4f("View", activeCamera->getViewMatrix());
    m_simple->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());

    scene.renderAll(m_simple.get());
}

void SimpleRenderer::renderLine(const Line &line, const std::shared_ptr<Camera> &activeCamera) const {
    m_simple->bind();

    m_simple->setUniformMatrix4f("World", glm::mat4());
    m_simple->setUniformMatrix4f("View", activeCamera->getViewMatrix());
    m_simple->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());

    line.render(m_simple.get());
}

void SimpleRenderer::initialize() {
    m_simple = std::make_unique<GLSLShaderProgram>("Shader/simple.lua");
    m_simple->link();
}

ForwardRenderer::ForwardRenderer() = default;

ForwardRenderer::~ForwardRenderer() = default;

void ForwardRenderer::render(const Zelo::Core::ECS::Entity &scene, Camera *activeCamera,
                             const std::vector<std::shared_ptr<PointLight>> &pointLights,
                             const std::vector<std::shared_ptr<DirectionalLight>> &directionalLights,
                             const std::vector<std::shared_ptr<SpotLight>> &spotLights) const {
    updateLights();
    updateEngineUBO();

    // TODO bind by material
    m_forwardShader->bind();

    const auto &meshRenderers = Game::getSingletonPtr()->getFastAccessComponents().meshRenderers;
    for (const auto &meshRenderer: meshRenderers) {
        updateEngineUBOModel(meshRenderer->getOwner()->getWorldMatrix());
        meshRenderer->render(m_forwardShader.get());
    }
}

void ForwardRenderer::initialize() {
    m_lightSSBO = std::make_unique<GLShaderStorageBuffer>(Core::RHI::EAccessSpecifier::STREAM_DRAW);
    m_lightSSBO->bind(0);
    m_engineUBO = std::make_unique<GLUniformBuffer>(
            sizeof(EngineUBO), 0, 0,
            Core::RHI::EAccessSpecifier::STREAM_DRAW);

    m_forwardShader = std::make_unique<GLSLShaderProgram>("Shader/forward_standard.lua");
    m_forwardShader->link();
    m_forwardShader->setUniform1i("u_DiffuseMap", 0);
    m_forwardShader->setUniform1i("u_NormalMap", 1);
    m_forwardShader->setUniform1i("u_SpecularMap", 2);
}

void ForwardRenderer::updateLights() const {
    auto lights = Game::getSingletonPtr()->getFastAccessComponents().lights;
    std::vector<glm::mat4> lightMatrices;
    lightMatrices.reserve(lights.size());
    for (const auto &light: lights) {
        lightMatrices.push_back(light->generateLightMatrix());
    }
    m_lightSSBO->sendBlocks<glm::mat4>(lightMatrices.data(), lightMatrices.size() * sizeof(glm::mat4));
}

void ForwardRenderer::updateEngineUBO() const {
    size_t offset = sizeof(glm::mat4);  // skip model matrix;
    auto *camera = Core::RHI::RenderSystem::getSingletonPtr()->getActiveCamera();
    m_engineUBO->setSubData(camera->getViewMatrix(), std::ref(offset));
    m_engineUBO->setSubData(camera->getProjectionMatrix(), std::ref(offset));
    m_engineUBO->setSubData(camera->getOwner()->getPosition(), std::ref(offset));
}

void ForwardRenderer::updateEngineUBOModel(const glm::mat4 &modelMatrix) const {
    m_engineUBO->setSubData(modelMatrix, 0);
}
