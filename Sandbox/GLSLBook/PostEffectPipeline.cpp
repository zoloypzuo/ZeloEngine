// PostEffectPipeline.cpp
// created on 2021/3/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "PostEffectPipeline.h"

using namespace Zelo::Renderer::OpenGL;

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

PostEffectPipeline::PostEffectPipeline() = default;

PostEffectPipeline::~PostEffectPipeline() = default;

void PostEffectPipeline::render(const Zelo::Core::ECS::Entity &scene) const {

    m_fbo->bind();

    glEnable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    ForwardPipeline::render(scene);

    m_fbo->unbind();

    glFlush();

    // pass2
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    m_postShader->bind();
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, m_fbo->getRenderTextureID());

    glDisable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT);

    renderQuad();
}

void PostEffectPipeline::initialize() {
    ForwardPipeline::initialize();
    m_fbo = std::make_unique<Zelo::GLFramebuffer>();
    m_fbo->resize(1280, 720);
    m_postShader = std::make_unique<GLSLShaderProgram>("Shader/edge.glsl");
    m_postShader->link();
    m_postShader->setUniform1i("RenderTex", 0);
    m_postShader->setUniform1f("EdgeThreshold", 0.05f);
}
