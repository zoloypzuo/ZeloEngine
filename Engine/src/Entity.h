// Entity.h
// created on 2021/3/28
// author @zoloypzuo

#ifndef ZELOENGINE_ENTITY_H
#define ZELOENGINE_ENTITY_H

#include "ZeloPrerequisites.h"

#include <vector>
#include <map>
#include <typeindex>
#include <algorithm>
#include <memory>
#include <chrono>

#include "Transform.h"
//#include "Shader.h"
#include "Input.h"

class Engine;

class Component;

class Entity {
public:
    Entity(const std::string &tag);

    Entity();

    ~Entity();

    void addChild(std::shared_ptr<Entity> child);

    template<class T>
    inline void addComponent(std::shared_ptr<T> component) {
        component->setParent(this);
        componentsByTypeid[typeid(T)].push_back(component);
        components.push_back(component);
    }

    template<class T, class... _Types>
    inline void addComponent(_Types &&... _Args) {
        auto component = std::make_shared<T>(_Args...);
        component->setParent(this);
        componentsByTypeid[typeid(T)].push_back(std::dynamic_pointer_cast<Component>(component));
        components.push_back(component);
    }

    void updateAll(Input *input, std::chrono::microseconds delta);

//    void renderAll(Shader *shader) const;
    void registerWithEngineAll(Engine *engine);

    void deregisterFromEngineAll();

    Transform &getTransform();

    std::vector<std::shared_ptr<Entity>> getChildren();

    std::vector<std::shared_ptr<Component>> getComponents();

    glm::mat4 &getWorldMatrix();

    glm::vec3 getPosition();

    glm::vec4 getDirection();

    template<class T>
    inline std::vector<std::shared_ptr<T>> getComponentsByType() {
        auto i = componentsByTypeid.find(typeid(T));
        if (i == componentsByTypeid.end()) {
            return std::vector<std::shared_ptr<T>>();
        } else {
            auto vec = i->second;

            std::vector<std::shared_ptr<T>> target(vec.size());
            std::transform(vec.begin(), vec.end(), target.begin(),
                           [](std::shared_ptr<Component> t) { return std::dynamic_pointer_cast<T>(t); });
            return target;
        }
    }

    template<class T>
    inline std::shared_ptr<T> getComponent() {
        auto i = componentsByTypeid.find(typeid(T));
        if (i == componentsByTypeid.end()) {
            return nullptr;
        } else {
            auto vec = i->second;
            if (vec.size() > 0) {
                return std::dynamic_pointer_cast<T>(vec[0]);
            } else {
                return nullptr;
            }
        }
    }

    static std::vector<Entity *> findByTag(const std::string &tag);

private:
    Transform transform;

    Entity *parentEntity;

    std::vector<std::shared_ptr<Entity>> children;
    std::vector<std::shared_ptr<Component>> components;

    glm::mat4 worldMatrix;

    std::string m_tag;

    Engine *m_engine;

    static void setTag(Entity *entity, const std::string &tag);

    static std::map<std::string, std::vector<Entity *>> taggedEntities;

    std::map<std::type_index, std::vector<std::shared_ptr<Component>>> componentsByTypeid;
};


#endif //ZELOENGINE_ENTITY_H