// Entity.h
// created on 2021/3/28
// author @zoloypzuo
#ifndef ZELOENGINE_ENTITY_H
#define ZELOENGINE_ENTITY_H

#include "ZeloPrerequisites.h"
#include "Core/Math/Transform.h"
#include "Core/RHI/Resource/Shader.h"
#include "Core/LuaScript/LuaScriptManager.h"
#include "Core/EventSystem/Event.h"


namespace Zelo::Core::ECS {
// TODO 解开Entity和场景图的依赖关系，不要在Entity类里递归，和注册
class Entity;

class Component;

// TODO use lua type
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

    // TODO change delta to float
    virtual void update(float delta) {};

    // TODO remove it
    virtual void render(Shader *shader) {};

    // TODO remove it
    virtual void registerWithEngine() {};

    // TODO remove it
    virtual void deregisterFromEngine() {};

    virtual const char *getType() = 0;

    // TODO remove it
    void setProperty(const char *name, PropertyType type, void *p, float min, float max);

    void setProperty(const char *name, PropertyType type, void *p);

    void setParent(Entity *parentEntity);

    Entity *getParent() const;

    Transform &getTransform() const;

    std::map<const char *, Property> m_properties;

protected:
    Entity *m_parentEntity;
};

class Entity {
public:
    explicit Entity(GUID_t guid);

    ~Entity();

    void addChild(const std::shared_ptr<Entity> &child);

    // NOTE hard to sol::resolve template
    // template<class T>
    // inline void addComponent(std::shared_ptr<T> component) {
    //     component->setParent(this);
    //     m_componentsByTypeid[typeid(T)].push_back(component);
    //     m_components.push_back(component);
    // }

    template<class T, class... Types>
    inline T *addComponent(Types &&... Args);

    void updateAll(float delta);

    void renderAll(Shader *shader) const;

    void registerWithEngineAll();

    void deregisterFromEngineAll();

    const std::string &getTag() const;

    Transform &getTransform();

    std::vector<std::shared_ptr<Entity>> getChildren();

    std::vector<std::shared_ptr<Component>> getComponents();

    glm::mat4 &getWorldMatrix();

    glm::vec3 getPosition();

    glm::vec4 getDirection();

    template<class T>
    inline std::vector<std::shared_ptr<T>> getComponentsByType();

    // TODO BUG cannot find
    template<class T>
    inline std::shared_ptr<T> getComponent();

public:
    static std::vector<Entity *> findByTag(const std::string &tag);

    static void setTag(Entity *entity, const std::string &tag);

public:  // script api
    GUID_t GetGUID() const;

    void AddTag(const std::string &tag);

    Transform *AddTransform();

public:  // event
    static EventSystem::Event<Entity &> s_DestroyedEvent;
    static EventSystem::Event<Entity &> s_CreatedEvent;
    static EventSystem::Event<Entity &, Entity &> s_AttachEvent;
    static EventSystem::Event<Entity &> s_DetachEvent;

private:
    // basic
    std::string m_name{};
    std::string m_tag{};
    GUID_t m_guid{};

    // transform component
    Transform m_transform;

    // parent and children
    Entity *m_parentEntity{};
    std::vector<std::shared_ptr<Entity>> m_children;

    // component
    std::vector<std::shared_ptr<Component>> m_components;
    std::map<std::type_index, std::vector<std::shared_ptr<Component>>> m_componentsByTypeid;

    // computed world matrix
    glm::mat4 m_worldMatrix{};

    // state
    bool m_destroyed = false;
    bool m_sleeping = true;
    bool m_awake = false;
    bool m_started = false;
    bool m_wasActive = false;

public:
    static std::map<std::string, std::vector<Entity *>> s_taggedEntities;
};
}

#include "Core/ECS/Entity.inl"

#endif //ZELOENGINE_ENTITY_H