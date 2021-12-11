// LuaScriptManager.inl
// created on 2021/8/16
// author @zoloypzuo
#pragma once

#include "Foundation/ZeloStringUtil.h"

#include <tuple-utils/tuple_interlace.h>

#define MAGIC_ENUM_RANGE_MIN 0
#define MAGIC_ENUM_RANGE_MAX 64

#include <magic_enum.hpp>

namespace Zelo::Core::LuaScript {
template<typename... Args>
void LuaScriptManager::luaCall(sol::protected_function pfr, Args &&... args) {
    pfr.set_default_handler(get<sol::object>("GlobalErrorHandler"));
    sol::protected_function_result pfrResult = pfr.call(std::forward<Args>(args)...);
    if (!pfrResult.valid()) {
        sol::error err = pfrResult;
        ZELO_CORE_ERROR(err.what());
    }
}

template<typename... Args>
void LuaScriptManager::luaCall(const std::string &functionName, Args &&... args) {
    sol::optional<sol::protected_function> pfrResult = get<sol::protected_function>(functionName);
    ZELO_ASSERT(pfrResult.has_value());
    luaCall(pfrResult.value(), std::forward<Args>(args)...);
}

template<typename TypeToRegister>
void LuaScriptManager::registerType() noexcept {
    registerTypeImpl<TypeToRegister>(refl::reflect<TypeToRegister>().members);
}

template<typename TypeToRegister, typename... Members>
void LuaScriptManager::registerTypeImpl(refl::type_list<Members...>) noexcept {
    std::string current_name = refl::reflect<TypeToRegister>().name.str();
    std::string final_name = current_name;
    // skip namespace
    if (std::size_t found = current_name.find_last_of(':'); found != std::string::npos) {
        final_name = current_name.substr(found + 1);
    }

    // build args
    auto name_table = std::make_tuple(final_name);
    auto final_table = std::tuple_cat(name_table, std::make_tuple(Members::name.c_str(), Members::pointer)...);

    // new_usertype
    try {
        std::apply([this](auto &&... params) {
            this->new_usertype<TypeToRegister>(std::forward<decltype(params)>(params)...);
        }, final_table);
    }
    catch (const std::exception &error) {
//        ZELO_CORE_ERROR("register type error: {}", error.what());
    }
}

template<typename TypeToRegister>
void LuaScriptManager::registerEnumType() noexcept {
    static_assert(magic_enum::is_scoped_enum<TypeToRegister>(), "enum must be enum class");
    static_assert(magic_enum::enum_count<TypeToRegister>() <= 8, "enum count must be <= 8");

    // typename
    constexpr auto current_name = magic_enum::enum_type_name<TypeToRegister>();
    std::string final_name(current_name);
    // skip namespace
    if (std::size_t found = current_name.find_last_of(':'); found != std::string::npos) {
        final_name = current_name.substr(found + 1);
    }

    // build args
    auto enum_names = std::tuple_cat(magic_enum::enum_names<TypeToRegister>());
    auto enum_values = std::tuple_cat(magic_enum::enum_values<TypeToRegister>());
    auto final_table = tupleutils::tuple_interlace(enum_names, enum_values);

    // new_enum
    try {
        std::apply([this, &final_name](auto &&... params) {
            new_enum(final_name, std::forward<decltype(params)>(params)...);
        }, final_table);
    }
    catch (const std::exception &error) {
        spdlog::error("register type error: {}", error.what());
    }
}
}