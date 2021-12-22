#include "AutoSymInitialize.h"
#include "AutoExceptionStacktraceRegister.h"
#include "StackTracePrinter.h"

#ifdef DetectMemoryLeak
#include "Foundation/ZeloMemoryLeak.h"
#endif

#include "Zelo.h"

using namespace ExceptionsStacktrace;

int main() {
    AutoSymInitialize autoSymInitialize;
    AutoExceptionStacktraceRegister autoExceptionStacktraceRegister;
    try {
        Zelo::Engine().start();
    } catch (...) {
        messageBoxStacktrace();
    }
    return 0;
}
