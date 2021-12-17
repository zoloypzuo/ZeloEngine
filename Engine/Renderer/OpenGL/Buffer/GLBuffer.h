// GLBuffer.h
// created on 2021/6/6
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/RHI/Buffer/Buffer.h"

namespace Zelo::Renderer::OpenGL {
class GLVertexBuffer : public VertexBuffer {
public:
    GLVertexBuffer();

    explicit GLVertexBuffer(uint32_t size);

    GLVertexBuffer(float *vertices, uint32_t size);

    ~GLVertexBuffer() override;

    void bind() const override;

    void unbind() const override;

    void setData(const void *data, uint32_t size);

    uint32_t getHandle() const override { return m_RendererID; }

private:
    uint32_t m_RendererID{};
};

class GLIndexBuffer : public IndexBuffer {
public:
    GLIndexBuffer(uint32_t *indices, uint32_t count);

    ~GLIndexBuffer() override;

    void bind() const override;

    void unbind() const override;

    uint32_t getHandle() const override { return m_RendererID; }

    uint32_t getCount() const override { return m_Count; }

private:
    uint32_t m_RendererID{};
    uint32_t m_Count;
};

class GLMapBufferJanitor {
public:
    GLMapBufferJanitor(const std::shared_ptr<GLVertexBuffer> &vertexBuffer, int32_t size);

    ~GLMapBufferJanitor();

    unsigned char *getBufferData() const { return m_bufferData; }

private:
    unsigned char *m_bufferData{};
};

enum class GLBufferType {
    ARRAY_BUFFER = GL_ARRAY_BUFFER,
    ATOMIC_COUNTER_BUFFER = GL_ATOMIC_COUNTER_BUFFER,
    COPY_READ_BUFFER = GL_COPY_READ_BUFFER,
    COPY_WRITE_BUFFER = GL_COPY_WRITE_BUFFER,
    DISPATCH_INDIRECT_BUFFER = GL_DISPATCH_INDIRECT_BUFFER,
    DRAW_INDIRECT_BUFFER = GL_DRAW_INDIRECT_BUFFER,
    ELEMENT_ARRAY_BUFFER = GL_ELEMENT_ARRAY_BUFFER,
    PIXEL_PACK_BUFFER = GL_PIXEL_PACK_BUFFER,
    PIXEL_UNPACK_BUFFER = GL_PIXEL_UNPACK_BUFFER,
    QUERY_BUFFER = GL_QUERY_BUFFER,
    SHADER_STORAGE_BUFFER = GL_SHADER_STORAGE_BUFFER,
    TEXTURE_BUFFER = GL_TEXTURE_BUFFER,
    TRANSFORM_FEEDBACK_BUFFER = GL_TRANSFORM_FEEDBACK_BUFFER,
    UNIFORM_BUFFER = GL_UNIFORM_BUFFER
};

class GLBufferImmutable {
public:
    GLBufferImmutable(uint32_t size, const void *data, uint32_t flags) {
        glCreateBuffers(1, &m_RendererID);
        glNamedBufferStorage(m_RendererID, size, data, flags);
    }

    ~GLBufferImmutable() {
        glDeleteBuffers(1, &m_RendererID);
    }

    uint32_t getHandle() const { return m_RendererID; }

protected:
    uint32_t m_RendererID{};
};
}
