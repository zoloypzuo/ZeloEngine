// GLFramebuffer.h
// created on 2021/9/30
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/RHI/Buffer/Framebuffer.h"

namespace Zelo {

class GLFramebuffer : public Core::RHI::Framebuffer {
public:
    explicit GLFramebuffer(uint16_t width = 0, uint16_t height = 0);

    ~GLFramebuffer();

    void bind() override;

    void unbind() override;

    void resize(uint32_t width, uint32_t height) override;

    uint32_t getRenderTextureID() const { return m_renderTexture; }

private:
    uint32_t m_bufferID = 0;
    uint32_t m_renderTexture = 0;
    uint32_t m_depthStencilBuffer = 0;
};

}
