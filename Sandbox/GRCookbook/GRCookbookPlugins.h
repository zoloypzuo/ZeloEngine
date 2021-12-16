// GRCookbookPlugins.h
// created on 2021/11/30
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

#include "Foundation/ZeloPlugin.h"
#include "Core/RHI/RenderSystem.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"

#include "Resource/GLBuffer.h"
#include "Resource/GLMesh2.h"

#include "GRCookbook/Scene/Scene.h"
#include "VtxData/MeshFileHeader.h"

class Ch7LargeScenePlugin : public Zelo::Plugin {
public:
    const std::string &getName() const override;;

    void install() override {}

    void uninstall() override {}

    void initialize() override;

    void update() override {}

    void render() override;

private:
    std::unique_ptr<GLSLShaderProgram> m_meshShader{};
    std::unique_ptr<GLBuffer> perFrameDataBuffer{};
    std::unique_ptr<GLMesh2> mesh1{};
    std::unique_ptr<GLMesh2> mesh2{};
    MeshFileHeader header;
    std::unique_ptr<GLSceneData> sceneData1;
    std::unique_ptr<GLSceneData> sceneData2;
};
