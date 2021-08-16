//
// Created by zuoyiping01 on 2021/3/31.
//

#ifndef ZELOENGINE_CFREELOOK_H
#define ZELOENGINE_CFREELOOK_H

#include "ZeloPrerequisites.h"
#include "Core/ECS/Entity.h"

namespace Zelo::Core::ECS {
class CFreeLook : public Component {
public:
    explicit CFreeLook(Entity &owner);

    ~CFreeLook() override;

    void update(float delta) override;

    void registerWithEngine() override;

    void deregisterFromEngine() override;

    inline std::string getType() override { return "FREE_LOOK"; }

private:
    float m_speed{1.f};
    bool m_look{};
};
}

#endif //ZELOENGINE_CFREELOOK_H
