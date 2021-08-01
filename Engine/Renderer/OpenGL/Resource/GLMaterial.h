// GLMaterial.h
// created on 2021/8/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Core/RHI/Resource/Material.h"
#include "Renderer/OpenGL/Resource/GLTexture.h"

namespace Zelo::Renderer::OpenGL {
class GLMaterial : public Core::RHI::Material {
public:
    GLMaterial(std::shared_ptr<GLTexture> diffuseMap,
               std::shared_ptr<GLTexture> normalMap,
               std::shared_ptr<GLTexture> specularMap);

    ~GLMaterial() override;

    void bind() const override;

private:
    std::shared_ptr<GLTexture> m_diffuseMap;
    std::shared_ptr<GLTexture> m_specularMap;
    std::shared_ptr<GLTexture> m_normalMap;
};
}


