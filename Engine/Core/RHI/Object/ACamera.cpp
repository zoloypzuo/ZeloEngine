// Camera.cpp
// created on 2021/3/31
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ACamera.h"

#include <glm/gtx/transform.hpp>

using namespace Zelo::Core::ECS;

ACamera::ACamera(Entity &owner) : Zelo::Core::ECS::Component(owner) {}

glm::mat4 ACamera::getViewMatrix() const {
    return glm::inverse(m_owner.getWorldMatrix());
}

glm::mat4 PerspectiveCamera::getProjectionMatrix() const {
    return glm::perspective(m_fov, m_aspect, m_zNear, m_zFar);
}

void PerspectiveCamera::setFov(float fov) {
    m_fov = fov;
}

float PerspectiveCamera::getFov() const {
    return m_fov;
}

PerspectiveCamera::PerspectiveCamera(Entity &owner) : ACamera(owner) {
    setProperty("fov", PropertyType::ANGLE, &m_fov, 0, 180);
    setProperty("aspect", PropertyType::FLOAT, &m_aspect, 0, 10);
    setProperty("zNear", PropertyType::FLOAT, &m_zNear, 0, 1);
    setProperty("zFar", PropertyType::FLOAT, &m_zFar, 0, 1000);
}
