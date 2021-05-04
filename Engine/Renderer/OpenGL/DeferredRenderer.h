// DeferredRenderer.h
// created on 2021/4/28
// author @zoloypzuo

#pragma once

#include <Renderer/OpenGL/ingredients/plane.h>
#include <Renderer/OpenGL/ingredients/torus.h>
#include <Renderer/OpenGL/ingredients/teapot.h>
#include "ZeloPrerequisites.h"


#include "ZeloPrerequisites.h"
#include "ForwardRenderer.h"
#include "Texture.h"
#include "skybox.h"
#include "plane.h"


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

    Ingredients::Plane plane;
    Torus torus;
    Teapot teapot;

protected:
    void initializeDeferred();

    void initializeQuad();

    void initializeParam();

    void initializeFbo();

    void pass1(const std::shared_ptr<Camera> &activeCamera) const;

    void pass2(const Entity &scene, const std::shared_ptr<Camera> &activeCamera,
               const std::vector<std::shared_ptr<PointLight>> &pointLights,
               const std::vector<std::shared_ptr<DirectionalLight>> &directionalLights,
               const std::vector<std::shared_ptr<SpotLight>> &spotLights) const;

    void setMatrices(glm::mat4 model, glm::mat4 view, glm::mat4 projection) const;
};
