// GLShadowMap.cpp
// created on 2021/9/30
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLShadowMap.h"

Zelo::GLShadowMap::GLShadowMap(uint16_t width, uint16_t height) {
    resize(width, height);

    GLfloat border[] = {1.0f, 0.0f, 0.0f, 0.0f};
    // The depth buffer texture
    glGenTextures(1, &m_depthTexture);
    glBindTexture(GL_TEXTURE_2D, m_depthTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, width, height, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_BYTE, NULL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);
    glTexParameterfv(GL_TEXTURE_2D, GL_TEXTURE_BORDER_COLOR, border);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE, GL_COMPARE_REF_TO_TEXTURE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_FUNC, GL_LESS);

    // Assign the depth buffer texture to texture channel 0
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, m_depthTexture);

    // Create and set up the FBO
    glGenFramebuffers(1, &m_bufferID);
    bind();
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, m_depthTexture, 0);
    unbind();
}

Zelo::GLShadowMap::~GLShadowMap() {
    glDeleteBuffers(1, &m_bufferID);
    glDeleteTextures(1, &m_depthTexture);
}

void Zelo::GLShadowMap::bind() {
    glBindFramebuffer(GL_FRAMEBUFFER, m_bufferID);
}

void Zelo::GLShadowMap::unbind() {
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

void Zelo::GLShadowMap::resize(uint32_t width, uint32_t height) {
    // TODO
}
