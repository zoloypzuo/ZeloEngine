// LightPlain.h
// created on 2021/11/7
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/ECS/Entity.h"

namespace Zelo::Core::RHI {
enum class ELightType {
    POINT, DIRECTIONAL, SPOT, AMBIENT_BOX, AMBIENT_SPHERE
};

class ALight : public Zelo::Core::ECS::Component,
                   public std::enable_shared_from_this<ALight> {
public:
    explicit ALight(Zelo::Core::ECS::Entity &owner);

    ~ALight() override;

    std::string getType() override { return "Light"; }

    // encode data into a matrix
    glm::mat4 generateLightMatrix() const;

public:
    // @formatter:off
    ZELO_SCRIPT_API ELightType GetType() const { return type;}
    ZELO_SCRIPT_API void SetType(ELightType type_) { type = type_;}
    ZELO_SCRIPT_API glm::vec3 GetColor() const { return color;}
    ZELO_SCRIPT_API void SetColor(glm::vec3 color_) { color = color_;}
    ZELO_SCRIPT_API float GetIntensity() const { return intensity;}
    ZELO_SCRIPT_API void SetIntensity(float intensity_) { intensity = intensity_;}
    ZELO_SCRIPT_API float GetConstant() const { return constant;}
    ZELO_SCRIPT_API void SetConstant(float constant_) { constant = constant_;}
    ZELO_SCRIPT_API float GetLinear() const { return linear;}
    ZELO_SCRIPT_API void SetLinear(float linear_) { linear = linear_;}
    ZELO_SCRIPT_API float GetQuadratic() const { return quadratic;}
    ZELO_SCRIPT_API void SetQuadratic(float quadratic_) { quadratic = quadratic_;}
    ZELO_SCRIPT_API float GetCutoff() const { return cutoff;}
    ZELO_SCRIPT_API void SetCutoff(float cutoff_) { cutoff = cutoff_;}
    ZELO_SCRIPT_API float GetOuterCutoff() const { return outerCutoff;}
    ZELO_SCRIPT_API void SetOuterCutoff(float outerCutoff_) { outerCutoff = outerCutoff_;}
    // @formatter:on

public:
    ELightType type = ELightType::POINT;
    glm::vec3 color = {1.f, 1.f, 1.f};
    float intensity = 1.f;
    float constant = 0.0f;
    float linear = 0.0f;
    float quadratic = 1.0f;
    float cutoff = 12.f;
    float outerCutoff = 15.f;
};
}

