#include "Zelo.h"

#include "AutoSymInitialize.h"
#include "AutoExceptionStacktraceRegister.h"
#include "StackTracePrinter.h"

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
