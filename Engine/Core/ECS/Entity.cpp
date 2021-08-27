// Entity.cpp
// created on 2021/3/28
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Entity.h"

using namespace Zelo::Core::LuaScript;
using namespace Zelo::Core::ECS;
using namespace Zelo::Core::EventSystem;

Entity::EntityMap Entity::s_taggedEntities;

Event<Entity &> Entity::s_DestroyedEvent;
Event<Entity &> Entity::s_CreatedEvent;
Event<Entity &, Entity &> Entity::s_AttachEvent;
Event<Entity &> Entity::s_DetachEvent;

Entity::Entity(Zelo::GUID_t guid) : m_guid(guid) {
    s_CreatedEvent.Invoke(*this);
}

Entity::~Entity() {
    // trigger entity callback
    if (!m_sleeping) {
        if (IsActive())
            OnDisable();

        if (m_awake && m_started)
            OnDestroy();
    }

    // trigger global event
    s_DestroyedEvent.Invoke(*this);

    // trigger component remove event
    std::for_each(m_components.begin(), m_components.end(),
                  [&](const std::shared_ptr<Component> &component) { ComponentRemovedEvent.Invoke(*component); });

    // cleanup component map
    if (!m_tag.empty()) {
        auto *taggedEntitiesVec = &Entity::s_taggedEntities[m_tag];
        taggedEntitiesVec->erase(std::remove(taggedEntitiesVec->begin(), taggedEntitiesVec->end(), this),
                                 taggedEntitiesVec->end());
    }
}

std::vector<Entity *> Entity::findByTag(const std::string &tag) {
    return Entity::s_taggedEntities[tag];
}


void Entity::updateAll(float delta) {
    if (m_parent == nullptr) {
        m_worldMatrix = m_transform.getTransformMatrix();
    } else {
        m_worldMatrix = m_parent->m_worldMatrix * m_transform.getTransformMatrix();
    }

    for (const auto &component : m_components) {
        component->update(delta);
    }

    for (const auto &child : m_children) {
        child->updateAll(delta);
    }
}

void Entity::renderAll(Shader *shader) const {
    for (const auto &component : m_components) {
        component->render(shader);
    }

    for (const auto &child : m_children) {
        child->renderAll(shader);
    }
}

void Entity::registerWithEngineAll() {

    for (const auto &component : m_components) {
        component->registerWithEngine();
    }

    for (const auto &child : m_children) {
        child->registerWithEngineAll();
    }
}

void Entity::deregisterFromEngineAll() {
    for (const auto &component : m_components) {
        component->deregisterFromEngine();
    }

    for (const auto &child : m_children) {
        child->deregisterFromEngineAll();
    }
}

Transform &Entity::getTransform() {
    return m_transform;
}

std::vector<std::shared_ptr<Entity>> Entity::getChildren() {
    return m_children;
}

glm::mat4 &Entity::getWorldMatrix() {
    return m_worldMatrix;
}

glm::vec3 Entity::getPosition() {
    if (m_parent == nullptr) {
        return m_transform.getPosition();
    } else {
        auto pos = m_transform.getPosition();
        return (m_parent->m_worldMatrix * glm::vec4(pos.x, pos.y, pos.z, 1));
    }
}

glm::vec4 Entity::getDirection() {
    if (m_parent == nullptr) {
        return m_transform.getDirection();
    } else {
        return glm::normalize(m_parent->m_worldMatrix * m_transform.getDirection());
    }
}

Zelo::GUID_t Entity::GetGUID() const {
    return m_guid;
}

const std::string &Entity::getTag() const {
    return m_tag;
}

void Entity::AddTag(const std::string &tag) {
    m_tag = tag;
    s_taggedEntities[tag].push_back(this);
}

std::string Entity::GetTag() const { return m_tag; }

Transform *Entity::AddTransform() {
    auto &L = LuaScriptManager::getSingleton();
    sol::table entityScript = L["Ents"][m_guid];
    entityScript["components"]["transform"] = &m_transform;
    return &m_transform;
}

Transform &Component::getTransform() const {
    return m_owner.getTransform();
}

void Component::setProperty(const char *name, PropertyType type, void *p, float min, float max) {
    Property prop{};

    prop.type = type;
    prop.p = p;
    prop.min = min;
    prop.max = max;

    m_properties[name] = prop;
}

