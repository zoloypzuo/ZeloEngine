// Frustum.cpp
// created on 2021/8/7
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Frustum.h"

enum FrustumSide {
    RIGHT = 0, LEFT = 1, BOTTOM = 2, TOP = 3, BACK = 4, FRONT = 5
};

enum PlaneData {
    A = 0, B = 1, C = 2, D = 3
};

void NormalizePlane(float frustum[6][4], int side) {
    float magnitude = (float) sqrt(frustum[side][A] * frustum[side][A] +
                                   frustum[side][B] * frustum[side][B] +
                                   frustum[side][C] * frustum[side][C]);

    frustum[side][A] /= magnitude;
    frustum[side][B] /= magnitude;
    frustum[side][C] /= magnitude;
    frustum[side][D] /= magnitude;
}

void Frustum::CalculateFrustum(const Maths::FMatrix4 &viewProjection) {
    auto columnMajorViewProjection = Maths::FMatrix4::Transpose(viewProjection);
    float const *clip = columnMajorViewProjection.data;

    m_frustum[RIGHT][A] = clip[3] - clip[0];
    m_frustum[RIGHT][B] = clip[7] - clip[4];
    m_frustum[RIGHT][C] = clip[11] - clip[8];
    m_frustum[RIGHT][D] = clip[15] - clip[12];

    NormalizePlane(m_frustum, RIGHT);

    m_frustum[LEFT][A] = clip[3] + clip[0];
    m_frustum[LEFT][B] = clip[7] + clip[4];
    m_frustum[LEFT][C] = clip[11] + clip[8];
    m_frustum[LEFT][D] = clip[15] + clip[12];

    NormalizePlane(m_frustum, LEFT);

    m_frustum[BOTTOM][A] = clip[3] + clip[1];
    m_frustum[BOTTOM][B] = clip[7] + clip[5];
    m_frustum[BOTTOM][C] = clip[11] + clip[9];
    m_frustum[BOTTOM][D] = clip[15] + clip[13];

    NormalizePlane(m_frustum, BOTTOM);

    m_frustum[TOP][A] = clip[3] - clip[1];
    m_frustum[TOP][B] = clip[7] - clip[5];
    m_frustum[TOP][C] = clip[11] - clip[9];
    m_frustum[TOP][D] = clip[15] - clip[13];

    NormalizePlane(m_frustum, TOP);

    m_frustum[BACK][A] = clip[3] - clip[2];
    m_frustum[BACK][B] = clip[7] - clip[6];
    m_frustum[BACK][C] = clip[11] - clip[10];
    m_frustum[BACK][D] = clip[15] - clip[14];

    NormalizePlane(m_frustum, BACK);

    m_frustum[FRONT][A] = clip[3] + clip[2];
    m_frustum[FRONT][B] = clip[7] + clip[6];
    m_frustum[FRONT][C] = clip[11] + clip[10];
    m_frustum[FRONT][D] = clip[15] + clip[14];

    NormalizePlane(m_frustum, FRONT);
}

bool Frustum::PointInFrustum(float x, float y, float z) const {

    for (int i = 0; i < 6; i++) {
        if (m_frustum[i][A] * x + m_frustum[i][B] * y + m_frustum[i][C] * z + m_frustum[i][D] <= 0) {
            return false;
        }
    }

    return true;
}

bool Frustum::SphereInFrustum(float x, float y, float z, float radius) const {

    for (int i = 0; i < 6; i++) {
        if (m_frustum[i][A] * x + m_frustum[i][B] * y + m_frustum[i][C] * z + m_frustum[i][D] <= -radius) {
            return false;
        }
    }

    return true;
}

bool Frustum::CubeInFrustum(float x, float y, float z, float size) const {

    for (int i = 0; i < 6; i++) {
        if (m_frustum[i][A] * (x - size) + m_frustum[i][B] * (y - size) + m_frustum[i][C] * (z - size) +
            m_frustum[i][D] > 0)
            continue;
        if (m_frustum[i][A] * (x + size) + m_frustum[i][B] * (y - size) + m_frustum[i][C] * (z - size) +
            m_frustum[i][D] > 0)
            continue;
        if (m_frustum[i][A] * (x - size) + m_frustum[i][B] * (y + size) + m_frustum[i][C] * (z - size) +
            m_frustum[i][D] > 0)
            continue;
        if (m_frustum[i][A] * (x + size) + m_frustum[i][B] * (y + size) + m_frustum[i][C] * (z - size) +
            m_frustum[i][D] > 0)
            continue;
        if (m_frustum[i][A] * (x - size) + m_frustum[i][B] * (y - size) + m_frustum[i][C] * (z + size) +
            m_frustum[i][D] > 0)
            continue;
        if (m_frustum[i][A] * (x + size) + m_frustum[i][B] * (y - size) + m_frustum[i][C] * (z + size) +
            m_frustum[i][D] > 0)
            continue;
        if (m_frustum[i][A] * (x - size) + m_frustum[i][B] * (y + size) + m_frustum[i][C] * (z + size) +
            m_frustum[i][D] > 0)
            continue;
        if (m_frustum[i][A] * (x + size) + m_frustum[i][B] * (y + size) + m_frustum[i][C] * (z + size) +
            m_frustum[i][D] > 0)
            continue;

        return false;
    }

    return true;
}

bool Frustum::BoundingSphereInFrustum(const Rendering::Geometry::BoundingSphere &boundingSphere,
                                      const Maths::FTransform &transform) const {
    const auto &position = transform.GetWorldPosition();
    const auto &rotation = transform.GetWorldRotation();
    const auto &scale = transform.GetWorldScale();

    float maxScale = std::max(std::max(std::max(scale.x, scale.y), scale.z), 0.0f);
    float scaledRadius = boundingSphere.radius * maxScale;
    auto sphereOffset = Maths::FQuaternion::RotatePoint(boundingSphere.position, rotation) * maxScale;

    Maths::FVector3 worldCenter = position + sphereOffset;

    return SphereInFrustum(worldCenter.x, worldCenter.y, worldCenter.z, scaledRadius);
}

std::array<float, 4> Frustum::GetNearPlane() const {
    return {m_frustum[FRONT][0], m_frustum[FRONT][1], m_frustum[FRONT][2], m_frustum[FRONT][3]};
}

std::array<float, 4> Frustum::GetFarPlane() const {
    return {m_frustum[BACK][0], m_frustum[BACK][1], m_frustum[BACK][2], m_frustum[BACK][3]};
}
