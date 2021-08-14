// LuaBind_Entity.cpp
// created on 2021/7/31
// author @zoloypzuo
#include <sol/sol.hpp>
#include "Core/ECS/Actor.h"

#include "Core/ECS/Components/CTransform.h"

#include "Core/ECS/Entity.h"
#include "Core/Math/Transform.h"
#include "Core/RHI/Object/Camera.h"
#include "Core/ECS/Component/FreeMove.h"
#include "Core/ECS/Component/FreeLook.h"
#include "Core/RHI/Object/Light.h"

#include <glm/glm.hpp>

void LuaBind_Entity(sol::state &luaState) {
    using namespace Zelo::Core::ECS;
    using namespace Zelo::Core::ECS::Components;

    luaState.new_usertype<Actor>(
            "Actor",

            "GetName", &Actor::GetName,
            "SetName", &Actor::SetName,
            "GetTag", &Actor::GetTag,
            "GetChildren", &Actor::GetChildren,
            "SetTag", &Actor::SetTag,
            "GetID", &Actor::GetID,
            "GetParent", &Actor::GetParent,
            "SetParent", &Actor::SetParent,
            "DetachFromParent", &Actor::DetachFromParent,
            "Destroy", &Actor::MarkAsDestroy,
            "IsSelfActive", &Actor::IsSelfActive, "IsActive", &Actor::IsActive,
            "SetActive", &Actor::SetActive,


            "GetTransform", &Actor::GetComponent<CTransform>,

            "GetBehaviour", [](Actor &actor,
                               const std::string &name) -> sol::table {
                auto *behaviour = actor.GetBehaviour(name);
                if (behaviour)
                    return behaviour->GetTable();
                else
                    return sol::nil;
            },

            "AddBehaviour", &Actor::AddBehaviour,
            "RemoveBehaviour", sol::overload
                    (
                            sol::resolve<bool(Behaviour &)>(&Actor::RemoveBehaviour),
                            sol::resolve<bool(const std::string &)>(&Actor::RemoveBehaviour)
                    )
    );

    luaState.new_usertype<AComponent>(
            "Component",
            "GetOwner", [](AComponent &component) -> Actor & { return component.owner; }
    );

    luaState.new_usertype<CTransform>(
            "Transform",
            sol::base_classes, sol::bases<AComponent>()

//            "SetPosition", &CTransform::SetLocalPosition,
//            "SetRotation", &CTransform::SetLocalRotation,
//            "SetScale", &CTransform::SetLocalScale,
//            "SetLocalPosition", &CTransform::SetLocalPosition,
//            "SetLocalRotation", &CTransform::SetLocalRotation,
//            "SetLocalScale", &CTransform::SetLocalScale,
//            "GetPosition", [](CTransform &
//    this) -> FVector3{return this.GetWorldPosition();},
//            "GetRotation", [](CTransform &
//    this) -> FQuaternion{return this.GetWorldRotation();},
//            "GetScale", [](CTransform &
//    this) -> FVector3{return this.GetWorldScale();},
//            "GetLocalPosition", [](CTransform &
//    this) -> FVector3{return this.GetLocalPosition();},
//            "GetLocalRotation", [](CTransform &
//    this) -> FQuaternion{return this.GetLocalRotation();},
//            "GetLocalScale", [](CTransform &
//    this) -> FVector3{return this.GetLocalScale();},
//            "GetWorldPosition", [](CTransform &
//    this) -> FVector3{return this.GetWorldPosition();},
//            "GetWorldRotation", [](CTransform &
//    this) -> FQuaternion{return this.GetWorldRotation();},
//            "GetWorldScale", [](CTransform &
//    this) -> FVector3{return this.GetWorldScale();},
//            "GetForward", &CTransform::GetWorldForward,
//            "GetUp", &CTransform::GetWorldUp,
//            "GetRight", &CTransform::GetWorldRight,
//            "GetLocalForward", &CTransform::GetLocalForward,
//            "GetLocalUp", &CTransform::GetLocalUp,
//            "GetLocalRight", &CTransform::GetLocalRight,
//            "GetWorldForward", &CTransform::GetWorldForward,
//            "GetWorldUp", &CTransform::GetWorldUp,
//            "GetWorldRight", &CTransform::GetWorldRight
    );

// @formatter:off
luaState.new_usertype<Entity>("Entity",
"GetGUID", &Entity::GetGUID,
"AddTag", &Entity::AddTag,
"AddTransform", &Entity::AddTransform,
"AddCamera", &Entity::addComponent<PerspectiveCamera>,
"AddFreeMove", &Entity::addComponent<FreeMove>,
"AddFreeLook", &Entity::addComponent<FreeLook>,
"AddSpotLight", &Entity::addComponent<SpotLight>,
"AddDirectionalLight", &Entity::addComponent<DirectionalLight>,
"Dummy", []{}
);
// @formatter: on

// @formatter:off
luaState.new_usertype<Transform>("Transform",
"SetPosition", &Transform::SetPosition,
"SetScale", &Transform::SetScale,
"Rotate", &Transform::Rotate,
"Dummy", []{}
);
// @formatter: on

// @formatter:off
luaState.new_usertype<PerspectiveCamera>("Camera",
"fov", &PerspectiveCamera::m_fov, 
"aspect", &PerspectiveCamera::m_aspect, 
"zNear", &PerspectiveCamera::m_zNear, 
"zFar", &PerspectiveCamera::m_zFar,
"Dummy", []{}
);
// @formatter:on

// @formatter:off
luaState.new_usertype<Attenuation>("Attenuation",
"constant", &Attenuation::m_constant, 
"linear", &Attenuation::m_linear, 
"exponent", &Attenuation::m_exponent, 
"Dummy", []{}
);
// @formatter:on

// @formatter:off
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
// @formatter:on

// @formatter:off
luaState.new_usertype<BaseLight>("BaseLight",
"color", &BaseLight::m_color,
"intensity", &BaseLight::m_intensity, 
"Dummy", []{}
);
// @formatter:on

// @formatter:off
luaState.new_usertype<SpotLight>("SpotLight",
sol::base_classes, sol::bases<BaseLight>(),
"attenuation", &SpotLight::m_attenuation,
"range", &SpotLight::m_range,
"cutoff", &SpotLight::m_cutoff, 
"Dummy", []{}
);
// @formatter:on

// @formatter:off
luaState.new_usertype<DirectionalLight>("DirectionalLight",
sol::base_classes, sol::bases<BaseLight>(),
"Dummy", []{}
);
// @formatter:on
}

