// ForwardShadowMap.h
// created on 2021/3/29
// author @zoloypzuo
#ifndef ZELOENGINE_FORWARDRENDERER_H
#define ZELOENGINE_FORWARDRENDERER_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "Core/RHI/RenderPipeline.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"
#include "Renderer/OpenGL/Drawable/Line.h"
#include "Renderer/OpenGL/Drawable/Frustum.h"
#include "Renderer/OpenGL/Buffer/GLFramebuffer.h"
#include "Renderer/OpenGL/Buffer/GLShadowMap.h"

class ForwardShadowMap : public Renderer {
public:
    ForwardShadowMap();

    ~ForwardShadowMap() override;

    void render(const Zelo::Core::ECS::Entity &scene) const override;

    void initialize() override;

protected:
    void createShaders();

    std::unique_ptr<GLSLShaderProgram> m_forwardAmbient;
    std::unique_ptr<GLSLShaderProgram> m_forwardDirectional;
    std::unique_ptr<GLSLShaderProgram> m_forwardPoint;
    std::unique_ptr<GLSLShaderProgram> m_forwardSpot;

    std::unique_ptr<GLSLShaderProgram> m_shadowMapShader;
    std::unique_ptr<GLSLShaderProgram> m_shadowMapDebugShader;
    std::unique_ptr<Zelo::GLShadowMap> m_shadowFbo{};
    std::unique_ptr<Frustum> m_lightFrustum{};
    std::unique_ptr<GLSLShaderProgram> m_simpleShader{};
};

#endif //ZELOENGINE_FORWARDRENDERER_H