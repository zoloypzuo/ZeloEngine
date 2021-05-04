#pragma once

#include "trianglemesh.h"

namespace Ingredients {
class Plane : public TriangleMesh
{
public:
    Plane(float xsize, float zsize, int xdivs, int zdivs, float smax = 1.0f, float tmax = 1.0f);
};
}
