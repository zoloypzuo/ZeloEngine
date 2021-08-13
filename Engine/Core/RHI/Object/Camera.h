// Camera.h
// created on 2021/3/31
// author @zoloypzuo

#ifndef ZELOENGINE_CAMERA_H
#define ZELOENGINE_CAMERA_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/ECS/Entity.h"

class Camera : public Component
{
public:
    virtual ~Camera() {}

    glm::mat4 getViewMatrix() const;

    virtual glm::mat4 getProjectionMatrix() const = 0;

    inline virtual const char *getType() { return "CAMERA"; }
};

class PerspectiveCamera : public Camera
{
public:
    PerspectiveCamera()
    {
        setProperty("fov", PropertyType::ANGLE, &m_fov, 0, 180);
        setProperty("aspect", PropertyType::FLOAT, &m_aspect, 0, 10);
        setProperty("zNear", PropertyType::FLOAT, &m_zNear, 0, 1);
        setProperty("zFar", PropertyType::FLOAT, &m_zFar, 0, 1000);
    };

    // NOTE sol cannot resolve template
    // PerspectiveCamera(float fov, float aspect, float zNear, float zFar);

    virtual glm::mat4 getProjectionMatrix() const;

    inline virtual const char *getType() { return "PERSPECTIVE_CAMERA"; }

    void setFov(float fov);

    float getFov();

public:
    float m_fov{}, m_aspect{}, m_zNear{}, m_zFar{};
};

#endif //ZELOENGINE_CAMERA_H