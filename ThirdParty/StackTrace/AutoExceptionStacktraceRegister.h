#pragma once

#include <Windows.h>

namespace ExceptionsStacktrace {
/**
    This class is responsible on registering a veh handler for the purpose of
    getting a stack trace when exception is thrown.
    https://docs.microsoft.com/en-us/windows/win32/debug/vectored-exception-handling
*/
class AutoExceptionStacktraceRegister {
public:
    AutoExceptionStacktraceRegister();

    ~AutoExceptionStacktraceRegister();

    AutoExceptionStacktraceRegister(const AutoExceptionStacktraceRegister &) = delete;

    AutoExceptionStacktraceRegister &operator=(const AutoExceptionStacktraceRegister &) = delete;

    AutoExceptionStacktraceRegister(AutoExceptionStacktraceRegister &&other) noexcept = delete;

    AutoExceptionStacktraceRegister &operator=(AutoExceptionStacktraceRegister &&other) noexcept = delete;

private:
    static LONG WINAPI addStackTraceToException(struct _EXCEPTION_POINTERS *ExceptionInfo);

    void *m_registeredHandler = nullptr;
};
}
