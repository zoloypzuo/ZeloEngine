// GLBuffer.h
// created on 2021/6/6
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"
#include "Core/RHI/Buffer.h"

namespace Zelo {

class OpenGLVertexBuffer : public VertexBuffer {
public:
    explicit OpenGLVertexBuffer(uint32_t size);

    OpenGLVertexBuffer(float *vertices, uint32_t size);

    ~OpenGLVertexBuffer() override;

    void bind() const override;

    void unbind() const override;

    void setData(const void *data, uint32_t size) override;

    const BufferLayout &getLayout() const override { return m_Layout; }

    void setLayout(const BufferLayout &layout) override { m_Layout = layout; }

private:
    uint32_t m_RendererID{};
    BufferLayout m_Layout;
};

class OpenGLIndexBuffer : public IndexBuffer {
public:
    OpenGLIndexBuffer(uint32_t *indices, uint32_t count);

    ~OpenGLIndexBuffer() override;

    void bind() const override;

    void unbind() const override;

    uint32_t getCount() const override { return m_Count; }

private:
    uint32_t m_RendererID{};
    uint32_t m_Count;
};

}
