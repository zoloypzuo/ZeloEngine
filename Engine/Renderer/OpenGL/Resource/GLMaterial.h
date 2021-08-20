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
    GLMaterial(GLTexture &diffuseMap,
               GLTexture &normalMap,
               GLTexture &specularMap);

    ~GLMaterial() override;

    void bind() const override;

private:
    GLTexture &m_diffuseMap;
    GLTexture &m_specularMap;
    GLTexture &m_normalMap;
};
}


