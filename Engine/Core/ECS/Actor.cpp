

#include <algorithm>

#include "Core/ECS/Actor.h"

//#include "Core/ECS/Components/CPhysicalBox.h"
//#include "Core/ECS/Components/CPhysicalSphere.h"
//#include "Core/ECS/Components/CPhysicalCapsule.h"
//#include "Core/ECS/Components/CCamera.h"
//#include "Core/ECS/Components/CModelRenderer.h"
//#include "Core/ECS/Components/CMaterialRenderer.h"
//#include "Core/ECS/Components/CAudioSource.h"
//#include "Core/ECS/Components/CAudioListener.h"
//#include "Core/ECS/Components/CPointLight.h"
//#include "Core/ECS/Components/CDirectionalLight.h"
//#include "Core/ECS/Components/CSpotLight.h"
//#include "Core/ECS/Components/CAmbientBoxLight.h"
//#include "Core/ECS/Components/CAmbientSphereLight.h"

using namespace Zelo::Core;
using namespace Zelo::Core::ECS;

Event::Event<Actor &> Actor::DestroyedEvent;
Event::Event<Actor &> Actor::CreatedEvent;
Event::Event<Actor &, Actor &> Actor::AttachEvent;
Event::Event<Actor &> Actor::DettachEvent;

Actor::Actor(int64_t actorID, const std::string &name, const std::string &tag, bool &playing) :
        m_actorID(actorID),
        m_name(name),
        m_tag(tag),
        m_playing(playing),
        transform(AddComponent<Components::CTransform>()) {
    CreatedEvent.Invoke(*this);
}

Actor::~Actor() {
    if (!m_sleeping) {
        if (IsActive())
            OnDisable();

        if (m_awaked && m_started)
            OnDestroy();
    }

    DestroyedEvent.Invoke(*this);

    std::vector<Actor *> toDetach = m_children;

    for (auto child : toDetach)
        child->DetachFromParent();

    toDetach.clear();

    DetachFromParent();

    std::for_each(m_components.begin(), m_components.end(),
                  [&](std::shared_ptr<Components::AComponent> component) { ComponentRemovedEvent.Invoke(*component); });
    std::for_each(m_behaviours.begin(), m_behaviours.end(),
                  [&](auto &behaviour) { BehaviourRemovedEvent.Invoke(std::ref(behaviour.second)); });
    std::for_each(m_children.begin(), m_children.end(), [](Actor *element) { delete element; });
}

const std::string &Actor::GetName() const {
    return m_name;
}

const std::string &Actor::GetTag() const {
    return m_tag;
}

void Actor::SetName(const std::string &name) {
    m_name = name;
}

void Actor::SetTag(const std::string &tag) {
    m_tag = tag;
}

void Actor::SetActive(bool active) {
    if (active != m_active) {
        RecursiveWasActiveUpdate();
        m_active = active;
        RecursiveActiveUpdate();
    }
}

bool Actor::IsSelfActive() const {
    return m_active;
}

bool Actor::IsActive() const {
    return m_active && (m_parent ? m_parent->IsActive() : true);
}

void Actor::SetID(int64_t id) {
    m_actorID = id;
}

int64_t Actor::GetID() const {
    return m_actorID;
}

void Actor::SetParent(Actor &parent) {
    DetachFromParent();


    m_parent = &parent;
    m_parentID = parent.m_actorID;
//    transform.SetParent(parent.transform);


    parent.m_children.push_back(this);

    AttachEvent.Invoke(*this, parent);
}

void Actor::DetachFromParent() {
    DettachEvent.Invoke(*this);


    if (m_parent) {
        m_parent->m_children.erase(
                std::remove_if(m_parent->m_children.begin(), m_parent->m_children.end(), [this](Actor *element) {
                    return element == this;
                }));
    }

    m_parent = nullptr;
    m_parentID = 0;

//    transform.RemoveParent();
}

bool Actor::HasParent() const {
    return m_parent;
}

Actor *Actor::GetParent() const {
    return m_parent;
}

int64_t Actor::GetParentID() const {
    return m_parentID;
}

std::vector<Actor *> &Actor::GetChildren() {
    return m_children;
}

void Actor::MarkAsDestroy() {
    m_destroyed = true;

    for (auto child : m_children)
        child->MarkAsDestroy();
}

bool Actor::IsAlive() const {
    return !m_destroyed;
}

