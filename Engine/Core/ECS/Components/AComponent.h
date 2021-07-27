#pragma once

//#include "Core/API/IInspectorItem.h"
#include "ZeloPrerequisites.h"

namespace Zelo::Core::ECS { class Actor; }

namespace Zelo::Core::ECS::Components {
class CPhysicalObject;


class AComponent /*: public API::IInspectorItem*/ {
public:

    explicit AComponent(ECS::Actor &owner);


    virtual ~AComponent();


    virtual void OnAwake() {}


    virtual void OnStart() {}


    virtual void OnEnable() {}


    virtual void OnDisable() {}


    virtual void OnDestroy() {}


    virtual void OnUpdate(float deltaTime) {}


    virtual void OnFixedUpdate(float deltaTime) {}


    virtual void OnLateUpdate(float deltaTime) {}


//    virtual void OnCollisionEnter(Components::CPhysicalObject &otherObject) {}
//
//
//    virtual void OnCollisionStay(Components::CPhysicalObject &otherObject) {}
//
//
//    virtual void OnCollisionExit(Components::CPhysicalObject &otherObject) {}
//
//
//    virtual void OnTriggerEnter(Components::CPhysicalObject &otherObject) {}
//
//
//    virtual void OnTriggerStay(Components::CPhysicalObject &otherObject) {}
//
//
//    virtual void OnTriggerExit(Components::CPhysicalObject &otherObject) {}


    virtual std::string GetName() = 0;

public:
    ECS::Actor &owner;
};
}