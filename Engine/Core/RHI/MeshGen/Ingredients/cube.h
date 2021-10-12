#pragma once

#include "TriangleMeshAdapter.h"

class Cube : public TriangleMeshAdapter {
public:
    explicit Cube(GLfloat size = 1.0f);
};
