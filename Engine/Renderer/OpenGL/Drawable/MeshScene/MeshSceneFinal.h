// MeshSceneFinalFinal.h
// created on 2021/12/18
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

#include "Core/RHI/Resource/Mesh.h"

namespace Zelo::Renderer::OpenGL {
class MeshSceneFinal : public Core::RHI::Mesh {
public:
    MeshSceneFinal(const std::string &meshFile,
                   const std::string &sceneFile,
                   const std::string &materialFile,
                   const std::string &dummyTextureFile);

    void render() override;

    ~MeshSceneFinal();

private:
    struct Impl;
    std::shared_ptr<Impl> pimpl{};
};
}
