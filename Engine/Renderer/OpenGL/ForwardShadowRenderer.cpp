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
    glGenFramebuffers(1, &depthMapFBO);
    // create depth texture
    glGenTextures(1, &depthMap);
    glBindTexture(GL_TEXTURE_2D, depthMap);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, SHADOW_WIDTH, SHADOW_HEIGHT, 0, GL_DEPTH_COMPONENT, GL_FLOAT,
                 NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    // attach depth texture as FBO's depth buffer
    glBindFramebuffer(GL_FRAMEBUFFER, depthMapFBO);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, depthMap, 0);
    glDrawBuffer(GL_NONE);
    glReadBuffer(GL_NONE);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

void ForwardShadowRenderer::render(const Entity &scene, std::shared_ptr<Camera> activeCamera,
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
    lightProjection = glm::ortho(-10.0f, 10.0f, -10.0f, 10.0f, near_plane, far_plane);
    lightView = glm::lookAt(lightPos, glm::vec3(0.0f, 0.0f, 0.0f), glm::vec3(0.0, 1.0, 0.0));
    lightSpaceMatrix = lightProjection * lightView;
    // render scene from light's point of view
    simpleDepthShader->bind();
    simpleDepthShader->setUniformMatrix4f("World", glm::mat4());
    simpleDepthShader->setUniformMatrix4f("lightSpaceMatrix", lightSpaceMatrix);

    glViewport(0, 0, SHADOW_WIDTH, SHADOW_HEIGHT);
    glBindFramebuffer(GL_FRAMEBUFFER, depthMapFBO);
    glEnable(GL_DEPTH_TEST);

    glClear(GL_DEPTH_BUFFER_BIT);
    simpleDepthShader->bind();
    scene.renderAll(simpleDepthShader.get());
    //renderScene(simpleDepthShader.get());  // DEBUG scene

    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    // reset viewport
    glViewport(0, 0, SCR_WIDTH, SCR_HEIGHT);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // 2. render scene as normal using the generated depth/shadow map
    // --------------------------------------------------------------
    glViewport(0, 0, SCR_WIDTH, SCR_HEIGHT);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    m_forwardAmbient->setUniformMatrix4f("View", activeCamera->getViewMatrix());
    m_forwardAmbient->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());

    scene.renderAll(m_forwardAmbient.get());

    glEnable(GL_BLEND);
    glBlendFunc(GL_ONE, GL_ONE);
    glDepthMask(GL_FALSE);
    glDepthFunc(GL_EQUAL);

    // set light uniforms
//    shader.setVec3("viewPos", camera.Position);
//    shader.setVec3("lightPos", lightPos);
//    shader.setMat4("lightSpaceMatrix", lightSpaceMatrix);
//    glActiveTexture(GL_TEXTURE0);
//    glBindTexture(GL_TEXTURE_2D, woodTexture);
//    glActiveTexture(GL_TEXTURE1);
//    glBindTexture(GL_TEXTURE_2D, depthMap);
//    renderScene(shader);

    m_forwardDirectional->setUniformMatrix4f("View", activeCamera->getViewMatrix());
    m_forwardDirectional->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());
    m_forwardDirectional->setUniformVec3f("eyePos", activeCamera->getParent()->getPosition());

    m_forwardDirectional->setUniform1f("specularIntensity", 0.5);
    m_forwardDirectional->setUniform1f("specularPower", 10);

    // shadow
    m_forwardDirectional->setUniformMatrix4f("lightSpaceMatrix", lightSpaceMatrix);
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, depthMap);

    for (const auto &light : directionalLights) {
        light->updateShader(m_forwardDirectional.get());

        scene.renderAll(m_forwardDirectional.get());
    }

    m_forwardPoint->setUniformMatrix4f("View", activeCamera->getViewMatrix());
    m_forwardPoint->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());
    m_forwardPoint->setUniformVec3f("eyePos", activeCamera->getParent()->getPosition());

    m_forwardPoint->setUniform1f("specularIntensity", 0.5);
    m_forwardPoint->setUniform1f("specularPower", 10);
    for (const auto &light : pointLights) {
        light->updateShader(m_forwardPoint.get());

        scene.renderAll(m_forwardPoint.get());
    }

    m_forwardSpot->setUniformMatrix4f("View", activeCamera->getViewMatrix());
    m_forwardSpot->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());
    m_forwardSpot->setUniformVec3f("eyePos", activeCamera->getParent()->getPosition());

    m_forwardSpot->setUniform1f("specularIntensity", 0.5);
    m_forwardSpot->setUniform1f("specularPower", 10);
    for (const auto &light : spotLights) {
        light->updateShader(m_forwardSpot.get());

        scene.renderAll(m_forwardSpot.get());
    }

    glDepthFunc(GL_LESS);
    glDepthMask(GL_TRUE);
    glDisable(GL_BLEND);

