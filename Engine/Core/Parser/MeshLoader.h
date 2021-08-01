// MeshLoader.h
// created on 2021/3/31
// author @zoloypzuo

#ifndef ZELOENGINE_MESHLOADER_H
#define ZELOENGINE_MESHLOADER_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/RHI/Resource/MeshRendererData.h"

namespace Zelo::Parser {

class MeshLoader {
public:
    explicit MeshLoader(const std::string &file);

    ~MeshLoader();

    std::string getFileName();

    std::shared_ptr<Core::RHI::MeshRendererData> getMeshRendererData();

private:
    std::string m_fileName;

    std::shared_ptr<Core::RHI::MeshRendererData> m_meshRendererData{};
};
}

#endif //ZELOENGINE_MESHLOADER_H