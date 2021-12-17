#pragma once

#include "ZeloPrerequisites.h"

#include "Foundation/ZeloPlugin.h"
#include "Core/ECS/Entity.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"

#include "Resource/GLBuffer.h"
#include "Resource/GLMeshPVP.h"

#include "GRCookbook/Texture/GLTexture.h"

class Ch6PBRPlugin : public Zelo::Plugin {
public:
    const std::string &getName() const override;;

    void install() override;

    void uninstall() override;

    void initialize() override;

    void update() override;

    void render() override;

private:
    void loadMesh(const std::string &meshPath);

    void loadTex();

private:
    std::unique_ptr<GLSLShaderProgram> m_meshShader{};
    std::unique_ptr<GLBuffer> perFrameDataBuffer{};
    std::unique_ptr<GLBuffer> modelMatrices{};
    std::unique_ptr<GLMeshPVP> mesh{};

    std::unique_ptr<GLTexture> texAO;
    std::unique_ptr<GLTexture> texEmissive;
    std::unique_ptr<GLTexture> texAlbedo;
    std::unique_ptr<GLTexture> texMeR;
    std::unique_ptr<GLTexture> texNormal;
    std::unique_ptr<GLTexture> envMap;
    std::unique_ptr<GLTexture> envMapIrradiance;
    std::unique_ptr<GLTexture> brdfLUT;

    Zelo::Core::ECS::Entity *entity{};
};

