// Test.h
// created on 2021/8/15
// author @zoloypzuo
#pragma once

template<class T, class... Types>
inline T *Entity::addComponent(Types &&... Args) {
    // create component
    auto component = std::make_shared<T>(Args...);
    component->setParent(this);
    m_componentsByTypeid[typeid(T)].push_back(std::dynamic_pointer_cast<Component>(component));
    m_components.push_back(component);

    // bind lua
    auto pComponent = std::dynamic_pointer_cast<Component>(component).get();
    auto &L = Zelo::Core::LuaScript::LuaScriptManager::getSingleton();
    sol::table entityScript = L["Ents"][m_guid];
    entityScript["m_components"][pComponent->getType()] = pComponent;
    return component.get();
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
inline std::shared_ptr<T> Entity::getComponent() {
    auto i = m_componentsByTypeid.find(typeid(T));
    if (i == m_componentsByTypeid.end()) {
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