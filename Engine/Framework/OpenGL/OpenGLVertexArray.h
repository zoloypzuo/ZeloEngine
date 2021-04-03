#pragma once

#include "ZeloPrerequisites.h"

#include "Framework/Renderer/VertexArray.h"

namespace Zelo {

class OpenGLVertexArray : public VertexArray {
public:
    OpenGLVertexArray();

    ~OpenGLVertexArray() override;

    void Bind() const override;

    void Unbind() const override;

    void AddVertexBuffer(const std::shared_ptr<VertexBuffer> &vertexBuffer) override;

    void SetIndexBuffer(const std::shared_ptr<IndexBuffer> &indexBuffer) override;

    const std::vector<std::shared_ptr<VertexBuffer>> &GetVertexBuffers() const override { return m_VertexBuffers; }

    const std::shared_ptr<IndexBuffer> &GetIndexBuffer() const override { return m_IndexBuffer; }

private:
    uint32_t m_RendererID{};
    uint32_t m_VertexBufferIndex{};
    std::vector<std::shared_ptr<VertexBuffer>> m_VertexBuffers;
    std::shared_ptr<IndexBuffer> m_IndexBuffer;
};

}