#ifdef DEBUG_SHADOWMAP
    // render Depth map to quad for visual debugging
    // ---------------------------------------------
    debugDepthQuad->bind();
    debugDepthQuad->setUniform1f("near_plane", near_plane);
    debugDepthQuad->setUniform1f("far_plane", far_plane);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, depthMap);
    renderQuad();
#endif
}

void ForwardShadowRenderer::createShader() {
    // build and compile shaders
    // -------------------------
    lightPos = glm::vec3(-2.0f, 4.0f, -1.0f);
    simpleDepthShader = std::make_unique<Shader>("Shader/3.1.1.shadow_mapping_depth");
    simpleDepthShader->link();
    simpleDepthShader->createUniform("lightSpaceMatrix");
    simpleDepthShader->createUniform("World");

    debugDepthQuad = std::make_unique<Shader>("Shader/3.1.1.debug_quad");
    debugDepthQuad->link();
    debugDepthQuad->createUniform("depthMap");
    debugDepthQuad->createUniform("near_plane");
    debugDepthQuad->createUniform("far_plane");
    debugDepthQuad->setUniform1i("depthMap", 0);

    m_forwardAmbient = std::make_unique<Shader>("shaders/forward-ambient");
    m_forwardAmbient->setAttribLocation("position", 0);
    m_forwardAmbient->setAttribLocation("texCoord", 1);
    m_forwardAmbient->link();

    m_forwardAmbient->createUniform("View");
    m_forwardAmbient->createUniform("Proj");
    m_forwardAmbient->createUniform("World");
    m_forwardAmbient->createUniform("ambientIntensity");

    m_forwardAmbient->createUniform("diffuseMap");

    m_forwardAmbient->setUniform1i("diffuseMap", 0);

    m_forwardAmbient->setUniformVec3f("ambientIntensity", glm::vec3(0.2f, 0.2f, 0.2f));

    m_forwardDirectional = std::make_unique<Shader>("Shader/forward-directional");
    m_forwardDirectional->setAttribLocation("position", 0);
    m_forwardDirectional->setAttribLocation("texCoord", 1);
    m_forwardDirectional->setAttribLocation("normal", 2);
    m_forwardDirectional->setAttribLocation("tangent", 3);
    m_forwardDirectional->link();

    m_forwardDirectional->createUniform("View");
    m_forwardDirectional->createUniform("Proj");
    m_forwardDirectional->createUniform("World");

    m_forwardDirectional->createUniform("eyePos");
    m_forwardDirectional->createUniform("specularIntensity");
    m_forwardDirectional->createUniform("specularPower");

    m_forwardDirectional->createUniform("directionalLight.base.color");
    m_forwardDirectional->createUniform("directionalLight.base.intensity");

    m_forwardDirectional->createUniform("directionalLight.direction");

    m_forwardDirectional->createUniform("diffuseMap");
    m_forwardDirectional->createUniform("normalMap");
    m_forwardDirectional->createUniform("specularMap");

    m_forwardDirectional->setUniform1i("diffuseMap", 0);
    m_forwardDirectional->setUniform1i("normalMap", 1);
    m_forwardDirectional->setUniform1i("specularMap", 2);
    m_forwardDirectional->setUniform1i("shadowMap", 3);

    m_forwardPoint = std::make_unique<Shader>("shaders/forward-point");
    m_forwardPoint->setAttribLocation("position", 0);
    m_forwardPoint->setAttribLocation("texCoord", 1);
    m_forwardPoint->setAttribLocation("normal", 2);
    m_forwardPoint->setAttribLocation("tangent", 3);
    m_forwardPoint->link();

    m_forwardPoint->createUniform("View");
    m_forwardPoint->createUniform("Proj");
    m_forwardPoint->createUniform("World");

    m_forwardPoint->createUniform("eyePos");
    m_forwardPoint->createUniform("specularIntensity");
    m_forwardPoint->createUniform("specularPower");

    m_forwardPoint->createUniform("pointLight.base.color");
    m_forwardPoint->createUniform("pointLight.base.intensity");

    m_forwardPoint->createUniform("pointLight.attenuation.constant");
    m_forwardPoint->createUniform("pointLight.attenuation.linear");
    m_forwardPoint->createUniform("pointLight.attenuation.exponent");

    m_forwardPoint->createUniform("pointLight.position");
    m_forwardPoint->createUniform("pointLight.range");

    m_forwardPoint->createUniform("diffuseMap");
    m_forwardPoint->createUniform("normalMap");
    m_forwardPoint->createUniform("specularMap");

    m_forwardPoint->setUniform1i("diffuseMap", 0);
    m_forwardPoint->setUniform1i("normalMap", 1);
    m_forwardPoint->setUniform1i("specularMap", 2);

    m_forwardSpot = std::make_unique<Shader>("shaders/forward-spot");
    m_forwardSpot->setAttribLocation("position", 0);
    m_forwardSpot->setAttribLocation("texCoord", 1);
    m_forwardSpot->setAttribLocation("normal", 2);
    m_forwardSpot->setAttribLocation("tangent", 3);
    m_forwardSpot->link();

    m_forwardSpot->createUniform("View");
    m_forwardSpot->createUniform("Proj");
    m_forwardSpot->createUniform("World");

    m_forwardSpot->createUniform("eyePos");
    m_forwardSpot->createUniform("specularIntensity");
    m_forwardSpot->createUniform("specularPower");

    m_forwardSpot->createUniform("spotLight.pointLight.base.color");
    m_forwardSpot->createUniform("spotLight.pointLight.base.intensity");

    m_forwardSpot->createUniform("spotLight.pointLight.attenuation.constant");
    m_forwardSpot->createUniform("spotLight.pointLight.attenuation.linear");
    m_forwardSpot->createUniform("spotLight.pointLight.attenuation.exponent");

    m_forwardSpot->createUniform("spotLight.pointLight.position");
    m_forwardSpot->createUniform("spotLight.pointLight.range");

    m_forwardSpot->createUniform("spotLight.cutoff");
    m_forwardSpot->createUniform("spotLight.direction");

    m_forwardSpot->createUniform("diffuseMap");
    m_forwardSpot->createUniform("normalMap");
    m_forwardSpot->createUniform("specularMap");

    m_forwardSpot->setUniform1i("diffuseMap", 0);
    m_forwardSpot->setUniform1i("normalMap", 1);
    m_forwardSpot->setUniform1i("specularMap", 2);
}

