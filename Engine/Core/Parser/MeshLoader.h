// MeshLoader.h
// created on 2021/3/31
// author @zoloypzuo

#ifndef ZELOENGINE_MESHLOADER_H
#define ZELOENGINE_MESHLOADER_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/RHI/MeshGen/IMeshGen.h"

namespace Zelo::Parser {

class MeshLoader : public Core::RHI::IMeshGen {
public:
    MeshLoader(const std::string &meshFileName, int meshIndex);

    ~MeshLoader() override;

public: // IMeshGen
    const std::string &getId() override;

    std::vector<Core::RHI::Vertex> getVertices() override;

    std::vector<uint32_t> getIndices() override;

private:
    // IMeshGen
    std::string m_id{};
    std::vector<Core::RHI::Vertex> m_vertices{};
    std::vector<uint32_t> m_indices{};
};
}

#endif //ZELOENGINE_MESHLOADER_H