#include "Core/ECS/Components/AComponent.h"
#include "Core/ECS/Actor.h"

using namespace Zelo::Core::ECS;
using namespace Zelo::Core::ECS::Components;

AComponent::AComponent(Actor &owner) : owner(owner) {
}

AComponent::~AComponent() {
    if (owner.IsActive()) {
        OnDisable();
        OnDestroy();
    }
}
