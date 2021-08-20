// LuaBind_Entity.cpp
// created on 2021/7/31
// author @zoloypzuo
#include <sol/sol.hpp>

#include "Core/ECS/Entity.h"
#include "Core/Math/Transform.h"
#include "Core/RHI/Object/Camera.h"
#include "Core/ECS/Component/CFreeMove.h"
#include "Core/ECS/Component/CFreeLook.h"
#include "Core/RHI/Object/Light.h"

#include <glm/glm.hpp>

#include "Core/RHI/MeshGen/Plane.h"
#include "Renderer/OpenGL/Drawable/MeshRenderer.h"
#include "Renderer/OpenGL/Resource/GLMesh.h"
#include "Renderer/OpenGL/Resource/GLMaterial.h"

#include "Core/Parser/MeshLoader.h"

#include "Core/RHI/RenderSystem.h"

using namespace Zelo::Core::LuaScript;
using namespace Zelo::Core::RHI;
using namespace Zelo::Renderer::OpenGL;
using namespace Zelo::Parser;
using namespace Zelo::Core::ECS;
using namespace Zelo::Core::Interface;

void LuaBind_Entity(sol::state &luaState) {
    using namespace Zelo::Core::ECS;

// @formatter:off
luaState.new_usertype<Entity>("Entity",
"GetGUID", &Entity::GetGUID,
"AddTag", &Entity::AddTag,
"AddTransform", &Entity::AddTransform,
"AddCamera", &Entity::AddComponent<PerspectiveCamera>,
"AddFreeMove", &Entity::AddComponent<CFreeMove>,
"AddFreeLook", &Entity::AddComponent<CFreeLook>,
"AddSpotLight", &Entity::AddComponent<SpotLight>,
"AddDirectionalLight", &Entity::AddComponent<DirectionalLight>,
"AddMeshRenderer", &Entity::AddComponent<MeshRenderer>,
"Dummy", []{}
);

luaState.new_usertype<Transform>("Transform",
"SetPosition", &Transform::SetPosition,
"SetScale", &Transform::SetScale,
"Rotate", &Transform::Rotate,
"Dummy", []{}
);

luaState.new_usertype<PerspectiveCamera>("Camera",
"fov", &PerspectiveCamera::m_fov, 
"aspect", &PerspectiveCamera::m_aspect, 
"zNear", &PerspectiveCamera::m_zNear, 
"zFar", &PerspectiveCamera::m_zFar,
"Dummy", []{}
);

luaState.new_usertype<Attenuation>("Attenuation",
"constant", &Attenuation::m_constant, 
"linear", &Attenuation::m_linear, 
"exponent", &Attenuation::m_exponent, 
"Dummy", []{}
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
"Dummpy", []{}
);

luaState.new_usertype<BaseLight>("BaseLight",
"color", &BaseLight::m_color,
"intensity", &BaseLight::m_intensity, 
"Dummy", []{}
);

luaState.new_usertype<SpotLight>("SpotLight",
sol::base_classes, sol::bases<BaseLight>(),
"attenuation", &SpotLight::m_attenuation,
"range", &SpotLight::m_range,
"cutoff", &SpotLight::m_cutoff, 
"Dummy", []{}
);

luaState.new_usertype<DirectionalLight>("DirectionalLight",
sol::base_classes, sol::bases<BaseLight>(),
"Dummy", []{}
);

luaState.new_usertype<MeshRenderer>("MeshRenderer",
//sol::base_classes, sol::bases<BaseLight>(),
"mesh", sol::property(&MeshRenderer::GetMesh, &MeshRenderer::SetMesh),
"material", sol::property(&MeshRenderer::GetMaterial, &MeshRenderer::SetMaterial),
"Dummy", []{}
);

luaState.new_usertype<Plane>("PlaneMeshGen",
sol::constructors<Plane()>(),
sol::base_classes, sol::bases<IMeshData>(),
"Dummy", []{}
);

luaState.new_usertype<GLMesh>("Mesh",
sol::constructors<GLMesh(IMeshData &)>(),
"Dummy", []{}
);

luaState.new_usertype<GLTexture>("Texture",
sol::constructors<GLTexture(std::string )>(),
"Dummy", []{}
);

luaState.new_usertype<GLMaterial>("Material",
sol::constructors<GLMaterial(GLTexture &diffuseMap, GLTexture &normalMap, GLTexture &specularMap)>(),
sol::base_classes, sol::bases<Material>(),
"Dummy", []{}
);

luaState.new_usertype<MeshLoader>("MeshLoader",
sol::constructors<MeshLoader(const std::string &, int)>(),
sol::base_classes, sol::bases<IMeshData>(),
"Dummy", []{}
);

// @formatter:on
}
