#include "ZeloPreCompiledHeader.h"
#include "Core/ECS/Components/CTransform.h"
#include "Core/ECS/Actor.h"

using namespace Zelo::Core::ECS::Components;

std::string CTransform::GetName() {
    return "Transform";
}

CTransform::CTransform(Zelo::Core::ECS::Actor &owner) : AComponent(owner) {
}