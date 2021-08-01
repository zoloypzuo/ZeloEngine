// Plane.h
// created on 2021/8/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Core/RHI/MeshGen/IMeshGen.h"

namespace Zelo::Core::RHI {
class Plane : public IMeshGen {
public:
    Plane();

    ~Plane() override = default;

    const std::string &getId() override;

    std::vector<Vertex> getVertices() override;

    std::vector<uint32_t> getIndices() override;
};
}
