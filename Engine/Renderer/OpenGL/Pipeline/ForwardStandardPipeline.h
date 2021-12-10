// ForwardStandardPipeline.h
// created on 2021/3/29
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "Core/RHI/RenderPipeline.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"
#include "Renderer/OpenGL/Drawable/Line.h"
#include "Renderer/OpenGL/Buffer/GLShaderStorageBuffer.h"
#include "Renderer/OpenGL/Buffer/GLUniformBuffer.h"
#include "Renderer/OpenGL/Drawable/Grid.h"

namespace Zelo::Core::RHI {
class Mesh;

class Material;
}

namespace Zelo::Renderer::OpenGL {
struct RenderItem {
    glm::mat4 modelMatrix;
    Core::RHI::Mesh *mesh;
    Core::RHI::Material *material;
//    glm::mat4 userMatrix;
};

using RenderQueue = std::vector<RenderItem>;

class ForwardStandardPipeline : public Core::RHI::RenderPipeline {
public:
    ZELO_PACKED
    (struct EngineUBO {
         glm::mat4 ubo_model;
         glm::mat4 ubo_view;
         glm::mat4 ubo_projection;
         glm::vec3 ubo_viewPos;
         float ubo_time;
     };)

public:
    ForwardStandardPipeline();

    ~ForwardStandardPipeline() override;

    void preRender() override;

    void render(const Core::ECS::Entity &scene) const override;

    void initialize() override;

protected:
    void updateLights() const;

    void updateEngineUBO() const;

    void updateEngineUBOModel(const glm::mat4 &modelMatrix) const;

    std::shared_ptr<GLSLShaderProgram> m_forwardStandardShader;

    std::unique_ptr<GLShaderStorageBuffer> m_lightSSBO{};
    std::unique_ptr<GLUniformBuffer> m_engineUBO{};

    RenderQueue sortRenderQueue() const;

private:
    std::unique_ptr<Grid> m_grid;
};
}
