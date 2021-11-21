// SimplePipeline.h
// created on 2021/11/21
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "Core/RHI/RenderPipeline.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"
#include "Renderer/OpenGL/Drawable/Line.h"

namespace Zelo::Renderer::OpenGL {
class SimplePipeline : public Core::RHI::RenderPipeline {
public:
    SimplePipeline();

    void initialize() override;

    ~SimplePipeline() override;

    void render(const Core::ECS::Entity &scene) const override;

    void renderLine(const Line &line, const std::shared_ptr<Camera> &activeCamera) const;

private:
    std::unique_ptr<GLSLShaderProgram> m_simpleShader;
};
}