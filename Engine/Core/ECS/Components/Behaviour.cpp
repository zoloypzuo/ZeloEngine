

#include <UI/Widgets/Texts/TextColored.h>
#include <Debug/Utils/Logger.h>

#include "Core/ECS/Actor.h"
#include "Core/ECS/Components/Behaviour.h"
#include "Core/Scripting/LuaBinder.h"

OvTools::Eventing::Event<OvCore::ECS::Components::Behaviour *> OvCore::ECS::Components::Behaviour::CreatedEvent;
OvTools::Eventing::Event<OvCore::ECS::Components::Behaviour *> OvCore::ECS::Components::Behaviour::DestroyedEvent;

OvCore::ECS::Components::Behaviour::Behaviour(ECS::Actor &owner, const std::string &name) :
        name(name), AComponent(owner) {
    CreatedEvent.Invoke(this);
}

OvCore::ECS::Components::Behaviour::~Behaviour() {
    DestroyedEvent.Invoke(this);
}

std::string OvCore::ECS::Components::Behaviour::GetName() {
    return "Behaviour";
}

bool OvCore::ECS::Components::Behaviour::RegisterToLuaContext(sol::state &luaState, const std::string &scriptFolder) {
    using namespace Zelo::Core::Scripting;

    auto result = luaState.safe_script_file(scriptFolder + name + ".lua", &sol::script_pass_on_error);

    if (!result.valid()) {
        sol::error err = result;
        OVLOG_ERROR(err.what());
        return false;
    } else {
        if (result.return_count() == 1 && result[0].is<sol::table>()) {
            m_object = result[0];
            m_object["owner"] = &owner;
            return true;
        } else {
            OVLOG_ERROR(" missing return expression");
            return false;
        }
    }
}

void OvCore::ECS::Components::Behaviour::UnregisterFromLuaContext() {
    m_object = sol::nil;
}

sol::table &OvCore::ECS::Components::Behaviour::GetTable() {
    return m_object;
}

void OvCore::ECS::Components::Behaviour::OnAwake() {
    LuaCall("OnAwake");
}

void OvCore::ECS::Components::Behaviour::OnStart() {
    LuaCall("OnStart");
}

void OvCore::ECS::Components::Behaviour::OnEnable() {
    LuaCall("OnEnable");
}

void OvCore::ECS::Components::Behaviour::OnDisable() {
    LuaCall("OnDisable");
}

void OvCore::ECS::Components::Behaviour::OnDestroy() {
    LuaCall("OnEnd");
    LuaCall("OnDestroy");
}

void OvCore::ECS::Components::Behaviour::OnUpdate(float deltaTime) {
    LuaCall("OnUpdate", deltaTime);
}

void OvCore::ECS::Components::Behaviour::OnFixedUpdate(float deltaTime) {
    LuaCall("OnFixedUpdate", deltaTime);
}

void OvCore::ECS::Components::Behaviour::OnLateUpdate(float deltaTime) {
    LuaCall("OnLateUpdate", deltaTime);
}

void OvCore::ECS::Components::Behaviour::OnCollisionEnter(Components::CPhysicalObject &otherObject) {
    LuaCall("OnCollisionStart", otherObject);
    LuaCall("OnCollisionEnter", otherObject);
}

void OvCore::ECS::Components::Behaviour::OnCollisionStay(Components::CPhysicalObject &otherObject) {
    LuaCall("OnCollisionStay", otherObject);
}

void OvCore::ECS::Components::Behaviour::OnCollisionExit(Components::CPhysicalObject &otherObject) {
    LuaCall("OnCollisionStop", otherObject);
    LuaCall("OnCollisionExit", otherObject);
}

void OvCore::ECS::Components::Behaviour::OnTriggerEnter(Components::CPhysicalObject &otherObject) {
    LuaCall("OnTriggerStart", otherObject);
    LuaCall("OnTriggerEnter", otherObject);
}

void OvCore::ECS::Components::Behaviour::OnTriggerStay(Components::CPhysicalObject &otherObject) {
    LuaCall("OnTriggerStay", otherObject);
}

void OvCore::ECS::Components::Behaviour::OnTriggerExit(Components::CPhysicalObject &otherObject) {
    LuaCall("OnTriggerStop", otherObject);
    LuaCall("OnTriggerExit", otherObject);
}

void OvCore::ECS::Components::Behaviour::OnSerialize(tinyxml2::XMLDocument &doc, tinyxml2::XMLNode *node) {
}

void OvCore::ECS::Components::Behaviour::OnDeserialize(tinyxml2::XMLDocument &doc, tinyxml2::XMLNode *node) {
}

void OvCore::ECS::Components::Behaviour::OnInspector(OvUI::Internal::WidgetContainer &root) {
    using namespace Zelo::Maths;
    using namespace Zelo::Core::Helpers;

    if (m_object.valid()) {
        root.CreateWidget<OvUI::Widgets::Texts::TextColored>("Ready", OvUI::Types::Color::Green);
        root.CreateWidget<OvUI::Widgets::Texts::TextColored>("Your script gets interpreted by the engine with success",
                                                             OvUI::Types::Color::White);
    } else {
        root.CreateWidget<OvUI::Widgets::Texts::TextColored>("Compilation failed!", OvUI::Types::Color::Red);
        root.CreateWidget<OvUI::Widgets::Texts::TextColored>("Check the console for more information",
                                                             OvUI::Types::Color::White);
    }
}
