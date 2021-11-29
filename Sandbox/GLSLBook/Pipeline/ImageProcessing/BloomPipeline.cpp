// BloomPipeline.cpp
// created on 2021/3/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "BloomPipeline.h"

using namespace Zelo::Renderer::OpenGL;

static float gauss(float x, float sigma2) {
    double coeff = 1.0 / (glm::two_pi<double>() * sigma2);
    double expon = -(x * x) / (2.0 * sigma2);
    return (float) (coeff * exp(expon));
}

BloomPipeline::BloomPipeline() = default;

BloomPipeline::~BloomPipeline() = default;

void BloomPipeline::render(const Zelo::Core::ECS::Entity &scene) const {
    m_renderFbo->bind();

    glEnable(GL_DEPTH_TEST);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    ForwardPipeline::render(scene);

    glDepthFunc(GL_LESS);
    glDepthMask(GL_TRUE);
    glDisable(GL_BLEND);

    m_renderFbo->unbind();

    {
        // pass2
        m_fbo1->bind();
        m_postShader->bind();
        m_postShader->setUniform1i("Pass", 2);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, m_renderFbo->getRenderTextureID());

        glDisable(GL_DEPTH_TEST);
        glClear(GL_COLOR_BUFFER_BIT);

        m_quad.render();
    }

    {
        // pass3
        m_fbo2->bind();
        m_postShader->bind();
        m_postShader->setUniform1i("Pass", 3);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, m_fbo1->getRenderTextureID());

        glDisable(GL_DEPTH_TEST);
        glClear(GL_COLOR_BUFFER_BIT);

        m_quad.render();
    }

    {
        // pass4
        glBindFramebuffer(GL_FRAMEBUFFER, 0);
        m_postShader->bind();
        m_postShader->setUniform1i("Pass", 4);
        glActiveTexture(GL_TEXTURE1);
        glBindTexture(GL_TEXTURE_2D, m_fbo2->getRenderTextureID());

        glDisable(GL_DEPTH_TEST);
        glClear(GL_COLOR_BUFFER_BIT);

        m_quad.render();
    }
}

void BloomPipeline::initialize() {
    ForwardPipeline::initialize();
    m_renderFbo = std::make_unique<Zelo::GLFramebuffer>(1280, 720);
    m_fbo1 = std::make_unique<Zelo::GLFramebuffer>(1280, 720);
    m_fbo2 = std::make_unique<Zelo::GLFramebuffer>(1280, 720);
    m_postShader = std::make_unique<GLSLShaderProgram>("bloom.lua");
    m_postShader->link();

    m_postShader->setUniform1i("Width", 1280);
    m_postShader->setUniform1i("Height", 720);
    m_postShader->setUniform1i("RenderTex", 0);
    m_postShader->setUniform1i("BlurTex", 1);
    m_postShader->setUniform1f("LumThresh", 0.15f);

    float weights[10], sum, sigma2 = 25.0f;

    // Compute and sum the weights
    weights[0] = gauss(0, sigma2);
    sum = weights[0];
    for (int i = 1; i < 10; i++) {
        weights[i] = gauss(float(i), sigma2);
        sum += 2 * weights[i];
    }

    // Normalize the weights and set the uniform
    for (int i = 0; i < 10; i++) {
        std::stringstream uniName;
        uniName << "Weight[" << i << "]";
        float val = weights[i] / sum;
        m_postShader->setUniform1f(uniName.str(), val);
    }
}