void Actor::SetSleeping(bool sleeping) {
    m_sleeping = sleeping;
}

void Actor::OnAwake() {
    m_awaked = true;
    std::for_each(m_components.begin(), m_components.end(), [](auto element) { element->OnAwake(); });
    std::for_each(m_behaviours.begin(), m_behaviours.end(), [](auto &element) { element.second.OnAwake(); });
}

void Actor::OnStart() {
    m_started = true;
    std::for_each(m_components.begin(), m_components.end(), [](auto element) { element->OnStart(); });
    std::for_each(m_behaviours.begin(), m_behaviours.end(), [](auto &element) { element.second.OnStart(); });
}

void Actor::OnEnable() {
    std::for_each(m_components.begin(), m_components.end(), [](auto element) { element->OnEnable(); });
    std::for_each(m_behaviours.begin(), m_behaviours.end(), [](auto &element) { element.second.OnEnable(); });
}

void Actor::OnDisable() {
    std::for_each(m_components.begin(), m_components.end(), [](auto element) { element->OnDisable(); });
    std::for_each(m_behaviours.begin(), m_behaviours.end(), [](auto &element) { element.second.OnDisable(); });
}

void Actor::OnDestroy() {
    std::for_each(m_components.begin(), m_components.end(), [](auto element) { element->OnDestroy(); });
    std::for_each(m_behaviours.begin(), m_behaviours.end(), [](auto &element) { element.second.OnDestroy(); });
}

void Actor::OnUpdate(float deltaTime) {
    if (IsActive()) {
        std::for_each(m_components.begin(), m_components.end(), [&](auto element) { element->OnUpdate(deltaTime); });
        std::for_each(m_behaviours.begin(), m_behaviours.end(),
                      [&](auto &element) { element.second.OnUpdate(deltaTime); });
    }
}

void Actor::OnFixedUpdate(float deltaTime) {
    if (IsActive()) {
        std::for_each(m_components.begin(), m_components.end(),
                      [&](auto element) { element->OnFixedUpdate(deltaTime); });
        std::for_each(m_behaviours.begin(), m_behaviours.end(),
                      [&](auto &element) { element.second.OnFixedUpdate(deltaTime); });
    }
}

void Actor::OnLateUpdate(float deltaTime) {
    if (IsActive()) {
        std::for_each(m_components.begin(), m_components.end(),
                      [&](auto element) { element->OnLateUpdate(deltaTime); });
        std::for_each(m_behaviours.begin(), m_behaviours.end(),
                      [&](auto &element) { element.second.OnLateUpdate(deltaTime); });
    }
}

//void Actor::OnCollisionEnter(Components::CPhysicalObject &otherObject) {
//    std::for_each(m_components.begin(), m_components.end(),
//                  [&](auto element) { element->OnCollisionEnter(otherObject); });
//    std::for_each(m_behaviours.begin(), m_behaviours.end(),
//                  [&](auto &element) { element.second.OnCollisionEnter(otherObject); });
//}
//
//void Actor::OnCollisionStay(Components::CPhysicalObject &otherObject) {
//    std::for_each(m_components.begin(), m_components.end(),
//                  [&](auto element) { element->OnCollisionStay(otherObject); });
//    std::for_each(m_behaviours.begin(), m_behaviours.end(),
//                  [&](auto &element) { element.second.OnCollisionStay(otherObject); });
//}
//
//void Actor::OnCollisionExit(Components::CPhysicalObject &otherObject) {
//    std::for_each(m_components.begin(), m_components.end(),
//                  [&](auto element) { element->OnCollisionExit(otherObject); });
//    std::for_each(m_behaviours.begin(), m_behaviours.end(),
//                  [&](auto &element) { element.second.OnCollisionExit(otherObject); });
//}
//
//void Actor::OnTriggerEnter(Components::CPhysicalObject &otherObject) {
//    std::for_each(m_components.begin(), m_components.end(),
//                  [&](auto element) { element->OnTriggerEnter(otherObject); });
//    std::for_each(m_behaviours.begin(), m_behaviours.end(),
//                  [&](auto &element) { element.second.OnTriggerEnter(otherObject); });
//}
//
//void Actor::OnTriggerStay(Components::CPhysicalObject &otherObject) {
//    std::for_each(m_components.begin(), m_components.end(), [&](auto element) { element->OnTriggerStay(otherObject); });
//    std::for_each(m_behaviours.begin(), m_behaviours.end(),
//                  [&](auto &element) { element.second.OnTriggerStay(otherObject); });
//}
//
//void Actor::OnTriggerExit(Components::CPhysicalObject &otherObject) {
//    std::for_each(m_components.begin(), m_components.end(), [&](auto element) { element->OnTriggerExit(otherObject); });
//    std::for_each(m_behaviours.begin(), m_behaviours.end(),
//                  [&](auto &element) { element.second.OnTriggerExit(otherObject); });
//}

