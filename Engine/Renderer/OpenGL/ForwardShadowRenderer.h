// ForwardShadowRenderer.h
// created on 2021/4/15
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"
#include "ForwardRenderer.h"


class ForwardShadowRenderer : public Renderer {

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

    glm::vec3 lightPos{};

private:
    void initializeShadowMap();

    void createShader();

    void renderQuad() const;

    void renderScene(Shader *shader) const;

    void renderCube() const;
};


