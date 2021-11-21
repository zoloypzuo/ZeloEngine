// ShadowMapPipeline.h
// created on 2021/3/29
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"
#include "Renderer/OpenGL/Drawable/Line.h"
#include "Renderer/OpenGL/Drawable/Frustum.h"
#include "Renderer/OpenGL/Buffer/GLFramebuffer.h"
#include "Renderer/OpenGL/Buffer/GLShadowMap.h"
#include "Renderer/OpenGL/Pipeline/ForwardPipeline.h"
#include "GLSLBook/Drawable/Quad.h"


class ShadowMapPipeline : public Zelo::Renderer::OpenGL::ForwardPipeline  {
public:
    ShadowMapPipeline();

    ~ShadowMapPipeline() override;

    void render(const Zelo::Core::ECS::Entity &scene) const override;

    void initialize() override;

protected:
    std::unique_ptr<GLSLShaderProgram> m_shadowMapShader;
    std::unique_ptr<Zelo::GLShadowMap> m_shadowFbo{};
    std::unique_ptr<Frustum> m_lightFrustum{};
    std::unique_ptr<GLSLShaderProgram> m_simpleShader{};
};