void ForwardShadowRenderer::initialize() {
    initializeShadowMap();
    createShader();
}

#ifdef DEBUG_SHADOWMAP

void ForwardShadowRenderer::renderScene(Shader *shader) const {
    // floor
    glm::mat4 model = glm::mat4(1.0f);
//    shader.setMat4("model", model);
//    glBindVertexArray(planeVAO);
//    glDrawArrays(GL_TRIANGLES, 0, 6);
    // cubes
    model = glm::mat4(1.0f);
    model = glm::translate(model, glm::vec3(0.0f, 1.5f, 0.0));
    model = glm::scale(model, glm::vec3(0.5f));
    shader->setUniformMatrix4f("World", model);
    renderCube();
    model = glm::mat4(1.0f);
    model = glm::translate(model, glm::vec3(2.0f, 0.0f, 1.0));
    model = glm::scale(model, glm::vec3(0.5f));
    shader->setUniformMatrix4f("World", model);


    renderCube();
    model = glm::mat4(1.0f);
    model = glm::translate(model, glm::vec3(-1.0f, 0.0f, 2.0));
    model = glm::rotate(model, glm::radians(60.0f), glm::normalize(glm::vec3(1.0, 0.0, 1.0)));
    model = glm::scale(model, glm::vec3(0.25));
    shader->setUniformMatrix4f("World", model);
    renderCube();
}

unsigned int cubeVAO = 0;
unsigned int cubeVBO = 0;

