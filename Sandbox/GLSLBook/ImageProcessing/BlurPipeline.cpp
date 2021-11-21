// BlurPipeline.cpp
// created on 2021/3/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "BlurPipeline.h"

using namespace Zelo::Renderer::OpenGL;

static float gauss(float x, float sigma2) {
    double coeff = 1.0 / (glm::two_pi<double>() * sigma2);
    double expon = -(x * x) / (2.0 * sigma2);
    return (float) (coeff * exp(expon));
}

BlurPipeline::BlurPipeline() = default;

BlurPipeline::~BlurPipeline() = default;

void BlurPipeline::render(const Zelo::Core::ECS::Entity &scene) const {

    m_fbo->bind();

    glEnable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    ForwardPipeline::render(scene);

    glDepthFunc(GL_LESS);
    glDepthMask(GL_TRUE);
    glDisable(GL_BLEND);

    m_fbo->unbind();

    // pass2
    m_fbo2->bind();
    m_postShader1->bind();
    m_postShader1->setUniform1i("Pass", 2);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, m_fbo->getRenderTextureID());

    glDisable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT);
    m_quad.render();
    m_fbo2->unbind();

    // pass3
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
    m_postShader1->setUniform1i("Pass", 3);
    m_postShader1->bind();
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, m_fbo2->getRenderTextureID());

    glDisable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT);

    m_quad.render();
}

void BlurPipeline::initialize() {
    ForwardPipeline::initialize();
    m_fbo = std::make_unique<Zelo::GLFramebuffer>(1280, 720);
    m_fbo2 = std::make_unique<Zelo::GLFramebuffer>(1280, 720);
    // Compute and sum the weights
    float weights[5], sum, sigma2 = 8.0f;
    weights[0] = gauss(0, sigma2);
    sum = weights[0];
    for (int i = 1; i < 5; i++) {
        weights[i] = gauss(float(i), sigma2);
        sum += 2 * weights[i];
    }

    m_postShader1 = std::make_unique<GLSLShaderProgram>("Shader/blur.lua");
    m_postShader1->link();
    m_postShader1->setUniform1i("Texture0", 0);

    // Normalize the weights and set the uniform
    for (int i = 0; i < 5; i++) {
        std::stringstream uniName;
        uniName << "Weight[" << i << "]";
        float val = weights[i] / sum;
        m_postShader1->setUniform1f(uniName.str(), val);
    }
}