bool Actor::RemoveComponent(Components::AComponent &component) {
    for (auto it = m_components.begin(); it != m_components.end(); ++it) {
        if (it->get() == &component) {
            ComponentRemovedEvent.Invoke(component);
            m_components.erase(it);
            return true;
        }
    }

    return false;
}

std::vector<std::shared_ptr<Components::AComponent>> &Actor::GetComponents() {
    return m_components;
}

Components::Behaviour &Actor::AddBehaviour(const std::string &name) {
    m_behaviours.try_emplace(name, *this, name);
    Components::Behaviour &newInstance = m_behaviours.at(name);
    BehaviourAddedEvent.Invoke(newInstance);
    if (m_playing && IsActive()) {
        newInstance.OnAwake();
        newInstance.OnEnable();
        newInstance.OnStart();
    }
    return newInstance;
}

bool Actor::RemoveBehaviour(Components::Behaviour &behaviour) {
    bool found = false;

    for (auto&[name, behaviour] : m_behaviours) {
        if (&behaviour == &behaviour) {
            found = true;
            break;
        }
    }

    if (found)
        return RemoveBehaviour(behaviour.name);
    else
        return false;
}

bool Actor::RemoveBehaviour(const std::string &name) {
    Components::Behaviour *found = GetBehaviour(name);
    if (found) {
        BehaviourRemovedEvent.Invoke(*found);
        return m_behaviours.erase(name);
    } else {
        return false;
    }
}

Components::Behaviour *Actor::GetBehaviour(const std::string &name) {
    if (auto result = m_behaviours.find(name); result != m_behaviours.end())
        return &result->second;
    else
        return nullptr;
}

std::unordered_map<std::string, Components::Behaviour> &Actor::GetBehaviours() {
    return m_behaviours;
}

