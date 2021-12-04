#include <windows.h>
#include <dbghelp.h>
#include <cstdio>
#include <cstdlib>
#include <filesystem>

#include "Exceptions.h"
#include "AutoSymInitialize.h"

namespace ExceptionsStacktrace {
AutoSymInitialize::AutoSymInitialize() {
    throwIfFalse(!s_is_already_initialized, "Symbols initializer already initialized");
    auto *current_process_handle = GetCurrentProcess();
    std::wstring symbolPathSize;
    symbolPathSize.resize(4096);
    throwIfFalse(SymInitialize(GetCurrentProcess(), nullptr, true),
                 "Failed to intialize symbols");

    symbolPathSize = std::wstring(L".;") +
                     std::filesystem::path(getExePath()).parent_path().c_str();
    throwIfFalse(SymSetSearchPathW(current_process_handle, symbolPathSize.data()),
                 "Failed to set search symbol path");
    s_is_already_initialized = true;
}

AutoSymInitialize::~AutoSymInitialize() {
    [[maybe_unused]] auto result = SymCleanup(GetCurrentProcess());
    _ASSERT(result);
}

std::wstring AutoSymInitialize::getExePath() {
    wchar_t system_buffer[MAX_PATH];
    GetModuleFileNameW(NULL, system_buffer, MAX_PATH);
    system_buffer[MAX_PATH - 1] = L'\0';
    return std::wstring(system_buffer);
}
}