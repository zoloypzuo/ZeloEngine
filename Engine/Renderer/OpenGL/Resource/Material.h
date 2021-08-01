// Material.h
// created on 2021/3/30
// author @zoloypzuo

#ifndef ZELOENGINE_MATERIAL_H
#define ZELOENGINE_MATERIAL_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Renderer/OpenGL/Resource/GLTexture.h"

class Material {
public:
    Material(std::shared_ptr<GLTexture> diffuseMap,
             std::shared_ptr<GLTexture> normalMap = std::make_shared<GLTexture>(Zelo::Resource("default_normal.jpg")),
             std::shared_ptr<GLTexture> specularMap = std::make_shared<GLTexture>(
                     Zelo::Resource("default_specular.jpg")));

    ~Material();

    void bind() const;

private:
    std::shared_ptr<GLTexture> m_diffuseMap;
    std::shared_ptr<GLTexture> m_specularMap;
    std::shared_ptr<GLTexture> m_normalMap;
};

#endif //ZELOENGINE_MATERIAL_H