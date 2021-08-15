// Light.cpp
// created on 2021/3/31
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Light.h"
#include "Core/RHI/RenderSystem.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"

using namespace Zelo::Core::RHI;
using namespace Zelo::Core::ECS;


BaseLight::~BaseLight() = default;

glm::vec3 BaseLight::getColor() const {
    return m_color;
}

float BaseLight::getIntensity() const {
    return m_intensity;
}

BaseLight::BaseLight() {
    setProperty("color", PropertyType::COLOR, &m_color.x, 0, 1);
    setProperty("intensity", PropertyType::FLOAT, &m_intensity, 0, 100);
}

void DirectionalLight::registerWithEngine() {
    RenderSystem::getSingletonPtr()->addDirectionalLight(
            std::dynamic_pointer_cast<DirectionalLight>(shared_from_this()));
}

void DirectionalLight::deregisterFromEngine() {
    RenderSystem::getSingletonPtr()->removeDirectionalLight(
            std::dynamic_pointer_cast<DirectionalLight>(shared_from_this()));
}

void DirectionalLight::updateShader(GLSLShaderProgram *shader) {
    shader->updateUniformDirectionalLight("directionalLight", this);
}

DirectionalLight::DirectionalLight() : BaseLight() {}

PointLight::PointLight() : BaseLight() {
    setProperty("exp", PropertyType::FLOAT, &m_attenuation->m_exponent, 0, 0.5);
    setProperty("linear", PropertyType::FLOAT, &m_attenuation->m_linear, 0, 1);
    setProperty("const", PropertyType::FLOAT, &m_attenuation->m_constant, 0, 1);
}

PointLight::~PointLight() = default;

void PointLight::registerWithEngine() {
    RenderSystem::getSingletonPtr()->addPointLight(std::dynamic_pointer_cast<PointLight>(shared_from_this()));
}

void PointLight::deregisterFromEngine() {
    RenderSystem::getSingletonPtr()->removePointLight(std::dynamic_pointer_cast<PointLight>(shared_from_this()));
}

void PointLight::updateShader(GLSLShaderProgram *shader) {
    shader->updateUniformPointLight("pointLight", this);
}

std::shared_ptr<Attenuation> PointLight::getAttenuation() const {
    return m_attenuation;
}

float PointLight::getRange() {
    float a = m_attenuation->getExponent();
    float b = m_attenuation->getLinear();
    float c = m_attenuation->getConstant() -
              8 * getIntensity() * glm::max(m_color.x, glm::max(m_color.y, m_color.z));

    m_range = (-b + glm::sqrt(b * b - 4 * a * c)) / (2 * a);
    return m_range;
}

SpotLight::SpotLight() : BaseLight() {
    setProperty("cutoff", PropertyType::FLOAT, &m_cutoff, 0, 1);
}

void SpotLight::registerWithEngine() {
    RenderSystem::getSingletonPtr()->addSpotLight(std::dynamic_pointer_cast<SpotLight>(shared_from_this()));
}

void SpotLight::deregisterFromEngine() {
    RenderSystem::getSingletonPtr()->removeSpotLight(std::dynamic_pointer_cast<SpotLight>(shared_from_this()));
}

void SpotLight::updateShader(GLSLShaderProgram *shader) {
    shader->updateUniformSpotLight("spotLight", this);
}

float SpotLight::getCutoff() const {
    return m_cutoff;
}


Attenuation::Attenuation(float constant, float linear, float exponent) {
    m_constant = constant;
    m_linear = linear;
    m_exponent = exponent;
}

float Attenuation::getConstant() const {
    return m_constant;
}

float Attenuation::getLinear() const {
    return m_linear;
}

float Attenuation::getExponent() const {
    return m_exponent;
}