// Light.h
// created on 2021/3/31
// author @zoloypzuo
#ifndef ZELOENGINE_LIGHT_H
#define ZELOENGINE_LIGHT_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/ECS/Entity.h"

struct Attenuation
{
public:
    Attenuation(float constant, float linear, float exponent);

    float getConstant() const;

    float getLinear() const;

    float getExponent() const;

    float m_constant;
    float m_linear;
    float m_exponent;
};

class BaseLight : public Component, public std::enable_shared_from_this<BaseLight>
{
public:
    BaseLight() {
        setProperty("color", PropertyType::COLOR, &m_color.x, 0, 1);
        setProperty("intensity", PropertyType::FLOAT, &m_intensity, 0, 100);
    };

    // BaseLight(glm::vec3 color, float intensity);

    ~BaseLight() override;

    void registerWithEngine() override{};

    glm::vec3 getColor() const;

    float getIntensity() const;

    //    virtual void updateShader(GLSLShaderProgram *shader) = 0;

public:
    glm::vec3 m_color{};
    float m_intensity{};
};

class DirectionalLight : public BaseLight
{
public:
    DirectionalLight(): BaseLight() {}

    // DirectionalLight(glm::vec3 color, float intensity);

    void registerWithEngine() override;

    void deregisterFromEngine() override;

    //    void updateShader(GLSLShaderProgram *shader) override;

    inline const char *getType() override { return "DIRECTIONAL_LIGHT"; }
};

class PointLight : public BaseLight
{
public:
    PointLight() : BaseLight(){}
    
    // PointLight(glm::vec3 color, float intensity, std::shared_ptr<Attenuation> attenuation);

    ~PointLight() override;

    void registerWithEngine() override;

    void deregisterFromEngine() override;

    //    void updateShader(GLSLShaderProgram *shader) override;

    inline const char *getType() override { return "POINT_LIGHT"; }

    std::shared_ptr<Attenuation> getAttenuation() const;

    float getRange();

public:
    std::shared_ptr<Attenuation> m_attenuation{};

    float m_range{};
};

class SpotLight : public PointLight
{
public:
    SpotLight() : PointLight() {}

    // SpotLight(glm::vec3 color, float intensity, float cutoff, std::shared_ptr<Attenuation> attenuation);

    void registerWithEngine() override;

    void deregisterFromEngine() override;

    inline const char *getType() override { return "SPOT_LIGHT"; }

    //    void updateShader(GLSLShaderProgram *shader) override;

    float getCutoff() const;

public:
    float m_cutoff{};
};

#endif //ZELOENGINE_LIGHT_H