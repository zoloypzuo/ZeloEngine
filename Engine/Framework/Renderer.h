// Renderer.h
// created on 2021/3/29
// author @zoloypzuo

#ifndef ZELOENGINE_RENDERER_H
#define ZELOENGINE_RENDERER_H

#include "ZeloPrerequisites.h"
#include "Entity.h"
//#include "Camera.h"
//#include "PointLight.h"
//#include "DirectionalLight.h"
//#include "SpotLight.h"

class Renderer {
public:
    virtual ~Renderer();

//    virtual void render(const Entity &scene, std::shared_ptr<Camera> activeCamera,
//                        const std::vector<std::shared_ptr<PointLight>> &pointLights,
//                        const std::vector<std::shared_ptr<DirectionalLight>> &directionalLights,
//                        const std::vector<std::shared_ptr<SpotLight>> &spotLights) const = 0;
};


#endif //ZELOENGINE_RENDERER_H