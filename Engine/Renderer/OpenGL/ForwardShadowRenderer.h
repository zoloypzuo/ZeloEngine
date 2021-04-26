// ForwardShadowRenderer.h
// created on 2021/4/15
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"
#include "ForwardRenderer.h"
#include "Texture.h"
#include "skybox.h"


class ForwardShadowRenderer : public ForwardRenderer {

public:
    void render(const Entity &scene, std::shared_ptr<Camera> activeCamera,
                const std::vector<std::shared_ptr<PointLight>> &pointLights,
                const std::vector<std::shared_ptr<DirectionalLight>> &directionalLights,
                const std::vector<std::shared_ptr<SpotLight>> &spotLights) const override;

    void initialize() override;

private:
    std::unique_ptr<Shader> debugDepthQuad;
    std::unique_ptr<Shader> simpleDepthShader;

    unsigned int depthMap{};
    unsigned int depthMapFBO{};

    std::unique_ptr<Texture3D> m_skyboxTex;
    std::unique_ptr<Shader> m_skyboxShader;
    std::unique_ptr<SkyBox> m_skybox;

protected:
    void initializeShadowMap();

    void createShader();

#ifdef DEBUG_SHADOWMAP
    void renderScene(Shader *shader) const;

    void renderQuad() const;

    void renderCube() const;
#endif

    void initializeSkybox();
};


