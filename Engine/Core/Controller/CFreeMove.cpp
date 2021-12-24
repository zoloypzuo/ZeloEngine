//
// Created by zuoyiping01 on 2021/3/31.
//
#include "ZeloPreCompiledHeader.h"
#include "CFreeMove.h"
#include "Core/OS/Input.h"

using namespace Zelo::Core::ECS;
using namespace Zelo::Core::OS;

CFreeMove::CFreeMove(Entity &owner) : Component(owner) {
}

CFreeMove::~CFreeMove() = default;

void CFreeMove::OnAwake() {
    auto *input = Input::getSingletonPtr();
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

void CFreeMove::OnDestroy() {
    auto *input = Input::getSingletonPtr();
    input->unbindAction("sprint");
    input->unbindAxis("forwards");
    input->unbindAxis("strafe");
}

void CFreeMove::update(float delta) {
    auto *input = Input::getSingletonPtr();

    float moveAmount = m_speed * delta;

    if (m_sprinting) {
        moveAmount *= 4.0f;
    }

    if (m_forwardsVelocity != 0) {
        if (m_moveForwards) {
            Move(glm::rotate(m_owner.getTransform().getRotation(), glm::vec3(0.0f, 0.0f, m_forwardsVelocity)),
                 moveAmount);
        } else {
            Move(glm::rotate(m_owner.getTransform().getRotation(), glm::vec3(0.0f, m_forwardsVelocity, 0.0f)),
                 moveAmount);
        }
    }

    if (m_strafeVelocity != 0) {
        Move(glm::rotate(m_owner.getTransform().getRotation(), glm::vec3(m_strafeVelocity, 0.0f, 0.0f)),
             moveAmount);
    }
}

void CFreeMove::Move(const glm::vec3 &direction, float amount) {
    m_owner.getTransform().translate(direction * amount);
}
