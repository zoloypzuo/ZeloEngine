// Camera.h
// created on 2021/3/31
// author @zoloypzuo

#ifndef ZELOENGINE_CAMERA_H
#define ZELOENGINE_CAMERA_H

#include "ZeloPrerequisites.h"
#include "Component.h"

class Camera : public Component
{
public:
    virtual ~Camera(void) {}

    glm::mat4 getViewMatrix(void) const;
    virtual glm::mat4 getProjectionMatrix(void) const = 0;

    inline virtual const char *getType(void) { return "CAMERA"; }
};

class PerspectiveCamera : public Camera
{
public:
    PerspectiveCamera(float fov, float aspect, float zNear, float zFar);

    virtual glm::mat4 getProjectionMatrix(void) const;

    inline virtual const char *getType(void) { return "PERSPECTIVE_CAMERA"; }

    void setFov(float fov);
    float getFov(void);

private:
    float m_fov, m_aspect, m_zNear, m_zFar;
};

#endif //ZELOENGINE_CAMERA_H