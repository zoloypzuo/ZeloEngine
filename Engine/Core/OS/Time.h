// Time.h
// created on 2021/7/30
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"

namespace Zelo::Core::OS {
class Time :
        public Singleton<Time>,
        public IRuntimeModule {
public:
    Time();

    ~Time() override;

    static Time *getSingletonPtr();

    static Time &getSingleton();

    void initialize() override;

    void finalize() override;

    void update() override;

public:
    float getDeltaTime();

    float getTotalTime();

    void reset();

private:
    std::chrono::high_resolution_clock::time_point m_baseTime{};
    std::chrono::high_resolution_clock::time_point m_time{};
    std::chrono::high_resolution_clock::time_point m_lastTime{};
    std::chrono::microseconds m_deltaTime{};
};
}
