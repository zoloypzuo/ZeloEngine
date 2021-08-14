// Light.cpp
// created on 2021/3/31
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Light.h"
#include "Core/RHI/RenderSystem.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"

using namespace Zelo::Core::RHI;

// BaseLight::BaseLight(glm::vec3 color, float intensity) {
//     m_color = color;
//     m_intensity = intensity;

//     setProperty("color", PropertyType::COLOR, &m_color.x, 0, 1);
//     setProperty("intensity", PropertyType::FLOAT, &m_intensity, 0, 100);
// }

BaseLight::~BaseLight() = default;

glm::vec3 BaseLight::getColor() const {
    return m_color;
}

float BaseLight::getIntensity() const {
    return m_intensity;
}

// DirectionalLight::DirectionalLight(glm::vec3 color, float intensity) : BaseLight(color, intensity) {
// }

void DirectionalLight::registerWithEngine() {
    RenderSystem::getSingletonPtr()->addDirectionalLight(std::dynamic_pointer_cast<DirectionalLight>(shared_from_this()));
}

void DirectionalLight::deregisterFromEngine() {
    RenderSystem::getSingletonPtr()->removeDirectionalLight(
            std::dynamic_pointer_cast<DirectionalLight>(shared_from_this()));
}

void DirectionalLight::updateShader(GLSLShaderProgram *shader) {
    shader->updateUniformDirectionalLight("directionalLight", this);
}

// PointLight::PointLight(glm::vec3 color, float intensity, std::shared_ptr<Attenuation> attenuation) : BaseLight(color,
//                                                                                                                intensity) {
//     m_attenuation = attenuation;

//     // float a = attenuation->getExponent();
//     // float b = attenuation->getLinear();
//     // float c = attenuation->getConstant() - BITS_PER_CHANNEL * getIntensity() * glm::max(color.x, glm::max(color.y, color.z));

//     setProperty("exp", PropertyType::FLOAT, &m_attenuation->m_exponent, 0, 0.5);
//     setProperty("linear", PropertyType::FLOAT, &m_attenuation->m_linear, 0, 1);
//     setProperty("const", PropertyType::FLOAT, &m_attenuation->m_constant, 0, 1);

//     // m_range = (-b + glm::sqrt(b * b - 4 * a * c)) / (2 * a);
// }

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

// SpotLight::SpotLight(glm::vec3 color, float intensity, float cutoff, std::shared_ptr<Attenuation> attenuation)
//         : PointLight(color, intensity, attenuation) {
//     m_cutoff = cutoff;
//     setProperty("cutoff", PropertyType::FLOAT, &m_cutoff, 0, 1);
// }

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