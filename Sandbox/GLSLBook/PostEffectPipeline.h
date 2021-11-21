// PostEffectPipeline.h
// created on 2021/3/29
// author @zoloypzuo

#ifndef ZELOENGINE_FORWARDRENDERER_H
#define ZELOENGINE_FORWARDRENDERER_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "Core/RHI/RenderPipeline.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"
#include "Renderer/OpenGL/Drawable/Line.h"
#include "Renderer/OpenGL/Buffer/GLFramebuffer.h"
#include "Renderer/OpenGL/Pipeline/ForwardPipeline.h"
#include "GLSLBook/Drawable/Quad.h"

class PostEffectPipeline : public Zelo::Renderer::OpenGL::ForwardPipeline {
public:
    PostEffectPipeline();

    ~PostEffectPipeline() override;

    void render(const Zelo::Core::ECS::Entity &scene) const override;

    void initialize() override;

protected:
    // post effect
    std::unique_ptr<GLSLShaderProgram> m_postShader;
    std::unique_ptr<Zelo::GLFramebuffer> m_fbo{};
    Quad m_quad{};
};

#endif //ZELOENGINE_FORWARDRENDERER_H