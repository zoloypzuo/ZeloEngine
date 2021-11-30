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

    Zelo::Core::ECS::Entity *entity{};

    void loadMesh(const std::string &meshPath);

    void loadTex() const;
};
