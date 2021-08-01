// Material.cpp
// created on 2021/3/30
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Material.h"
#include "Texture.h"

using namespace Zelo::Core::RHI;

Material::Material(std::shared_ptr<Texture> diffuseMap,
                   std::shared_ptr<Texture> normalMap,
                   std::shared_ptr<Texture> specularMap) {
    m_diffuseMap = std::move(diffuseMap);
    m_normalMap = std::move(normalMap);
    m_specularMap = std::move(specularMap);
}

Material::~Material() = default;

void Material::bind() const {
    m_diffuseMap->bind(0);
    m_normalMap->bind(1);
    m_specularMap->bind(2);
}
