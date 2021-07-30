//
// Created by zuoyiping01 on 2021/3/31.
//
#include "ZeloPreCompiledHeader.h"
#include "FreeLook.h"
#include "Core/ECS/Entity.h"

FreeLook::FreeLook(float speed) {
    m_speed = speed;
    m_look = false;

    setProperty("speed", PropertyType::FLOAT, &m_speed, 0, 5);
    setProperty("look", PropertyType::BOOLEAN, &m_look);
}

FreeLook::~FreeLook() {
}

void FreeLook::registerWithEngine() {
    auto input = Input::getSingletonPtr();

    input->registerButtonToAction(SDL_BUTTON_RIGHT, "look");

    input->bindAction("look", IE_PRESSED, [this]() {
        m_look = true;
    });
    input->bindAction("look", IE_RELEASED, [this]() {
        m_look = false;
    });
}

void FreeLook::deregisterFromEngine() {
    auto input = Input::getSingletonPtr();

    input->unbindAction("look");
}

void FreeLook::update(Input *input, std::chrono::microseconds delta) {
    float moveAmount = m_speed * std::chrono::duration_cast<std::chrono::duration<float>>(delta).count();

    if (m_look) {
        input->grabMouse();
        glm::vec2 pos = input->getMouseDelta();
        if (pos.y != 0) {
            m_parentEntity->getTransform().rotate(glm::vec3(1, 0, 0), -pos.y * moveAmount);
        }
        if (pos.x != 0) {
            m_parentEntity->getTransform().setRotation(glm::angleAxis(-pos.x * moveAmount, glm::vec3(0, 1, 0)) *
                                                       m_parentEntity->getTransform().getRotation());
        }
    } else {
        input->releaseMouse();
    }
}
