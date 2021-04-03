#include "ZeloPreCompiledHeader.h"
#include "Framework/Renderer/VertexArray.h"

#include "Framework/Renderer/Renderer.h"
//#include "Framework/OpenGL/OpenGLVertexArray.h"

namespace Zelo {

Ref<VertexArray> VertexArray::Create() {
    switch (Renderer::GetAPI()) {
        case RendererAPI::API::None:
            ZELO_CORE_ASSERT(false, "RendererAPI::None is currently not supported!");
            return nullptr;
            //case RendererAPI::API::OpenGL:
            // return CreateRef<OpenGLVertexArray>();
    }

    ZELO_CORE_ASSERT(false, "Unknown RendererAPI!");
    return nullptr;
}

}