// VertexArray.h
// created on 2021/6/6
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Buffer.h"

namespace Zelo {

class VertexArray {
public:
    virtual ~VertexArray() = default;

    virtual void bind() const = 0;

    virtual void unbind() const = 0;

    virtual void addVertexBuffer(const std::shared_ptr<VertexBuffer> &vertexBuffer) = 0;

    virtual void setIndexBuffer(const std::shared_ptr<IndexBuffer> &indexBuffer) = 0;

    virtual const std::vector<std::shared_ptr<VertexBuffer>> &getVertexBuffers() const = 0;

    virtual const std::shared_ptr<IndexBuffer> &getIndexBuffer() const = 0;
};

}

