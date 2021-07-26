//
// Created by zuoyiping01 on 2021/3/31.
//

#ifndef ZELOENGINE_FREEMOVE_H
#define ZELOENGINE_FREEMOVE_H

#include "ZeloPrerequisites.h"
#include <glm/glm.hpp>
#include <glm/gtx/quaternion.hpp>
#include "Component.h"

class FreeMove : public Component {
public:
    explicit FreeMove(bool moveForwards = true, float speed = 10.f);

    ~FreeMove() override;

    void update(Input *input, std::chrono::microseconds delta) override;

    void registerWithEngine(Engine *engine) override;

    void deregisterFromEngine(Engine *engine) override;

    inline const char *getType() override { return "FREE_MOVE"; }

private:
    void Move(const glm::vec3 &direction, float amount);

    float m_speed, m_forwardsVelocity, m_strafeVelocity;
    bool m_moveForwards, m_sprinting;
};


#endif //ZELOENGINE_FREEMOVE_H
