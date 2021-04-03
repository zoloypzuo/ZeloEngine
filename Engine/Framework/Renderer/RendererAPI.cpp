#include "ZeloPreCompiledHeader.h"
#include "Framework/Renderer/RendererAPI.h"

//#include "Framework/OpenGL/OpenGLRendererAPI.h"

namespace Zelo {

RendererAPI::API RendererAPI::s_API = RendererAPI::API::OpenGL;

Scope<RendererAPI> RendererAPI::Create() {
    switch (s_API) {
        case RendererAPI::API::None:
            ZELO_CORE_ASSERT(false, "RendererAPI::None is currently not supported!");
            return nullptr;
            //case RendererAPI::API::OpenGL:
            //return CreateScope<OpenGLRendererAPI>();
    }

    ZELO_CORE_ASSERT(false, "Unknown RendererAPI!");
    return nullptr;
}

}