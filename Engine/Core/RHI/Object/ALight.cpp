// LightPlain.cpp
// created on 2021/11/7
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ALight.h"
#include "Core/RHI/RenderSystem.h"

using namespace Zelo::Core::RHI;
using namespace Zelo::Core::ECS;

ALight::~ALight() = default;

ALight::ALight(Entity &owner) : Component(owner) {
    // TODO refactor property
    setProperty("color", PropertyType::COLOR, &color.x, 0, 1);
    setProperty("intensity", PropertyType::FLOAT, &intensity, 0, 100);
}

glm::mat4 ALight::generateLightMatrix() const {
    auto position = m_owner.getPosition();
    auto forward = m_owner.getDirection();
    return glm::mat4{
            glm::vec4(position.x, position.y, position.z, 0),
            glm::vec4(forward.x, forward.y, forward.z, 0),
            glm::vec4(color.x, color.y, color.z, 0),
            glm::vec4(type, linear, quadratic, intensity)
    };
}
