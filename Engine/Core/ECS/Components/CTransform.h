#pragma once

#include "Core/ECS/Components/AComponent.h"

namespace Zelo::Core::ECS { class Actor; }

namespace Zelo::Core::ECS::Components {

class CTransform : public AComponent {
public:
    CTransform(ECS::Actor &owner);

    std::string GetName() override;
};
}