// MeshSceneSimple.h
// created on 2021/12/16
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

#include "Core/RHI/Resource/Mesh.h"

namespace Zelo::Renderer::OpenGL {
class MeshSceneSimple : public Core::RHI::Mesh {
public:
    MeshSceneSimple(const std::string &sceneFile, const std::string &meshFile, const std::string& materialFile);

    void render()  override;

    ~MeshSceneSimple();

private:
    struct Impl;
    std::shared_ptr<Impl> pimpl{};
};
}
