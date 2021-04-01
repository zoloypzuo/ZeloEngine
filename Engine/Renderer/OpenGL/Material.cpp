// Material.cpp
// created on 2021/3/30
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Material.h"

Material::Material(std::shared_ptr<Texture> diffuseMap, std::shared_ptr<Texture> normalMap,
                   std::shared_ptr<Texture> specularMap) {
    m_diffuseMap = diffuseMap;
    m_normalMap = normalMap;
    m_specularMap = specularMap;
}

Material::~Material() {
}

void Material::bind() const {
    m_diffuseMap->bind(0);
    // if (m_normalMap != nullptr)
    m_normalMap->bind(1);
    // if (m_specularMap != nullptr)
    m_specularMap->bind(2);
}
