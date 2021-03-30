// Renderer.h
// created on 2021/3/29
// author @zoloypzuo

#ifndef ZELOENGINE_RENDERER_H
#define ZELOENGINE_RENDERER_H

#include "ZeloPrerequisites.h"
#include "Entity.h"
#include "Renderer/OpenGL/Camera.h"
#include "Renderer/OpenGL/Light.h"

class Renderer {
public:
    virtual ~Renderer();

    virtual void initialize() = 0;

    virtual void render(const Entity &scene, std::shared_ptr<Camera> activeCamera,
                        const std::vector<std::shared_ptr<PointLight>> &pointLights,
                        const std::vector<std::shared_ptr<DirectionalLight>> &directionalLights,
                        const std::vector<std::shared_ptr<SpotLight>> &spotLights) const = 0;
};


#endif //ZELOENGINE_RENDERER_H