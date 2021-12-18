// LuaBind_Renderer.cpp.cc
// created on 2021/12/18
// author @zoloypzuo
#include <sol/sol.hpp>

#include "Renderer/OpenGL/Resource/GLMesh.h"
#include "Renderer/OpenGL/Resource/GLMaterial.h"
#include "Renderer/OpenGL/Buffer/GLFramebuffer.h"
#include "Renderer/OpenGL/Drawable/MeshScene/MeshScene.h"

using namespace Zelo;
using namespace Zelo::Core::Interface;
using namespace Zelo::Core::RHI;
using namespace Zelo::Renderer::OpenGL;

void LuaBind_Renderer(sol::state &luaState) {
// @formatter:off
luaState.new_usertype<GLMesh>("Mesh",
sol::constructors<GLMesh(IMeshData &)>(),
sol::base_classes,  sol::bases<Mesh>(),
"__Dummy", []{}
);

luaState.new_usertype<GLTexture>("Texture",
sol::constructors<GLTexture(std::string )>(),
"__Dummy", []{}
);

luaState.new_usertype<GLMaterial>("Material",
sol::constructors<GLMaterial(GLTexture &, GLTexture &, GLTexture &, GLSLShaderProgram *)>(),
sol::base_classes, sol::bases<Material>(),
"__Dummy", []{}
);

luaState.new_usertype<MeshScene>("Scene",
sol::constructors<MeshScene(const std::string&, const std::string&, const std::string&)>(),
sol::base_classes,  sol::bases<Mesh>(),
"__Dummy", []{}
);

luaState.new_usertype<GLFramebuffer>("Framebuffer",
sol::constructors<GLFramebuffer(uint16_t, uint16_t)>(),
sol::base_classes, sol::bases<IView>(),
"GetRenderTextureID", &GLFramebuffer::getRenderTextureID,
"Bind", &GLFramebuffer::bind,
"UnBind", &GLFramebuffer::unbind,
"Resize", &GLFramebuffer::resize,
"__Dummy", []{}
);
// @formatter:on
}