// GLBuffer.h
// created on 2021/6/6
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"
#include "Core/RHI/Buffer.h"

namespace Zelo {

class GLVertexBuffer : public VertexBuffer {
public:
    explicit GLVertexBuffer(uint32_t size);

    GLVertexBuffer(float *vertices, uint32_t size);

    ~GLVertexBuffer() override;

    void bind() const override;

    void unbind() const override;

    void setData(const void *data, uint32_t size) override;

    const BufferLayout &getLayout() const override { return m_Layout; }

    void setLayout(const BufferLayout &layout) override { m_Layout = layout; }

private:
    uint32_t m_RendererID{};
    BufferLayout m_Layout;
};

class GLIndexBuffer : public IndexBuffer {
public:
    GLIndexBuffer(uint32_t *indices, uint32_t count);

    ~GLIndexBuffer() override;

    void bind() const override;

    void unbind() const override;

    uint32_t getCount() const override { return m_Count; }

private:
    uint32_t m_RendererID{};
    uint32_t m_Count;
};

}
