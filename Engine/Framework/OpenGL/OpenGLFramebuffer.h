#pragma once

#include "ZeloPrerequisites.h"

#include "Framework/Renderer/Framebuffer.h"

namespace Zelo {

class OpenGLFramebuffer : public Framebuffer {
public:
    explicit OpenGLFramebuffer(const FramebufferSpecification &spec);

    ~OpenGLFramebuffer() override;

    void Invalidate();

    void Bind() override;

    void Unbind() override;

    void Resize(uint32_t width, uint32_t height) override;

    uint32_t GetColorAttachmentRendererID(uint32_t index = 0) const {
        ZELO_CORE_ASSERT(index < m_ColorAttachments.size());
        return m_ColorAttachments[index];
    }

    const FramebufferSpecification &GetSpecification() const override { return m_Specification; }

private:
    uint32_t m_RendererID = 0;
    FramebufferSpecification m_Specification;

//    std::vector<FramebufferTextureSpecification> m_ColorAttachmentSpecifications;
//    FramebufferTextureSpecification m_DepthAttachmentSpecification = FramebufferTextureFormat::None;

    std::vector<uint32_t> m_ColorAttachments;
    uint32_t m_DepthAttachment = 0;
};

}
