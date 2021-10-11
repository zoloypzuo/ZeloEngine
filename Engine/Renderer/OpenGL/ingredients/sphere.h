#pragma once

#include "trianglemesh.h"
#include "ZeloGLPrerequisites.h"

class Sphere : public TriangleMesh {
public:
    Sphere(float rad, GLuint sl, GLuint st);
};
