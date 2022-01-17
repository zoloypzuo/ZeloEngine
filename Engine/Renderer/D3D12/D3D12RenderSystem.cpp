// D3D12RenderSystem.cpp
// created on 2022/1/17
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "D3D12RenderSystem.h"

namespace Zelo::Renderer::D3D12 {
D3D12RenderSystem::D3D12RenderSystem() {

}

D3D12RenderSystem::~D3D12RenderSystem() {

}

void D3D12RenderSystem::initialize() {
    RenderSystem::initialize();
}

void D3D12RenderSystem::update() {
    RenderSystem::update();
}

void D3D12RenderSystem::pushView(Zelo::Core::Interface::IView *view) {

}

void D3D12RenderSystem::popView() {

}

void D3D12RenderSystem::setViewport(int32_t x, int32_t y, int32_t width, int32_t height) {

}

void D3D12RenderSystem::setClearColor(const glm::vec4 &color) {

}

void D3D12RenderSystem::clear(bool colorBuffer, bool depthBuffer, bool stencilBuffer) {

}

void D3D12RenderSystem::setCapabilityEnabled(Zelo::Core::RHI::ERenderCapability capability,
                                             bool value) {

}

bool D3D12RenderSystem::getCapabilityEnabled(Zelo::Core::RHI::ERenderCapability capability) {
    return false;
}

void D3D12RenderSystem::setStencilAlgorithm(Zelo::Core::RHI::EComparaisonAlgorithm algorithm,
                                            int32_t reference, uint32_t mask) {

}

void D3D12RenderSystem::setDepthAlgorithm(Zelo::Core::RHI::EComparaisonAlgorithm algorithm) {

}

void D3D12RenderSystem::setStencilMask(uint32_t mask) {

}

void D3D12RenderSystem::setStencilOperations(Zelo::Core::RHI::EOperation stencilFail,
                                             Zelo::Core::RHI::EOperation depthFail,
                                             Zelo::Core::RHI::EOperation bothPass) {

}

void D3D12RenderSystem::setCullFace(Zelo::Core::RHI::ECullFace cullFace) {

}

void D3D12RenderSystem::setDepthWriting(bool enable) {

}

void D3D12RenderSystem::setColorWriting(bool enableRed, bool enableGreen, bool enableBlue,
                                        bool enableAlpha) {

}

void D3D12RenderSystem::setColorWriting(bool enable) {

}

void D3D12RenderSystem::readPixels(uint32_t x, uint32_t y, uint32_t width, uint32_t height,
                                   Zelo::Core::RHI::EPixelDataFormat format,
                                   Zelo::Core::RHI::EPixelDataType type, void *data) {

}

bool D3D12RenderSystem::getBool(uint32_t parameter) {
    return false;
}

bool D3D12RenderSystem::getBool(uint32_t parameter, uint32_t index) {
    return false;
}

int D3D12RenderSystem::getInt(uint32_t parameter) {
    return 0;
}

int D3D12RenderSystem::getInt(uint32_t parameter, uint32_t index) {
    return 0;
}

float D3D12RenderSystem::getFloat(uint32_t parameter) {
    return 0;
}

float D3D12RenderSystem::getFloat(uint32_t parameter, uint32_t index) {
    return 0;
}

double D3D12RenderSystem::getDouble(uint32_t parameter) {
    return 0;
}

double D3D12RenderSystem::getDouble(uint32_t parameter, uint32_t index) {
    return 0;
}

int64_t D3D12RenderSystem::getInt64(uint32_t parameter) {
    return 0;
}

int64_t D3D12RenderSystem::getInt64(uint32_t parameter, uint32_t index) {
    return 0;
}

std::string D3D12RenderSystem::getString(uint32_t parameter) {
    return std::string();
}

std::string D3D12RenderSystem::getString(uint32_t parameter, uint32_t index) {
    return std::string();
}

uint8_t D3D12RenderSystem::fetchGLState() {
    return 0;
}

void D3D12RenderSystem::applyStateMask(uint8_t mask) {

}
}