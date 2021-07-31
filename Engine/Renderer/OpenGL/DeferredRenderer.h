// DeferredRenderer.h
// created on 2021/4/28
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "ForwardRenderer.h"
#include "GLTexture.h"
#include <Renderer/OpenGL/ingredients/plane.h>
#include <Renderer/OpenGL/ingredients/torus.h>
#include <Renderer/OpenGL/ingredients/teapot.h>

class DeferredRenderer : public ForwardRenderer {

public:
    void render(const Entity &scene, std::shared_ptr<Camera> activeCamera,
                const std::vector<std::shared_ptr<PointLight>> &pointLights,
                const std::vector<std::shared_ptr<DirectionalLight>> &directionalLights,
                const std::vector<std::shared_ptr<SpotLight>> &spotLights) const override;

    void initialize() override;

private:
    std::unique_ptr<GLSLShaderProgram> m_deferredShader;
    uint32_t pass1Index;
    uint32_t pass2Index;
    uint32_t deferredFBO;
    uint32_t quad;

    std::unique_ptr<Ingredients::Plane> plane;
    std::unique_ptr<Torus> torus;
    std::unique_ptr<Teapot> teapot;

protected:
    void initializeDeferred();

    void initiializeMesh();

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
