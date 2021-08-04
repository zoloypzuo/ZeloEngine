// MeshRendererData.h
// created on 2021/8/1
// author @zoloypzuo
#pragma once

#include <utility>

#include "ZeloPrerequisites.h"
#include "Core/RHI/Resource/Material.h"
#include "Core/RHI/Resource/Mesh.h"

namespace Zelo::Core::RHI {
struct MeshRendererData {
    MeshRendererData(const std::shared_ptr<Mesh> &mesh, std::shared_ptr<Material> material)
            : mesh(mesh), material(std::move(material)) {}

    std::shared_ptr<Mesh> mesh;
    std::shared_ptr<Material> material;
};
}