//    luaState.new_enum<CModelRenderer::EFrustumBehaviour>(
//            "FrustumBehaviour",
//            {
//                    {"DISABLED",    CModelRenderer::EFrustumBehaviour::DISABLED},
//                    {"CULL_MODEL",  CModelRenderer::EFrustumBehaviour::CULL_MODEL},
//                    {"CULL_MESHES", CModelRenderer::EFrustumBehaviour::CULL_MESHES},
//                    {"CULL_CUSTOM", CModelRenderer::EFrustumBehaviour::CULL_CUSTOM}
//            });
//
//    luaState.new_usertype<CModelRenderer>(
//            "ModelRenderer",
//            sol::base_classes, sol::bases<AComponent>(),
//            "GetModel", &CModelRenderer::GetModel,
//            "SetModel", &CModelRenderer::SetModel,
//            "GetFrustumBehaviour", &CModelRenderer::GetFrustumBehaviour,
//            "SetFrustumBehaviour", &CModelRenderer::SetFrustumBehaviour
//    );
//
//    luaState.new_usertype<CMaterialRenderer>(
//            "MaterialRenderer",
//            sol::base_classes, sol::bases<AComponent>(),
//            "SetMaterial", &CMaterialRenderer::SetMaterialAtIndex,
//            "SetUserMatrixElement", &CMaterialRenderer::SetUserMatrixElement,
//            "GetUserMatrixElement", &CMaterialRenderer::GetUserMatrixElement
//    );
//
//    luaState.new_enum<ECollisionDetectionMode>(
//            "CollisionDetectionMode",
//            {
//                    {"DISCRETE",   ECollisionDetectionMode::DISCRETE},
//                    {"CONTINUOUS", ECollisionDetectionMode::CONTINUOUS}
//            });
//
//    luaState.new_usertype<CPhysicalObject>(
//            "PhysicalObject",
//            sol::base_classes, sol::bases<AComponent>(),
//            "GetMass", &CPhysicalObject::GetMass,
//            "SetMass", &CPhysicalObject::SetMass,
//            "GetFriction", &CPhysicalObject::GetFriction,
//            "SetFriction", &CPhysicalObject::SetFriction,
//            "GetBounciness", &CPhysicalObject::GetBounciness,
//            "SetBounciness", &CPhysicalObject::SetBounciness,
//            "SetLinearVelocity", &CPhysicalObject::SetLinearVelocity,
//            "SetAngularVelocity", &CPhysicalObject::SetAngularVelocity,
//            "GetLinearVelocity", &CPhysicalObject::GetLinearVelocity,
//            "GetAngularVelocity", &CPhysicalObject::GetAngularVelocity,
//            "SetLinearFactor", &CPhysicalObject::SetLinearFactor,
//            "SetAngularFactor", &CPhysicalObject::SetAngularFactor,
//            "GetLinearFactor", &CPhysicalObject::GetLinearFactor,
//            "GetAngularFactor", &CPhysicalObject::GetAngularFactor,
//            "IsTrigger", &CPhysicalObject::IsTrigger,
//            "SetTrigger", &CPhysicalObject::SetTrigger,
//            "AddForce", &CPhysicalObject::AddForce,
//            "AddImpulse", &CPhysicalObject::AddImpulse,
//            "ClearForces", &CPhysicalObject::ClearForces,
//            "SetCollisionDetectionMode", &CPhysicalObject::SetCollisionDetectionMode,
//            "GetCollisionMode", &CPhysicalObject::GetCollisionDetectionMode,
//            "SetKinematic", &CPhysicalObject::SetKinematic
//    );
//
//    luaState.new_usertype<CPhysicalBox>(
//            "PhysicalBox",
//            sol::base_classes, sol::bases<CPhysicalObject>(),
//            "GetSize", &CPhysicalBox::GetSize,
//            "SetSize", &CPhysicalBox::SetSize
//    );
//
//    luaState.new_usertype<CPhysicalSphere>(
//            "PhysicalSphere",
//            sol::base_classes, sol::bases<CPhysicalObject>(),
//            "GetRadius", &CPhysicalSphere::GetRadius,
//            "SetRadius", &CPhysicalSphere::SetRadius
//    );
//
//    luaState.new_usertype<CPhysicalCapsule>(
//            "PhysicalCapsule",
//            sol::base_classes, sol::bases<CPhysicalObject>(),
//            "GetRadius", &CPhysicalCapsule::GetRadius,
//            "SetRadius", &CPhysicalCapsule::SetRadius,
//            "GetHeight", &CPhysicalCapsule::GetHeight,
//            "SetHeight", &CPhysicalCapsule::SetHeight
//    );
//
//    luaState.new_enum<EProjectionMode>(
//            "ProjectionMode",
//            {
//                    {"ORTHOGRAPHIC", EProjectionMode::ORTHOGRAPHIC},
//                    {"PERSPECTIVE",  EProjectionMode::PERSPECTIVE}
//            });
//
//    luaState.new_usertype<CCamera>(
//            "Camera",
//            sol::base_classes, sol::bases<AComponent>(),
//            "GetFov", &CCamera::GetFov,
//            "GetSize", &CCamera::GetSize,
//            "GetNear", &CCamera::GetNear,
//            "GetFar", &CCamera::GetFar,
//            "GetClearColor", &CCamera::GetClearColor,
//            "SetFov", &CCamera::SetFov,
//            "SetSize", &CCamera::SetSize,
//            "SetNear", &CCamera::SetNear,
//            "SetFar", &CCamera::SetFar,
//            "SetClearColor", &CCamera::SetClearColor,
//            "HasFrustumGeometryCulling", &CCamera::HasFrustumGeometryCulling,
//            "HasFrustumLightCulling", &CCamera::HasFrustumLightCulling,
//            "GetProjectionMode", &CCamera::GetProjectionMode,
//            "SetFrustumGeometryCulling", &CCamera::SetFrustumGeometryCulling,
//            "SetFrustumLightCulling", &CCamera::SetFrustumLightCulling,
//            "SetProjectionMode", &CCamera::SetProjectionMode
//    );
//
//    luaState.new_usertype<CLight>(
//            "Light",
//            sol::base_classes, sol::bases<AComponent>(),
//            "GetColor", &CPointLight::GetColor,
//            "GetIntensity", &CPointLight::GetIntensity,
//            "SetColor", &CPointLight::SetColor,
//            "SetIntensity", &CPointLight::SetIntensity
//    );
//
//    luaState.new_usertype<CPointLight>(
//            "PointLight",
//            sol::base_classes, sol::bases<CLight>(),
//            "GetConstant", &CPointLight::GetConstant,
//            "GetLinear", &CPointLight::GetLinear,
//            "GetQuadratic", &CPointLight::GetQuadratic,
//            "SetConstant", &CPointLight::SetConstant,
//            "SetLinear", &CPointLight::SetLinear,
//            "SetQuadratic", &CPointLight::SetQuadratic
//    );
//
//    luaState.new_usertype<CSpotLight>(
//            "SpotLight",
//            sol::base_classes, sol::bases<CLight>(),
//            "GetConstant", &CSpotLight::GetConstant,
//            "GetLinear", &CSpotLight::GetLinear,
//            "GetQuadratic", &CSpotLight::GetQuadratic,
//            "GetCutOff", &CSpotLight::GetCutoff,
//            "GetOuterCutOff", &CSpotLight::GetOuterCutoff,
//            "SetConstant", &CSpotLight::SetConstant,
//            "SetLinear", &CSpotLight::SetLinear,
//            "SetQuadratic", &CSpotLight::SetQuadratic,
//            "SetCutOff", &CSpotLight::SetCutoff,
//            "SetOuterCutOff", &CSpotLight::SetOuterCutoff
//    );
//
//    luaState.new_usertype<CAmbientBoxLight>(
//            "AmbientBoxLight",
//            sol::base_classes, sol::bases<CLight>(),
//            "GetSize", &CAmbientBoxLight::GetSize,
//            "SetSize", &CAmbientBoxLight::SetSize
//    );
//
//    luaState.new_usertype<CAmbientSphereLight>(
//            "AmbientSphereLight",
//            sol::base_classes, sol::bases<CLight>(),
//            "GetRadius", &CAmbientSphereLight::GetRadius,
//            "SetRadius", &CAmbientSphereLight::SetRadius
//    );
//
//    luaState.new_usertype<CDirectionalLight>(
//            "DirectionalLight",
//            sol::base_classes, sol::bases<CLight>()
//    );
//
//    luaState.new_usertype<CAudioSource>(
//            "AudioSource",
//            sol::base_classes, sol::bases<AComponent>(),
//            "Play", &CAudioSource::Play,
//            "Stop", &CAudioSource::Stop,
//            "Pause", &CAudioSource::Pause,
//            "Resume", &CAudioSource::Resume,
//            "GetSound", &CAudioSource::GetSound,
//            "GetVolume", &CAudioSource::GetVolume,
//            "GetPan", &CAudioSource::GetPan,
//            "IsLooped", &CAudioSource::IsLooped,
//            "GetPitch", &CAudioSource::GetPitch,
//            "IsFinished", &CAudioSource::IsFinished,
//            "IsSpatial", &CAudioSource::IsSpatial,
//            "GetAttenuationThreshold", &CAudioSource::GetAttenuationThreshold,
//            "SetSound", &CAudioSource::SetSound,
//            "SetVolume", &CAudioSource::SetVolume,
//            "SetPan", &CAudioSource::SetPan,
//            "SetLooped", &CAudioSource::SetLooped,
//            "SetPitch", &CAudioSource::SetPitch,
//            "SetSpatial", &CAudioSource::SetSpatial,
//            "SetAttenuationThreshold", &CAudioSource::SetAttenuationThreshold
//    );
//
//    luaState.new_usertype<CAudioListener>(
//            "AudioListener",
//            sol::base_classes, sol::bases<AComponent>()
//    );