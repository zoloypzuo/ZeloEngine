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

class LightPlain : public Zelo::Core::ECS::Component,
                   public std::enable_shared_from_this<LightPlain> {
public:
    explicit LightPlain(Zelo::Core::ECS::Entity &owner);

    ~LightPlain() override;

    std::string getType() override { return "Light"; }

    // encode data into a matrix
    glm::mat4 generateLightMatrix() const;

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

