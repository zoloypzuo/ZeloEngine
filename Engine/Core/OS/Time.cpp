// Time.cpp
// created on 2021/7/30
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Time.h"

using namespace Zelo::Core::OS::TimeSystem;

Time::Time() {

}

Time::~Time() {

}

template<> Time *Singleton<Time>::msSingleton = nullptr;

Time *Time::getSingletonPtr() {
    return msSingleton;
}

Time &Time::getSingleton() {
    assert(msSingleton);
    return *msSingleton;
}

void Time::initialize() {
    m_time = std::chrono::high_resolution_clock::now();
}

void Time::finalize() {

}

void Time::update() {
    m_lastTime = m_time;
    m_time = std::chrono::high_resolution_clock::now();
    m_deltaTime = std::chrono::duration_cast<std::chrono::microseconds>(m_time - m_lastTime);
}

float Time::getDeltaTime() {
    return std::chrono::duration_cast<std::chrono::duration<float>>(m_deltaTime).count();
}
