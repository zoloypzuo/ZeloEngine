// ZeloStackTrace.h
// created on 2021/12/23
// author @zoloypzuo
// include this header to log stacktrace on exception
#pragma once

#include "ZeloStackTrace.h"
#include "ZeloSDL.h"  // SDL_ShowSimpleMessageBox
#include <spdlog/spdlog.h>  // spdlog::error

using namespace backward;

namespace Zelo {
SignalHandling::SignalHandling(const std::vector<int> &)
        : reporter_thread_([]() {
    /* We handle crashes in a utility thread:
      backward structures and some Windows functions called here
      need stack space, which we do not have when we encounter a
      stack overflow.
      To support reporting stack traces during a stack overflow,
      we create a utility thread at startup, which waits until a
      crash happens or the program exits normally. */

    {
        std::unique_lock<std::mutex> lk(mtx());
        cv().wait(lk, [] { return crashed() != crash_status::running; });
    }
    if (crashed() == crash_status::crashed) {
        handle_stacktrace(skip_recs());
    }
    {
        std::unique_lock<std::mutex> lk(mtx());
        crashed() = crash_status::ending;
    }
    cv().notify_one();
}) {
    SetUnhandledExceptionFilter(crash_handler);

    signal(SIGABRT, signal_handler);
    _set_abort_behavior(0, _WRITE_ABORT_MSG | _CALL_REPORTFAULT);

    std::set_terminate(&terminator);
#ifndef BACKWARD_ATLEAST_CXX17
    std::set_unexpected(&terminator);
#endif
    _set_purecall_handler(&terminator);
    _set_invalid_parameter_handler(&invalid_parameter_handler);
}

bool SignalHandling::loaded() const { return true; }

SignalHandling::~SignalHandling() {
    {
        std::unique_lock<std::mutex> lk(mtx());
        crashed() = crash_status::normal_exit;
    }

    cv().notify_one();

    reporter_thread_.join();
}

CONTEXT *SignalHandling::ctx() {
    static CONTEXT data;
    return &data;
}

SignalHandling::crash_status &SignalHandling::crashed() {
    static crash_status data;
    return data;
}

std::mutex &SignalHandling::mtx() {
    static std::mutex data;
    return data;
}

std::condition_variable &SignalHandling::cv() {
    static std::condition_variable data;
    return data;
}

HANDLE &SignalHandling::thread_handle() {
    static HANDLE handle;
    return handle;
}

int &SignalHandling::skip_recs() {
    static int data;
    return data;
}

LONG SignalHandling::crash_handler(EXCEPTION_POINTERS *info) {
    // The exception info supplies a trace from exactly where the issue was,
    // no need to skip records
    crash_handler(0, info->ContextRecord);
    return EXCEPTION_CONTINUE_SEARCH;
}

void SignalHandling::crash_handler(int skip, CONTEXT *ct) {

    if (ct == nullptr) {
        RtlCaptureContext(ctx());
    } else {
        memcpy(ctx(), ct, sizeof(CONTEXT));
    }
    DuplicateHandle(GetCurrentProcess(), GetCurrentThread(),
                    GetCurrentProcess(), &thread_handle(), 0, FALSE,
                    DUPLICATE_SAME_ACCESS);

    skip_recs() = skip;

    {
        std::unique_lock<std::mutex> lk(mtx());
        crashed() = crash_status::crashed;
    }

    cv().notify_one();

    {
        std::unique_lock<std::mutex> lk(mtx());
        cv().wait(lk, [] { return crashed() != crash_status::crashed; });
    }
}

void SignalHandling::handle_stacktrace(int skip_frames) {
    // printer creates the TraceResolver, which can supply us a machine type
    // for stack walking. Without this, StackTrace can only guess using some
    // macros.
    // StackTrace also requires that the PDBs are already loaded, which is done
    // in the constructor of TraceResolver
    Printer printer;

    StackTrace st;
    st.set_machine_type(printer.resolver().machine_type());
    st.set_thread_handle(thread_handle());
    st.load_here(32 + skip_frames, ctx());
    st.skip_n_firsts(skip_frames);

    printer.address = true;

    // log
    {
        std::ostringstream oss;
        printer.print(st, oss);
        spdlog::error(oss.str());
    }

    // msgbox
    {
        printer.snippet = false;
        printer.address = false;
        std::ostringstream oss;
        printer.print(st, oss);
        SDL_ShowSimpleMessageBox(SDL_MESSAGEBOX_ERROR, "C++ exception", oss.str().c_str(), nullptr);
    }
}
}