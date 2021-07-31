#pragma once

#include "ZeloPrerequisites.h"
#include "Core/ECS/Components/AComponent.h"
#include "Core/EventSystem/Event.h"
#include <sol/sol.hpp>

namespace Zelo::Core::ECS { class Actor; }

namespace Zelo::Core::ECS::Components {

class Behaviour : public AComponent {
public:

    Behaviour(ECS::Actor &owner, const std::string &name);

    ~Behaviour() override;

    std::string GetName() override;

    bool RegisterToLuaContext(sol::state &luaState);

    void UnregisterFromLuaContext();

    template<typename... Args>
    void LuaCall(const std::string &functionName, Args &&... args);

    sol::table &GetTable();

    void OnAwake() override;

    void OnStart() override;

    void OnEnable() override;

    void OnDisable() override;

    void OnDestroy() override;

    void OnUpdate(float deltaTime) override;

    void OnFixedUpdate(float deltaTime) override;

    void OnLateUpdate(float deltaTime) override;

public:
    static EventSystem::Event<Behaviour *> s_CreatedEvent;
    static EventSystem::Event<Behaviour *> s_DestroyedEvent;

    const std::string name;

private:
    sol::table m_object = sol::nil;
};
}

#include "Core/ECS/Components/Behaviour.inl"
