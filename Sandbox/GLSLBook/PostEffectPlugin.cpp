// PostEffectPlugin.cpp
// created on 2021/11/21
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "PostEffectPlugin.h"

#include "Core/RHI/RenderSystem.h"
#include "GLSLBook/PostEffectPipeline.h"

const std::string &PostEffectPlugin::getName() const {
    static std::string s = "PostEffect";
    return s;
}

void PostEffectPlugin::install() {
    auto renderPipeline = std::make_unique<PostEffectPipeline>();
    renderPipeline->initialize();
    Zelo::Core::RHI::RenderSystem::getSingletonPtr()->setRenderPipeline(std::move(renderPipeline));
}

void PostEffectPlugin::initialise() {

}

void PostEffectPlugin::shutdown() {

}

void PostEffectPlugin::uninstall() {

}
