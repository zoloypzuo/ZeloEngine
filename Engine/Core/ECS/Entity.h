// Entity.h
// created on 2021/3/28
// author @zoloypzuo
#ifndef ZELOENGINE_ENTITY_H
#define ZELOENGINE_ENTITY_H

#include "ZeloPrerequisites.h"
#include "Core/Input/Input.h"  // TODO remove it
#include "Core/Math/Transform.h"
#include "Core/RHI/Resource/Shader.h"

#include "Core/LuaScript/LuaScriptManager.h"

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

    // TODO remove input
    // TODO change delta to float
    virtual void update(Input *input, float delta) {};

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
    explicit Entity(Zelo::GUID_t guid);

    explicit Entity(const std::string &tag);

    Entity();

    ~Entity();

    void addChild(const std::shared_ptr<Entity> &child);

    // NOTE hard to sol::resolve template
    // template<class T>
    // inline void addComponent(std::shared_ptr<T> component) {
    //     component->setParent(this);
    //     componentsByTypeid[typeid(T)].push_back(component);
    //     components.push_back(component);
    // }

    template<class T, class... Types>
    inline T *addComponent(Types &&... _Args) {
        // create component
        auto component = std::make_shared<T>(_Args...);
        component->setParent(this);
        componentsByTypeid[typeid(T)].push_back(std::dynamic_pointer_cast<Component>(component));
        components.push_back(component);

        // bind lua
        auto pComponent = std::dynamic_pointer_cast<Component>(component).get();
        auto &L = Zelo::Core::LuaScript::LuaScriptManager::getSingleton();
        sol::table entityScript = L["Ents"][m_guid];
        entityScript["components"][pComponent->getType()] = pComponent;
        return component.get();
    }

    void updateAll(Input *input, float delta);

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

    // TODO BUG cannot find
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

    static void setTag(Entity *entity, const std::string &tag);

ZELO_SCRIPT_API:

    Zelo::GUID_t GetGUID() const;

    void AddTag(const std::string &tag);

    Transform *AddTransform();

private:
    std::string m_name{};
    std::string m_tag;
    Zelo::GUID_t m_guid{};
    Entity *parentEntity{};
    Transform transform;
    std::vector<std::shared_ptr<Entity>> children;
    std::vector<std::shared_ptr<Component>> components;
    glm::mat4 worldMatrix{};
    std::map<std::type_index, std::vector<std::shared_ptr<Component>>> componentsByTypeid;

public:
    static std::map<std::string, std::vector<Entity *>> taggedEntities;
};

#endif //ZELOENGINE_ENTITY_H