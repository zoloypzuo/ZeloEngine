// Camera.h
// created on 2021/3/31
// author @zoloypzuo

#ifndef ZELOENGINE_CAMERA_H
#define ZELOENGINE_CAMERA_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/ECS/Entity.h"

class Camera : public Zelo::Core::ECS::Component
{
public:
    ~Camera() override = default;

    glm::mat4 getViewMatrix() const;

    virtual glm::mat4 getProjectionMatrix() const = 0;

    inline std::string getType() override { return "CAMERA"; }
};

class PerspectiveCamera : public Camera
{
public:
    PerspectiveCamera();;

    glm::mat4 getProjectionMatrix() const override;

    inline std::string getType() override { return "PERSPECTIVE_CAMERA"; }

    void setFov(float fov);

    float getFov() const;

public:  // script property
    float m_fov{}, m_aspect{}, m_zNear{}, m_zFar{};
};

#endif //ZELOENGINE_CAMERA_H