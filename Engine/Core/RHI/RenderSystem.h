// RenderSystem.h
// created on 2021/8/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"
#include "Core/RHI/RenderCommand.h"
#include "Core/RHI/Object/Camera.h"
#include "ZeloGLPrerequisites.h"
#include "Core/RHI/RenderSystem.h"
#include "Renderer/OpenGL/Pipeline/Renderer.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"
#include "Core/RHI/Resource/MeshManager.h"
#include "Core/RHI/Object/Light.h"

namespace Zelo::Core::RHI {
class RenderSystem :
        public Singleton<RenderSystem>,
        IRuntimeModule,
        RenderCommand {

public:
    struct FrameInfo {
        uint64_t batchCount = 0;
        uint64_t instanceCount = 0;
        uint64_t polyCount = 0;
    };

    struct RenderState {

    };

public:
    ~RenderSystem() override;

    void initialize() override;

    void update() override;

    void finalize() override;

    static RenderSystem *getSingletonPtr();

    static RenderSystem &getSingleton();

public:
    const FrameInfo &GetFrameInfo() const;

    void ClearFrameInfo();

public:
    void setActiveCamera(Camera *camera);

    void addDirectionalLight(const std::shared_ptr<DirectionalLight> &light);

    void removeDirectionalLight(const std::shared_ptr<DirectionalLight> &light);

    void addPointLight(const std::shared_ptr<PointLight> &light);

    void removePointLight(const std::shared_ptr<PointLight> &light);

    void addSpotLight(const std::shared_ptr<SpotLight> &light);

    void removeSpotLight(const std::shared_ptr<SpotLight> &light);

private:
    FrameInfo m_frameInfo;

protected:
    Camera *m_activeCamera{};
    std::vector<std::shared_ptr<DirectionalLight>> m_directionalLights{};
    std::vector<std::shared_ptr<PointLight>> m_pointLights{};
    std::vector<std::shared_ptr<SpotLight>> m_spotLights{};
};
}


