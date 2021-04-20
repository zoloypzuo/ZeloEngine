// Transform.h
// created on 2021/3/28
// author @zoloypzuo

#ifndef ZELOENGINE_TRANSFORM_H
#define ZELOENGINE_TRANSFORM_H

#include "ZeloPrerequisites.h"
#include <glm/gtc/quaternion.hpp>

class Transform {
public:
    Transform(const glm::vec3 &position = glm::vec3(),
              const glm::quat &rotation = glm::quat(1, 0, 0, 0),
              const glm::vec3 &scale = glm::vec3(1.0f));

    ~Transform();

    Transform &rotate(const glm::vec3 &axis, float angle);

    Transform &scale(float scale);

    Transform &scale(const glm::vec3 &scale);

    Transform &translate(const glm::vec3 &position);

    Transform &setPosition(const glm::vec3 &position);

    Transform &setScale(const glm::vec3 &scale);

    Transform &setRotation(const glm::quat &rotation);

    Transform &setRotation(const glm::vec3 &axis, float w);

    glm::vec3 getPosition() const;

    glm::vec3 getScale() const;

    glm::quat getRotation() const;

    glm::mat4 getTransformMatrix() const;

    glm::vec4 getDirection() const;

    void lookAt(const glm::vec3 center);

    // private:
    glm::vec3 m_position{};
    glm::quat m_rotation{};
    glm::vec3 m_scale{};
};


#endif //ZELOENGINE_TRANSFORM_H