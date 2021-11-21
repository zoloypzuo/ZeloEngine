// Frustum.h
// created on 2021/10/20
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

class Frustum {
private:
    GLuint vao;

    glm::vec3 center, u, v, n;
    float mNear, mFar, fovy, ar;
    std::vector<GLuint> buffers;

public:
    Frustum();

    ~Frustum();

    void orient(const glm::vec3 &pos, const glm::vec3 &a, const glm::vec3 &u);

    void setPerspective(float, float, float, float);

    glm::mat4 getViewMatrix() const;

    glm::mat4 getInverseViewMatrix() const;

    glm::mat4 getProjectionMatrix() const;

    glm::vec3 getOrigin() const;

    void render() const;

    void deleteBuffers();
};


