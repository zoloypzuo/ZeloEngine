// LuaBind_Entity.cpp
// created on 2021/7/31
// author @zoloypzuo
#include <sol/sol.hpp>

#include "Core/Controller/CFreeLook.h"
#include "Core/Controller/CFreeMove.h"
#include "Core/ECS/Entity.h"

#include "Core/Parser/MeshLoader.h"

#include "Core/RHI/MeshRenderer.h"
#include "Core/RHI/Object/ACamera.h"
#include "Core/RHI/Object/ALight.h"

#include "Renderer/OpenGL/Drawable/MeshScene/GLSkyboxRenderer.h"

//#include "ThirdParty/Glm/LuaBind_Glm.h"  // glm::vec3

using namespace Zelo;
using namespace Zelo::Core::ECS;
using namespace Zelo::Core::LuaScript;
using namespace Zelo::Core::Parser;
using namespace Zelo::Core::RHI;

using namespace Zelo::Renderer::OpenGL;

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
"AddLight", &Entity::AddComponent<ALight>,
"AddMeshRenderer", &Entity::AddComponent<MeshRenderer>,
"AddSkyboxRenderer", [](Entity &self,
                        std::string_view envMap,
                        std::string_view envMapIrradiance,
                        std::string_view brdfLUTFileName) { self.AddComponent<GLSkyboxRenderer>(
                                envMap, envMapIrradiance, brdfLUTFileName);},
"__Dummy", []{}
);

luaState.new_usertype<Transform>("Transform",
"position", sol::property(&Transform::getPosition, &Transform::setPosition),
"rotation", sol::property(&Transform::GetRotation, &Transform::SetRotation),
"scale", sol::property(&Transform::getScale, & Transform::setScale),
"SetPosition", &Transform::SetPosition,
"SetScale", &Transform::SetScale,
"Rotate", &Transform::Rotate,
"__Dummy", []{}
);

luaState.new_usertype<MeshLoader>("MeshLoader",
sol::constructors<MeshLoader(const std::string &, int)>(),
sol::base_classes, sol::bases<IMeshData>(),
"__Dummy", []{}
);
// @formatter:on
}
