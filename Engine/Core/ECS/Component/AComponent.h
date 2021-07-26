// AComponent.h
// created on 2021/7/27
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"


namespace Zelo::Core::ECS::Component {

class AComponent // : public API::IInspectorItem
{
public:

    AComponent(ECS::Actor& p_owner);


    virtual ~AComponent();


    virtual void OnAwake() {}


    virtual void OnStart() {}


    virtual void OnEnable() {}


    virtual void OnDisable() {}


    virtual void OnDestroy() {}


    virtual void OnUpdate(float p_deltaTime) {}


    virtual void OnFixedUpdate(float p_deltaTime) {}


    virtual void OnLateUpdate(float p_deltaTime) {}


    virtual void OnCollisionEnter(Components::CPhysicalObject& p_otherObject) {}


    virtual void OnCollisionStay(Components::CPhysicalObject& p_otherObject) {}


    virtual void OnCollisionExit(Components::CPhysicalObject& p_otherObject) {}


    virtual void OnTriggerEnter(Components::CPhysicalObject& p_otherObject) {}


    virtual void OnTriggerStay(Components::CPhysicalObject& p_otherObject) {}


    virtual void OnTriggerExit(Components::CPhysicalObject& p_otherObject) {}


    virtual std::string GetName() = 0;

public:
    ECS::Actor& owner;
};
}


