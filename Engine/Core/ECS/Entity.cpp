// Entity.cpp
// created on 2021/3/28
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Entity.h"

#include "Core/LuaScript/LuaScriptManager.h"
#include <sol/sol.hpp>

using namespace Zelo::Core::LuaScript;

std::map<std::string, std::vector<Entity *>> Entity::s_taggedEntities;

Entity::Entity(Zelo::GUID_t guid) : m_guid(guid) {
}

Entity::Entity(const std::string &tag) {
    Entity::setTag(this, tag);

    m_tag = tag;
    m_parentEntity = nullptr;
}

Entity::Entity() {
    m_parentEntity = nullptr;
}

Entity::~Entity() {
    if (!m_tag.empty()) {
        auto *taggedEntitiesVec = &Entity::s_taggedEntities[m_tag];
        taggedEntitiesVec->erase(std::remove(taggedEntitiesVec->begin(), taggedEntitiesVec->end(), this),
                                 taggedEntitiesVec->end());
    }
}

void Entity::setTag(Entity *entity, const std::string &tag) {
    entity->m_tag = tag;
    Entity::s_taggedEntities[tag].push_back(entity);
}

std::vector<Entity *> Entity::findByTag(const std::string &tag) {
    return Entity::s_taggedEntities[tag];
}

void Entity::addChild(const std::shared_ptr<Entity> &child) {
    child->m_parentEntity = this;
    m_children.push_back(child);

    // FIXME: IF MOVING ENTITY TO ANOTHER ENTITY THIS WILL BE AN ISSUE AS WE WILL REREGISTER
    child->registerWithEngineAll();
}

void Entity::updateAll(Input *input, float delta) {
    if (m_parentEntity == nullptr) {
        m_worldMatrix = m_transform.getTransformMatrix();
    } else {
        m_worldMatrix = m_parentEntity->m_worldMatrix * m_transform.getTransformMatrix();
    }

    for (const auto &component : m_components) {
        component->update(input, delta);
    }

    for (const auto &child : m_children) {
        child->updateAll(input, delta);
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

std::vector<std::shared_ptr<Component>> Entity::getComponents() {
    return m_components;
}

glm::mat4 &Entity::getWorldMatrix() {
    return m_worldMatrix;
}

glm::vec3 Entity::getPosition() {
    if (m_parentEntity == nullptr) {
        return m_transform.getPosition();
    } else {
        auto pos = m_transform.getPosition();
        return (m_parentEntity->m_worldMatrix * glm::vec4(pos.x, pos.y, pos.z, 1));
    }
}

glm::vec4 Entity::getDirection() {
    if (m_parentEntity == nullptr) {
        return m_transform.getDirection();
    } else {
        return glm::normalize(m_parentEntity->m_worldMatrix * m_transform.getDirection());
    }
}

Zelo::GUID_t Entity::GetGUID() const {
    return m_guid;
}

const std::string &Entity::getTag() const {
    return m_tag;
}

void Entity::AddTag(const std::string &tag) {
    setTag(this, tag);
}

Transform *Entity::AddTransform() {
    auto &L = LuaScriptManager::getSingleton();
    sol::table entityScript = L["Ents"][m_guid];
    entityScript["m_components"]["m_transform"] = &m_transform;
    return &m_transform;
}

void Component::setParent(Entity *parentEntity) {
    m_parentEntity = parentEntity;
}

Entity *Component::getParent() const {
    return m_parentEntity;
}

Transform &Component::getTransform() const {
    return m_parentEntity->getTransform();
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
