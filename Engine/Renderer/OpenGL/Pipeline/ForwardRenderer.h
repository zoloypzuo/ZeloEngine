// ForwardRenderer.h
// created on 2021/3/29
// author @zoloypzuo

#ifndef ZELOENGINE_FORWARDRENDERER_H
#define ZELOENGINE_FORWARDRENDERER_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "Core/RHI/RenderPipeline.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"
#include "Renderer/OpenGL/Drawable/Line.h"
#include "Renderer/OpenGL/Buffer/GLShaderStorageBuffer.h"
#include "Renderer/OpenGL/Buffer/GLUniformBuffer.h"

namespace Zelo {
class SimpleRenderer : public Core::RHI::RenderPipeline {
public:
    SimpleRenderer();

    void initialize() override;

    ~SimpleRenderer() override;

    void render(const Core::ECS::Entity &scene) const override;

    void renderLine(const Line &line, const std::shared_ptr<Camera> &activeCamera) const;

private:

    std::unique_ptr<GLSLShaderProgram> m_simple;
};

class ForwardRenderer : public Core::RHI::RenderPipeline {
public:
    ZELO_PACKED
    (struct EngineUBO {
         glm::mat4 ubo_model;
         glm::mat4 ubo_view;
         glm::mat4 ubo_projection;
         glm::vec3 ubo_viewPos;
         float ubo_time;
     };)

    // model matrix, mesh, material, material, userdata matrix
    using Drawable = std::tuple<
            glm::mat4, Core::RHI::Mesh *,
            Core::RHI::Material *, glm::mat4
    >;

    // 2 render queue, opaque and transparent, sorted by distance to camera
    using OpaqueDrawables = std::multimap<float, Drawable, std::less<float>>;
    using TransparentDrawables = std::multimap<float, Drawable, std::greater<float>>;

public:
    ForwardRenderer();

    ~ForwardRenderer() override;

    void render(const Core::ECS::Entity &scene) const override;

    void initialize() override;

protected:

    void updateLights() const;

    void updateEngineUBO() const;

    void updateEngineUBOModel(const glm::mat4 &modelMatrix) const;

    std::pair <OpaqueDrawables, TransparentDrawables> FindAndSortDrawables(const Core::ECS::Entity &scene) const;

    std::unique_ptr<GLSLShaderProgram> m_forwardShader;

    std::unique_ptr<GLShaderStorageBuffer> m_lightSSBO{};
    std::unique_ptr<GLUniformBuffer> m_engineUBO{};
};
}

#endif //ZELOENGINE_FORWARDRENDERER_H