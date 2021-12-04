#pragma warning(push, 0)

#include "backward.h"

#pragma warning(pop)

#include <Windows.h>
#include <vector>
#include "AutoExceptionStacktraceRegister.h"
#include "Exceptions.h"
#include "Globals.h"

using namespace backward;

namespace ExceptionsStacktrace {
static const size_t CALL_FIRST = 0;

static constexpr size_t CXX_EXECPTION_CODE = 0xe06d7363;

thread_local std::vector<size_t> t_currentExceptionArguments;


LONG WINAPI AutoExceptionStacktraceRegister::addStackTraceToException(
        struct _EXCEPTION_POINTERS *ExceptionInfo) {
    bool isCxxException = (CXX_EXECPTION_CODE == ExceptionInfo->ExceptionRecord->ExceptionCode);
    if (isCxxException) {
        bool isSimpleRethrow = ExceptionInfo->ExceptionRecord->ExceptionInformation[1] == 0;
        if (!isSimpleRethrow) {
            auto currentExceptionsArguments = std::vector<size_t>(
                    reinterpret_cast<size_t *>(ExceptionInfo->ExceptionRecord->ExceptionInformation),
                    reinterpret_cast<size_t *>(ExceptionInfo->ExceptionRecord->ExceptionInformation +
                                               ExceptionInfo->ExceptionRecord->NumberParameters));

            if (t_currentExceptionArguments != currentExceptionsArguments) {
                t_currentExceptionStacktraces.clear();
                t_currentExceptionArguments = currentExceptionsArguments;
            }
            StackTrace st;
            st.load_here();
            std::vector<void *> currentStacktrace;
            for (size_t i = 0; i < st.size(); i++) {
                currentStacktrace.push_back(st[i].addr);
            }
            t_currentExceptionStacktraces.push_back(currentStacktrace);
        }
    }
    return EXCEPTION_CONTINUE_SEARCH;
}

AutoExceptionStacktraceRegister::AutoExceptionStacktraceRegister() {
    m_registeredHandler = AddVectoredExceptionHandler(CALL_FIRST, addStackTraceToException);
    throwIfFalse(m_registeredHandler, "failed to add veh handler");
}

AutoExceptionStacktraceRegister::~AutoExceptionStacktraceRegister() {
    if (m_registeredHandler) {
        [[maybe_unused]] auto result = RemoveVectoredExceptionHandler(m_registeredHandler);
        _ASSERT(0 != result);
    }
}
}