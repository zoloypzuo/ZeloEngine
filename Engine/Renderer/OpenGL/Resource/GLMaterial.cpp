// GLMaterial.cpp
// created on 2021/8/1
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLMaterial.h"

using namespace Zelo::Renderer::OpenGL;

GLMaterial::GLMaterial(std::shared_ptr<GLTexture> diffuseMap,
                       std::shared_ptr<GLTexture> normalMap,
                       std::shared_ptr<GLTexture> specularMap) {
    m_diffuseMap = std::move(diffuseMap);
    m_normalMap = std::move(normalMap);
    m_specularMap = std::move(specularMap);
}

GLMaterial::~GLMaterial() = default;

void GLMaterial::bind() const {
    m_diffuseMap->bind(0);
    m_normalMap->bind(1);
    m_specularMap->bind(2);
}

