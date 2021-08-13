// Frustum.h
// created on 2021/8/7
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"


class Frustum {
public:

    void CalculateFrustum(const Maths::FMatrix4 &viewProjection);

    bool PointInFrustum(float x, float y, float z) const;

    bool SphereInFrustum(float x, float y, float z, float radius) const;

    bool CubeInFrustum(float x, float y, float z, float size) const;

    bool BoundingSphereInFrustum(const Rendering::Geometry::BoundingSphere &boundingSphere,
                                 const Maths::FTransform &transform) const;

    std::array<float, 4> GetNearPlane() const;

    std::array<float, 4> GetFarPlane() const;

private:
    float m_frustum[6][4];
};
