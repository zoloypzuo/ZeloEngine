// MeshGen.h
// created on 2021/8/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Core/RHI/Buffer/Vertex.h"

namespace Zelo::Core::RHI {
class IMeshGen {
public:
    virtual ~IMeshGen() = default;

    virtual const std::string &getId() = 0;

    virtual std::vector<Vertex> getVertices() = 0;

    virtual std::vector<uint32_t> getIndices() = 0;
};
}
