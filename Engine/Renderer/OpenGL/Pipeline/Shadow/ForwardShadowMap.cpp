// ForwardShadowMap.cpp
// created on 2021/3/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ForwardShadowMap.h"

using namespace Zelo::Core::RHI;

static void renderQuad() {
    static unsigned int quadVAO = 0;
    static unsigned int quadVBO;
    if (quadVAO == 0) {
        float quadVertices[] = {
                // positions        // texture Coords
                -1.0f, 1.0f, 0.0f, 0.0f, 1.0f,
                -1.0f, -1.0f, 0.0f, 0.0f, 0.0f,
                1.0f, 1.0f, 0.0f, 1.0f, 1.0f,
                1.0f, -1.0f, 0.0f, 1.0f, 0.0f,
        };
        // setup plane VAO
        glGenVertexArrays(1, &quadVAO);
        glGenBuffers(1, &quadVBO);
        glBindVertexArray(quadVAO);
        glBindBuffer(GL_ARRAY_BUFFER, quadVBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(quadVertices), &quadVertices, GL_STATIC_DRAW);
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void *) nullptr);
        glEnableVertexAttribArray(1);
        glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(float), (void *) (3 * sizeof(float)));
    }
    glBindVertexArray(quadVAO);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    glBindVertexArray(0);
}

ForwardShadowMap::ForwardShadowMap() = default;

ForwardShadowMap::~ForwardShadowMap() = default;

void ForwardShadowMap::render(const Zelo::Core::ECS::Entity &scene, Camera *activeCamera,
                              const std::vector<std::shared_ptr<PointLight>> &pointLights,
                              const std::vector<std::shared_ptr<DirectionalLight>> &directionalLights,
                              const std::vector<std::shared_ptr<SpotLight>> &spotLights) const {

    glm::vec3 lightPos = directionalLights[0]->getOwner()->getTransform().getPosition();
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
        scene.renderAll(m_shadowMapShader.get());
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

        m_forwardAmbient->setUniformMatrix4f("View", activeCamera->getViewMatrix());
        m_forwardAmbient->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());

        scene.renderAll(m_forwardAmbient.get());

        glEnable(GL_BLEND);
        glBlendFunc(GL_ONE, GL_ONE);
        glDepthMask(GL_FALSE);
        glDepthFunc(GL_EQUAL);

        {
            // directional light
            m_forwardDirectional->bind();

            m_forwardDirectional->setUniformMatrix4f("View", activeCamera->getViewMatrix());
            m_forwardDirectional->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());
            m_forwardDirectional->setUniformVec3f("eyePos", activeCamera->getOwner()->getPosition());

            m_forwardDirectional->setUniform1f("specularIntensity", 0.5);
            m_forwardDirectional->setUniform1f("specularPower", 10);

            // shadow
            glActiveTexture(GL_TEXTURE3);
            glBindTexture(GL_TEXTURE_2D, m_shadowFbo->getDepthTexture());
            m_forwardDirectional->setUniformMatrix4f("lightSpaceMatrix", lightSpaceMatrix);
            m_forwardDirectional->setUniformVec3f("lightPos", lightPos);

            for (const auto &light : directionalLights) {
                light->updateShader(m_forwardDirectional.get());
                scene.renderAll(m_forwardDirectional.get());
            }
        }

        m_forwardPoint->setUniformMatrix4f("View", activeCamera->getViewMatrix());
        m_forwardPoint->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());
        m_forwardPoint->setUniformVec3f("eyePos", activeCamera->getOwner()->getPosition());

        m_forwardPoint->setUniform1f("specularIntensity", 0.5);
        m_forwardPoint->setUniform1f("specularPower", 10);
        for (const auto &light : pointLights) {
            light->updateShader(m_forwardPoint.get());
            scene.renderAll(m_forwardPoint.get());
        }

        m_forwardSpot->setUniformMatrix4f("View", activeCamera->getViewMatrix());
        m_forwardSpot->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());
        m_forwardSpot->setUniformVec3f("eyePos", activeCamera->getOwner()->getPosition());

        m_forwardSpot->setUniform1f("specularIntensity", 0.5);
        m_forwardSpot->setUniform1f("specularPower", 10);
        for (const auto &light : spotLights) {
            light->updateShader(m_forwardSpot.get());
            scene.renderAll(m_forwardSpot.get());
        }

        glDepthFunc(GL_LESS);
        glDepthMask(GL_TRUE);
        glDisable(GL_BLEND);
    }

    m_simpleShader->bind();
    m_simpleShader->setUniformMatrix4f("View", activeCamera->getViewMatrix());
    m_simpleShader->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());
    m_simpleShader->setUniformMatrix4f("World", m_lightFrustum->getInverseViewMatrix());
    m_lightFrustum->render(m_simpleShader.get());

//    m_shadowMapDebugShader->bind();
//    glActiveTexture(GL_TEXTURE0);
//    glBindTexture(GL_TEXTURE_2D, m_shadowFbo->getDepthTexture());
//    renderQuad();
}

void ForwardShadowMap::createShaders() {
    m_forwardAmbient = std::make_unique<GLSLShaderProgram>("Shader/forward-ambient.lua");
    m_forwardAmbient->link();

    m_forwardAmbient->setUniform1i("diffuseMap", 0);

    m_forwardAmbient->setUniformVec3f("ambientIntensity", glm::vec3(0.2f, 0.2f, 0.2f));

    m_forwardDirectional = std::make_unique<GLSLShaderProgram>("Shader/forward-directional.lua");
    m_forwardDirectional->link();
    m_forwardDirectional->setUniform1i("diffuseMap", 0);
    m_forwardDirectional->setUniform1i("normalMap", 1);
    m_forwardDirectional->setUniform1i("specularMap", 2);
    m_forwardDirectional->setUniform1i("shadowMap", 3);

    m_forwardPoint = std::make_unique<GLSLShaderProgram>("Shader/forward-point.lua");
    m_forwardPoint->link();

    m_forwardPoint->setUniform1i("diffuseMap", 0);
    m_forwardPoint->setUniform1i("normalMap", 1);
    m_forwardPoint->setUniform1i("specularMap", 2);

    m_forwardSpot = std::make_unique<GLSLShaderProgram>("Shader/forward-spot.lua");
    m_forwardSpot->link();
    m_forwardSpot->setUniform1i("diffuseMap", 0);
    m_forwardSpot->setUniform1i("normalMap", 1);
    m_forwardSpot->setUniform1i("specularMap", 2);

    m_shadowMapShader = std::make_unique<GLSLShaderProgram>("Shader/shadow_map.lua");
    m_shadowMapShader->link();

    m_shadowMapDebugShader = std::make_unique<GLSLShaderProgram>("Shader/shadow_map_debug.lua");
    m_shadowMapDebugShader->link();
    m_shadowMapDebugShader->setUniform1i("depthMap", 0);
    float near_plane = 1.0f, far_plane = 7.5f;
    m_shadowMapDebugShader->setUniform1f("near_plane", near_plane);
    m_shadowMapDebugShader->setUniform1f("far_plane", far_plane);

    m_simpleShader = std::make_unique<GLSLShaderProgram>("Shader/simple.lua");
    m_simpleShader->link();
}

void ForwardShadowMap::initialize() {
    m_shadowFbo = std::make_unique<Zelo::GLShadowMap>(1280, 720);
    m_lightFrustum = std::make_unique<Frustum>();
    m_lightFrustum->setPerspective(50.0f, 1.0f, 5.0f, 1000.0f);
    createShaders();
}
