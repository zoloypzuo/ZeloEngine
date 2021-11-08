// ForwardRenderer.h
// created on 2021/3/29
// author @zoloypzuo

#ifndef ZELOENGINE_FORWARDRENDERER_H
#define ZELOENGINE_FORWARDRENDERER_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "Renderer.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"
#include "Renderer/OpenGL/Drawable/Line.h"
#include "Renderer/OpenGL/Buffer/GLShaderStorageBuffer.h"
#include "Renderer/OpenGL/Buffer/GLUniformBuffer.h"

class SimpleRenderer : public Renderer {
public:
    SimpleRenderer();

    void initialize() override;

    ~SimpleRenderer() override;

    void render(const Zelo::Core::ECS::Entity &scene) const override;

    void renderLine(const Line &line, const std::shared_ptr<Camera> &activeCamera) const;

private:

    std::unique_ptr<GLSLShaderProgram> m_simple;
};

class ForwardRenderer : public Renderer {
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
    ForwardRenderer();

    ~ForwardRenderer() override;

    void render(const Zelo::Core::ECS::Entity &scene) const override;

    void initialize() override;

protected:

    void updateLights() const;

    void updateEngineUBO() const;

    void updateEngineUBOModel(const glm::mat4 &modelMatrix) const;

    std::unique_ptr<GLSLShaderProgram> m_forwardShader;

    std::unique_ptr<Zelo::GLShaderStorageBuffer> m_lightSSBO{};
    std::unique_ptr<Zelo::GLUniformBuffer> m_engineUBO{};
};

#endif //ZELOENGINE_FORWARDRENDERER_H