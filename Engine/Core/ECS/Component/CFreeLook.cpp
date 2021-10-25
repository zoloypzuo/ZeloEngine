//
// Created by zuoyiping01 on 2021/3/31.
//
#include "ZeloPreCompiledHeader.h"
#include "CFreeLook.h"
#include "Core/Input/Input.h"

using namespace Zelo::Core::ECS;

CFreeLook::CFreeLook(Entity &owner) : Component(owner) {
    setProperty("speed", PropertyType::FLOAT, &m_speed, 0, 5);
    setProperty("look", PropertyType::BOOLEAN, &m_look);
}

CFreeLook::~CFreeLook() = default;

void CFreeLook::registerWithEngine() {
    auto *input = Input::getSingletonPtr();

    input->registerButtonToAction(SDL_BUTTON_RIGHT, "look");

    input->bindAction("look", IE_PRESSED, [this]() {
        m_look = true;
    });
    input->bindAction("look", IE_RELEASED, [this]() {
        m_look = false;
    });
}

void CFreeLook::deregisterFromEngine() {
    auto *input = Input::getSingletonPtr();

    input->unbindAction("look");
}

void CFreeLook::update(float delta) {
    auto *input = Input::getSingletonPtr();
    float moveAmount = m_speed * delta;

    if (m_look) {
        input->grabMouse();
        glm::vec2 pos = input->getMouseDelta();
        if (pos.y != 0) {
            m_owner.getTransform().rotate(glm::vec3(1, 0, 0), -pos.y * moveAmount);
        }
        if (pos.x != 0) {
            m_owner.getTransform().setRotation(glm::angleAxis(-pos.x * moveAmount, glm::vec3(0, 1, 0)) *
                                               m_owner.getTransform().getRotation());
        }
    } else {
        input->releaseMouse();
    }
}
