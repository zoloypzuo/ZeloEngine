// LuaBind_Entity.cpp
// created on 2021/7/31
// author @zoloypzuo
#include <sol/sol.hpp>

#include "Core/ECS/Entity.h"
#include "Core/RHI/Object/Camera.h"
#include "Core/ECS/Component/CFreeMove.h"
#include "Core/ECS/Component/CFreeLook.h"
#include "Core/RHI/Object/Light.h"
#include "Core/RHI/Object/LightPlain.h"

#include "Core/RHI/MeshGen/Plane.h"
#include "Renderer/OpenGL/Drawable/MeshRenderer.h"
#include "Renderer/OpenGL/Resource/GLMaterial.h"
#include "Renderer/OpenGL/Buffer/GLFramebuffer.h"
#include "Core/RHI/RenderSystem.h"

#include "Core/Parser/MeshLoader.h"

using namespace Zelo::Core::LuaScript;
using namespace Zelo::Core::RHI;
using namespace Zelo::Renderer::OpenGL;
using namespace Zelo::Parser;
using namespace Zelo::Core::ECS;
using namespace Zelo::Core::Interface;
using namespace Zelo;

bool sol_lua_check(sol::types<glm::vec3>, lua_State *L, int index,
                   std::function<sol::check_handler_type> handler,
                   sol::stack::record &tracking) {
    // use sol's method for checking
    // specifically for a table
    return sol::stack::check<sol::lua_table>(
            L, index, handler, tracking);
}

glm::vec3 sol_lua_get(sol::types<glm::vec3>, lua_State *L, int index, sol::stack::record &tracking) {
    sol::lua_table vec3table
            = sol::stack::get<sol::lua_table>(L, index, tracking);
    float x = vec3table["x"];
    float y = vec3table["y"];
    float z = vec3table["z"];
    return glm::vec3{x, y, z};
}

int sol_lua_push(sol::types<glm::vec3>, lua_State *L, const glm::vec3 &v) {
    // create table
    sol::state_view lua(L);
    sol::table vec3table = sol::table::create_with(
            L, "x", v.x, "y", v.y, "z", v.z);
    // use base sol method to
    // push the table
    int amount = sol::stack::push(L, vec3table);
    // return # of things pushed onto stack
    return amount;
}

