// GLVertexArrayDSA.h
// created on 2021/12/17
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/RHI/Buffer/VertexArray.h"

namespace Zelo::Renderer::OpenGL {
class GLVertexArrayDSA : public Zelo::VertexArray {
public:
    GLVertexArrayDSA();

    ~GLVertexArrayDSA() override;

    void bind() const override;

    void unbind() const override;

    void addVertexBuffer(const std::shared_ptr<VertexBuffer> &vertexBuffer) override;

    void setIndexBuffer(const std::shared_ptr<IndexBuffer> &indexBuffer) override;

    const std::vector<std::shared_ptr<VertexBuffer>> &
    getVertexBuffers() const override { return m_VertexBuffers; }

    const std::shared_ptr<IndexBuffer> &getIndexBuffer() const override { return m_IndexBuffer; }

public:
    uint32_t getHandle() const { return m_RendererID; }

private:
    uint32_t m_RendererID{};
    uint32_t m_VertexBufferIndex{};
    std::vector<std::shared_ptr<VertexBuffer>> m_VertexBuffers;
    std::shared_ptr<IndexBuffer> m_IndexBuffer;
};
}
