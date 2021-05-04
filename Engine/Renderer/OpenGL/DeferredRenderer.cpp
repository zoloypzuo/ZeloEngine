// DeferredRenderer.cpp.cc
// created on 2021/4/28
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "DeferredRenderer.h"

const unsigned int SHADOW_WIDTH = 1024, SHADOW_HEIGHT = 1024;
const unsigned int SCR_WIDTH = 800;
const unsigned int SCR_HEIGHT = 600;


void DeferredRenderer::initializeShadowMap() {
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
    m_simpleDepthShader = std::make_unique<Shader>("Shader/3.1.1.shadow_mapping_depth.lua");
    m_simpleDepthShader->link();

    m_debugDepthQuad = std::make_unique<Shader>("Shader/3.1.1.debug_quad.lua");
    m_debugDepthQuad->link();
    m_debugDepthQuad->setUniform1i("m_depthMap", 0);
}

void DeferredRenderer::render(const Entity &scene, std::shared_ptr<Camera> activeCamera,
                              const std::vector<std::shared_ptr<PointLight>> &pointLights,
                              const std::vector<std::shared_ptr<DirectionalLight>> &directionalLights,
                              const std::vector<std::shared_ptr<SpotLight>> &spotLights) const {
    glBindFramebuffer(GL_FRAMEBUFFER, deferredFBO);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    glUniformSubroutinesuiv(GL_FRAGMENT_SHADER, 1, &pass1Index);

    auto view = activeCamera->getViewMatrix();
    auto projection = activeCamera->getProjectionMatrix();


    m_deferredShader->setUniformVec4f("Light.Position", glm::vec4(0.0f, 0.0f, 0.0f, 1.0f));
    m_deferredShader->setUniformVec3f("Material.Kd", glm::vec3(0.9f, 0.9f, 0.9f));

    // render item TODO

    glFinish();

    glFlush();

    // Revert to default framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    glUniformSubroutinesuiv(GL_FRAGMENT_SHADER, 1, &pass2Index);

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glDisable(GL_DEPTH_TEST);

    view = glm::mat4(1.0);
    auto model = glm::mat4(1.0);
    projection = glm::mat4(1.0);
//    setMatrices();

    // Render the quad
    glBindVertexArray(quad);
    glDrawArrays(GL_TRIANGLES, 0, 6);

    // render
    // ------
    glClearColor(0.1f, 0.1f, 0.1f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    // 1. render depth of scene to texture (from light's perspective)
    // --------------------------------------------------------------
    glm::mat4 lightProjection, lightView;
    glm::mat4 lightSpaceMatrix;
    float near_plane = 0.1f, far_plane = 7.5f;
    auto lightPos = directionalLights[0]->getParent()->getTransform().getPosition();
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
    m_forwardDirectional->setUniformVec3f("eyePos", activeCamera->getParent()->getPosition());

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

//        renderScene(m_forwardDirectional.get());
    }

    m_forwardPoint->bind();
    m_forwardPoint->setUniformMatrix4f("View", activeCamera->getViewMatrix());
    m_forwardPoint->setUniformMatrix4f("Proj", activeCamera->getProjectionMatrix());
    m_forwardPoint->setUniformVec3f("eyePos", activeCamera->getParent()->getPosition());

    m_forwardPoint->setUniform1f("specularIntensity", 0.5);
    m_forwardPoint->setUniform1f("specularPower", 10);
    for (const auto &light : pointLights) {
        light->updateShader(m_forwardPoint.get());

        scene.renderAll(m_forwardPoint.get());
    }

    m_forwardSpot->bind();
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
    m_debugDepthQuad->bind();
    m_debugDepthQuad->setUniform1f("near_plane", near_plane);
    m_debugDepthQuad->setUniform1f("far_plane", far_plane);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, m_depthMap);
    renderQuad();
#endif
}

void DeferredRenderer::createShader() {
    // build and compile shaders
    // -------------------------
    m_forwardAmbient = std::make_unique<Shader>("Shader/forward-ambient.lua");
    m_forwardAmbient->link();

    m_forwardAmbient->setUniform1i("diffuseMap", 0);

    m_forwardAmbient->setUniformVec3f("ambientIntensity", glm::vec3(0.2f, 0.2f, 0.2f));

    m_forwardDirectional = std::make_unique<Shader>("Shader/forward-directional.lua");
    m_forwardDirectional->link();

    m_forwardDirectional->setUniform1i("diffuseMap", 0);
    m_forwardDirectional->setUniform1i("normalMap", 1);
    m_forwardDirectional->setUniform1i("specularMap", 2);
    m_forwardDirectional->setUniform1i("shadowMap", 3);

    m_forwardPoint = std::make_unique<Shader>("Shader/forward-point.lua");
    m_forwardPoint->link();

    m_forwardPoint->setUniform1i("diffuseMap", 0);
    m_forwardPoint->setUniform1i("normalMap", 1);
    m_forwardPoint->setUniform1i("specularMap", 2);

    m_forwardSpot = std::make_unique<Shader>("Shader/forward-spot.lua");
    m_forwardSpot->link();

    m_forwardSpot->setUniform1i("diffuseMap", 0);
    m_forwardSpot->setUniform1i("normalMap", 1);
    m_forwardSpot->setUniform1i("specularMap", 2);

}

void DeferredRenderer::initialize() {
    initializeSkybox();
    initializeShadowMap();
    initializeDeferred();
    createShader();
}

