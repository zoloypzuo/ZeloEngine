// EdgePipeline.cpp
// created on 2021/3/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "EdgePipeline.h"

using namespace Zelo::Renderer::OpenGL;

EdgePipeline::EdgePipeline() = default;

EdgePipeline::~EdgePipeline() = default;

void EdgePipeline::render(const Zelo::Core::ECS::Entity &scene) const {
    // pass 1
    m_fbo->bind();

    glEnable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    ForwardPipeline::render(scene);

    m_fbo->unbind();

    // pass 2
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    m_postShader->bind();
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, m_fbo->getRenderTextureID());

    glDisable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT);

    m_quad.render();
}

void EdgePipeline::initialize() {
    ForwardPipeline::initialize();
    m_fbo = std::make_unique<Zelo::GLFramebuffer>();
    m_fbo->resize(1280, 720);
    m_postShader = std::make_unique<GLSLShaderProgram>("Shader/edge.glsl");
    m_postShader->link();
    m_postShader->setUniform1i("RenderTex", 0);
    m_postShader->setUniform1f("EdgeThreshold", 0.05f);
}
