// DeferredRenderer.cpp
// created on 2021/4/28
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "DeferredRenderer.h"

const unsigned int SHADOW_WIDTH = 1024, SHADOW_HEIGHT = 1024;
const unsigned int SCR_WIDTH = 800;
const unsigned int SCR_HEIGHT = 600;

void DeferredRenderer::setMatrices(glm::mat4 model, glm::mat4 view, glm::mat4 projection) const {
    glm::mat4 mv = view * model;
    m_deferredShader->setUniformMatrix4f("ModelViewMatrix", mv);
    m_deferredShader->setUniformMatrix4f("NormalMatrix",
                                         glm::mat3(glm::vec3(mv[0]), glm::vec3(mv[1]), glm::vec3(mv[2])));
    m_deferredShader->setUniformMatrix4f("MVP", projection * mv);
}

void DeferredRenderer::render(const Entity &scene, std::shared_ptr<Camera> activeCamera,
                              const std::vector<std::shared_ptr<PointLight>> &pointLights,
                              const std::vector<std::shared_ptr<DirectionalLight>> &directionalLights,
                              const std::vector<std::shared_ptr<SpotLight>> &spotLights) const {

    pass1(activeCamera);
    glFlush();
    pass2(scene, activeCamera, pointLights, directionalLights, spotLights);


}

void DeferredRenderer::pass2(const Entity &scene, const std::shared_ptr<Camera> &activeCamera,
                             const std::vector<std::shared_ptr<PointLight>> &pointLights,
                             const std::vector<std::shared_ptr<DirectionalLight>> &directionalLights,
                             const std::vector<std::shared_ptr<SpotLight>> &spotLights) const {

    // Revert to default framebuffer
    glBindFramebuffer(GL_FRAMEBUFFER, 0);

    glUniformSubroutinesuiv(GL_FRAGMENT_SHADER, 1, &pass2Index);

    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glDisable(GL_DEPTH_TEST);

    auto view = glm::mat4(1.0);
    auto model = glm::mat4(1.0);
    auto projection = glm::mat4(1.0);
    auto mv = view * model;
    m_deferredShader->setUniformMatrix4f("ModelViewMatrix", mv);
    m_deferredShader->setUniformMatrix4f("NormalMatrix",
                                         glm::mat3(glm::vec3(mv[0]), glm::vec3(mv[1]), glm::vec3(mv[2])));
    m_deferredShader->setUniformMatrix4f("MVP", projection * mv);


    // Render the quad
    glBindVertexArray(quad);
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

void DeferredRenderer::pass1(const std::shared_ptr<Camera> &activeCamera) const {
    glBindFramebuffer(GL_FRAMEBUFFER, deferredFBO);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    glUniformSubroutinesuiv(GL_FRAGMENT_SHADER, 1, &pass1Index);

    auto view = activeCamera->getViewMatrix();
    auto projection = activeCamera->getProjectionMatrix();


    m_deferredShader->setUniformVec4f("Light.Position", glm::vec4(0.0f, 0.0f, 0.0f, 1.0f));
    m_deferredShader->setUniformVec3f("Material.Kd", glm::vec3(0.9f, 0.9f, 0.9f));

    view = glm::lookAt(glm::vec3(0.0f, 0.0f, 0.0f),
                       glm::vec3(0.0f, 0.0f, 0.0f),
                       glm::vec3(0.0f, 1.0f, 0.0f));
    projection = glm::perspective(glm::radians(60.0f), (float) SCR_WIDTH / SCR_HEIGHT, 0.3f, 100.0f);

    m_deferredShader->setUniformVec4f("Light.Position", glm::vec4(0.0f, 0.0f, 0.0f, 1.0f));
    m_deferredShader->setUniformVec3f("Material.Kd", glm::vec3(0.9f, 0.9f, 0.9f));

    auto model = glm::mat4(1.0f);
    model = glm::translate(model, glm::vec3(0.0f, 0.0f, 0.0f));
    model = glm::rotate(model, glm::radians(-90.0f), glm::vec3(1.0f, 0.0f, 0.0f));
    setMatrices(model, view, projection);
    teapot->render();

    m_deferredShader->setUniformVec3f("Material.Kd", glm::vec3(0.4f, 0.4f, 0.4f));
    model = glm::mat4(1.0f);
    model = glm::translate(model, glm::vec3(0.0f, -0.75f, 0.0f));
    setMatrices(model, view, projection);
    plane->render();

    m_deferredShader->setUniformVec4f("Light.Position", glm::vec4(0.0f, 0.0f, 0.0f, 1.0f));
    m_deferredShader->setUniformVec3f("Material.Kd", glm::vec3(0.9f, 0.5f, 0.2f));
    model = glm::mat4(1.0f);
    model = glm::translate(model, glm::vec3(1.0f, 1.0f, 3.0f));
    model = glm::rotate(model, glm::radians(90.0f), glm::vec3(1.0f, 0.0f, 0.0f));
    setMatrices(model, view, projection);
    torus->render();

    glFinish();
}

void DeferredRenderer::initialize() {
    initializeDeferred();
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
    m_deferredShader = std::make_unique<GLSLShaderProgram>("Shader/deferred.lua");
    m_deferredShader->link();
    m_deferredShader->bind();
    initiializeMesh();
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

void DeferredRenderer::initializeQuad() {
    // Array for quad
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
    glEnableVertexAttribArray(2);  // GLTexture coordinates

    glBindVertexArray(0);
}

void DeferredRenderer::initiializeMesh() {
    //                                  plane(50.0f, 50.0f, 1, 1),
    //                                 torus(0.7f * 1.5f, 0.3f * 1.5f, 50,50),
    //                                 teapot(14, mat4(1.0))
    plane = std::make_unique<Ingredients::Plane>(50.0f, 50.0f, 1, 1);
    torus = std::make_unique<Torus>(0.7f * 1.5f, 0.3f * 1.5f, 50, 50);
    teapot = std::make_unique<Teapot>(14, glm::mat4(1.0f));
}
