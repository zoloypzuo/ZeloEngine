// GLSLBookPlugins.cpp
// created on 2021/11/21
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLSLBookPlugins.h"

#include "Core/RHI/RenderSystem.h"
#include "GLSLBook/PostEffectPipeline.h"
#include "GLSLBook/ImageProcessing/EdgePipeline.h"
#include "GLSLBook/ImageProcessing/BlurPipeline.h"

using namespace Zelo::Core::RHI;

const std::string &EdgePipelinePlugin::getName() const {
    static std::string s = "PostEffect";
    return s;
}

void EdgePipelinePlugin::install() {
    auto renderPipeline = std::make_unique<EdgePipeline>();
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

const std::string &BlurPipelinePlugin::getName() const {
    static std::string s = "PostEffect";
    return s;
}

void BlurPipelinePlugin::install() {
    auto renderPipeline = std::make_unique<BlurPipeline>();
    renderPipeline->initialize();
    RenderSystem::getSingletonPtr()->setRenderPipeline(std::move(renderPipeline));
}

void BlurPipelinePlugin::initialise() {
    // do nothing
}

void BlurPipelinePlugin::shutdown() {
    // do nothing
}

void BlurPipelinePlugin::uninstall() {
    RenderSystem::getSingletonPtr()->resetRenderPipeline();
}