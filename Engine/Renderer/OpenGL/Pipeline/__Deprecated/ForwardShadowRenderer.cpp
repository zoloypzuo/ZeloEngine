// ForwardShadowRenderer.cpp
// created on 2021/4/15
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ForwardShadowRenderer.h"

const unsigned int SHADOW_WIDTH = 1024, SHADOW_HEIGHT = 1024;
const unsigned int SCR_WIDTH = 800;
const unsigned int SCR_HEIGHT = 600;

void ForwardShadowRenderer::initializeShadowMap() {
    // configure depth map FBO
    // -----------------------
    glGenFramebuffers(1, &m_depthMapFBO);

    // create depth texture
    glGenTextures(1, &m_depthMap);
    glBindTexture(GL_TEXTURE_2D, m_depthMap);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, SHADOW_WIDTH, SHADOW_HEIGHT, 0, GL_DEPTH_COMPONENT, GL_FLOAT,
                 NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);

    // attach depth texture as FBO's depth buffer
    glBindFramebuffer(GL_FRAMEBUFFER, m_depthMapFBO);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, m_depthMap, 0);
    glDrawBuffer(GL_NONE);
    glReadBuffer(GL_NONE);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    // shader
    m_simpleDepthShader = std::make_unique<GLSLShaderProgram>("3.1.1.shadow_mapping_depth.lua");
    m_simpleDepthShader->link();

    m_debugDepthQuad = std::make_unique<GLSLShaderProgram>("3.1.1.debug_quad.lua");
    m_debugDepthQuad->link();
    m_debugDepthQuad->setUniform1i("m_depthMap", 0);
}

void ForwardShadowRenderer::render(const Zelo::Core::ECS::Entity &scene, Camera *activeCamera,
                                   const std::vector<std::shared_ptr<PointLight>> &pointLights,
                                   const std::vector<std::shared_ptr<DirectionalLight>> &directionalLights,
                                   const std::vector<std::shared_ptr<SpotLight>> &spotLights) const {
    // render
    // ------
    glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // 1. render depth of scene to texture (from light's perspective)
    // --------------------------------------------------------------
    glm::mat4 lightProjection, lightView;
    glm::mat4 lightSpaceMatrix;
    float near_plane = 0.1f, far_plane = 7.5f;
    auto lightPos = directionalLights[0]->getOwner()->getTransform().getPosition();
    lightProjection = glm::ortho(-10.0f, 10.0f, -10.0f, 10.0f, near_plane, far_plane);
    lightView = glm::lookAt(lightPos, glm::vec3(0.0f, 0.0f, 0.0f), glm::vec3(0.0, 1.0, 0.0));
    lightSpaceMatrix = lightProjection * lightView;
    // render scene from light's point of view
    m_simpleDepthShader->bind();
    m_simpleDepthShader->setUniformMatrix4f("World", glm::mat4());
    m_simpleDepthShader->setUniformMatrix4f("lightSpaceMatrix", lightSpaceMatrix);

    glViewport(0, 0, SHADOW_WIDTH, SHADOW_HEIGHT);
    glBindFramebuffer(GL_FRAMEBUFFER, m_depthMapFBO);
    glEnable(GL_DEPTH_TEST);

    glClear(GL_DEPTH_BUFFER_BIT);
    m_simpleDepthShader->bind();
    scene.renderAll(m_simpleDepthShader.get());
    renderScene(m_simpleDepthShader.get());  // DEBUG scene

    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    // reset viewport
    glViewport(0, 0, SCR_WIDTH, SCR_HEIGHT);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // 2. render scene as normal using the generated depth/shadow map
    // --------------------------------------------------------------
    glViewport(0, 0, SCR_WIDTH, SCR_HEIGHT);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // render sky
    m_skyboxShader->bind();
    m_skyboxTex->bind(0);
    m_skyboxShader->setUniformVec3f("WorldCameraPosition", activeCamera->getTransform().getPosition());
    m_skyboxShader->setUniformMatrix4f("ModelMatrix", glm::mat4(1.0f));
    m_skyboxShader->setUniformMatrix4f("MVP", activeCamera->getProjectionMatrix() * activeCamera->getViewMatrix());
    m_skyboxShader->setUniform1i("DrawSkyBox", true);
    m_skybox->render();
    m_skyboxShader->setUniform1i("DrawSkyBox", false);

    m_forwardAmbient->bind();
    m_forwardAmbient->setUniformMatrix4f("View", activeCamera->getViewMatrix());
    m_forwardAmbient->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());

    scene.renderAll(m_forwardAmbient.get());

    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE);
    glDepthMask(GL_FALSE);
    glDepthFunc(GL_EQUAL);

    m_forwardAmbient->bind();
    m_forwardDirectional->setUniformMatrix4f("View", activeCamera->getViewMatrix());
    m_forwardDirectional->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());
    m_forwardDirectional->setUniformVec3f("eyePos", activeCamera->getOwner()->getPosition());

    m_forwardDirectional->setUniform1f("specularIntensity", 0.5);
    m_forwardDirectional->setUniform1f("specularPower", 10);

    // shadow
    m_forwardDirectional->setUniformMatrix4f("lightSpaceMatrix", lightSpaceMatrix);
    m_forwardDirectional->setUniformVec3f("lightPos", lightPos);

    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, m_depthMap);

    for (const auto &light : directionalLights) {
        light->updateShader(m_forwardDirectional.get());

        scene.renderAll(m_forwardDirectional.get());

        renderScene(m_forwardDirectional.get());
    }

    m_forwardPoint->bind();
    m_forwardPoint->setUniformMatrix4f("View", activeCamera->getViewMatrix());
    m_forwardPoint->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());
    m_forwardPoint->setUniformVec3f("eyePos", activeCamera->getOwner()->getPosition());

    m_forwardPoint->setUniform1f("specularIntensity", 0.5);
    m_forwardPoint->setUniform1f("specularPower", 10);
    for (const auto &light : pointLights) {
        light->updateShader(m_forwardPoint.get());

        scene.renderAll(m_forwardPoint.get());
    }

    m_forwardSpot->bind();
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

