#include "ZeloPreCompiledHeader.h"
#include "Framework/Renderer/Buffer.h"

#include "Framework/Renderer/Renderer.h"

//#include "Framework/OpenGL/OpenGLBuffer.h"

namespace Zelo {

Ref<VertexBuffer> VertexBuffer::Create(uint32_t size) {
    switch (Renderer::GetAPI()) {
        case RendererAPI::API::None:
            ZELO_CORE_ASSERT(false, "RendererAPI::None is currently not supported!");
            return nullptr;
            //case RendererAPI::API::OpenGL:
            //  return CreateRef<OpenGLVertexBuffer>(size);
    }

    ZELO_CORE_ASSERT(false, "Unknown RendererAPI!");
    return nullptr;
}

Ref<VertexBuffer> VertexBuffer::Create(float *vertices, uint32_t size) {
    switch (Renderer::GetAPI()) {
        case RendererAPI::API::None:
            ZELO_CORE_ASSERT(false, "RendererAPI::None is currently not supported!");
            return nullptr;
            // case RendererAPI::API::OpenGL:
            //return CreateRef<OpenGLVertexBuffer>(vertices, size);
    }

    ZELO_CORE_ASSERT(false, "Unknown RendererAPI!");
    return nullptr;
}

Ref<IndexBuffer> IndexBuffer::Create(uint32_t *indices, uint32_t size) {
    switch (Renderer::GetAPI()) {
        case RendererAPI::API::None:
            ZELO_CORE_ASSERT(false, "RendererAPI::None is currently not supported!");
            return nullptr;
            //  case RendererAPI::API::OpenGL:
            //return CreateRef<OpenGLIndexBuffer>(indices, size);
    }

    ZELO_CORE_ASSERT(false, "Unknown RendererAPI!");
    return nullptr;
}

}