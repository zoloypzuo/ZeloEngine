// GLFramebuffer.cpp
// created on 2021/9/30
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLFramebuffer.h"

Zelo::GLFramebuffer::GLFramebuffer(uint16_t width, uint16_t height) {
    glGenFramebuffers(1, &m_bufferID);
    glGenTextures(1, &m_renderTexture);
    glGenRenderbuffers(1, &m_depthStencilBuffer);

    glBindTexture(GL_TEXTURE_2D, m_renderTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glBindTexture(GL_TEXTURE_2D, 0);

    bind();
    glFramebufferTexture(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, m_renderTexture, 0);
    unbind();

    resize(width, height);
}

Zelo::GLFramebuffer::~GLFramebuffer() {
    glDeleteBuffers(1, &m_bufferID);
    glDeleteTextures(1, &m_renderTexture);
    glDeleteRenderbuffers(1, &m_depthStencilBuffer);
}

void Zelo::GLFramebuffer::bind() {
    glBindFramebuffer(GL_FRAMEBUFFER, m_bufferID);
}

void Zelo::GLFramebuffer::unbind() {
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

void Zelo::GLFramebuffer::resize(uint32_t width, uint32_t height) {
    onResize({width, height});

    glBindTexture(GL_TEXTURE_2D, m_renderTexture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, 0);
    glBindTexture(GL_TEXTURE_2D, 0);

    glBindRenderbuffer(GL_RENDERBUFFER, m_depthStencilBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_STENCIL, width, height);
    glBindRenderbuffer(GL_RENDERBUFFER, 0);

    bind();
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, m_depthStencilBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, m_depthStencilBuffer);
    unbind();
}
