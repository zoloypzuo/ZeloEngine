#pragma once

#include "TriangleMeshAdapter.h"

class Sphere : public TriangleMeshAdapter {
public:
    Sphere(float rad, uint32_t sl, uint32_t st);
};
