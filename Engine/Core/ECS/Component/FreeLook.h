//
// Created by zuoyiping01 on 2021/3/31.
//

#ifndef ZELOENGINE_FREELOOK_H
#define ZELOENGINE_FREELOOK_H

#include "ZeloPrerequisites.h"
#include "Core/ECS/Component.h"
#include "Engine.h"

class FreeLook : public Component {
public:
    explicit FreeLook(float speed = 1.f);

    ~FreeLook() override;

    void update(Input *input, std::chrono::microseconds delta) override;

    void registerWithEngine(Engine *engine) override;

    void deregisterFromEngine(Engine *engine) override;

    inline const char *getType() override { return "FREE_LOOK"; }

private:
    float m_speed;
    bool m_look;
};


#endif //ZELOENGINE_FREELOOK_H
