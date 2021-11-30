// GRCookbookPlugins.cpp
// created on 2021/11/30
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GRCookbookPlugins.h"

#include "Core/Input/Input.h"
#include "Core/OS/Time.h"
#include "Core/Window/Window.h"
#include "Core/Scene/SceneManager.h"
#include "Core/RHI/RenderSystem.h"


const std::string &Ch5MeshRendererPlugin::getName() const {
    static std::string s = "Ch5MeshRendererPlugin";
    return s;
}

void Ch5MeshRendererPlugin::install() {

}

void Ch5MeshRendererPlugin::uninstall() {

}

void Ch5MeshRendererPlugin::initialize() {
    Zelo::Core::Scene::SceneManager::getSingletonPtr()->clear();
    Zelo::Core::RHI::RenderSystem::getSingletonPtr()->resetRenderPipeline();
}

void Ch5MeshRendererPlugin::update() {
    Plugin::update();
}

void Ch5MeshRendererPlugin::render() {
    Plugin::render();
}
