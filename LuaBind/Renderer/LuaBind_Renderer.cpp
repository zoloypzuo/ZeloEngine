// LuaBind_Renderer.cpp.cc
// created on 2021/12/18
// author @zoloypzuo
#include <sol/sol.hpp>

#include "Renderer/OpenGL/Buffer/GLFramebuffer.h"
#include "Renderer/OpenGL/Drawable/MeshScene/MeshSceneSimple.h"
#include "Renderer/OpenGL/Drawable/MeshScene/MeshSceneFinal.h"
#include "Renderer/OpenGL/Drawable/MeshScene/MeshSceneWireFrame.h"
#include "Renderer/OpenGL/Resource/GLMaterial.h"
#include "Renderer/OpenGL/Resource/GLMesh.h"

using namespace Zelo;
using namespace Zelo::Core::Interface;
using namespace Zelo::Core::RHI;
using namespace Zelo::Renderer::OpenGL;

void LuaBind_Renderer(sol::state &luaState) {
// @formatter:off
luaState.new_usertype<GLMesh>("Mesh",
sol::constructors<GLMesh(IMeshData &)>(),
sol::base_classes, sol::bases<Mesh>(),
"__Dummy", [] {}
);

luaState.new_usertype<GLTexture>("Texture",
sol::constructors<GLTexture(std::string)>(),
"__Dummy", [] {}
);

luaState.new_usertype<GLMaterial>("Material",
sol::constructors<GLMaterial(GLTexture &, GLTexture &, GLTexture &,
GLSLShaderProgram *)>(),
sol::base_classes, sol::bases<Material>(),
"__Dummy", [] {}
);

luaState.new_usertype<MeshSceneWireFrame>("SceneWireFrame",
sol::constructors<MeshSceneWireFrame(const std::string &)>(),
sol::base_classes, sol::bases<Mesh>()
);

luaState.new_usertype<MeshSceneSimple>("SceneSimple",
sol::constructors<MeshSceneSimple(const std::string &, const std::string &, const std::string &)>(),
sol::base_classes, sol::bases<Mesh>()
);

luaState.new_usertype<MeshSceneFinal>("Scene",
sol::constructors<MeshSceneFinal(const std::string &, const std::string &,
const std::string &, const std::string &)>(),
sol::base_classes, sol::bases<Mesh>(),
"EnableGPUCulling", sol::property(&MeshSceneFinal::GetEnableGPUCulling,
&MeshSceneFinal::SetEnableGPUCulling),
"FreezeCullingView", sol::property(&MeshSceneFinal::GetFreezeCullingView,
&MeshSceneFinal::SetFreezeCullingView),
"DrawOpaque",
sol::property(&MeshSceneFinal::GetDrawOpaque, &MeshSceneFinal::SetDrawOpaque),
"DrawTransparent", sol::property(&MeshSceneFinal::GetDrawTransparent,
&MeshSceneFinal::SetDrawTransparent),
"DrawGrid",
sol::property(&MeshSceneFinal::GetDrawGrid, &MeshSceneFinal::SetDrawGrid),
"EnableSSAO",
sol::property(&MeshSceneFinal::GetEnableSSAO, &MeshSceneFinal::SetEnableSSAO),
"EnableBlur",
sol::property(&MeshSceneFinal::GetEnableBlur, &MeshSceneFinal::SetEnableBlur),
"EnableHDR",
sol::property(&MeshSceneFinal::GetEnableHDR, &MeshSceneFinal::SetEnableHDR),
"EnableShadows", sol::property(&MeshSceneFinal::GetEnableShadows,
&MeshSceneFinal::SetEnableShadows),
"LightTheta",
sol::property(&MeshSceneFinal::GetLightTheta, &MeshSceneFinal::SetLightTheta),
"LightPhi",
sol::property(&MeshSceneFinal::GetLightPhi, &MeshSceneFinal::SetLightPhi),
"__Dummy", [] {}
);

luaState.new_usertype<GLFramebuffer>("Framebuffer",
sol::constructors<GLFramebuffer(uint16_t, uint16_t)>(),
sol::base_classes, sol::bases<IView>(),
"GetRenderTextureID", &GLFramebuffer::getRenderTextureID,
"Bind", &GLFramebuffer::bind,
"UnBind", &GLFramebuffer::unbind,
"Resize", &GLFramebuffer::resize,
"__Dummy", [] {}
);
// @formatter:on
}