//
// Created by zuoyiping01 on 2021/3/31.
//

#ifndef ZELOENGINE_CFREEMOVE_H
#define ZELOENGINE_CFREEMOVE_H

#include "ZeloPrerequisites.h"
#include "Core/ECS/Entity.h"
#include <glm/glm.hpp>
#include <glm/gtx/quaternion.hpp>

namespace Zelo::Core::ECS {
class CFreeMove : public Component {
public:
    explicit CFreeMove(Entity &owner);

    ~CFreeMove() override;

    void update(float delta) override;

    void OnAwake() override;

    void OnDestroy() override;

    inline std::string getType() override { return "FREE_MOVE"; }

private:
    void Move(const glm::vec3 &direction, float amount);

    float m_speed{10.f};
    float m_forwardsVelocity{};
    float m_strafeVelocity{};
    bool m_moveForwards{true};
    bool m_sprinting{};
};
}

#endif //ZELOENGINE_CFREEMOVE_H
