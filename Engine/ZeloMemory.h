// ZeloMemory.h
// created on 2021/10/27
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

#if defined(__GNUC__) || defined(__SNC__)
#define ALIGN_OF(T) __alignof__(T)
	#define ALIGN_TYPE(val) __attribute__((aligned(val)))
	#define FORCE_INLINE inline __attribute__ ((always_inline))
#elif defined(_MSC_VER)
#define ALIGN_OF(T) __alignof(T)
#define ALIGN_TYPE(val) __declspec(align(val))
#define FORCE_INLINE __forceinline
#else
#define ALIGN_TYPE(size)
	#define FORCE_INLINE inline
#endif

