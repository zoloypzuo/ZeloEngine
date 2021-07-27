#include "ZeloPreCompiledHeader.h"
#include "Core/ECS/Actor.h"

using namespace Zelo::Core;
using namespace Zelo::Core::ECS;

EventSystem::Event<Actor &> Actor::DestroyedEvent;
EventSystem::Event<Actor &> Actor::CreatedEvent;
EventSystem::Event<Actor &, Actor &> Actor::AttachEvent;
EventSystem::Event<Actor &> Actor::DetachEvent;

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

        if (m_awake && m_started)
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
    DetachEvent.Invoke(*this);

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
    m_awake = true;
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

void Actor::RecursiveActiveUpdate() {
    bool isActive = IsActive();

    if (!m_sleeping) {
        if (!m_wasActive && isActive) {
            if (!m_awake)
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
