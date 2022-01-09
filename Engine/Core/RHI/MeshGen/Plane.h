// Plane.h
// created on 2021/8/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Core/RHI/IMeshData.h"

namespace Zelo::Core::RHI {
class Plane : public IMeshData {
public:
    Plane();

    ~Plane() override = default;

    std::string getId() override;

    std::vector<Vertex> getVertices() override;

    std::vector<uint32_t> getIndices() override;
};
}
