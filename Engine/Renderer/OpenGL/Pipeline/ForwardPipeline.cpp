// ForwardPipeline.cpp
// created on 2021/3/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ForwardPipeline.h"

#include "Core/Scene/SceneManager.h"
#include "Core/RHI/RenderSystem.h"
#include "Renderer/OpenGL/Drawable/MeshRenderer.h"

using namespace Zelo;
using namespace Zelo::Core::RHI;
using namespace Zelo::Core::Scene;
using namespace Zelo::Renderer::OpenGL;

// 2 render queue, opaque and transparent, sorted by distance to camera
using OpaqueDrawables = std::multimap<float, RenderItem, std::less<float>>;
using TransparentDrawables = std::multimap<float, RenderItem, std::greater<float>>;

namespace Zelo::Renderer::OpenGL {
ForwardPipeline::ForwardPipeline() = default;

ForwardPipeline::~ForwardPipeline() = default;

void ForwardPipeline::render(const Zelo::Core::ECS::Entity &scene) const {
    RenderSystem::getSingletonPtr()->clear(true, true, false);

    updateLights();
    updateEngineUBO();

    for (const auto &renderItem: sortRenderQueue()) {
        updateEngineUBOModel(renderItem.modelMatrix);
        renderItem.material->bind();
        renderItem.mesh->render();
    }
}

RenderQueue ForwardPipeline::sortRenderQueue() const {
    OpaqueDrawables opaqueDrawables;
    TransparentDrawables transparentDrawables;

    // sort by opaque/transparent, then by distance to the camera
    const auto &meshRenderers = SceneManager::getSingletonPtr()->getFastAccessComponents().meshRenderers;
    const auto &camera = SceneManager::getSingletonPtr()->getActiveCamera();
    for (const auto &meshRenderer: meshRenderers) {
        if (!meshRenderer->getOwner()->IsActive()) { continue; }
        float distantToCamera = glm::distance(
                meshRenderer->getOwner()->getPosition(),
                camera->getOwner()->getPosition());

        auto &material = meshRenderer->GetMaterial();

        // use standard shader as default
        if (!material.hasShader()){
            material.setShader(m_forwardStandardShader);
        }

        RenderItem renderItem{
                meshRenderer->getOwner()->getWorldMatrix(),
                &meshRenderer->GetMesh(),
                &material
        };

        if (material.isBlendable()) {
            transparentDrawables.emplace(distantToCamera, renderItem);
        } else {
            opaqueDrawables.emplace(distantToCamera, renderItem);
        }
    }

    // push opaque object first, then transparent object to render queue
    RenderQueue renderQueue;
    renderQueue.reserve(opaqueDrawables.size() + transparentDrawables.size());
    for (const auto&[distance, renderItem]: opaqueDrawables) {
        renderQueue.emplace_back(renderItem);
    }

    for (const auto&[distance, renderItem]: transparentDrawables) {
        renderQueue.emplace_back(renderItem);
    }
    return renderQueue;
}

void ForwardPipeline::initialize() {
    m_lightSSBO = std::make_unique<GLShaderStorageBuffer>(Core::RHI::EAccessSpecifier::STREAM_DRAW);
    m_lightSSBO->bind(0);
    m_engineUBO = std::make_unique<GLUniformBuffer>(
            sizeof(EngineUBO), 0, 0,
            Core::RHI::EAccessSpecifier::STREAM_DRAW);

    m_forwardStandardShader = std::make_shared<GLSLShaderProgram>("Shader/forward_standard.glsl");
    m_forwardStandardShader->link();
    m_forwardStandardShader->setUniform1i("u_DiffuseMap", 0);
    m_forwardStandardShader->setUniform1i("u_NormalMap", 1);
    m_forwardStandardShader->setUniform1i("u_SpecularMap", 2);
}

void ForwardPipeline::updateLights() const {
    auto lights = SceneManager::getSingletonPtr()->getFastAccessComponents().lights;
    std::vector<glm::mat4> lightMatrices;
    lightMatrices.reserve(lights.size());
    for (const auto &light: lights) {
        lightMatrices.push_back(light->generateLightMatrix());
    }
    m_lightSSBO->sendBlocks<glm::mat4>(lightMatrices.data(), lightMatrices.size() * sizeof(glm::mat4));
}

void ForwardPipeline::updateEngineUBO() const {
    size_t offset = sizeof(glm::mat4);  // skip model matrix;
    auto *camera = SceneManager::getSingletonPtr()->getActiveCamera();
    m_engineUBO->setSubData(camera->getViewMatrix(), std::ref(offset));
    m_engineUBO->setSubData(camera->getProjectionMatrix(), std::ref(offset));
    m_engineUBO->setSubData(camera->getOwner()->getPosition(), std::ref(offset));
}

void ForwardPipeline::updateEngineUBOModel(const glm::mat4 &modelMatrix) const {
    m_engineUBO->setSubData(modelMatrix, 0);
}
}