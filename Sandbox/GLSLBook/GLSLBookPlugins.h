// GLSLBookPlugins.h
// created on 2021/11/21
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Core/Plugin/Plugin.h"
#include "Core/RHI/RenderSystem.h"

#include "GLSLBook/ImageProcessing/EdgePipeline.h"
#include "GLSLBook/ImageProcessing/BlurPipeline.h"
#include "GLSLBook/ImageProcessing/BloomPipeline.h"
#include "GLSLBook/Shadow//ShadowMapPipeline.h"

template<class T>
class PipelinePlugin : public Plugin {
public:
    const std::string &getName() const override;;

    void install() override;

    void initialise() override;

    void shutdown() override;

    void uninstall() override;
};

template<class T>
const std::string &PipelinePlugin<T>::getName() const {
    static std::string s("");
    return s;
}

template<class T>
void PipelinePlugin<T>::install() {
    Zelo::Core::RHI::RenderSystem::getSingletonPtr()->resetRenderPipeline();
    auto renderPipeline = std::make_unique<T>();
    renderPipeline->initialize();
    Zelo::Core::RHI::RenderSystem::getSingletonPtr()->setRenderPipeline(std::move(renderPipeline));
}

template<class T>
void PipelinePlugin<T>::initialise() {
    // do nothing
}

template<class T>
void PipelinePlugin<T>::shutdown() {
    // do nothing
}

template<class T>
void PipelinePlugin<T>::uninstall() {
    Zelo::Core::RHI::RenderSystem::getSingletonPtr()->resetRenderPipeline();
}

class EdgePipelinePlugin : public PipelinePlugin<EdgePipeline> {
public:
    const std::string &getName() const override {
        static std::string s = "EdgePipelinePlugin";
        return s;
    }
};

class BlurPipelinePlugin : public PipelinePlugin<BlurPipeline> {
public:
    const std::string &getName() const override {
        static std::string s = "BlurPipelinePlugin";
        return s;
    }
};

class BloomPipelinePlugin : public PipelinePlugin<BloomPipeline> {
public:
    const std::string &getName() const override {
        static std::string s = "BloomPipelinePlugin";
        return s;
    }
};

class ShadowMapPipelinePlugin : public PipelinePlugin<ShadowMapPipeline> {
public:
    const std::string &getName() const override {
        static std::string s = "ShadowMapPipelinePlugin";
        return s;
    }
};