// LuaBind_Entity.cpp
// created on 2021/7/31
// author @zoloypzuo
#include <sol/sol.hpp>

#include "Core/RHI/MeshRenderer.h"
#include "Core/RHI/RenderSystem.h"
#include "Core/RHI/MeshGen/Plane.h"
#include "Core/RHI/Object/ACamera.h"
#include "Core/RHI/Object/ALight.h"

#include "ThirdParty/Glm/LuaBind_Glm.h"  // glm::vec3

using namespace Zelo;
using namespace Zelo::Core::ECS;
using namespace Zelo::Core::LuaScript;
using namespace Zelo::Core::Interface;
using namespace Zelo::Core::RHI;

void LuaBind_RHI(sol::state &luaState) {
// @formatter:off
luaState.new_usertype<PerspectiveCamera>("Camera",
"fov", &PerspectiveCamera::m_fov,
"aspect", &PerspectiveCamera::m_aspect,
"zNear", &PerspectiveCamera::m_zNear,
"zFar", &PerspectiveCamera::m_zFar,
"__Dummy", []{}
);

luaState.new_usertype<ALight>("Light",
"Type", sol::property(&ALight::GetType, &ALight::SetType),
"Color", sol::property(&ALight::GetColor, &ALight::SetColor),
"Intensity", sol::property(&ALight::GetIntensity, &ALight::SetIntensity),
"Constant", sol::property(&ALight::GetConstant, &ALight::SetConstant),
"Linear", sol::property(&ALight::GetLinear, &ALight::SetLinear),
"Quadratic", sol::property(&ALight::GetQuadratic, &ALight::SetQuadratic),
"Cutoff", sol::property(&ALight::GetCutoff, &ALight::SetCutoff),
"OuterCutoff", sol::property(&ALight::GetOuterCutoff, &ALight::SetOuterCutoff),
"Size", sol::property(&ALight::GetSize, &ALight::SetSize),
"Radius", sol::property(&ALight::GetRadius, &ALight::SetRadius),
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
//luaState.new_usertype<GLSLShaderProgram>("Shader",
//sol::constructors<GLSLShaderProgram(const std::string &)>(),
//"__Dummy", []{}
//);

luaState.new_usertype<IView>("IView",
"__Dummy", []{}
);

luaState.new_usertype<RenderSystem>("RenderSystem",
"GetSingletonPtr", &RenderSystem::getSingletonPtr,
"Update", &RenderSystem::update,
"PushView", &RenderSystem::pushView,
"PopView", &RenderSystem::popView,
"__Dummy", []{}
);
// @formatter:on
}