void LuaBind_Entity(sol::state &luaState) {
    using namespace Zelo::Core::ECS;

// @formatter:off
luaState.new_usertype<Entity>("Entity",
"tag", sol::property(&Entity::GetTag, &Entity::AddTag),
"active", sol::property(&Entity::IsActive, &Entity::SetActive),
"GetGUID", &Entity::GetGUID,
"AddTag", &Entity::AddTag,
"AddTransform", &Entity::AddTransform,
"AddCamera", &Entity::AddComponent<PerspectiveCamera>,
"AddFreeMove", &Entity::AddComponent<CFreeMove>,
"AddFreeLook", &Entity::AddComponent<CFreeLook>,
"AddSpotLight", &Entity::AddComponent<SpotLight>,
"AddDirectionalLight", &Entity::AddComponent<DirectionalLight>,
"AddLight", &Entity::AddComponent<LightPlain>,
"AddMeshRenderer", &Entity::AddComponent<MeshRenderer>,
"__Dummy", []{}
);

luaState.new_usertype<Transform>("Transform",
"position", sol::property(&Transform::getPosition, &Transform::setPosition),
"rotation", sol::property(&Transform::GetRotation),
"scale", sol::property(&Transform::getScale, & Transform::setScale),
"SetPosition", &Transform::SetPosition,
"SetScale", &Transform::SetScale,
"Rotate", &Transform::Rotate,
"__Dummy", []{}
);

luaState.new_usertype<PerspectiveCamera>("Camera",
"fov", &PerspectiveCamera::m_fov, 
"aspect", &PerspectiveCamera::m_aspect, 
"zNear", &PerspectiveCamera::m_zNear, 
"zFar", &PerspectiveCamera::m_zFar,
"__Dummy", []{}
);

luaState.new_usertype<Attenuation>("Attenuation",
"constant", &Attenuation::m_constant, 
"linear", &Attenuation::m_linear, 
"exponent", &Attenuation::m_exponent, 
"__Dummy", []{}
);

luaState.new_usertype<glm::vec3>("vec3",
sol::constructors<
        glm::vec3(), 
        glm::vec3(float), 
        glm::vec3(float, float, float)>(),
"x", &glm::vec3::x,
"y", &glm::vec3::y,
"z", &glm::vec3::z,
sol::meta_function::multiplication, sol::overload(
    [](const glm::vec3& v1, const glm::vec3& v2) -> glm::vec3 { return v1*v2; },
    [](const glm::vec3& v1, float f) -> glm::vec3 { return v1*f; },
    [](float f, const glm::vec3& v1) -> glm::vec3 { return f*v1; }
),
"__Dummy", []{}
);

luaState.new_usertype<BaseLight>("BaseLight",
"color", &BaseLight::m_color,
"intensity", &BaseLight::m_intensity, 
"__Dummy", []{}
);

luaState.new_usertype<SpotLight>("SpotLight",
sol::base_classes, sol::bases<BaseLight>(),
"attenuation", &SpotLight::m_attenuation,
"range", &SpotLight::m_range,
"cutoff", &SpotLight::m_cutoff, 
"__Dummy", []{}
);

luaState.new_usertype<LightPlain>("Light",
"type ", &LightPlain::type,
"color ", &LightPlain::color,
"intensity ", &LightPlain::intensity,
"constant ", &LightPlain::constant,
"linear ", &LightPlain::linear,
"quadratic ", &LightPlain::quadratic,
"cutoff ", &LightPlain::cutoff,
"outerCutoff ", &LightPlain::outerCutoff,
"__Dummy", []{}
);

luaState.new_usertype<DirectionalLight>("DirectionalLight",
sol::base_classes, sol::bases<BaseLight>(),
"__Dummy", []{}
);

luaState.new_usertype<MeshRenderer>("MeshRenderer",
//sol::base_classes, sol::bases<BaseLight>(),
"mesh", sol::property(&MeshRenderer::GetMesh, &MeshRenderer::SetMesh),
"material", sol::property(&MeshRenderer::GetMaterial, &MeshRenderer::SetMaterial),
"__Dummy", []{}
);

luaState.new_usertype<Plane>("PlaneMeshGen",
sol::constructors<Plane()>(),
sol::base_classes, sol::bases<IMeshData>(),
"__Dummy", []{}
);

luaState.new_usertype<GLMesh>("Mesh",
sol::constructors<GLMesh(IMeshData &)>(),
"__Dummy", []{}
);

luaState.new_usertype<GLTexture>("Texture",
sol::constructors<GLTexture(std::string )>(),
"__Dummy", []{}
);

luaState.new_usertype<GLMaterial>("Material",
sol::constructors<GLMaterial(GLTexture &diffuseMap, GLTexture &normalMap, GLTexture &specularMap)>(),
sol::base_classes, sol::bases<Material>(),
"__Dummy", []{}
);

luaState.new_usertype<MeshLoader>("MeshLoader",
sol::constructors<MeshLoader(const std::string &, int)>(),
sol::base_classes, sol::bases<IMeshData>(),
"__Dummy", []{}
);


luaState.new_usertype<GLFramebuffer>("Framebuffer",
sol::constructors<GLFramebuffer(uint16_t, uint16_t)>(),
"GetRenderTextureID", &GLFramebuffer::getRenderTextureID,
"Bind", &GLFramebuffer::bind,
"UnBind", &GLFramebuffer::unbind,
"Resize", &GLFramebuffer::resize,
"__Dummy", []{}
);

luaState.new_usertype<RenderSystem>("RenderSystem",
"GetSingletonPtr", &RenderSystem::getSingletonPtr,
"Update", &RenderSystem::update,
"__Dummy", []{}
);

// @formatter:on
}
