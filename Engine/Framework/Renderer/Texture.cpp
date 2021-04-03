#include "ZeloPreCompiledHeader.h"
#include "Framework/Renderer/Texture.h"

#include "Framework/Renderer/Renderer.h"
//#include "Framework/OpenGL/OpenGLTexture.h"

namespace Zelo {

Ref<Texture2D> Texture2D::Create(uint32_t width, uint32_t height) {
    switch (Renderer::GetAPI()) {
        case RendererAPI::API::None:
            ZELO_CORE_ASSERT(false, "RendererAPI::None is currently not supported!");
            return nullptr;
            //case RendererAPI::API::OpenGL:
            //return CreateRef<OpenGLTexture2D>(width, height);
    }

    ZELO_CORE_ASSERT(false, "Unknown RendererAPI!");
    return nullptr;
}

Ref<Texture2D> Texture2D::Create(const std::string &path) {
    switch (Renderer::GetAPI()) {
        case RendererAPI::API::None:
            ZELO_CORE_ASSERT(false, "RendererAPI::None is currently not supported!");
            return nullptr;
            //case RendererAPI::API::OpenGL:
            // return CreateRef<OpenGLTexture2D>(path);
    }

    ZELO_CORE_ASSERT(false, "Unknown RendererAPI!");
    return nullptr;
}

}