// ForwardShadowRenderer.h
// created on 2021/4/15
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "ForwardRenderer.h"
#include "Renderer/OpenGL/Resource/GLTexture.h"
#include "Renderer/OpenGL/Drawable/skybox.h"

class ForwardShadowRenderer : public ForwardRenderer {

public:
    void render(const Zelo::Core::ECS::Entity &scene, Camera *activeCamera,
                const std::vector<std::shared_ptr<PointLight>> &pointLights,
                const std::vector<std::shared_ptr<DirectionalLight>> &directionalLights,
                const std::vector<std::shared_ptr<SpotLight>> &spotLights) const override;

    void initialize() override;

private:
    std::unique_ptr<GLSLShaderProgram> m_debugDepthQuad;
    std::unique_ptr<GLSLShaderProgram> m_simpleDepthShader;

    unsigned int m_depthMap{};
    unsigned int m_depthMapFBO{};

    std::unique_ptr<GLTexture3D> m_skyboxTex;
    std::unique_ptr<GLSLShaderProgram> m_skyboxShader;
    std::unique_ptr<SkyBox> m_skybox;

protected:
    void initializeShadowMap();

    void createShader();

#ifdef DEBUG_SHADOWMAP

    void renderScene(GLSLShaderProgram *shader) const;

    void renderQuad() const;

    void renderCube() const;

#endif

    void initializeSkybox();
};

