// Time.cpp
// created on 2021/7/30
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Time.h"
#include "Window.h"

using namespace std::chrono;
using namespace Zelo::Core::OS;

Time::Time() = default;

Time::~Time() = default;

template<> Time *Zelo::Singleton<Time>::msSingleton = nullptr;

Time *Time::getSingletonPtr() {
    return msSingleton;
}

Time &Time::getSingleton() {
    assert(msSingleton);
    return *msSingleton;
}

void Time::initialize() {
    m_baseTime = m_time = high_resolution_clock::now();
    lockFrameRate(60);
}

void Time::finalize() {
}

void Time::update() {
    m_lastTime = m_time;
    m_time = high_resolution_clock::now();
    m_deltaTime = duration_cast<microseconds>(m_time - m_lastTime);

    // lock frame rate
    if (m_lockFrameRate) {
        uint32_t delay = m_iFrameRate - static_cast<uint32_t>(getDeltaTime());
        Window::getSingletonPtr()->delay(delay);
    }
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

void Time::lockFrameRate(int frameRate) {
    m_lockFrameRate = true;
    m_iFrameRate = 1000 / frameRate;
}
