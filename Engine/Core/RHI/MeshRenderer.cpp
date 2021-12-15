// MeshRenderer.cpp
// created on 2021/3/31
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "MeshRenderer.h"

using namespace Zelo::Core::ECS;

namespace Zelo::Core::RHI {
MeshRenderer::MeshRenderer(Entity &owner) : Component(owner) {
}

MeshRenderer::~MeshRenderer() = default;

void MeshRenderer::SetMesh(Mesh &mesh) {
    m_mesh = &mesh;
}

void MeshRenderer::SetMaterial(Material &material) {
    m_material = &material;
}
}