// ZeloMemoryLeak.h
// created on 2021/12/22
// author @zoloypzuo
// include this file in main to enable memory leak check
#pragma once

#if defined(__clang__)
#pragma clang system_header
#elif defined(__GNUC__)
#pragma GCC system_header
#elif defined(_MSC_VER)
#pragma system_header
#endif

#if defined(_MSC_VER)
#ifdef ZELO_DEBUG

#include <vld.h>

#else

#define VLD_FORCE_ENABLE
#include <vld.h>

#endif
#endif