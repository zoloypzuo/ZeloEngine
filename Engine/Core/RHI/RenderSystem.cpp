// RenderSystem.cpp
// created on 2021/8/1
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "RenderSystem.h"

using namespace Zelo::Core::RHI;

RenderSystem::~RenderSystem() = default;

void RenderSystem::initialize() {

}

void RenderSystem::update() {

}

void RenderSystem::finalize() {

}

const RenderSystem::FrameInfo &RenderSystem::GetFrameInfo() const {
    return m_frameInfo;
}

void RenderSystem::ClearFrameInfo() {
    m_frameInfo.batchCount = 0;
    m_frameInfo.instanceCount = 0;
    m_frameInfo.polyCount = 0;
}

template<> RenderSystem *Singleton<RenderSystem>::msSingleton = nullptr;

RenderSystem *RenderSystem::getSingletonPtr() {
    return msSingleton;

}

RenderSystem &RenderSystem::getSingleton() {
    assert(msSingleton);
    return *msSingleton;
}

void RenderSystem::setActiveCamera(Camera *camera) {
    m_activeCamera = camera;
}

void RenderSystem::addDirectionalLight(const std::shared_ptr<DirectionalLight> &light) {
    m_directionalLights.push_back(light);
}

void RenderSystem::removeDirectionalLight(const std::shared_ptr<DirectionalLight> &light) {
    Zelo::Erase(m_directionalLights, light);
}

void RenderSystem::addPointLight(const std::shared_ptr<PointLight> &light) {
    m_pointLights.push_back(light);
}

void RenderSystem::removePointLight(const std::shared_ptr<PointLight> &light) {
    Zelo::Erase(m_pointLights, light);
}

void RenderSystem::addSpotLight(const std::shared_ptr<SpotLight> &light) {
    m_spotLights.push_back(light);
}

void RenderSystem::removeSpotLight(const std::shared_ptr<SpotLight> &light) {
    Zelo::Erase(m_spotLights, light);
}