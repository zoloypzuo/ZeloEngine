add_library(StackTrace
        AutoExceptionStacktraceRegister.cpp
        AutoExceptionStacktraceRegister.h
        AutoSymInitialize.cpp
        AutoSymInitialize.h
        backward.h
        Exceptions.h
        Globals.h
        StackTracePrinter.cpp
        StackTracePrinter.h)

target_compile_definitions(StackTrace PRIVATE NOMINMAX WIN32_LEAN_AND_MEAN UNICODE)
