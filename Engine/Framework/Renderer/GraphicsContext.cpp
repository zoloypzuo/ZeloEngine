#include "ZeloPreCompiledHeader.h"
#include "Framework/Renderer/GraphicsContext.h"

#include "Framework/Renderer/Renderer.h"
//#include "Framework/OpenGL/OpenGLContext.h"

namespace Zelo {

Scope<GraphicsContext> GraphicsContext::Create(void *window) {
    switch (Renderer::GetAPI()) {
        case RendererAPI::API::None:
            ZELO_CORE_ASSERT(false, "RendererAPI::None is currently not supported!");
            return nullptr;
            //case RendererAPI::API::OpenGL:
            //  return CreateScope<OpenGLContext>(static_cast<GLFWwindow *>(window));
    }

    ZELO_CORE_ASSERT(false, "Unknown RendererAPI!");
    return nullptr;
}

}