void DeferredRenderer::initializeSkybox() {
    m_skyboxTex = std::make_unique<Texture3D>("texture/cubemap_night/night");
    m_skybox = std::make_unique<SkyBox>();

    m_skyboxShader = std::make_unique<Shader>("Shader/cubemap_reflect.lua");
    m_skyboxShader->link();
    m_skyboxShader->setUniform1i("CubeMapTex", 0);
}

void createGBufTex(GLenum texUnit, GLenum format, GLuint &texid) {
    glActiveTexture(texUnit);
    glGenTextures(1, &texid);
    glBindTexture(GL_TEXTURE_2D, texid);
#ifdef __APPLE__
    glTexImage2D(GL_TEXTURE_2D, 0, format, SCR_WIDTH, SCR_HEIGHT, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL);
#else
    glTexStorage2D(GL_TEXTURE_2D, 1, format, SCR_WIDTH, SCR_HEIGHT);
#endif
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAX_LEVEL, 0);
}

void DeferredRenderer::initializeDeferred() {
    m_deferredShader = std::make_unique<Shader>("Shader/deferred.lua");
    m_deferredShader->link();
    m_deferredShader->bind();
    initializeQuad();
    initializeFbo();
    initializeParam();
}

void DeferredRenderer::initializeFbo() {
    GLuint depthBuf, posTex, normTex, colorTex;

    // Create and bind the FBO
    glGenFramebuffers(1, &deferredFBO);
    glBindFramebuffer(GL_FRAMEBUFFER, deferredFBO);

    // The depth buffer
    glGenRenderbuffers(1, &depthBuf);
    glBindRenderbuffer(GL_RENDERBUFFER, depthBuf);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT, SCR_WIDTH, SCR_HEIGHT);

    // Create the textures for position, normal and color
    createGBufTex(GL_TEXTURE0, GL_RGB32F, posTex);  // Position
    createGBufTex(GL_TEXTURE1, GL_RGB32F, normTex); // Normal
    createGBufTex(GL_TEXTURE2, GL_RGB8, colorTex);  // Color

    // Attach the textures to the framebuffer
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthBuf);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, posTex, 0);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT1, GL_TEXTURE_2D, normTex, 0);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT2, GL_TEXTURE_2D, colorTex, 0);

    GLenum drawBuffers[] = {GL_NONE, GL_COLOR_ATTACHMENT0, GL_COLOR_ATTACHMENT1,
                            GL_COLOR_ATTACHMENT2};
    glDrawBuffers(4, drawBuffers);

    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

void DeferredRenderer::initializeParam() {// Set up the subroutine indexes
    GLuint programHandle = m_deferredShader->getHandle();
    m_deferredShader->printActiveAttributes();
    m_deferredShader->printActiveUniforms();
    pass1Index = glGetSubroutineIndex(programHandle, GL_FRAGMENT_SHADER, "pass1");
    pass2Index = glGetSubroutineIndex(programHandle, GL_FRAGMENT_SHADER, "pass2");

    m_deferredShader->setUniformVec3f("Light.Intensity", glm::vec3(1.0f, 1.0f, 1.0f));

// #ifdef __APPLE__
    m_deferredShader->setUniform1i("PositionTex", 0);
    m_deferredShader->setUniform1i("NormalTex", 1);
    m_deferredShader->setUniform1i("ColorTex", 2);
// #endif

}

void DeferredRenderer::initializeQuad() {// Array for quad
    GLfloat verts[] = {
            -1.0f, -1.0f, 0.0f, 1.0f, -1.0f, 0.0f, 1.0f, 1.0f, 0.0f,
            -1.0f, -1.0f, 0.0f, 1.0f, 1.0f, 0.0f, -1.0f, 1.0f, 0.0f
    };
    GLfloat tc[] = {
            0.0f, 0.0f, 1.0f, 0.0f, 1.0f, 1.0f,
            0.0f, 0.0f, 1.0f, 1.0f, 0.0f, 1.0f
    };

    // Set up the buffers
    unsigned int handle[2];
    glGenBuffers(2, handle);

    glBindBuffer(GL_ARRAY_BUFFER, handle[0]);
    glBufferData(GL_ARRAY_BUFFER, 6 * 3 * sizeof(float), verts, GL_STATIC_DRAW);

    glBindBuffer(GL_ARRAY_BUFFER, handle[1]);
    glBufferData(GL_ARRAY_BUFFER, 6 * 2 * sizeof(float), tc, GL_STATIC_DRAW);

    // Set up the vertex array object
    glGenVertexArrays(1, &quad);
    glBindVertexArray(quad);

    glBindBuffer(GL_ARRAY_BUFFER, handle[0]);
    glVertexAttribPointer((GLuint) 0, 3, GL_FLOAT, GL_FALSE, 0, 0);
    glEnableVertexAttribArray(0);  // Vertex position

    glBindBuffer(GL_ARRAY_BUFFER, handle[1]);
    glVertexAttribPointer((GLuint) 2, 2, GL_FLOAT, GL_FALSE, 0, 0);
    glEnableVertexAttribArray(2);  // Texture coordinates

    glBindVertexArray(0);
}

#ifdef DEBUG_SHADOWMAP

void DeferredRenderer::renderScene(Shader *shader) const {
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


void DeferredRenderer::renderCube() const {
    static unsigned int cubeVAO = 0;
    static unsigned int cubeVBO = 0;
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

void DeferredRenderer::renderQuad() const {
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