void ForwardShadowRenderer::createShader() {
    // build and compile shaders
    // -------------------------
    m_forwardAmbient = std::make_unique<GLSLShaderProgram>("forward-ambient.lua");
    m_forwardAmbient->link();

    m_forwardAmbient->setUniform1i("diffuseMap", 0);

    m_forwardAmbient->setUniformVec3f("ambientIntensity", glm::vec3(0.2f, 0.2f, 0.2f));

    m_forwardDirectional = std::make_unique<GLSLShaderProgram>("forward-directional.lua");
    m_forwardDirectional->link();

    m_forwardDirectional->setUniform1i("diffuseMap", 0);
    m_forwardDirectional->setUniform1i("normalMap", 1);
    m_forwardDirectional->setUniform1i("specularMap", 2);
    m_forwardDirectional->setUniform1i("shadowMap", 3);

    m_forwardPoint = std::make_unique<GLSLShaderProgram>("forward-point.lua");
    m_forwardPoint->link();

    m_forwardPoint->setUniform1i("diffuseMap", 0);
    m_forwardPoint->setUniform1i("normalMap", 1);
    m_forwardPoint->setUniform1i("specularMap", 2);

    m_forwardSpot = std::make_unique<GLSLShaderProgram>("forward-spot.lua");
    m_forwardSpot->link();

    m_forwardSpot->setUniform1i("diffuseMap", 0);
    m_forwardSpot->setUniform1i("normalMap", 1);
    m_forwardSpot->setUniform1i("specularMap", 2);

}

void ForwardShadowRenderer::initialize() {
    initializeSkybox();
    initializeShadowMap();
    createShader();
}

void ForwardShadowRenderer::initializeSkybox() {
    m_skyboxTex = std::make_unique<GLTexture3D>("texture/cubemap_night/night");
    m_skybox = std::make_unique<SkyBox>();

    m_skyboxShader = std::make_unique<GLSLShaderProgram>("cubemap_reflect.lua");
    m_skyboxShader->link();
    m_skyboxShader->setUniform1i("CubeMapTex", 0);
}
