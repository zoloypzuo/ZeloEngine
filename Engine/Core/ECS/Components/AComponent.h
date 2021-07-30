#pragma once

#include "ZeloPrerequisites.h"

namespace Zelo::Core::ECS { class Actor; }

namespace Zelo::Core::ECS::Components {
class CPhysicalObject;

class AComponent {
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

    virtual std::string GetName() = 0;

public:
    ECS::Actor &owner;
};
}