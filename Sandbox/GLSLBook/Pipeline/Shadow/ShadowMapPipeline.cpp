// ShadowMapPipeline.cpp
// created on 2021/3/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ShadowMapPipeline.h"
#include "Core/Scene/SceneManager.h"
#include "Renderer/OpenGL/Drawable/MeshRenderer.h"

using namespace Zelo::Core::RHI;
using namespace Zelo::Core::Scene;
using namespace Zelo::Core::ECS;
using namespace Zelo::Renderer::OpenGL;

ShadowMapPipeline::ShadowMapPipeline() = default;

ShadowMapPipeline::~ShadowMapPipeline() = default;

void ShadowMapPipeline::preRender() {
    // do nothing
}

void ShadowMapPipeline::render(const Entity &scene) const {
    auto *mainLight = SceneManager::getSingletonPtr()->getMainDirectionalLight(); // TODO handle nullptr
    glm::vec3 lightPos = mainLight->getOwner()->getTransform().getPosition();
    m_lightFrustum->orient(lightPos, glm::vec3(0), glm::vec3(0.0f, 1.0f, 0.0f));
    glm::mat4 lightProjection = m_lightFrustum->getProjectionMatrix();
    glm::mat4 lightView = m_lightFrustum->getViewMatrix();
    glm::mat4 shadowBias = glm::mat4(glm::vec4(0.5f, 0.0f, 0.0f, 0.0f),
                                     glm::vec4(0.0f, 0.5f, 0.0f, 0.0f),
                                     glm::vec4(0.0f, 0.0f, 0.5f, 0.0f),
                                     glm::vec4(0.5f, 0.5f, 0.5f, 1.0f)
    );
    glm::mat4 lightSpaceMatrix = shadowBias * lightProjection * lightView;

    {
        // pass 1 (shadow map generation)
        m_shadowFbo->bind();
        m_shadowMapShader->bind();
        glClear(GL_DEPTH_BUFFER_BIT);
        glViewport(0, 0, 1280, 720);
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_CULL_FACE);
        glCullFace(GL_FRONT);

        m_shadowMapShader->setUniformMatrix4f("View", lightView);
        m_shadowMapShader->setUniformMatrix4f("Proj", lightProjection);
        const auto &meshRenderers = SceneManager::getSingletonPtr()->getFastAccessComponents().meshRenderers;
        for (const auto &meshRenderer: meshRenderers) {
            if (!meshRenderer->getOwner()->IsActive()) { continue; }
            m_shadowMapShader->setUniformMatrix4f("World", meshRenderer->getOwner()->getWorldMatrix());
            meshRenderer->GetMesh().render();
        }
        m_shadowFbo->unbind();

        glDisable(GL_CULL_FACE);
    }

    {
        // pass 2
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        glViewport(0, 0, 1280, 720);
        glEnable(GL_DEPTH_TEST);
        glEnable(GL_CULL_FACE);
        glCullFace(GL_BACK);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

        // shadow
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(GL_TEXTURE_2D, m_shadowFbo->getDepthTexture());
        m_forwardStandardShader->setUniformMatrix4f("u_LightSpaceMatrix", lightSpaceMatrix);
        ForwardStandardPipeline::render(scene);
    }

    auto *camera = SceneManager::getSingletonPtr()->getActiveCamera();
    m_simpleShader->bind();
    m_simpleShader->setUniformMatrix4f("View", camera->getViewMatrix());
    m_simpleShader->setUniformMatrix4f("Proj", camera->getProjectionMatrix());
    m_simpleShader->setUniformMatrix4f("World", m_lightFrustum->getInverseViewMatrix());
    m_lightFrustum->render();
}

void ShadowMapPipeline::initialize() {
    ForwardStandardPipeline::initialize();
    m_shadowFbo = std::make_unique<Zelo::GLShadowMap>(1280, 720);
    m_lightFrustum = std::make_unique<Frustum>();
    m_lightFrustum->setPerspective(50.0f, 1.0f, 5.0f, 1000.0f);

    m_forwardStandardShader = std::make_unique<GLSLShaderProgram>("forward_shadow.glsl");
    m_forwardStandardShader->link();
    m_forwardStandardShader->setUniform1i("u_DiffuseMap", 0);
    m_forwardStandardShader->setUniform1i("u_NormalMap", 1);
    m_forwardStandardShader->setUniform1i("u_SpecularMap", 2);
    // shadow
    m_forwardStandardShader->setUniform1i("u_ShadowMap", 3);

    m_shadowMapShader = std::make_unique<GLSLShaderProgram>("shadow_map.lua");
    m_shadowMapShader->link();

    m_simpleShader = std::make_unique<GLSLShaderProgram>("simple.lua");
    m_simpleShader->link();
}

