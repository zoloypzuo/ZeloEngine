// ForwardRendererPost.cpp
// created on 2021/3/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ForwardRendererPost.h"

static void renderQuad() {
    static unsigned int quadVAO = 0;
    static unsigned int quadVBO;
    if (quadVAO == 0) {
        float quadVertices[] = {
                // positions        // texture Coords
                0.5f, 1.0f, 0.0f, 0.0f, 1.0f,
                0.5f, 0.5f, 0.0f, 0.0f, 0.0f,
                1.0f, 1.0f, 0.0f, 1.0f, 1.0f,
                1.0f, 0.5f, 0.0f, 1.0f, 0.0f,
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

ForwardRendererPost::ForwardRendererPost() = default;

ForwardRendererPost::~ForwardRendererPost() = default;

void ForwardRendererPost::render(const Zelo::Core::ECS::Entity &scene, Camera *activeCamera,
                             const std::vector<std::shared_ptr<PointLight>> &pointLights,
                             const std::vector<std::shared_ptr<DirectionalLight>> &directionalLights,
                             const std::vector<std::shared_ptr<SpotLight>> &spotLights) const {
    
    m_fbo->bind();
    m_forwardAmbient->setUniformMatrix4f("View", activeCamera->getViewMatrix());
    m_forwardAmbient->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());

    scene.renderAll(m_forwardAmbient.get());

    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE);
    glDepthMask(GL_FALSE);
    glDepthFunc(GL_EQUAL);

    m_forwardDirectional->setUniformMatrix4f("View", activeCamera->getViewMatrix());
    m_forwardDirectional->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());
    m_forwardDirectional->setUniformVec3f("eyePos", activeCamera->getOwner()->getPosition());

    m_forwardDirectional->setUniform1f("specularIntensity", 0.5);
    m_forwardDirectional->setUniform1f("specularPower", 10);
    for (const auto &light : directionalLights) {
//        light->updateShader(m_forwardDirectional.get());

        scene.renderAll(m_forwardDirectional.get());
    }

    m_forwardPoint->setUniformMatrix4f("View", activeCamera->getViewMatrix());
    m_forwardPoint->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());
    m_forwardPoint->setUniformVec3f("eyePos", activeCamera->getOwner()->getPosition());

    m_forwardPoint->setUniform1f("specularIntensity", 0.5);
    m_forwardPoint->setUniform1f("specularPower", 10);
    for (const auto &light : pointLights) {
//        light->updateShader(m_forwardPoint.get());

        scene.renderAll(m_forwardPoint.get());
    }

    m_forwardSpot->setUniformMatrix4f("View", activeCamera->getViewMatrix());
    m_forwardSpot->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());
    m_forwardSpot->setUniformVec3f("eyePos", activeCamera->getOwner()->getPosition());

    m_forwardSpot->setUniform1f("specularIntensity", 0.5);
    m_forwardSpot->setUniform1f("specularPower", 10);
    for (const auto &light : spotLights) {
//        light->updateShader(m_forwardSpot.get());

        scene.renderAll(m_forwardSpot.get());
    }

    glDepthFunc(GL_LESS);
    glDepthMask(GL_TRUE);
    glDisable(GL_BLEND);

    m_fbo->unbind();
    
    // pass2
    m_postShader->bind();
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, m_fbo->getRenderTextureID());
    renderQuad();
}

void ForwardRendererPost::createShaders() {
    m_forwardAmbient = std::make_unique<GLSLShaderProgram>("Shader/forward-ambient.lua");
    m_forwardAmbient->link();

    m_forwardAmbient->setUniform1i("diffuseMap", 0);

    m_forwardAmbient->setUniformVec3f("ambientIntensity", glm::vec3(0.2f, 0.2f, 0.2f));

    m_forwardDirectional = std::make_unique<GLSLShaderProgram>("Shader/forward-directional.lua");
    m_forwardDirectional->link();
    m_forwardDirectional->setUniform1i("diffuseMap", 0);
    m_forwardDirectional->setUniform1i("normalMap", 1);
    m_forwardDirectional->setUniform1i("specularMap", 2);

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

    m_postShader = std::make_unique<GLSLShaderProgram>("Shader/edge_post.lua");
    m_postShader->link();
    m_postShader->setUniform1i("RenderTex", 0);
    m_postShader->setUniform1f("EdgeThreshold", 0.05f);
}

void ForwardRendererPost::initialize() {
    m_fbo = std::make_unique<Zelo::GLFramebuffer>();
    m_fbo->resize(1280, 720);
    createShaders();
}
