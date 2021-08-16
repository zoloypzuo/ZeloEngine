// MeshRenderer.cpp
// created on 2021/3/31
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "MeshRenderer.h"

MeshRenderer::MeshRenderer(
        Zelo::Core::ECS::Entity &owner,
        std::shared_ptr<GLMesh> mesh,
        std::shared_ptr<Zelo::Core::RHI::Material> material) : Zelo::Core::ECS::Component(owner) {
    this->m_mesh = std::move(mesh);
    this->m_material = std::move(material);
}

MeshRenderer::~MeshRenderer() = default;

void MeshRenderer::render(Shader *shader) {
    shader->setUniformMatrix4f("World", m_owner.getWorldMatrix());

    m_material->bind();
    m_mesh->render();
}