void Component::setProperty(const char *name, PropertyType type, void *p) {
    Property prop{};

    prop.type = type;
    prop.p = p;

    m_properties[name] = prop;
}


Component::Component(Entity &owner) : m_owner(owner) {

}

Component::~Component() {
    if (m_owner.IsActive()) {
        OnDisable();
        OnDestroy();
    }
}


void Entity::SetActive(bool active) {
    if (active != m_active) {
        RecursiveWasActiveUpdate();
        m_active = active;
        RecursiveActiveUpdate();
    }
}

bool Entity::IsSelfActive() const {
    return m_active;
}

bool Entity::IsActive() const {
    return m_active && (m_parent ? m_parent->IsActive() : true);
}

void Entity::RecursiveActiveUpdate() {
    bool isActive = IsActive();

    if (!m_sleeping) {
        if (!m_wasActive && isActive) {
            if (!m_awake)
                OnAwake();

            OnEnable();

            if (!m_started)
                OnStart();
        }

        if (m_wasActive && !isActive)
            OnDisable();
    }

    for (const auto &child : m_children)
        child->RecursiveActiveUpdate();
}

void Entity::RecursiveWasActiveUpdate() {
    m_wasActive = IsActive();
    for (const auto &child : m_children)
        child->RecursiveWasActiveUpdate();
}

void Entity::OnAwake() {
    m_awake = true;
    std::for_each(m_components.begin(), m_components.end(), [](auto element) { element->OnAwake(); });
}

void Entity::OnStart() {
    m_started = true;
    std::for_each(m_components.begin(), m_components.end(), [](auto element) { element->OnStart(); });
}

void Entity::OnEnable() {
    std::for_each(m_components.begin(), m_components.end(), [](auto element) { element->OnEnable(); });
}

void Entity::OnDisable() {
    std::for_each(m_components.begin(), m_components.end(), [](auto element) { element->OnDisable(); });
}

void Entity::OnDestroy() {
    std::for_each(m_components.begin(), m_components.end(), [](auto element) { element->OnDestroy(); });
}

void Entity::OnUpdate(float deltaTime) {
    if (IsActive()) {
        std::for_each(m_components.begin(), m_components.end(), [&](auto element) { element->OnUpdate(deltaTime); });
    }
}

void Entity::OnFixedUpdate(float deltaTime) {
    if (IsActive()) {
        std::for_each(m_components.begin(), m_components.end(),
                      [&](auto element) { element->OnFixedUpdate(deltaTime); });
    }
}

void Entity::OnLateUpdate(float deltaTime) {
    if (IsActive()) {
        std::for_each(m_components.begin(), m_components.end(),
                      [&](auto element) { element->OnLateUpdate(deltaTime); });
    }
}

void Entity::MarkAsDestroy() {
    m_destroyed = true;

    for (const auto &child : m_children)
        child->MarkAsDestroy();
}

bool Entity::IsDestroyed() const { return m_destroyed; }

void Entity::SetSleeping(bool sleeping) {
    m_sleeping = sleeping;
}

void Entity::addChild(const std::shared_ptr<Entity> &child) {
    child->m_parent = this;
    m_children.push_back(child);

    // FIXME: IF MOVING ENTITY TO ANOTHER ENTITY THIS WILL BE AN ISSUE AS WE WILL REREGISTER
    child->registerWithEngineAll();
}

void Entity::SetParent(Entity &parent) {
    s_DetachEvent.Invoke(*this);

    ZELO_ASSERT(m_parent);
    auto result = std::find_if(
            m_parent->m_children.begin(), m_parent->m_children.end(),
            [this](const std::shared_ptr<Entity> &element) {
                return element.get() == this;
            });
    ZELO_ASSERT(result != m_parent->m_children.end());

    parent.addChild(*result);

    s_AttachEvent.Invoke(*this, parent);
}

void Entity::DetachFromParent() {
    s_DetachEvent.Invoke(*this);

    ZELO_ASSERT(m_parent);
    const auto &result = std::remove_if(
            m_parent->m_children.begin(), m_parent->m_children.end(),
            [this](const std::shared_ptr<Entity> &element) {
                return element.get() == this;
            });
    ZELO_ASSERT(result != m_parent->m_children.end());

    m_parent->m_children.erase(m_parent->m_children.begin(), result);

    m_parent = nullptr;
}

std::shared_ptr<Entity> Entity::getChild(int index) {
    return m_children[index];
}

