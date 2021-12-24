// Camera.cpp
// created on 2021/3/31
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ACamera.h"

#include <glm/gtx/transform.hpp>

using namespace Zelo::Core::ECS;

Zelo::Core::RHI::ACamera::ACamera(Entity &owner) : Zelo::Core::ECS::Component(owner) {}

glm::mat4 Zelo::Core::RHI::ACamera::getViewMatrix() const {
    return glm::inverse(m_owner.getWorldMatrix());
}

glm::mat4 Zelo::Core::RHI::PerspectiveCamera::getProjectionMatrix() const {
    return glm::perspective(m_fov, m_aspect, m_zNear, m_zFar);
}

void Zelo::Core::RHI::PerspectiveCamera::setFov(float fov) {
    m_fov = fov;
}

float Zelo::Core::RHI::PerspectiveCamera::getFov() const {
    return m_fov;
}

Zelo::Core::RHI::PerspectiveCamera::PerspectiveCamera(Entity &owner) : ACamera(owner) {
}
