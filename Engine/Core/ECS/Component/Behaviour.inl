// Behaviour.inl
// created on 2021/7/26
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Core/ECS/Component/Behaviour.h"

namespace Zelo::Core::ECS::Component {
template<typename ...Args>
inline void Component::Behaviour::LuaCall(const std::string &p_functionName, Args &&...p_args) {
    if (m_object.valid()) {
        if (m_object[p_functionName].valid()) {
            sol::protected_function pfr = m_object[p_functionName];
            auto pfrResult = pfr.call(m_object, std::forward<Args>(p_args)...);
            if (!pfrResult.valid()) {
                sol::error err = pfrResult;
                ZELO_CORE_ERROR(err.what());
            }
        }
    }
}
}