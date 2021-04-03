#include "ZeloPreCompiledHeader.h"
#include "Framework/Renderer/RenderCommand.h"

namespace Zelo {

Scope<RendererAPI> RenderCommand::s_RendererAPI = RendererAPI::Create();

}