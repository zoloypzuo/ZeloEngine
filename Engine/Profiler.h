// Profiler.h
// created on 2021/4/3
// author @zoloypzuo

#ifndef ZELOENGINE_PROFILER_H
#define ZELOENGINE_PROFILER_H

#include "ZeloPrerequisites.h"

#pragma once

#include <algorithm>
#include <chrono>
#include <fstream>
#include <iomanip>
#include <string>
#include <thread>
#include <mutex>
#include <sstream>

namespace Zelo {

using FloatingPointMicroseconds = std::chrono::duration<double, std::micro>;

struct ProfileResult {
    std::string Name;

    FloatingPointMicroseconds Start;
    std::chrono::microseconds ElapsedTime;
    std::thread::id ThreadID;
};

struct InstrumentationSession {
    std::string Name;
};

class Profiler {
public:
    Profiler(const Profiler &) = delete;

    Profiler(Profiler &&) = delete;

    void BeginSession(const std::string &name, const std::string &filename = "results.json");

    void EndSession();

    void WriteProfile(const ProfileResult &result);

    static Profiler &Get() {
        static Profiler instance;
        return instance;
    }

private:
    Profiler();

    ~Profiler();

    void WriteHeader();

    void WriteFooter();

    // Note: you must already own lock on m_Mutex before
    // calling InternalEndSession()
    void InternalEndSession();

private:
    std::mutex m_Mutex;
    InstrumentationSession *m_CurrentSession;
    std::ofstream m_OutputStream;
};

class InstrumentationTimer {
public:
    explicit InstrumentationTimer(const char *name)
            : m_Name(name), m_Stopped(false) {
        m_StartTimepoint = std::chrono::steady_clock::now();
    }

    ~InstrumentationTimer() {
        if (!m_Stopped)
            Stop();
    }

    void Stop() {
        auto endTimepoint = std::chrono::steady_clock::now();
        auto highResStart = FloatingPointMicroseconds{m_StartTimepoint.time_since_epoch()};
        auto elapsedTime = std::chrono::time_point_cast<std::chrono::microseconds>(endTimepoint).time_since_epoch() -
                           std::chrono::time_point_cast<std::chrono::microseconds>(m_StartTimepoint).time_since_epoch();

        Profiler::Get().WriteProfile({m_Name, highResStart, elapsedTime, std::this_thread::get_id()});

        m_Stopped = true;
    }

private:
    const char *m_Name;
    std::chrono::time_point<std::chrono::steady_clock> m_StartTimepoint;
    bool m_Stopped;
};

namespace ProfilerUtils {

template<size_t N>
struct ChangeResult {
    char Data[N];
};

template<size_t N, size_t K>
constexpr auto CleanupOutputString(const char(&expr)[N], const char(&remove)[K]) {
    ChangeResult<N> result = {};

    size_t srcIndex = 0;
    size_t dstIndex = 0;
    while (srcIndex < N) {
        size_t matchIndex = 0;
        while (matchIndex < K - 1 && srcIndex + matchIndex < N - 1 && expr[srcIndex + matchIndex] == remove[matchIndex])
            matchIndex++;
        if (matchIndex == K - 1)
            srcIndex += matchIndex;
        result.Data[dstIndex++] = expr[srcIndex] == '"' ? '\'' : expr[srcIndex];
        srcIndex++;
    }
    return result;
}
}
}

#define ZELO_PROFILE 1
#if ZELO_PROFILE
// Resolve which function signature macro will be used. Note that this only
// is resolved when the (pre)compiler starts, so the syntax highlighting
// could mark the wrong one in your editor!
#if defined(__GNUC__) || (defined(__MWERKS__) && (__MWERKS__ >= 0x3000)) || (defined(__ICC) && (__ICC >= 600)) || defined(__ghs__)
#define ZELO_FUNC_SIG __PRETTY_FUNCTION__
#elif defined(__DMC__) && (__DMC__ >= 0x810)
#define ZELO_FUNC_SIG __PRETTY_FUNCTION__
#elif (defined(__FUNCSIG__) || (_MSC_VER))
#define ZELO_FUNC_SIG __FUNCSIG__
#elif (defined(__INTEL_COMPILER) && (__INTEL_COMPILER >= 600)) || (defined(__IBMCPP__) && (__IBMCPP__ >= 500))
#define ZELO_FUNC_SIG __FUNCTION__
#elif defined(__BORLANDC__) && (__BORLANDC__ >= 0x550)
#define ZELO_FUNC_SIG __FUNC__
#elif defined(__STDC_VERSION__) && (__STDC_VERSION__ >= 199901)
#define ZELO_FUNC_SIG __func__
#elif defined(__cplusplus) && (__cplusplus >= 201103)
#define ZELO_FUNC_SIG __func__
#else
#define ZELO_FUNC_SIG "ZELO_FUNC_SIG unknown!"
#endif

#define ZELO_PROFILE_BEGIN_SESSION(name, filename) ::Zelo::Profiler::Get().BeginSession(name, filename)
#define ZELO_PROFILE_END_SESSION() ::Zelo::Profiler::Get().EndSession()
#define ZELO_PROFILE_SCOPE_LINE2(name, line) constexpr auto fixedName##line = ::Zelo::ProfilerUtils::CleanupOutputString(name, "__cdecl ");\
                         ::Zelo::InstrumentationTimer timer##line(fixedName##line.Data)
#define ZELO_PROFILE_SCOPE_LINE(name, line) ZELO_PROFILE_SCOPE_LINE2(name, line)
#define ZELO_PROFILE_SCOPE(name) ZELO_PROFILE_SCOPE_LINE(name, __LINE__)
#define ZELO_PROFILE_FUNCTION() ZELO_PROFILE_SCOPE(ZELO_FUNC_SIG)
#else
#define ZELO_PROFILE_BEGIN_SESSION(name, filename)
#define ZELO_PROFILE_END_SESSION()
#define ZELO_PROFILE_SCOPE(name)
#define ZELO_PROFILE_FUNCTION()
#endif

#endif //ZELOENGINE_PROFILER_H