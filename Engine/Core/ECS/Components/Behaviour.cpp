#include "ZeloPreCompiledHeader.h"
#include "Core/ECS/Components/Behaviour.h"
#include "Core/ECS/Actor.h"
#include "Core/Resource/ResourceManager.h"

using namespace Zelo::Core;
using namespace Zelo::Core::ECS;
using namespace Zelo::Core::ECS::Components;
using namespace Zelo::Core::Resource;

EventSystem::Event<Behaviour *> Behaviour::s_CreatedEvent;
EventSystem::Event<Behaviour *> Behaviour::s_DestroyedEvent;

Behaviour::Behaviour(ECS::Actor &owner, const std::string &name) :
        name(name), AComponent(owner) {
    s_CreatedEvent.Invoke(this);
}

Behaviour::~Behaviour() {
    s_DestroyedEvent.Invoke(this);
}

std::string Behaviour::GetName() {
    return "Behaviour";
}

bool Behaviour::RegisterToLuaContext(sol::state &luaState) {
    auto scriptFolder = ResourceManager::getSingletonPtr()->getScriptDir();
    const auto &scriptPath = scriptFolder / name / ".lua";
    auto result = luaState.safe_script_file(scriptPath.string(), &sol::script_pass_on_error);

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
