// Behaviour.h
// created on 2021/7/26
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Core/ECS/Component/AComponent.h"
#include "Core/Event/Event.h"

#include <sol/sol.hpp>

namespace Zelo::Core::ECS { class Actor; }

namespace Zelo::Core::ECS::Component {
// Lua Script Behaviour
// = Unity's MonoBehaviour
class Behaviour : public AComponent {
public:

    Behaviour(Actor &p_owner, const std::string &p_name);


    ~Behaviour();


    virtual std::string GetName() override;


    bool RegisterToLuaContext(sol::state &p_luaState, const std::string &p_scriptFolder);


    void UnregisterFromLuaContext();


    template<typename... Args>
    void LuaCall(const std::string &p_functionName, Args &&... p_args);


    sol::table &GetTable();


    virtual void OnAwake() override;


    virtual void OnStart() override;


    virtual void OnEnable() override;


    virtual void OnDisable() override;


    virtual void OnDestroy() override;


    virtual void OnUpdate(float p_deltaTime) override;


    virtual void OnFixedUpdate(float p_deltaTime) override;


    virtual void OnLateUpdate(float p_deltaTime) override;


//    virtual void OnCollisionEnter(Components::CPhysicalObject &p_otherObject) override;
//
//
//    virtual void OnCollisionStay(Components::CPhysicalObject &p_otherObject) override;
//
//
//    virtual void OnCollisionExit(Components::CPhysicalObject &p_otherObject) override;
//
//
//    virtual void OnTriggerEnter(Components::CPhysicalObject &p_otherObject) override;
//
//
//    virtual void OnTriggerStay(Components::CPhysicalObject &p_otherObject) override;
//
//
//    virtual void OnTriggerExit(Components::CPhysicalObject &p_otherObject) override;
//
//
//    virtual void OnSerialize(tinyxml2::XMLDocument &p_doc, tinyxml2::XMLNode *p_node) override;
//
//
//    virtual void OnDeserialize(tinyxml2::XMLDocument &p_doc, tinyxml2::XMLNode *p_node) override;
//
//
//    virtual void OnInspector(OvUI::Internal::WidgetContainer &p_root) override;

public:
    static Zelo::Core::Event::Event<Behaviour *> CreatedEvent;
    static Zelo::Core::Event::Event<Behaviour *> DestroyedEvent;

    const std::string name;

private:
    sol::table m_object = sol::nil;

};
}

#include "Core/ECS/Component/Behaviour.inl"
