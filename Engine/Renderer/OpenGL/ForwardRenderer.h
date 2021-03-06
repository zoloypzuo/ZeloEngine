// ForwardRenderer.h
// created on 2021/3/29
// author @zoloypzuo

#ifndef ZELOENGINE_FORWARDRENDERER_H
#define ZELOENGINE_FORWARDRENDERER_H

#include "ZeloPrerequisites.h"

#include "Renderer.h"
#include "Shader.h"
#include "Line.h"

class SimpleRenderer : public Renderer {
public:
    SimpleRenderer();

    void initialize() override;

    ~SimpleRenderer() override;

    void render(const Entity &scene, std::shared_ptr<Camera> activeCamera,
                const std::vector<std::shared_ptr<PointLight>> &pointLights,
                const std::vector<std::shared_ptr<DirectionalLight>> &directionalLights,
                const std::vector<std::shared_ptr<SpotLight>> &spotLights) const override;

    void renderLine(const Line &line, const std::shared_ptr<Camera>& activeCamera) const;

private:
    void createShaders();

    std::unique_ptr<Shader> m_simple;
};


class ForwardRenderer : public Renderer {
public:
    ForwardRenderer();

    ~ForwardRenderer() override;

    void render(const Entity &scene, std::shared_ptr<Camera> activeCamera,
                        const std::vector<std::shared_ptr<PointLight>> &pointLights,
                        const std::vector<std::shared_ptr<DirectionalLight>> &directionalLights,
                        const std::vector<std::shared_ptr<SpotLight>> &spotLights) const override;

    void initialize() override;

protected:
    void createShaders();

    std::unique_ptr<Shader> m_forwardAmbient;
    std::unique_ptr<Shader> m_forwardDirectional;
    std::unique_ptr<Shader> m_forwardPoint;
    std::unique_ptr<Shader> m_forwardSpot;
};


#endif //ZELOENGINE_FORWARDRENDERER_H