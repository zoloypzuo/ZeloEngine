// GLBufferDSA.h
// created on 2021/12/17
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/RHI/Buffer/Buffer.h"

namespace Zelo::Renderer::OpenGL {
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

class GLBufferDSABase {
public:
    GLBufferDSABase(uint32_t size, const void *data, uint32_t flags) {
        glCreateBuffers(1, &m_RendererID);
        glNamedBufferStorage(m_RendererID, size, data, flags);
    }

    virtual ~GLBufferDSABase() {
        glDeleteBuffers(1, &m_RendererID);
    }

    uint32_t getHandle() const { return m_RendererID; }

    virtual void bind() const { glBindBuffer(static_cast<GLenum>(getType()), m_RendererID); }

    virtual void unbind() const { glBindBuffer(static_cast<GLenum>(getType()), 0); }

    void bind(uint32_t bindingPoint) const {
        glBindBufferBase(static_cast<GLenum>(getType()), bindingPoint, m_RendererID);
    }

    void unbind(uint32_t bindingPoint) const {
        glBindBufferBase(static_cast<GLenum>(getType()), bindingPoint, 0);
    }

    virtual GLBufferType getType() const = 0;

protected:
    uint32_t m_RendererID{};
};

class GLVertexBufferDSA : public VertexBuffer, public GLBufferDSABase {
public:
    GLVertexBufferDSA(uint32_t size, const void *data, uint32_t flags) :
            GLBufferDSABase(size, data, flags) {}

    ~GLVertexBufferDSA() override = default;

    void bind() const override { GLBufferDSABase::bind(); }

    void unbind() const override { GLBufferDSABase::unbind(); }

    uint32_t getHandle() const override { return m_RendererID; }

    GLBufferType getType() const override { return GLBufferType::ARRAY_BUFFER; }
};

class GLIndexBufferDSA : public IndexBuffer, public GLBufferDSABase {
public:
    GLIndexBufferDSA(uint32_t size, const void *data, uint32_t flags) :
            GLBufferDSABase(size, data, flags) {}

    ~GLIndexBufferDSA() override = default;

    void bind() const override { GLBufferDSABase::bind(); }

    void unbind() const override { GLBufferDSABase::unbind(); }

    uint32_t getHandle() const override { return m_RendererID; }

    GLBufferType getType() const override { return GLBufferType::ELEMENT_ARRAY_BUFFER; }

    uint32_t getCount() const override { return 0; }
};
}
