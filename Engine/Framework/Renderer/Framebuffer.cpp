#include "ZeloPreCompiledHeader.h"
#include "Framework/Renderer/Framebuffer.h"

#include "Framework/Renderer/Renderer.h"

////#include "Framework/OpenGL/OpenGLFramebuffer.h"

namespace Zelo {

Ref<Framebuffer> Framebuffer::Create(const FramebufferSpecification &spec) {
    switch (Renderer::GetAPI()) {
        case RendererAPI::API::None:
            ZELO_CORE_ASSERT(false, "RendererAPI::None is currently not supported!");
            return nullptr;
            //case RendererAPI::API::OpenGL:
//            return CreateRef<OpenGLFramebuffer>(spec);
    }

    ZELO_CORE_ASSERT(false, "Unknown RendererAPI!");
    return nullptr;
}

}

