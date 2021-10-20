// Frustum.h
// created on 2021/10/20
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Core/RHI/Const/EProjectionMode.h"

namespace Zelo::Core::RHI {

#define PI 3.141592653589793
#define TWOPI 6.2831853071795862
#define TO_RADIANS(x) (x * 0.017453292519943295)
#define TO_DEGREES(x) (x * 57.29577951308232)

class Frustum {
private:
    EProjectionMode type{};

    glm::vec3 origin{};
    glm::vec3 at{};
    glm::vec3 up{};

    float mNear{};
    float mFar{};
    float xmin{}, xmax{}, ymin{}, ymax{};
    float fovy{}, ar{};

    glm::mat4 view{}, proj{};

public:
    explicit Frustum(EProjectionMode t) : type(t) {
        this->orient(glm::vec3(0.0f, 0.0f, 1.0f),
                     glm::vec3(0.0f, 0.0f, 0.0f),
                     glm::vec3(0.0f, 1.0f, 0.0f));
        if (type == EProjectionMode::ORTHOGRAPHIC) {
            this->setOrthoBounds(-1.0f, 1.0f, -1.0f, 1.0f, -1.0f, 1.0f);
        } else {
            this->setPerspective(50.0f, 1.0f, 0.5f, 100.0f);
        }
    }

    void orient(const glm::vec3 &pos, const glm::vec3 &a, const glm::vec3 &u) {
        this->origin = pos;
        this->at = a;
        this->up = u;
    }

    void setOrthoBounds(float xmin, float xmax, float ymin, float ymax, float near, float far) {
        this->xmin = xmin;
        this->xmax = xmax;
        this->ymin = ymin;
        this->ymax = ymax;
        this->mNear = near;
        this->mFar = far;
    }

    void setPerspective(float fovy, float ar, float near, float far) {
        this->fovy = fovy;
        this->ar = ar;
        this->mNear = near;
        this->mFar = far;
    }

    void enclose(const Frustum &other) {
        glm::vec3 n = glm::normalize(other.origin - other.at);
        glm::vec3 u = glm::normalize(glm::cross(other.up, n));
        glm::vec3 v = glm::normalize(glm::cross(n, u));
        if (type == EProjectionMode::PERSPECTIVE)
            this->orient(origin, other.getCenter(), up);
        glm::mat4 m = this->getViewMatrix();

        glm::vec3 p[8];

        // Get 8 points that define the frustum
        if (other.type == EProjectionMode::PERSPECTIVE) {
            float dy = other.mNear * tanf(TO_RADIANS(other.fovy) / 2.0f);
            float dx = other.ar * dy;
            glm::vec3 c = other.origin - n * other.mNear;
            p[0] = c + u * dx + v * dy;
            p[1] = c - u * dx + v * dy;
            p[2] = c - u * dx - v * dy;
            p[3] = c + u * dx - v * dy;
            dy = other.mFar * tanf(TO_RADIANS(other.fovy) / 2.0f);
            dx = other.ar * dy;
            c = other.origin - n * other.mFar;
            p[4] = c + u * dx + v * dy;
            p[5] = c - u * dx + v * dy;
            p[6] = c - u * dx - v * dy;
            p[7] = c + u * dx - v * dy;
        } else {
            glm::vec3 c = other.origin - n * other.mNear;
            p[0] = c + u * other.xmax + v * other.ymax;
            p[1] = c + u * other.xmax + v * other.ymin;
            p[2] = c + u * other.xmin + v * other.ymax;
            p[3] = c + u * other.xmin + v * other.ymin;
            c = other.origin - n * other.mFar;
            p[4] = c + u * other.xmax + v * other.ymax;
            p[5] = c + u * other.xmax + v * other.ymin;
            p[6] = c + u * other.xmin + v * other.ymax;
            p[7] = c + u * other.xmin + v * other.ymin;
        }

        // Adjust frustum to contain
        if (type == EProjectionMode::PERSPECTIVE) {
            fovy = 0.0f;
            mFar = 0.0f;
            mNear = std::numeric_limits<float>::max();
            float maxHorizAngle = 0.0f;
            for (int i = 0; i < 8; i++) {
                // Convert to local space
                glm::vec4 pt = m * glm::vec4(p[i], 1.0f);

                if (pt.z < 0.0f) {
                    float d = -pt.z;
                    float angle = atanf(fabs(pt.x) / d);
                    if (angle > maxHorizAngle) maxHorizAngle = angle;
                    angle = TO_DEGREES(atanf(fabs(pt.y) / d));
                    if (angle * 2.0f > fovy) fovy = angle * 2.0f;
                    if (mNear > d) mNear = d;
                    if (mFar < d) mFar = d;
                }
            }
            float h = (mNear * tanf(TO_RADIANS(fovy) / 2.0f)) * 2.0f;
            float w = (mNear * tanf(maxHorizAngle)) * 2.0f;
            ar = w / h;
        } else {
            xmin = ymin = mNear = std::numeric_limits<float>::max();
            xmax = ymax = mFar = std::numeric_limits<float>::min();
            for (int i = 0; i < 8; i++) {
                // Convert to local space
                glm::vec4 pt = m * glm::vec4(p[i], 1.0f);
                if (xmin > pt.x) xmin = pt.x;
                if (xmax < pt.x) xmax = pt.x;
                if (ymin > pt.y) ymin = pt.y;
                if (ymax < pt.y) ymax = pt.y;
                if (mNear > -pt.z) mNear = -pt.z;
                if (mFar < -pt.z) mFar = -pt.z;
            }
        }
    }

    glm::mat4 getViewMatrix() const { return glm::lookAt(origin, at, up); }

    glm::mat4 getProjectionMatrix() const {
        if (type == EProjectionMode::PERSPECTIVE)
            return glm::perspective(fovy, ar, mNear, mFar);
        else
            return glm::ortho(xmin, xmax, ymin, ymax, mNear, mFar);
    }

    glm::vec3 getOrigin() const { return this->origin; }

    glm::vec3 getCenter() const {
        float dist = (mNear + mFar) / 2.0f;
        glm::vec3 r = glm::normalize(at - origin);

        return origin + (r * dist);
    }

    void printInfo() const {
        if (type == EProjectionMode::PERSPECTIVE) {
            spdlog::debug("Perspective:  fovy = %f  ar = %f  near = %f  far = %f",
                          fovy, ar, mNear, mFar);
        } else {
            spdlog::debug("Orthographic: x(%f,%f) y(%f,%f) near = %f far = %f",
                          xmin, xmax, ymin, ymax, mNear, mFar);
        }
        spdlog::debug("   Origin = (%f, %f, %f)  at = (%f, %f, %f) up = (%f, %f, %f)",
                      origin.x, origin.y, origin.z, at.x, at.y, at.z, up.x, up.y, up.z);
    }
};
}
