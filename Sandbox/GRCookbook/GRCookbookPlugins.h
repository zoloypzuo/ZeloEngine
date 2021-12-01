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
#include "Resource/GLMesh2.h"
#include "Resource/GLMesh9.h"
#include "Resource/GLSkyboxRenderer.h"

#include "shared/glFramework/GLTexture.h"
#include "shared/glFramework/GLSceneDataLazy.h"
#include "shared/glFramework/GLFramebuffer.h"

#include "shared/scene/VtxData.h"
#include "shared/scene/Scene.h"

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

class Ch6PBRPlugin : public Plugin {
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

};

class Ch7LargeScenePlugin : public Plugin {
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
    std::unique_ptr<GLMesh2> mesh1{};
    std::unique_ptr<GLMesh2> mesh2{};
    MeshFileHeader header;

    std::unique_ptr<GLSceneData> sceneData1;
    std::unique_ptr<GLSceneData> sceneData2;

    Zelo::Core::ECS::Entity *entity{};
};

namespace FinalScene {
class Ch10FinalPlugin : public Plugin {
public:

public:
    const std::string &getName() const override;;

    void install() override;

    void uninstall() override;

    void initialize() override;

    void update() override;

    void render() override;

private:
    struct Impl;
    std::shared_ptr<Impl> pimpl{};

    Zelo::Core::ECS::Entity *entity{};
};
}