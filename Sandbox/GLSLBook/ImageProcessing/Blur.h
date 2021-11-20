// Blur.h
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

class Blur : public  Zelo::Core::RHI::RenderPipeline {
public:
    Blur();

    ~Blur() override;

    void render(const Zelo::Core::ECS::Entity &scene) const override;

    void initialize() override;

protected:
    void createShaders();

    std::unique_ptr<GLSLShaderProgram> m_forwardAmbient;
    std::unique_ptr<GLSLShaderProgram> m_forwardDirectional;
    std::unique_ptr<GLSLShaderProgram> m_forwardPoint;
    std::unique_ptr<GLSLShaderProgram> m_forwardSpot;

    // post effect
    std::unique_ptr<GLSLShaderProgram> m_postShader1;
    std::unique_ptr<Zelo::GLFramebuffer> m_fbo{};
    std::unique_ptr<Zelo::GLFramebuffer> m_fbo2{};
};

#endif //ZELOENGINE_FORWARDRENDERER_H