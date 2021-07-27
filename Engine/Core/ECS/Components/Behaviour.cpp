#include "ZeloPreCompiledHeader.h"
//#include <UI/Widgets/Texts/TextColored.h>
//#include <Debug/Utils/Logger.h>

#include "Core/ECS/Actor.h"
#include "Core/ECS/Components/Behaviour.h"
//#include "Core/Scripting/LuaBinder.h"

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

//void Behaviour::OnCollisionEnter(Components::CPhysicalObject &otherObject) {
//    LuaCall("OnCollisionStart", otherObject);
//    LuaCall("OnCollisionEnter", otherObject);
//}
//
//void Behaviour::OnCollisionStay(Components::CPhysicalObject &otherObject) {
//    LuaCall("OnCollisionStay", otherObject);
//}
//
//void Behaviour::OnCollisionExit(Components::CPhysicalObject &otherObject) {
//    LuaCall("OnCollisionStop", otherObject);
//    LuaCall("OnCollisionExit", otherObject);
//}
//
//void Behaviour::OnTriggerEnter(Components::CPhysicalObject &otherObject) {
//    LuaCall("OnTriggerStart", otherObject);
//    LuaCall("OnTriggerEnter", otherObject);
//}
//
//void Behaviour::OnTriggerStay(Components::CPhysicalObject &otherObject) {
//    LuaCall("OnTriggerStay", otherObject);
//}
//
//void Behaviour::OnTriggerExit(Components::CPhysicalObject &otherObject) {
//    LuaCall("OnTriggerStop", otherObject);
//    LuaCall("OnTriggerExit", otherObject);
//}

//void Behaviour::OnSerialize(tinyxml2::XMLDocument &doc, tinyxml2::XMLNode *node) {
//}
//
//void Behaviour::OnDeserialize(tinyxml2::XMLDocument &doc, tinyxml2::XMLNode *node) {
//}

//void Behaviour::OnInspector(OvUI::Internal::WidgetContainer &root) {
//    using namespace Zelo::Maths;
//    using namespace Zelo::Core::Helpers;
//
//    if (m_object.valid()) {
//        root.CreateWidget<OvUI::Widgets::Texts::TextColored>("Ready", OvUI::Types::Color::Green);
//        root.CreateWidget<OvUI::Widgets::Texts::TextColored>("Your script gets interpreted by the engine with success",
//                                                             OvUI::Types::Color::White);
//    } else {
//        root.CreateWidget<OvUI::Widgets::Texts::TextColored>("Compilation failed!", OvUI::Types::Color::Red);
//        root.CreateWidget<OvUI::Widgets::Texts::TextColored>("Check the console for more information",
//                                                             OvUI::Types::Color::White);
//    }
//}
