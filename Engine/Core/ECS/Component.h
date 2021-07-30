// Component.h
// created on 2021/3/28
// author @zoloypzuo

#ifndef ZELOENGINE_COMPONENT_H
#define ZELOENGINE_COMPONENT_H

#include "ZeloPrerequisites.h"
#include "Core/Input/Input.h"
#include "Core/Math/Transform.h"

class Entity;

class GLSLShaderProgram;

enum class PropertyType {
    FLOAT,
    FLOAT3,
    BOOLEAN,
    ANGLE,
    COLOR
};

struct Property {
    PropertyType type;
    void *p;
    float min;
    float max;
};

class Component {
public:
    virtual ~Component() = default;;

    virtual void update(Input *input, std::chrono::microseconds delta) {};

    virtual void render(GLSLShaderProgram *shader) {};

    virtual void registerWithEngine() {};

    virtual void deregisterFromEngine() {};

    virtual const char *getType() = 0;

    void setProperty(const char *name, PropertyType type, void *p, float min, float max);

    void setProperty(const char *name, PropertyType type, void *p);

    void setParent(Entity *parentEntity);

    Entity *getParent() const;

    Transform &getTransform() const;

    std::map<const char *, Property> m_properties;

protected:
    Entity *m_parentEntity;
};

#endif //ZELOENGINE_COMPONENT_H