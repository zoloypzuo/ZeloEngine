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

void RenderSystem::setActiveCamera(std::shared_ptr<Camera> camera) {
    m_activeCamera = std::move(camera);
}

void RenderSystem::addDirectionalLight(const std::shared_ptr<DirectionalLight> &light) {
    m_directionalLights.push_back(light);
}

void RenderSystem::removeDirectionalLight(const std::shared_ptr<DirectionalLight> &light) {
    m_directionalLights.erase(std::remove(m_directionalLights.begin(), m_directionalLights.end(), light),
                              m_directionalLights.end());
}

void RenderSystem::addPointLight(const std::shared_ptr<PointLight> &light) {
    m_pointLights.push_back(light);
}

void RenderSystem::removePointLight(const std::shared_ptr<PointLight> &light) {
    m_pointLights.erase(std::remove(m_pointLights.begin(), m_pointLights.end(), light), m_pointLights.end());
}

void RenderSystem::addSpotLight(const std::shared_ptr<SpotLight> &light) {
    m_spotLights.push_back(light);
}

void RenderSystem::removeSpotLight(const std::shared_ptr<SpotLight> &light) {
    m_spotLights.erase(std::remove(m_spotLights.begin(), m_spotLights.end(), light), m_spotLights.end());
}