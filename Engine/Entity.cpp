// Entity.cpp
// created on 2021/3/28
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Entity.h"
#include "Component.h"

std::map<std::string, std::vector<Entity *>> Entity::taggedEntities;

Entity::Entity(const std::string &tag) {
    Entity::setTag(this, tag);

    m_tag = tag;
    parentEntity = nullptr;
}

Entity::Entity() {
    parentEntity = nullptr;
}

Entity::~Entity() {
    if (!m_tag.empty()) {
        auto taggedEntitiesVec = &Entity::taggedEntities[m_tag];
        taggedEntitiesVec->erase(std::remove(taggedEntitiesVec->begin(), taggedEntitiesVec->end(), this),
                                 taggedEntitiesVec->end());
    }
}

void Entity::setTag(Entity *entity, const std::string &tag) {
    Entity::taggedEntities[tag].push_back(entity);
}

std::vector<Entity *> Entity::findByTag(const std::string &tag) {
    return Entity::taggedEntities[tag];
}

void Entity::addChild(std::shared_ptr<Entity> child) {
    child->parentEntity = this;
    children.push_back(child);

    // FIXME: IF MOVING ENTITY TO ANOTHER ENTITY THIS WILL BE AN ISSUE AS WE WILL REREGISTER
    if (m_engine) {
//        child->registerWithEngineAll(m_engine);
    }
}

void Entity::updateAll(Input *input, std::chrono::microseconds delta) {
    if (parentEntity == nullptr) {
        worldMatrix = transform.getTransformMatrix();
    } else {
        worldMatrix = parentEntity->worldMatrix * transform.getTransformMatrix();
    }

    for (const auto& component : components) {
        component->update(input, delta);
    }

    for (const auto& child : children) {
        child->updateAll(input, delta);
    }
}

//void Entity::renderAll(Shader *shader) const {
//    for (auto component : components) {
//        component->render(shader);
//    }
//
//    for (auto child : children) {
//        child->renderAll(shader);
//    }
//}
//
//void Entity::registerWithEngineAll(Engine *engine) {
//    m_engine = engine;
//
//    for (auto component : components) {
//        component->registerWithEngine(engine);
//    }
//
//    for (auto child : children) {
//        child->registerWithEngineAll(engine);
//    }
//}
//
//void Entity::deregisterFromEngineAll() {
//    for (auto component : components) {
//        component->deregisterFromEngine(m_engine);
//    }
//
//    for (auto child : children) {
//        child->deregisterFromEngineAll();
//    }
//
//    m_engine = nullptr;
//}

Transform &Entity::getTransform() {
    return transform;
}

std::vector<std::shared_ptr<Entity>> Entity::getChildren() {
    return children;
}

std::vector<std::shared_ptr<Component>> Entity::getComponents() {
    return components;
}

glm::mat4 &Entity::getWorldMatrix() {
    return worldMatrix;
}

glm::vec3 Entity::getPosition() {
    if (parentEntity == nullptr) {
        return transform.getPosition();
    } else {
        auto pos = transform.getPosition();
        return (parentEntity->worldMatrix * glm::vec4(pos.x, pos.y, pos.z, 1));
    }
}

glm::vec4 Entity::getDirection() {
    if (parentEntity == nullptr) {
        return transform.getDirection();
    } else {
        return glm::normalize(parentEntity->worldMatrix * transform.getDirection());
    }
}
