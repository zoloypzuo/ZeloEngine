#pragma once

#include <unordered_map>
#include <memory>

#include "Core/Event/Event.h"
#include "Core/Interface/ISerializable.h"

#include "Core/ECS/Components/AComponent.h"
#include "Core/ECS/Components/CTransform.h"
#include "Core/ECS/Components/Behaviour.h"
//#include "Core/API/ISerializable.h"

namespace Zelo::Core::ECS {

class Actor : public Interface::ISerializable {
public:

    Actor(int64_t actorID, const std::string &name, const std::string &tag, bool &playing);


    virtual ~Actor() override;


    const std::string &GetName() const;


    const std::string &GetTag() const;


    void SetName(const std::string &name);


    void SetTag(const std::string &tag);


    void SetActive(bool active);


    bool IsSelfActive() const;


    bool IsActive() const;


    void SetID(int64_t id);


    int64_t GetID() const;


    void SetParent(Actor &parent);


    void DetachFromParent();


    bool HasParent() const;


    Actor *GetParent() const;


    int64_t GetParentID() const;


    std::vector<Actor *> &GetChildren();


    void MarkAsDestroy();


    bool IsAlive() const;


    void SetSleeping(bool sleeping);


    void OnAwake();


    void OnStart();


    void OnEnable();


    void OnDisable();


    void OnDestroy();


    void OnUpdate(float deltaTime);


    void OnFixedUpdate(float deltaTime);


    void OnLateUpdate(float deltaTime);


//    void OnCollisionEnter(Components::CPhysicalObject &otherObject);
//
//
//    void OnCollisionStay(Components::CPhysicalObject &otherObject);
//
//
//    void OnCollisionExit(Components::CPhysicalObject &otherObject);
//
//
//    void OnTriggerEnter(Components::CPhysicalObject &otherObject);
//
//
//    void OnTriggerStay(Components::CPhysicalObject &otherObject);
//
//
//    void OnTriggerExit(Components::CPhysicalObject &otherObject);


    template<typename T, typename ... Args>
    T &AddComponent(Args &&... args);


    template<typename T>
    bool RemoveComponent();


    bool RemoveComponent(Components::AComponent &component);


    template<typename T>
    T *GetComponent();


    std::vector<std::shared_ptr<Components::AComponent>> &GetComponents();


    Components::Behaviour &AddBehaviour(const std::string &name);


    bool RemoveBehaviour(Components::Behaviour &behaviour);


    bool RemoveBehaviour(const std::string &name);


    Components::Behaviour *GetBehaviour(const std::string &name);


    std::unordered_map<std::string, Components::Behaviour> &GetBehaviours();


//    virtual void OnSerialize(tinyxml2::XMLDocument &doc, tinyxml2::XMLNode *actorsRoot) override;


//    virtual void OnDeserialize(tinyxml2::XMLDocument &doc, tinyxml2::XMLNode *actorsRoot) override;

private:

    Actor(const Actor &actor) = delete;

    void RecursiveActiveUpdate();

    void RecursiveWasActiveUpdate();

public:

    Event::Event<Components::AComponent &> ComponentAddedEvent;
    Event::Event<Components::AComponent &> ComponentRemovedEvent;
    Event::Event<Components::Behaviour &> BehaviourAddedEvent;
    Event::Event<Components::Behaviour &> BehaviourRemovedEvent;


    static Event::Event<Actor &> DestroyedEvent;
    static Event::Event<Actor &> CreatedEvent;
    static Event::Event<Actor &, Actor &> AttachEvent;
    static Event::Event<Actor &> DettachEvent;

private:

    std::string m_name;
    std::string m_tag;
    bool m_active = true;
    bool &m_playing;


    int64_t m_actorID;
    bool m_destroyed = false;
    bool m_sleeping = true;
    bool m_awaked = false;
    bool m_started = false;
    bool m_wasActive = false;


    int64_t m_parentID = 0;
    Actor *m_parent = nullptr;
    std::vector<Actor *> m_children;


    std::vector<std::shared_ptr<Components::AComponent>> m_components;
    std::unordered_map<std::string, Components::Behaviour> m_behaviours;

public:
    Components::CTransform &transform;
};
}

#include "Core/ECS/Actor.inl"