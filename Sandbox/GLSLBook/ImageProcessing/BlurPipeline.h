// BlurPipeline.h
// created on 2021/3/29
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "Core/RHI/RenderPipeline.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"
#include "Renderer/OpenGL/Drawable/Line.h"
#include "Renderer/OpenGL/Buffer/GLFramebuffer.h"
#include "Renderer/OpenGL/Pipeline/ForwardPipeline.h"
#include "GLSLBook/Drawable/Quad.h"


class BlurPipeline : public Zelo::Renderer::OpenGL::ForwardPipeline {
public:
    BlurPipeline();

    ~BlurPipeline() override;

    void render(const Zelo::Core::ECS::Entity &scene) const override;

    void initialize() override;

protected:
    // post effect
    std::unique_ptr<GLSLShaderProgram> m_postShader1;
    std::unique_ptr<Zelo::GLFramebuffer> m_fbo{};
    std::unique_ptr<Zelo::GLFramebuffer> m_fbo2{};
    Quad m_quad{};
};