//void Actor::OnSerialize(tinyxml2::XMLDocument &doc, tinyxml2::XMLNode *actorsRoot) {
//    tinyxml2::XMLNode *actorNode = doc.NewElement("actor");
//    actorsRoot->InsertEndChild(actorNode);
//
//    OvCore::Helpers::Serializer::SerializeString(doc, actorNode, "name", m_name);
//    OvCore::Helpers::Serializer::SerializeString(doc, actorNode, "tag", m_tag);
//    OvCore::Helpers::Serializer::SerializeBoolean(doc, actorNode, "active", m_active);
//    OvCore::Helpers::Serializer::SerializeInt64(doc, actorNode, "id", m_actorID);
//    OvCore::Helpers::Serializer::SerializeInt64(doc, actorNode, "parent", m_parentID);
//
//    tinyxml2::XMLNode *componentsNode = doc.NewElement("components");
//    actorNode->InsertEndChild(componentsNode);
//
//    for (auto &component : m_components) {
//
//        tinyxml2::XMLNode *componentNode = doc.NewElement("component");
//        componentsNode->InsertEndChild(componentNode);
//
//
//        OvCore::Helpers::Serializer::SerializeString(doc, componentNode, "type", typeid(*component).name());
//
//
//        tinyxml2::XMLElement *data = doc.NewElement("data");
//        componentNode->InsertEndChild(data);
//
//
//        component->OnSerialize(doc, data);
//    }
//
//    tinyxml2::XMLNode *behavioursNode = doc.NewElement("behaviours");
//    actorNode->InsertEndChild(behavioursNode);
//
//    for (auto &behaviour : m_behaviours) {
//
//        tinyxml2::XMLNode *behaviourNode = doc.NewElement("behaviour");
//        behavioursNode->InsertEndChild(behaviourNode);
//
//
//        OvCore::Helpers::Serializer::SerializeString(doc, behaviourNode, "type", behaviour.first);
//
//
//        tinyxml2::XMLElement *data = doc.NewElement("data");
//        behaviourNode->InsertEndChild(data);
//
//
//        behaviour.second.OnSerialize(doc, data);
//    }
//}
//
//void Actor::OnDeserialize(tinyxml2::XMLDocument &doc, tinyxml2::XMLNode *actorsRoot) {
//    OvCore::Helpers::Serializer::DeserializeString(doc, actorsRoot, "name", m_name);
//    OvCore::Helpers::Serializer::DeserializeString(doc, actorsRoot, "tag", m_tag);
//    OvCore::Helpers::Serializer::DeserializeBoolean(doc, actorsRoot, "active", m_active);
//    OvCore::Helpers::Serializer::DeserializeInt64(doc, actorsRoot, "id", m_actorID);
//    OvCore::Helpers::Serializer::DeserializeInt64(doc, actorsRoot, "parent", m_parentID);
//
//    {
//        tinyxml2::XMLNode *componentsRoot = actorsRoot->FirstChildElement("components");
//        if (componentsRoot) {
//            tinyxml2::XMLElement *currentComponent = componentsRoot->FirstChildElement("component");
//
//            while (currentComponent) {
//                std::string componentType = currentComponent->FirstChildElement("type")->GetText();
//                Components::AComponent *component = nullptr;
//
//                if (componentType == typeid(Components::CTransform).name()) component = &transform;
//                else if (componentType == typeid(Components::CPhysicalBox).name())
//                    component = &AddComponent<Components::CPhysicalBox>();
//                else if (componentType == typeid(Components::CPhysicalSphere).name())
//                    component = &AddComponent<Components::CPhysicalSphere>();
//                else if (componentType == typeid(Components::CPhysicalCapsule).name())
//                    component = &AddComponent<Components::CPhysicalCapsule>();
//                else if (componentType == typeid(Components::CModelRenderer).name())
//                    component = &AddComponent<Components::CModelRenderer>();
//                else if (componentType == typeid(Components::CCamera).name())
//                    component = &AddComponent<Components::CCamera>();
//                else if (componentType == typeid(Components::CMaterialRenderer).name())
//                    component = &AddComponent<Components::CMaterialRenderer>();
//                else if (componentType == typeid(Components::CAudioSource).name())
//                    component = &AddComponent<Components::CAudioSource>();
//                else if (componentType == typeid(Components::CAudioListener).name())
//                    component = &AddComponent<Components::CAudioListener>();
//                else if (componentType == typeid(Components::CPointLight).name())
//                    component = &AddComponent<Components::CPointLight>();
//                else if (componentType == typeid(Components::CDirectionalLight).name())
//                    component = &AddComponent<Components::CDirectionalLight>();
//                else if (componentType == typeid(Components::CSpotLight).name())
//                    component = &AddComponent<Components::CSpotLight>();
//                else if (componentType == typeid(Components::CAmbientBoxLight).name())
//                    component = &AddComponent<Components::CAmbientBoxLight>();
//                else if (componentType == typeid(Components::CAmbientSphereLight).name())
//                    component = &AddComponent<Components::CAmbientSphereLight>();
//
//                if (component)
//                    component->OnDeserialize(doc, currentComponent->FirstChildElement("data"));
//
//                currentComponent = currentComponent->NextSiblingElement("component");
//            }
//        }
//    }
//
//    {
//        tinyxml2::XMLNode *behavioursRoot = actorsRoot->FirstChildElement("behaviours");
//
//        if (behavioursRoot) {
//            tinyxml2::XMLElement *currentBehaviour = behavioursRoot->FirstChildElement("behaviour");
//
//            while (currentBehaviour) {
//                std::string behaviourType = currentBehaviour->FirstChildElement("type")->GetText();
//
//                auto &behaviour = AddBehaviour(behaviourType);
//                behaviour.OnDeserialize(doc, currentBehaviour->FirstChildElement("data"));
//
//                currentBehaviour = currentBehaviour->NextSiblingElement("behaviour");
//            }
//        }
//    }
//}

void Actor::RecursiveActiveUpdate() {
    bool isActive = IsActive();

    if (!m_sleeping) {
        if (!m_wasActive && isActive) {
            if (!m_awaked)
                OnAwake();

            OnEnable();

            if (!m_started)
                OnStart();
        }

        if (m_wasActive && !isActive)
            OnDisable();
    }

    for (auto child : m_children)
        child->RecursiveActiveUpdate();
}

void Actor::RecursiveWasActiveUpdate() {
    m_wasActive = IsActive();
    for (auto child : m_children)
        child->RecursiveWasActiveUpdate();
}
