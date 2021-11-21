// GLSLBookPlugins.cpp
// created on 2021/11/21
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLSLBookPlugins.h"

#include "Core/RHI/RenderSystem.h"
#include "GLSLBook/PostEffectPipeline.h"
#include "GLSLBook/ImageProcessing/EdgePipeline.h"
#include "GLSLBook/ImageProcessing/BlurPipeline.h"
#include "GLSLBook/ImageProcessing/BloomPipeline.h"

using namespace Zelo::Core::RHI;

const std::string &EdgePipelinePlugin::getName() const {
    static std::string s = "EdgePipelinePlugin";
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
    static std::string s = "BlurPipelinePlugin";
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

const std::string &BloomPipelinePlugin::getName() const {
    static std::string s = "BloomPipelinePlugin";
    return s;
}

void BloomPipelinePlugin::install() {
    auto renderPipeline = std::make_unique<BloomPipeline>();
    renderPipeline->initialize();
    RenderSystem::getSingletonPtr()->setRenderPipeline(std::move(renderPipeline));
}

void BloomPipelinePlugin::initialise() {
    // do nothing
}

void BloomPipelinePlugin::shutdown() {
    // do nothing
}

void BloomPipelinePlugin::uninstall() {
    RenderSystem::getSingletonPtr()->resetRenderPipeline();
}