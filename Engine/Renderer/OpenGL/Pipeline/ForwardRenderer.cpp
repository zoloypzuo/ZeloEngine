// ForwardRenderer.cpp
// created on 2021/3/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ForwardRenderer.h"
#include "Core/Scene/SceneManager.h"
#include "Renderer/OpenGL/Drawable/MeshRenderer.h"

using namespace Zelo;
using namespace Zelo::Core::RHI;
using namespace Zelo::Core::Scene;

// model matrix, mesh, material, material, /*userdata matrix*/
using Drawable = std::tuple<glm::mat4, Mesh *, Material * /*, glm::mat4*/>;

// 2 render queue, opaque and transparent, sorted by distance to camera
using OpaqueDrawables = std::multimap<float, Drawable, std::less<float>>;
using TransparentDrawables = std::multimap<float, Drawable, std::greater<float>>;
using RenderQueue = std::vector<Drawable>;

namespace Zelo::Renderer::OpenGL {
SimpleRenderer::SimpleRenderer() = default;

SimpleRenderer::~SimpleRenderer() = default;

void SimpleRenderer::render(const Zelo::Core::ECS::Entity &scene) const {
//    m_simple->bind();
//
//    m_simple->setUniformMatrix4f("World", glm::mat4());
//    m_simple->setUniformMatrix4f("View", activeCamera->getViewMatrix());
//    m_simple->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());
//
//    scene.renderAll(m_simple.get());
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

void ForwardRenderer::render(const Zelo::Core::ECS::Entity &scene) const {
    updateLights();
    updateEngineUBO();

    // TODO bind by material
    m_forwardShader->bind();

    OpaqueDrawables opaqueDrawables;
    TransparentDrawables transparentDrawables;

    const auto &meshRenderers = SceneManager::getSingletonPtr()->getFastAccessComponents().meshRenderers;
    const auto &camera = SceneManager::getSingletonPtr()->getActiveCamera();
    for (const auto &meshRenderer: meshRenderers) {
        if (!meshRenderer->getOwner()->IsActive()) { continue; }
        float distantToCamera = glm::distance(meshRenderer->getOwner()->getPosition(),
                                              camera->getOwner()->getPosition());

        auto &material = meshRenderer->GetMaterial();
        Drawable drawable = std::make_tuple(
                meshRenderer->getOwner()->getWorldMatrix(),
                &meshRenderer->GetMesh(),
                &material
        );

        if (material.isBlendable()) {
            transparentDrawables.emplace(distantToCamera, drawable);
        } else {
            opaqueDrawables.emplace(distantToCamera, drawable);
        }
    }

    RenderQueue renderQueue;
    renderQueue.reserve(opaqueDrawables.size() + transparentDrawables.size());
    for (const auto&[distance, drawable]: opaqueDrawables) {
        renderQueue.emplace_back(drawable);
    }

    for (const auto&[distance, drawable]: transparentDrawables) {
        renderQueue.emplace_back(drawable);
    }

    for (const auto &drawable: renderQueue) {
        glm::mat4 modelMatrix;
        Mesh *mesh{};
        Material *material{};
        std::tie(modelMatrix, mesh, material) = drawable;
        updateEngineUBOModel(modelMatrix);
        material->bind();
        mesh->render();
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
    auto lights = SceneManager::getSingletonPtr()->getFastAccessComponents().lights;
    std::vector<glm::mat4> lightMatrices;
    lightMatrices.reserve(lights.size());
    for (const auto &light: lights) {
        lightMatrices.push_back(light->generateLightMatrix());
    }
    m_lightSSBO->sendBlocks<glm::mat4>(lightMatrices.data(), lightMatrices.size() * sizeof(glm::mat4));
}

void ForwardRenderer::updateEngineUBO() const {
    size_t offset = sizeof(glm::mat4);  // skip model matrix;
    auto *camera = SceneManager::getSingletonPtr()->getActiveCamera();
    m_engineUBO->setSubData(camera->getViewMatrix(), std::ref(offset));
    m_engineUBO->setSubData(camera->getProjectionMatrix(), std::ref(offset));
    m_engineUBO->setSubData(camera->getOwner()->getPosition(), std::ref(offset));
}

void ForwardRenderer::updateEngineUBOModel(const glm::mat4 &modelMatrix) const {
    m_engineUBO->setSubData(modelMatrix, 0);
}
}