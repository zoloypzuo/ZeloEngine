#pragma once
#include "ZeloPrerequisites.h"

namespace Zelo::Core::ECS::Components {
template<typename ...Args>
inline void Behaviour::LuaCall(const std::string &functionName, Args &&...args) {
    if (m_object.valid()) {
        if (m_object[functionName].valid()) {
            sol::protected_function pfr = m_object[functionName];
            auto pfrResult = pfr.call(m_object, std::forward<Args>(args)...);
            if (!pfrResult.valid()) {
                sol::error err = pfrResult;
                ZELO_CORE_ERROR(err.what());
            }
        }
    }
}
}