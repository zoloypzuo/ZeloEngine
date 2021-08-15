// Light.h
// created on 2021/3/31
// author @zoloypzuo
#ifndef ZELOENGINE_LIGHT_H
#define ZELOENGINE_LIGHT_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/ECS/Entity.h"

class GLSLShaderProgram;

struct Attenuation {
public:
    Attenuation() = default;

    Attenuation(float constant, float linear, float exponent);

    float getConstant() const;

    float getLinear() const;

    float getExponent() const;

    float m_constant;
    float m_linear;
    float m_exponent;
};

class BaseLight : public Zelo::Core::ECS::Component, public std::enable_shared_from_this<BaseLight> {
public:
    BaseLight();

    ~BaseLight() override;

    void registerWithEngine() override {};

    glm::vec3 getColor() const;

    float getIntensity() const;

    virtual void updateShader(GLSLShaderProgram *shader) = 0;

public:
    glm::vec3 m_color{};
    float m_intensity{};
};

class DirectionalLight : public BaseLight {
public:
    DirectionalLight();

    void registerWithEngine() override;

    void deregisterFromEngine() override;

    void updateShader(GLSLShaderProgram *shader) override;

    inline const char *getType() override { return "DIRECTIONAL_LIGHT"; }
};

class PointLight : public BaseLight {
public:
    PointLight();

    ~PointLight() override;

    void registerWithEngine() override;

    void deregisterFromEngine() override;

    void updateShader(GLSLShaderProgram *shader) override;

    inline const char *getType() override { return "POINT_LIGHT"; }

    std::shared_ptr<Attenuation> getAttenuation() const;

    float getRange();

public:
    std::shared_ptr<Attenuation> m_attenuation{};

    float m_range{};
};

class SpotLight : public BaseLight {
public:
    SpotLight();

    void registerWithEngine() override;

    void deregisterFromEngine() override;

    inline const char *getType() override { return "SPOT_LIGHT"; }

    void updateShader(GLSLShaderProgram *shader) override;

    std::shared_ptr<Attenuation> getAttenuation() const {
        return std::make_shared<Attenuation>(
                m_attenuation->m_constant,
                m_attenuation->m_linear,
                m_attenuation->m_exponent
        );
    }

    float getCutoff() const;

public:
    Attenuation *m_attenuation{};
    float m_range{};
    float m_cutoff{};
};

#endif //ZELOENGINE_LIGHT_H