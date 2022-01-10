// GLSkyboxRenderer.h
// created on 2021/12/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "Core/ECS/Entity.h"
#include "Core/RHI/IDrawable.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Texture/GLTexture.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"

namespace Zelo::Renderer::OpenGL {
class GLSkyboxRenderer :
        public Core::ECS::Component,
        public Core::RHI::IDrawable {
public:
    GLSkyboxRenderer(
            Core::ECS::Entity &owner,
            std::string_view envMap,
            std::string_view envMapIrradiance,
            std::string_view brdfLUTFileName
    );

    ~GLSkyboxRenderer() override;

    void render() const override;

    std::string getType() override;

private:
    // https://hdrihaven.com/hdri/?h=immenstadter_horn
    GLTexture envMap_;
    GLTexture envMapIrradiance_;
    GLTexture brdfLUT_;
    std::unique_ptr<GLSLShaderProgram> progCube_;
    GLuint dummyVAO_{};
};
}
