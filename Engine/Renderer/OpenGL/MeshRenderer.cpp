// MeshRenderer.cpp
// created on 2021/3/31
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "MeshRenderer.h"

MeshRenderer::MeshRenderer(std::shared_ptr<Mesh> mesh, std::shared_ptr<Material> material) {
    this->m_mesh = mesh;
    this->m_material = material;
}

MeshRenderer::~MeshRenderer() {
}

void MeshRenderer::render(Shader *shader) {
    shader->setUniformMatrix4f("World", m_parentEntity->getWorldMatrix());

    m_material->bind();
    m_mesh->render();
}
