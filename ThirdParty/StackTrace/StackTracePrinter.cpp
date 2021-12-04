#pragma warning(push, 0)

#include "backward.h"

#pragma warning(pop)

#include "StackTracePrinter.h"
#include "Globals.h"

using namespace backward;

namespace ExceptionsStacktrace {
std::string getStacktraceAsString(const std::vector<void *> &addresses) {
    StackTrace st;
    st.load_from(addresses);
    TraceResolver tr;
    std::stringstream ss;
    tr.load_stacktrace(st);
    ss << "stacktrace is:" << std::endl;
    for (size_t i = 0; i < st.size(); ++i) {
        auto traces = tr.resolve(st[i]);
        for (const auto &trace: traces) {
            if (trace.has_value()) {
                ss << "#" << i
                   << " " << trace->object_filename
                   << " " << trace->object_function
                   << " line: " << trace->source.line
                   << " [" << trace->addr << "]"
                   << std::endl;
            } else {
                ss << "#" << i << " " << st[i].addr << std::endl;
            }
        }
    }
    return ss.str();
}

std::string getStacktraceAsString() {
    std::string stacktraceString;
    for (const auto &stacktrace: t_currentExceptionStacktraces) {
        stacktraceString += getStacktraceAsString(stacktrace);
    }
    return stacktraceString;
}

void printStacktrace() {
    std::cerr << getStacktraceAsString();
}

void messageBoxStacktrace() {
    std::string s = getStacktraceAsString();
    std::wstring ws(s.begin(), s.end());
    clearCollectedExceptionInfo();
    MessageBox(nullptr, ws.c_str(), L"C++ Exception", MB_OK);
}
}