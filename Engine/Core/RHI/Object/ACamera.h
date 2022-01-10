// Camera.h
// created on 2021/3/31
// author @zoloypzuo

#ifndef ZELOENGINE_ACAMERA_H
#define ZELOENGINE_ACAMERA_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/ECS/Entity.h"

namespace Zelo::Core::RHI {
class ACamera : public Zelo::Core::ECS::Component {
public:
    explicit ACamera(ECS::Entity &owner);;

    ~ACamera() override = default;

    glm::mat4 getViewMatrix() const;

    virtual glm::mat4 getProjectionMatrix() const = 0;

    inline std::string getType() override { return "CAMERA"; }
};

class PerspectiveCamera : public Zelo::Core::RHI::ACamera {
public:
    explicit PerspectiveCamera(ECS::Entity &owner);;

    glm::mat4 getProjectionMatrix() const override;

    inline std::string getType() override { return "PERSPECTIVE_CAMERA"; }

    void setFov(float fov);

    float getFov() const;

public:  // script property
    float m_fov{}, m_aspect{}, m_zNear{}, m_zFar{};
};
}

#endif //ZELOENGINE_ACAMERA_H