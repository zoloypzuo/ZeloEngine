// DeferredRenderer.h
// created on 2021/4/28
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"


#include "ZeloPrerequisites.h"
#include "ForwardRenderer.h"
#include "Texture.h"
#include "skybox.h"


class DeferredRenderer : public ForwardRenderer {

public:
    void render(const Entity &scene, std::shared_ptr<Camera> activeCamera,
                const std::vector<std::shared_ptr<PointLight>> &pointLights,
                const std::vector<std::shared_ptr<DirectionalLight>> &directionalLights,
                const std::vector<std::shared_ptr<SpotLight>> &spotLights) const override;

    void initialize() override;

private:
    std::unique_ptr<Shader> m_debugDepthQuad;
    std::unique_ptr<Shader> m_simpleDepthShader;

    unsigned int m_depthMap{};
    unsigned int m_depthMapFBO{};

    std::unique_ptr<Texture3D> m_skyboxTex;
    std::unique_ptr<Shader> m_skyboxShader;
    std::unique_ptr<SkyBox> m_skybox;

    std::unique_ptr<Shader> m_deferredShader;
    uint32_t pass1Index;
    uint32_t pass2Index;
    uint32_t deferredFBO;
    uint32_t quad;

protected:
    void initializeShadowMap();

    void createShader();

#ifdef DEBUG_SHADOWMAP
    void renderScene(Shader *shader) const;

    void renderQuad() const;

    void renderCube() const;
#endif

    void initializeSkybox();

    void initializeDeferred();

    void initializeQuad() ;

    void initializeParam();

    void initializeFbo() ;
};
