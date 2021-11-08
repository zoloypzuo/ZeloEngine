// Bloom.h
// created on 2021/3/29
// author @zoloypzuo

#ifndef ZELOENGINE_FORWARDRENDERER_H
#define ZELOENGINE_FORWARDRENDERER_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "Renderer/OpenGL/Pipeline/Renderer.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"
#include "Renderer/OpenGL/Drawable/Line.h"
#include "Renderer/OpenGL/Buffer/GLFramebuffer.h"

class Bloom : public Renderer {
public:
    Bloom();

    ~Bloom() override;

    void render(const Zelo::Core::ECS::Entity &scene) const override;

    void initialize() override;

protected:
    void createShaders();

    std::unique_ptr<GLSLShaderProgram> m_forwardAmbient;
    std::unique_ptr<GLSLShaderProgram> m_forwardDirectional;
    std::unique_ptr<GLSLShaderProgram> m_forwardPoint;
    std::unique_ptr<GLSLShaderProgram> m_forwardSpot;

    // post effect
    std::unique_ptr<GLSLShaderProgram> m_postShader;
    std::unique_ptr<Zelo::GLFramebuffer> m_renderFbo, m_fbo1, m_fbo2;
};

#endif //ZELOENGINE_FORWARDRENDERER_H