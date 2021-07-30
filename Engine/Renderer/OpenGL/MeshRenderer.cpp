// MeshRenderer.cpp
// created on 2021/3/31
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "MeshRenderer.h"
#include "Core/ECS/Entity.h"

MeshRenderer::MeshRenderer(std::shared_ptr<GLMesh> mesh, std::shared_ptr<Material> material) {
    this->m_mesh = std::move(mesh);
    this->m_material = std::move(material);
}

MeshRenderer::~MeshRenderer() {
}

void MeshRenderer::render(GLSLShaderProgram *shader) {
    shader->setUniformMatrix4f("World", m_parentEntity->getWorldMatrix());

    m_material->bind();
    m_mesh->render();
}
