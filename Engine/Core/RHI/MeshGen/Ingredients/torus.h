#pragma once

#include "TriangleMeshAdapter.h"

class Torus : public TriangleMeshAdapter {
public:
    Torus(float outerRadius, float innerRadius, uint32_t nsides, uint32_t nrings);
};
