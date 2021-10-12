#pragma once

#include "TriangleMeshAdapter.h"

namespace Ingredients {
class Plane : public TriangleMeshAdapter {
public:
    Plane(float xsize, float zsize, int xdivs, int zdivs, float smax = 1.0f, float tmax = 1.0f);
};
}
