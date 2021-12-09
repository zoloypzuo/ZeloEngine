// Test.h
// created on 2021/8/15
// author @zoloypzuo
#pragma once

#include "Foundation/ZeloStringUtil.h"
#include "Core/LuaScript/LuaScriptManager.h"

namespace Zelo::Core::ECS {
template<class T, class... Args>
inline T *Entity::AddComponent(Args &&... args) {
    static_assert(std::is_base_of<Component, T>::value, "T should derive from Core::ECS::Component");

    // create component
    auto component = std::make_shared<T>(*this, args...);
    m_componentsByTypeid[typeid(T)].push_back(std::dynamic_pointer_cast<Component>(component));
    m_components.push_back(component);

    // bind lua
    auto pComponent = component.get();
    auto &L = Core::LuaScript::LuaScriptManager::getSingleton();
    sol::table entityScript = L["Ents"][m_guid];
    entityScript["components"][Zelo::ToLower(pComponent->getType())] = pComponent;

    // trigger event and callback
    Component &rComponent = *pComponent;
    ComponentAddedEvent.Invoke(rComponent);
    if (IsActive()) {
        rComponent.OnAwake();
        rComponent.OnEnable();
        rComponent.OnStart();
    }

    return pComponent;
}

template<class T>
inline std::vector<std::shared_ptr<T>> Entity::getComponentsByType() {
    auto i = m_componentsByTypeid.find(typeid(T));
    if (i == m_componentsByTypeid.end()) {
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
inline T *Entity::getComponent() {
    static_assert(std::is_base_of<Component, T>::value, "T should derive from Core::ECS::Component");

    auto iterator = m_componentsByTypeid.find(typeid(T));
    if (iterator != m_componentsByTypeid.end() && iterator->second.size() > 0) {
        return std::dynamic_pointer_cast<T>(iterator->second[0]).get();
    } else {
        // fallback to linear search
        for (auto it = m_components.begin(); it != m_components.end(); it++) {
            auto result = std::dynamic_pointer_cast<T>(*it);
            if (result) {
                return result.get();
            }
        }
        return nullptr;
    }
}
}
