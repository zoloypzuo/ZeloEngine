

#include "Core/ECS/Components/AComponent.h"
#include "Core/ECS/Actor.h"

OvCore::ECS::Components::AComponent::AComponent(ECS::Actor& owner) : owner(owner)
{
}

OvCore::ECS::Components::AComponent::~AComponent()
{
	if (owner.IsActive())
	{
		OnDisable();
		OnDestroy();
	}
}
