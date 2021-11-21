// GLSLBookPlugins.cpp
// created on 2021/11/21
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLSLBookPlugins.h"

#include "Core/RHI/RenderSystem.h"
#include "GLSLBook/PostEffectPipeline.h"

using namespace Zelo::Core::RHI;

const std::string &EdgePipelinePlugin::getName() const {
    static std::string s = "PostEffect";
    return s;
}

void EdgePipelinePlugin::install() {
    auto renderPipeline = std::make_unique<PostEffectPipeline>();
    renderPipeline->initialize();
    RenderSystem::getSingletonPtr()->setRenderPipeline(std::move(renderPipeline));
}

void EdgePipelinePlugin::initialise() {
    // do nothing
}

void EdgePipelinePlugin::shutdown() {
    // do nothing
}

void EdgePipelinePlugin::uninstall() {
    RenderSystem::getSingletonPtr()->resetRenderPipeline();
}
