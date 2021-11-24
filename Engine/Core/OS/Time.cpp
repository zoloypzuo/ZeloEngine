// Time.cpp
// created on 2021/7/30
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Time.h"

using namespace Zelo::Core::OS;
using namespace std::chrono;

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
    m_baseTime = m_time = high_resolution_clock::now();
}

void Time::finalize() {

}

void Time::update() {
    m_lastTime = m_time;
    m_time = high_resolution_clock::now();
    m_deltaTime = duration_cast<microseconds>(m_time - m_lastTime);
}

float Time::getDeltaTime() {
    return duration_cast<duration<float>>(m_deltaTime).count();
}

float Time::getTotalTime() {
    return duration_cast<duration<float>>(duration_cast<seconds>(m_time - m_baseTime)).count();
}

void Time::reset() {
    m_baseTime = high_resolution_clock::now();
}
