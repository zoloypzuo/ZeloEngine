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
using namespace Zelo::Renderer::OpenGL;

// 2 render queue, opaque and transparent, sorted by distance to camera
using OpaqueDrawables = std::multimap<float, Drawable, std::less<float>>;
using TransparentDrawables = std::multimap<float, Drawable, std::greater<float>>;

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

    for (const auto &drawable: sortRenderQueue()) {
        updateEngineUBOModel(drawable.modelMatrix);
        drawable.material->bind();
        drawable.mesh->render();
    }
}

RenderQueue ForwardRenderer::sortRenderQueue() const {
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

        Drawable drawable{
                meshRenderer->getOwner()->getWorldMatrix(),
                &meshRenderer->GetMesh(),
                &material
        };

        if (material.isBlendable()) {
            transparentDrawables.emplace(distantToCamera, drawable);
        } else {
            opaqueDrawables.emplace(distantToCamera, drawable);
        }
    }

    // push opaque object first, then transparent object to render queue
    RenderQueue renderQueue;
    renderQueue.reserve(opaqueDrawables.size() + transparentDrawables.size());
    for (const auto&[distance, drawable]: opaqueDrawables) {
        renderQueue.emplace_back(drawable);
    }

    for (const auto&[distance, drawable]: transparentDrawables) {
        renderQueue.emplace_back(drawable);
    }
    return renderQueue;
}

void ForwardRenderer::initialize() {
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