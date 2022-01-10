// MeshSceneWireFrame.h
// created on 2021/12/16
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

#include "Core/RHI/Resource/Mesh.h"

namespace Zelo::Renderer::OpenGL {
class MeshSceneWireFrame : public Core::RHI::Mesh {
public:
    explicit MeshSceneWireFrame(const std::string &meshFile);

    void render() override;

    ~MeshSceneWireFrame();

private:
    struct Impl;
    std::shared_ptr<Impl> pimpl{};
};
}
