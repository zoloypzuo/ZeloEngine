// Grid.h
// created on 2021/11/29
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "Core/ECS/Entity.h"
#include "Core/RHI/IDrawable.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"

namespace Zelo::Renderer::OpenGL {
class Grid :
        public Core::ECS::Component,
        public Core::RHI::IDrawable {
public:
    explicit Grid(Core::ECS::Entity &owner);

    void render() const override;

    std::string getType() override;

private:
    GLuint m_vao{};
    std::unique_ptr<GLSLShaderProgram> m_gridShader{};
};
}

