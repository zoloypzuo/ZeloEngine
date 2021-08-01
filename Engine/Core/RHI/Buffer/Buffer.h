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

    virtual void setData(const void *data, uint32_t size) = 0;

    virtual const BufferLayout &getLayout() const = 0;

    virtual void setLayout(const BufferLayout &layout) = 0;

//    static Ref<VertexBuffer> Create(uint32_t size);
//
//    static Ref<VertexBuffer> Create(float *vertices, uint32_t size);
};

// Currently Zelo only supports 32-bit index buffers
class IndexBuffer {
public:
    virtual ~IndexBuffer() = default;

    virtual void bind() const = 0;

    virtual void unbind() const = 0;

    virtual int32_t getCount() const = 0;

//    static Ref<IndexBuffer> Create(uint32_t *indices, uint32_t count);
};

}
