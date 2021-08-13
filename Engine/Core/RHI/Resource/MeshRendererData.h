// MeshRendererData.h
// created on 2021/8/1
// author @zoloypzuo
#pragma once

#include <utility>

#include "ZeloPrerequisites.h"
// #include "Core/RHI/Resource/Material.h"
// #include "Core/RHI/Resource/Mesh.h"
#include "Renderer/OpenGL/Resource/GLMesh.h"
#include "Renderer/OpenGL/Resource/GLMaterial.h"

namespace Zelo::Core::RHI {
struct MeshRendererData {
    MeshRendererData(std::shared_ptr<GLMesh> &mesh, std::shared_ptr<Zelo::Renderer::OpenGL::GLMaterial> material)
            : mesh(std::move(mesh)), material(std::move(material)) {}

    std::shared_ptr<GLMesh> mesh;
    std::shared_ptr<Zelo::Renderer::OpenGL::GLMaterial> material;
};
}
