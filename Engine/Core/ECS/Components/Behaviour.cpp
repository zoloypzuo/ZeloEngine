#include "ZeloPreCompiledHeader.h"
#include "Core/ECS/Components/Behaviour.h"

using namespace Zelo::Core;
using namespace Zelo::Core::ECS;
using namespace Zelo::Core::ECS::Components;

EventSystem::Event<Behaviour *> Behaviour::CreatedEvent;
EventSystem::Event<Behaviour *> Behaviour::DestroyedEvent;

Behaviour::Behaviour(ECS::Actor &owner, const std::string &name) :
        name(name), AComponent(owner) {
    CreatedEvent.Invoke(this);
}

Behaviour::~Behaviour() {
    DestroyedEvent.Invoke(this);
}

std::string Behaviour::GetName() {
    return "Behaviour";
}

bool Behaviour::RegisterToLuaContext(sol::state &luaState, const std::string &scriptFolder) {

    auto result = luaState.safe_script_file(scriptFolder + name + ".lua", &sol::script_pass_on_error);

    if (!result.valid()) {
        sol::error err = result;
        ZELO_CORE_ERROR(err.what());
        return false;
    } else {
        if (result.return_count() == 1 && result[0].is<sol::table>()) {
            m_object = result[0];
            m_object["owner"] = &owner;
            return true;
        } else {
            ZELO_CORE_ERROR(" missing return expression");
            return false;
        }
    }
}

void Behaviour::UnregisterFromLuaContext() {
    m_object = sol::nil;
}

sol::table &Behaviour::GetTable() {
    return m_object;
}

void Behaviour::OnAwake() {
    LuaCall("OnAwake");
}

void Behaviour::OnStart() {
    LuaCall("OnStart");
}

void Behaviour::OnEnable() {
    LuaCall("OnEnable");
}

void Behaviour::OnDisable() {
    LuaCall("OnDisable");
}

void Behaviour::OnDestroy() {
    LuaCall("OnEnd");
    LuaCall("OnDestroy");
}

void Behaviour::OnUpdate(float deltaTime) {
    LuaCall("OnUpdate", deltaTime);
}

void Behaviour::OnFixedUpdate(float deltaTime) {
    LuaCall("OnFixedUpdate", deltaTime);
}

void Behaviour::OnLateUpdate(float deltaTime) {
    LuaCall("OnLateUpdate", deltaTime);
}
