// Material.h
// created on 2021/3/30
// author @zoloypzuo
#ifndef ZELOENGINE_MATERIAL_H
#define ZELOENGINE_MATERIAL_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/RHI/Resource/Texture.h"
#include "Texture.h"

namespace Zelo::Core::RHI {
class Material {
public:
    Material(std::shared_ptr<Texture> diffuseMap,
             std::shared_ptr<Texture> normalMap,
             std::shared_ptr<Texture> specularMap);

    ~Material();

    void bind() const;

private:
    std::shared_ptr<Texture> m_diffuseMap;
    std::shared_ptr<Texture> m_specularMap;
    std::shared_ptr<Texture> m_normalMap;
};
}

#endif //ZELOENGINE_MATERIAL_H