// ZeloPreCompiledHeader.h
// created on 2021/3/28.
// author @zoloypzuo
#pragma once

// common header
#include "Foundation/ZeloPlatform.h"  // platform macro first
#include "Foundation/ZeloAlgorithmUtil.h"  // stl algorithm patch
#include "Foundation/ZeloMemory.h"  // memory macro
#include "Foundation/ZeloStringUtil.h" // string patch
#include "Core/Math/Mathf.h"  // common math patch

// c++ patch
#include <absl/strings/match.h>

// spdlog
#pragma warning(push, 0)  // This ignores all warnings raised inside External headers

#include <spdlog/spdlog.h>
#include <spdlog/fmt/fmt.h>
#include <spdlog/fmt/ostr.h>

#pragma warning(pop)

// debug break
#ifdef ZELO_DEBUG
#if defined(ZELO_PLATFORM_WINDOWS)
#define ZELO_DEBUGBREAK() __debugbreak()
#elif defined(ZELO_PLATFORM_LINUX)
#include <signal.h>
#define ZELO_DEBUGBREAK() raise(SIGTRAP)
#else
#define ZELO_DEBUGBREAK() __asm {int 3}
#endif
#define ZELO_ENABLE_ASSERTS
#else
#define ZELO_DEBUGBREAK()
#endif

// base
#define ZELO_EXPAND_MACRO(x) x
#define ZELO_STRINGIFY_MACRO(x) #x

// log
// Core log macros
// TODO log to core logger
#define ZELO_CORE_TRACE(...)    spdlog::trace(__VA_ARGS__)
#define ZELO_CORE_INFO(...)     spdlog::info(__VA_ARGS__)
#define ZELO_CORE_WARN(...)     spdlog::warn(__VA_ARGS__)
#define ZELO_CORE_ERROR(...)    spdlog::error(__VA_ARGS__)
#define ZELO_CORE_CRITICAL(...) spdlog::critical(__VA_ARGS__)

#define ZELO_TRACE(...)         spdlog::trace(__VA_ARGS__)
#define ZELO_INFO(...)          spdlog::info(__VA_ARGS__)
#define ZELO_WARN(...)          spdlog::warn(__VA_ARGS__)
#define ZELO_ERROR(...)         spdlog::error(__VA_ARGS__)
#define ZELO_CRITICAL(...)      spdlog::critical(__VA_ARGS__)

// assert
#include <filesystem>

#ifdef ZELO_ENABLE_ASSERTS

// Alternatively we could use the same "default" message for both "WITH_MSG" and "NO_MSG" and
// provide support for custom formatting by concatenating the formatting string instead of having the format inside the default message
#define __ZELO_INTERNAL_ASSERT_IMPL(type, check, msg, ...) { if(!(check)) { ZELO##type##ERROR(msg, __VA_ARGS__); ZELO_DEBUGBREAK(); } }
#define __ZELO_INTERNAL_ASSERT_WITH_MSG(type, check, ...) __ZELO_INTERNAL_ASSERT_IMPL(type, check, "Assertion failed: {0}", __VA_ARGS__)
#define __ZELO_INTERNAL_ASSERT_NO_MSG(type, check) __ZELO_INTERNAL_ASSERT_IMPL(type, check, "Assertion '{0}' failed at {1}:{2}", ZELO_STRINGIFY_MACRO(check), std::filesystem::path(__FILE__).filename().string(), __LINE__)

#define __ZELO_INTERNAL_ASSERT_GET_MACRO_NAME(arg1, arg2, macro, ...) macro
#define __ZELO_INTERNAL_ASSERT_GET_MACRO(...) ZELO_EXPAND_MACRO( __ZELO_INTERNAL_ASSERT_GET_MACRO_NAME(__VA_ARGS__, __ZELO_INTERNAL_ASSERT_WITH_MSG, __ZELO_INTERNAL_ASSERT_NO_MSG) )

// Currently accepts at least the condition and one additional parameter (the message) being optional
#define ZELO_ASSERT(...) do {ZELO_EXPAND_MACRO( __ZELO_INTERNAL_ASSERT_GET_MACRO(__VA_ARGS__)(_, __VA_ARGS__) )} while(0)
#define ZELO_CORE_ASSERT(...) do {ZELO_EXPAND_MACRO( __ZELO_INTERNAL_ASSERT_GET_MACRO(__VA_ARGS__)(_CORE_, __VA_ARGS__) )} while(0)
#else
#define ZELO_ASSERT(...)
#define ZELO_CORE_ASSERT(...)
#endif
