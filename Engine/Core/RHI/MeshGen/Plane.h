// Plane.h
// created on 2021/8/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "GLMesh.h"


class Plane {
public:
    Plane();

    ~Plane() = default;

    static std::shared_ptr<GLMesh> getMesh();
};