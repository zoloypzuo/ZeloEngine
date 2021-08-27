// Entity.h
// created on 2021/3/28
// author @zoloypzuo
#ifndef ZELOENGINE_ENTITY_H
#define ZELOENGINE_ENTITY_H

#include "ZeloPrerequisites.h"
#include "Core/Math/Transform.h"
#include "Core/RHI/Resource/Shader.h"
#include "Core/EventSystem/Event.h"

namespace Zelo::Core::ECS {
// TODO 解开Entity和场景图的依赖关系，不要在Entity类里递归，和注册

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
    explicit Component(Entity &owner);

    virtual ~Component();;

    // TODO change delta to float
    virtual void update(float delta) {};

    // TODO remove it
    virtual void render(Shader *shader) {};

    // TODO remove it
    virtual void registerWithEngine() {};

    // TODO remove it
    virtual void deregisterFromEngine() {};

    virtual std::string getType() = 0;

    // region callback
    virtual void OnAwake() {}

    virtual void OnStart() {}

    virtual void OnEnable() {}

    virtual void OnDisable() {}

    virtual void OnDestroy() {}

    virtual void OnUpdate(float deltaTime) {}

    virtual void OnFixedUpdate(float deltaTime) {}

    virtual void OnLateUpdate(float deltaTime) {}

    // region property
    // TODO remove it
    void setProperty(const char *name, PropertyType type, void *p, float min, float max);

    void setProperty(const char *name, PropertyType type, void *p);

    Entity *getOwner() { return &m_owner; }

    Transform &getTransform() const;

    typedef std::map<const char *, Property> PropertyMap;
    PropertyMap m_properties{};

protected:
    Entity &m_owner;
};

class Entity {
public:
    typedef std::vector<std::shared_ptr<Component>> ComponentList;
    typedef std::map<std::type_index, ComponentList> ComponentTypeMap;
    typedef std::vector<std::shared_ptr<Entity>> EntityList;
    typedef std::map<std::string, std::vector<Entity *>> EntityMap;

public:
    explicit Entity(GUID_t guid);

    Entity(const Entity &entity) = delete;

    ~Entity();

public:
#pragma region component management

    template<class T, class... Args>
    ZELO_SCRIPT_API inline T *AddComponent(Args &&... args);

    template<class T>
    inline T *getComponent();

    template<class T>
    inline std::vector<std::shared_ptr<T>> getComponentsByType();

#pragma endregion

    void addChild(const std::shared_ptr<Entity> &child);

    std::shared_ptr<Entity> getChild(int index);

    void SetParent(Entity &parent);

    void DetachFromParent();

    void updateAll(float delta);

    void renderAll(Shader *shader) const;

    void registerWithEngineAll();

    void deregisterFromEngineAll();

    const std::string &getTag() const;

    Transform &getTransform();

    EntityList getChildren();

    glm::mat4 &getWorldMatrix();

    glm::vec3 getPosition();

    glm::vec4 getDirection();

#pragma region state

    void SetActive(bool active);

    bool IsSelfActive() const;

    bool IsActive() const;

    void MarkAsDestroy();

    bool IsDestroyed() const;

    void SetSleeping(bool sleeping);

#pragma endregion

#pragma region callback

    void OnAwake();

    void OnStart();

    void OnEnable();

    void OnDisable();

    void OnDestroy();

    void OnUpdate(float deltaTime);

    void OnFixedUpdate(float deltaTime);

    void OnLateUpdate(float deltaTime);

#pragma endregion

public:
    static std::vector<Entity *> findByTag(const std::string &tag);

public:  // script api
    GUID_t GetGUID() const;

    ZELO_SCRIPT_API void AddTag(const std::string &tag);

    ZELO_SCRIPT_API std::string GetTag() const;

    Transform *AddTransform();

public:  // event
    EventSystem::Event<Component &> ComponentAddedEvent;
    EventSystem::Event<Component &> ComponentRemovedEvent;

    static EventSystem::Event<Entity &> s_DestroyedEvent;
    static EventSystem::Event<Entity &> s_CreatedEvent;
    static EventSystem::Event<Entity &, Entity &> s_AttachEvent;
    static EventSystem::Event<Entity &> s_DetachEvent;

private:
    void RecursiveActiveUpdate();

    void RecursiveWasActiveUpdate();

private:
    // basic
    std::string m_name{};
    std::string m_tag{};
    GUID_t m_guid{};

    // transform component
    Transform m_transform;

    // parent and children
    Entity *m_parent{};
    EntityList m_children;

    // component
    ComponentList m_components;
    ComponentTypeMap m_componentsByTypeid;

    // computed world matrix
    glm::mat4 m_worldMatrix{};

    // state
    bool m_active = true;
    bool m_wasActive = false;
    bool m_destroyed = false;
    bool m_sleeping = true;
    bool m_awake = false;
    bool m_started = false;

public:
    static EntityMap s_taggedEntities;
};
}

#include "Core/ECS/Entity.inl"

#endif //ZELOENGINE_ENTITY_H