// Light.h
// created on 2021/3/31
// author @zoloypzuo

#ifndef ZELOENGINE_LIGHT_H
#define ZELOENGINE_LIGHT_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/ECS/Component.h"
#include "GLSLShaderProgram.h"
#include "Attenuation.h"

class BaseLight : public Component, public std::enable_shared_from_this<BaseLight> {
public:
    BaseLight(glm::vec3 color, float intensity);

    virtual ~BaseLight();

    virtual void registerWithEngine(Engine *engine) {};

    glm::vec3 getColor() const;

    float getIntensity() const;

    virtual void updateShader(GLSLShaderProgram *shader) = 0;

protected:
    glm::vec3 m_color;
    float m_intensity;
};

class DirectionalLight : public BaseLight {
public:
    DirectionalLight(glm::vec3 color, float intensity);

    virtual void registerWithEngine(Engine *engine);

    virtual void deregisterFromEngine(Engine *engine);

    virtual void updateShader(GLSLShaderProgram *shader);

    inline virtual const char *getType() { return "DIRECTIONAL_LIGHT"; }
};

class PointLight : public BaseLight {
public:
    PointLight(glm::vec3 color, float intensity, std::shared_ptr<Attenuation> attenuation);

    virtual ~PointLight();

    virtual void registerWithEngine(Engine *engine);

    virtual void deregisterFromEngine(Engine *engine);

    virtual void updateShader(GLSLShaderProgram *shader);

    inline virtual const char *getType() { return "POINT_LIGHT"; }

    std::shared_ptr<Attenuation> getAttenuation() const;

    float getRange();

private:
    std::shared_ptr<Attenuation> m_attenuation;

    float m_range;
};

class SpotLight : public PointLight {
public:
    SpotLight(glm::vec3 color, float intensity, float cutoff, std::shared_ptr<Attenuation> attenuation);

    virtual void registerWithEngine(Engine *engine);

    virtual void deregisterFromEngine(Engine *engine);

    inline virtual const char *getType() { return "SPOT_LIGHT"; }

    virtual void updateShader(GLSLShaderProgram *shader);

    float getCutoff() const;

private:
    float m_cutoff;
};


#endif //ZELOENGINE_LIGHT_H