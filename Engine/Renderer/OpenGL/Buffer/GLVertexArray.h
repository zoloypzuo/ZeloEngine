// GLVertexArray.h
// created on 2021/6/6
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/RHI/Buffer/VertexArray.h"

namespace Zelo {

class GLVertexArray : public VertexArray {
public:
    GLVertexArray();

    ~GLVertexArray() override;

    void bind() const override;

    void unbind() const override;

    void addVertexBuffer(const std::shared_ptr<VertexBuffer> &vertexBuffer) override;

    void setIndexBuffer(const std::shared_ptr<IndexBuffer> &indexBuffer) override;

    const std::vector<std::shared_ptr<VertexBuffer>> &getVertexBuffers() const override { return m_VertexBuffers; }

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
