//
// Created by zuoyiping01 on 2021/3/31.
//

#ifndef ZELOENGINE_FREELOOK_H
#define ZELOENGINE_FREELOOK_H

#include "ZeloPrerequisites.h"
#include "Core/ECS/Entity.h"

class FreeLook : public Component {
public:
    explicit FreeLook(float speed = 1.f);

    ~FreeLook() override;

    void update(float delta) override;

    void registerWithEngine() override;

    void deregisterFromEngine() override;

    inline const char *getType() override { return "FREE_LOOK"; }

private:
    float m_speed;
    bool m_look;
};

#endif //ZELOENGINE_FREELOOK_H
