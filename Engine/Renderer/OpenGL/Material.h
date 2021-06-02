// Material.h
// created on 2021/3/30
// author @zoloypzuo

#ifndef ZELOENGINE_MATERIAL_H
#define ZELOENGINE_MATERIAL_H

#include "ZeloPrerequisites.h"
#include "Texture.h"

class Material {
public:
    Material(std::shared_ptr<Texture> diffuseMap,
             std::shared_ptr<Texture> normalMap = std::make_shared<Texture>(Zelo::Resource("default_normal.jpg")),
             std::shared_ptr<Texture> specularMap = std::make_shared<Texture>(Zelo::Resource("default_specular.jpg")));

    ~Material();

    void bind() const;

private:
    std::shared_ptr<Texture> m_diffuseMap;
    std::shared_ptr<Texture> m_specularMap;
    std::shared_ptr<Texture> m_normalMap;
};


#endif //ZELOENGINE_MATERIAL_H