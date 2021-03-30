// ForwardRenderer.h
// created on 2021/3/29
// author @zoloypzuo

#ifndef ZELOENGINE_FORWARDRENDERER_H
#define ZELOENGINE_FORWARDRENDERER_H

#include "ZeloPrerequisites.h"

#include "Framework/Renderer.h"
#include "Framework/Shader.h"

class ForwardRenderer : public Renderer {
public:
    ForwardRenderer();

    ~ForwardRenderer() override;

    virtual void render(const Entity &scene, std::shared_ptr<Camera> activeCamera,
                        const std::vector<std::shared_ptr<PointLight>> &pointLights,
                        const std::vector<std::shared_ptr<DirectionalLight>> &directionalLights,
                        const std::vector<std::shared_ptr<SpotLight>> &spotLights) const;

    void initialize() override;

private:
    void createShaders();

    std::unique_ptr<Shader> m_forwardAmbient;
    std::unique_ptr<Shader> m_forwardDirectional;
    std::unique_ptr<Shader> m_forwardPoint;
    std::unique_ptr<Shader> m_forwardSpot;
};


#endif //ZELOENGINE_FORWARDRENDERER_H