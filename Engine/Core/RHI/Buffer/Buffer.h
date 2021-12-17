// Buffer.h
// created on 2021/6/6
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "BufferLayout.h"

namespace Zelo {
class VertexBuffer {
public:
    virtual ~VertexBuffer() = default;

    virtual void bind() const = 0;

    virtual void unbind() const = 0;

    virtual uint32_t getHandle() const = 0;

    const BufferLayout &getLayout() const { return m_Layout; }

    void setLayout(const BufferLayout &layout) { m_Layout = layout; }

protected:
    BufferLayout m_Layout;
};

// Currently Zelo only supports 32-bit index buffers
class IndexBuffer {
public:
    virtual ~IndexBuffer() = default;

    virtual void bind() const = 0;

    virtual void unbind() const = 0;

    virtual uint32_t getHandle() const = 0;

    virtual uint32_t getCount() const = 0;
};
}
