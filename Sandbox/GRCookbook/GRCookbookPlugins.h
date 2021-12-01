// GRCookbookPlugins.h
// created on 2021/11/30
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Core/Plugin/Plugin.h"
#include "Core/RHI/RenderSystem.h"

#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"
#include "Resource/GLBuffer.h"
#include "Resource/GLMesh1.h"
#include "Resource/GLMeshPVP.h"
#include "shared/glFramework/GLTexture.h"

class Ch5MeshRendererPlugin : public Plugin {
public:
    const std::string &getName() const override;;

    void install() override;

    void uninstall() override;

    void initialize() override;

    void update() override;

    void render() override;

private:
    std::unique_ptr<GLSLShaderProgram> m_meshShader{};
    std::unique_ptr<GLBuffer> perFrameDataBuffer{};
    std::unique_ptr<GLBuffer> modelMatrices{};
    std::unique_ptr<GLMesh1> mesh{};
    MeshFileHeader header;

    Zelo::Core::ECS::Entity *entity{};
};

class Ch7PBRPlugin : public Plugin {
public:
    const std::string &getName() const override;;

    void install() override;

    void uninstall() override;

    void initialize() override;

    void update() override;

    void render() override;

private:
    std::unique_ptr<GLSLShaderProgram> m_meshShader{};
    std::unique_ptr<GLBuffer> perFrameDataBuffer{};
    std::unique_ptr<GLBuffer> modelMatrices{};
    std::unique_ptr<GLMeshPVP> mesh{};
    MeshFileHeader header;

    std::unique_ptr<GLTexture> texAO;
    std::unique_ptr<GLTexture> texEmissive;
    std::unique_ptr<GLTexture> texAlbedo;
    std::unique_ptr<GLTexture> texMeR;
    std::unique_ptr<GLTexture> texNormal;
    std::unique_ptr<GLTexture> envMap;
    std::unique_ptr<GLTexture> envMapIrradiance;
    std::unique_ptr<GLTexture> brdfLUT;

    Zelo::Core::ECS::Entity *entity{};

    void loadMesh(const std::string &meshPath);

    void loadTex();
};