void ForwardShadowRenderer::renderCube() const {
    // initialize (if necessary)
    if (cubeVAO == 0) {
        float vertices[] = {
                // back face
                -1.0f, -1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, // bottom-left
                1.0f, 1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 1.0f, 1.0f, // top-right
                1.0f, -1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 1.0f, 0.0f, // bottom-right
                1.0f, 1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 1.0f, 1.0f, // top-right
                -1.0f, -1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 0.0f, // bottom-left
                -1.0f, 1.0f, -1.0f, 0.0f, 0.0f, -1.0f, 0.0f, 1.0f, // top-left
                // front face
                -1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, // bottom-left
                1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 0.0f, // bottom-right
                1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, // top-right
                1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, 1.0f, // top-right
                -1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 1.0f, // top-left
                -1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, 0.0f, // bottom-left
                // left face
                -1.0f, 1.0f, 1.0f, -1.0f, 0.0f, 0.0f, 1.0f, 0.0f, // top-right
                -1.0f, 1.0f, -1.0f, -1.0f, 0.0f, 0.0f, 1.0f, 1.0f, // top-left
                -1.0f, -1.0f, -1.0f, -1.0f, 0.0f, 0.0f, 0.0f, 1.0f, // bottom-left
                -1.0f, -1.0f, -1.0f, -1.0f, 0.0f, 0.0f, 0.0f, 1.0f, // bottom-left
                -1.0f, -1.0f, 1.0f, -1.0f, 0.0f, 0.0f, 0.0f, 0.0f, // bottom-right
                -1.0f, 1.0f, 1.0f, -1.0f, 0.0f, 0.0f, 1.0f, 0.0f, // top-right
                // right face
                1.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, // top-left
                1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, // bottom-right
                1.0f, 1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 1.0f, // top-right
                1.0f, -1.0f, -1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 1.0f, // bottom-right
                1.0f, 1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 1.0f, 0.0f, // top-left
                1.0f, -1.0f, 1.0f, 1.0f, 0.0f, 0.0f, 0.0f, 0.0f, // bottom-left
                // bottom face
                -1.0f, -1.0f, -1.0f, 0.0f, -1.0f, 0.0f, 0.0f, 1.0f, // top-right
                1.0f, -1.0f, -1.0f, 0.0f, -1.0f, 0.0f, 1.0f, 1.0f, // top-left
                1.0f, -1.0f, 1.0f, 0.0f, -1.0f, 0.0f, 1.0f, 0.0f, // bottom-left
                1.0f, -1.0f, 1.0f, 0.0f, -1.0f, 0.0f, 1.0f, 0.0f, // bottom-left
                -1.0f, -1.0f, 1.0f, 0.0f, -1.0f, 0.0f, 0.0f, 0.0f, // bottom-right
                -1.0f, -1.0f, -1.0f, 0.0f, -1.0f, 0.0f, 0.0f, 1.0f, // top-right
                // top face
                -1.0f, 1.0f, -1.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, // top-left
                1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f, // bottom-right
                1.0f, 1.0f, -1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f, // top-right
                1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 1.0f, 0.0f, // bottom-right
                -1.0f, 1.0f, -1.0f, 0.0f, 1.0f, 0.0f, 0.0f, 1.0f, // top-left
                -1.0f, 1.0f, 1.0f, 0.0f, 1.0f, 0.0f, 0.0f, 0.0f  // bottom-left
        };
        glGenVertexArrays(1, &cubeVAO);
        glGenBuffers(1, &cubeVBO);
        // fill buffer
        glBindBuffer(GL_ARRAY_BUFFER, cubeVBO);
        glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
        // link vertex attributes
        glBindVertexArray(cubeVAO);
        glEnableVertexAttribArray(0);
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void *) 0);
        glEnableVertexAttribArray(1);
        glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void *) (3 * sizeof(float)));
        glEnableVertexAttribArray(2);
        glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, 8 * sizeof(float), (void *) (6 * sizeof(float)));
        glBindBuffer(GL_ARRAY_BUFFER, 0);
        glBindVertexArray(0);
    }
    // render Cube
    glBindVertexArray(cubeVAO);
    glDrawArrays(GL_TRIANGLES, 0, 36);
    glBindVertexArray(0);
}

void ForwardShadowRenderer::renderQuad() const {
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
#endif