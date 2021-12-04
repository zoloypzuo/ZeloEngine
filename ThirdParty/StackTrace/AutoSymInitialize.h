#pragma once

#include <string>

namespace ExceptionsStacktrace {
class AutoSymInitialize {
public:
    /**
        Initialized symbols search options.
        Should be called only once in your program.
    */
    AutoSymInitialize();

    ~AutoSymInitialize();

    AutoSymInitialize(const AutoSymInitialize &) = delete;

    AutoSymInitialize &operator=(const AutoSymInitialize &) = delete;

    AutoSymInitialize(AutoSymInitialize &&other) noexcept = delete;

    AutoSymInitialize &operator=(AutoSymInitialize &&other) noexcept = delete;

private:
    static std::wstring getExePath();

    inline static bool s_is_already_initialized = false;
};
}

