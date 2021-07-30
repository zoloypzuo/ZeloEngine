//
// Created by zuoyiping01 on 2021/3/31.
//
#include "ZeloPreCompiledHeader.h"
#include "FreeMove.h"

FreeMove::FreeMove(bool moveForwards, float speed) {
    m_speed = speed;
    m_moveForwards = moveForwards;
    m_sprinting = false;
    m_forwardsVelocity = 0;
    m_strafeVelocity = 0;

    setProperty("speed", PropertyType::FLOAT, &m_speed, 0, 20);
    setProperty("forwards velocity", PropertyType::FLOAT, &m_forwardsVelocity, -1, 1);
    setProperty("strafe velocity", PropertyType::FLOAT, &m_strafeVelocity, -1, 1);
    setProperty("forwards", PropertyType::BOOLEAN, &m_moveForwards);
    setProperty("sprinting", PropertyType::BOOLEAN, &m_sprinting);
}

FreeMove::~FreeMove() = default;

void FreeMove::registerWithEngine() {
    auto input = Input::getSingletonPtr();
    input->registerKeyToAction(SDLK_LSHIFT, "sprint");
    input->registerKeysToAxis(SDLK_w, SDLK_s, -1.f, 1.f, "forwards");
    input->registerKeysToAxis(SDLK_a, SDLK_d, -1.f, 1.f, "strafe");

    input->bindAction("sprint", IE_PRESSED, [this]() {
        m_sprinting = true;
    });
    input->bindAction("sprint", IE_RELEASED, [this]() {
        m_sprinting = false;
    });

    input->bindAxis("forwards", [this](float value) {
        m_forwardsVelocity = value;
    });
    input->bindAxis("strafe", [this](float value) {
        m_strafeVelocity = value;
    });
}

void FreeMove::deregisterFromEngine() {
    auto input = Input::getSingletonPtr();
    input->unbindAction("sprint");
    input->unbindAxis("forwards");
    input->unbindAxis("strafe");
}

void FreeMove::update(Input *input, std::chrono::microseconds delta) {
    float moveAmount = m_speed * std::chrono::duration_cast<std::chrono::duration<float>>(delta).count();

    if (m_sprinting) {
        moveAmount *= 4.0f;
    }

    if (m_forwardsVelocity != 0) {
        if (m_moveForwards) {
            Move(glm::rotate(m_parentEntity->getTransform().getRotation(), glm::vec3(0.0f, 0.0f, m_forwardsVelocity)),
                 moveAmount);
        } else {
            Move(glm::rotate(m_parentEntity->getTransform().getRotation(), glm::vec3(0.0f, m_forwardsVelocity, 0.0f)),
                 moveAmount);
        }
    }

    if (m_strafeVelocity != 0) {
        Move(glm::rotate(m_parentEntity->getTransform().getRotation(), glm::vec3(m_strafeVelocity, 0.0f, 0.0f)),
             moveAmount);
    }
}

void FreeMove::Move(const glm::vec3 &direction, float amount) {
    m_parentEntity->getTransform().translate(direction * amount);
}
