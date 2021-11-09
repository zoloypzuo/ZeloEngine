// GLMaterial.h
// created on 2021/8/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Core/RHI/Resource/Material.h"
#include "Renderer/OpenGL/Resource/GLTexture.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"

namespace Zelo::Renderer::OpenGL {
class GLMaterial : public Core::RHI::Material {
public:
    GLMaterial(GLTexture &diffuseMap,
               GLTexture &normalMap,
               GLTexture &specularMap);

    ~GLMaterial() override;

    void bind() const override;

    void unbind();

    void setShader(std::shared_ptr<Shader> shader) override;

    bool hasShader() const override;

    void fillUniforms();

    std::map<std::string, std::any> getUniformsData() const;

    template<typename T>
    void set(const std::string &key, const T &value);

    template<typename T>
    const T &get(const std::string &key);

public:
    bool isBlendable() const override { return m_blendable; }

private:
    GLTexture &m_diffuseMap;
    GLTexture &m_specularMap;
    GLTexture &m_normalMap;

    // shader and shader uniforms
    std::shared_ptr<GLSLShaderProgram> m_shader{};
    std::map<std::string, std::any> m_uniformsData;

    // extra parameters
    bool m_blendable = false;
    bool m_backfaceCulling = true;
    bool m_frontfaceCulling = false;
    bool m_depthTest = true;
    bool m_depthWriting = true;
    bool m_colorWriting = true;
    int m_gpuInstances = 1;
};
}

#include "GLMaterial.inl"
