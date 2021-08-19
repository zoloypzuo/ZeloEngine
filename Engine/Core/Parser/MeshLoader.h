// MeshLoader.h
// created on 2021/3/31
// author @zoloypzuo

#ifndef ZELOENGINE_MESHLOADER_H
#define ZELOENGINE_MESHLOADER_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/RHI/Resource/MeshRendererData.h"
#include "Core/RHI/MeshGen/IMeshGen.h"

namespace Zelo::Parser {

class MeshLoader : public Core::RHI::IMeshGen {
public:
    explicit MeshLoader(const std::string &file);

    MeshLoader(const std::string &meshFileName, int meshIndex);

    ~MeshLoader();

    std::string getFileName();

    std::vector<Core::RHI::MeshRendererData> getMeshRendererData();


public: // IMeshGen
    const std::string &getId() override;

    std::vector<Core::RHI::Vertex> getVertices() override;

    std::vector<uint32_t> getIndices() override;

private:
    std::string m_fileName;

    std::vector<Core::RHI::MeshRendererData> m_meshRendererData{};

    // IMeshGen
    std::string m_id{};
    std::vector<Core::RHI::Vertex> m_vertex{};
    std::vector<uint32_t> m_indice{};
};
}

#endif //ZELOENGINE_MESHLOADER_H