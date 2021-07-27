#pragma once

#include <sol/sol.hpp>

//#include "Core/ECS/Components/CPhysicalObject.h"

namespace Zelo::Core::ECS { class Actor; }

namespace Zelo::Core::ECS::Components {

class Behaviour : public AComponent {
public:

    Behaviour(ECS::Actor &owner, const std::string &name);


    ~Behaviour();


    virtual std::string GetName() override;


    bool RegisterToLuaContext(sol::state &luaState, const std::string &scriptFolder);


    void UnregisterFromLuaContext();


    template<typename... Args>
    void LuaCall(const std::string &functionName, Args &&... args);


    sol::table &GetTable();


    virtual void OnAwake() override;


    virtual void OnStart() override;


    virtual void OnEnable() override;


    virtual void OnDisable() override;


    virtual void OnDestroy() override;


    virtual void OnUpdate(float deltaTime) override;


    virtual void OnFixedUpdate(float deltaTime) override;


    virtual void OnLateUpdate(float deltaTime) override;


    virtual void OnCollisionEnter(Components::CPhysicalObject &otherObject) override;


    virtual void OnCollisionStay(Components::CPhysicalObject &otherObject) override;


    virtual void OnCollisionExit(Components::CPhysicalObject &otherObject) override;


    virtual void OnTriggerEnter(Components::CPhysicalObject &otherObject) override;


    virtual void OnTriggerStay(Components::CPhysicalObject &otherObject) override;


    virtual void OnTriggerExit(Components::CPhysicalObject &otherObject) override;


//    virtual void OnSerialize(tinyxml2::XMLDocument &doc, tinyxml2::XMLNode *node) override;
//
//
//    virtual void OnDeserialize(tinyxml2::XMLDocument &doc, tinyxml2::XMLNode *node) override;
//
//
//    virtual void OnInspector(OvUI::Internal::WidgetContainer &root) override;

public:
    static Event::Event<Behaviour *> CreatedEvent;
    static Event::Event<Behaviour *> DestroyedEvent;

    const std::string name;

private:
    sol::table m_object = sol::nil;
};
}

#include "Core/ECS/Components/Behaviour.inl"