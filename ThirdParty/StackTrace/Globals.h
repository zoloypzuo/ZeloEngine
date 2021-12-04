#pragma once

#include <Windows.h>
#include <vector>
#include <optional>

namespace ExceptionsStacktrace {
inline thread_local std::vector<std::vector<void *>> t_currentExceptionStacktraces;

/**
    This function is clearing the collected exception info,
    and should be used after printing the stack trace.
*/
inline void clearCollectedExceptionInfo() {
    t_currentExceptionStacktraces.clear();
}
}