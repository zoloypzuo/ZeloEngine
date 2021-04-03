// Profiler.cpp
// created on 2021/4/3
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Profiler.h"

void Zelo::Profiler::BeginSession(const std::string &name, const std::string &filename) {
    std::lock_guard lock(m_Mutex);
    if (m_CurrentSession) {
        // If there is already a current session, then close it before beginning new one.
        // Subsequent profiling output meant for the original session will end up in the
        // newly opened session instead.  That's better than having badly formatted
        // profiling output.
        spdlog::error("Profiler::BeginSession('{0}') when session '{1}' already open.", name,
                      m_CurrentSession->Name);
        InternalEndSession();
    }
    m_OutputStream.open(filename);

    if (m_OutputStream.is_open()) {
        m_CurrentSession = new InstrumentationSession({name});
        WriteHeader();
    } else {
        spdlog::error("Profiler could not open results file '{0}'.", filename);
    }
}

void Zelo::Profiler::EndSession() {
    std::lock_guard lock(m_Mutex);
    InternalEndSession();
}

void Zelo::Profiler::WriteProfile(const Zelo::ProfileResult &result) {
    std::stringstream json;

    json << std::setprecision(3) << std::fixed;
    json << ",{";
    json << "\"cat\":\"function\",";
    json << "\"dur\":" << (result.ElapsedTime.count()) << ',';
    json << "\"name\":\"" << result.Name << "\",";
    json << "\"ph\":\"X\",";
    json << "\"pid\":0,";
    json << "\"tid\":" << result.ThreadID << ",";
    json << "\"ts\":" << result.Start.count();
    json << "}";

    std::lock_guard lock(m_Mutex);
    if (m_CurrentSession) {
        m_OutputStream << json.str();
        m_OutputStream.flush();
    }
}

Zelo::Profiler::Profiler()
        : m_CurrentSession(nullptr) {
}

Zelo::Profiler::~Profiler() {
    EndSession();
}

void Zelo::Profiler::WriteHeader() {
    m_OutputStream << "{\"otherData\": {},\"traceEvents\":[{}";
    m_OutputStream.flush();
}

void Zelo::Profiler::WriteFooter() {
    m_OutputStream << "]}";
    m_OutputStream.flush();
}

void Zelo::Profiler::InternalEndSession() {
    if (m_CurrentSession) {
        WriteFooter();
        m_OutputStream.close();
        delete m_CurrentSession;
        m_CurrentSession = nullptr;
    }
}
