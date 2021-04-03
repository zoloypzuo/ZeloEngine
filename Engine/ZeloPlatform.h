// ZeloPlatform.h
// created on 2021/3/28
// author @zoloypzuo

#ifndef ZELOENGINE_ZELOPLATFORM_H
#define ZELOENGINE_ZELOPLATFORM_H

#include "ZeloPrerequisites.h"

// Platform detection using predefined macros
#ifdef _WIN32
//#ifdef _WIN64
#define ZELO_PLATFORM_WINDOWS
#elif defined(__APPLE__) || defined(__MACH__)
#include <TargetConditionals.h>
/* TARGET_OS_MAC exists on all the platforms
 * so we must check all of them (in this order)
 * to ensure that we're running on MAC
 * and not some other Apple platform */
#if TARGET_IPHONE_SIMULATOR == 1
#error "IOS simulator is not supported!"
#elif TARGET_OS_IPHONE == 1
#define ZELO_PLATFORM_IOS
#error "IOS is not supported!"
#elif TARGET_OS_MAC == 1
#define ZELO_PLATFORM_MACOS
#error "MacOS is not supported!"
#else
#error "Unknown Apple platform!"
#endif
/* We also have to check __ANDROID__ before __linux__
* since android is based on the linux kernel
* it has __linux__ defined */
#elif defined(__ANDROID__)
#define ZELO_PLATFORM_ANDROID
#error "Android is not supported!"
#elif defined(__linux__)
#define ZELO_PLATFORM_LINUX
#error "Linux is not supported!"
#else
/* Unknown compiler/platform */
//#error "Unknown platform!"
#endif // End of platform detection


/* Initial platform/compiler-related stuff to set.
*/
#define ZELO_PLATFORM_WIN32 1
#define ZELO_PLATFORM_LINUX 2
#define ZELO_PLATFORM_APPLE 3
#define ZELO_PLATFORM_APPLE_IOS 4
#define ZELO_PLATFORM_ANDROID 5
#define ZELO_PLATFORM_WINRT 7
#define ZELO_PLATFORM_EMSCRIPTEN 8

#define ZELO_COMPILER_MSVC 1
#define ZELO_COMPILER_GNUC 2
#define ZELO_COMPILER_BORL 3
#define ZELO_COMPILER_WINSCW 4
#define ZELO_COMPILER_GCCE 5
#define ZELO_COMPILER_CLANG 6

#define ZELO_ENDIAN_LITTLE 1
#define ZELO_ENDIAN_BIG 2

#define ZELO_ARCHITECTURE_32 1
#define ZELO_ARCHITECTURE_64 2

/* Finds the compiler type and version.
*/
#if (defined( __WIN32__ ) || defined( _WIN32 )) && defined(__ANDROID__) // We are using NVTegra
#   define ZELO_COMPILER ZELO_COMPILER_GNUC
#   define ZELO_COMP_VER 470
#elif defined( __GCCE__ )
#   define ZELO_COMPILER ZELO_COMPILER_GCCE
#   define ZELO_COMP_VER _MSC_VER
//# include <staticlibinit_gcce.h> // This is a GCCE toolchain workaround needed when compiling with GCCE
#elif defined( __WINSCW__ )
#   define ZELO_COMPILER ZELO_COMPILER_WINSCW
#   define ZELO_COMP_VER _MSC_VER
#elif defined( _MSC_VER )
#   define ZELO_COMPILER ZELO_COMPILER_MSVC
#   define ZELO_COMP_VER _MSC_VER
#elif defined( __clang__ )
#   define ZELO_COMPILER ZELO_COMPILER_CLANG
#   define ZELO_COMP_VER (((__clang_major__)*100) + \
        (__clang_minor__*10) + \
        __clang_patchlevel__)
#elif defined( __GNUC__ )
#   define ZELO_COMPILER ZELO_COMPILER_GNUC
#   define ZELO_COMP_VER (((__GNUC__)*100) + \
        (__GNUC_MINOR__*10) + \
        __GNUC_PATCHLEVEL__)
#elif defined( __BORLANDC__ )
#   define ZELO_COMPILER ZELO_COMPILER_BORL
#   define ZELO_COMP_VER __BCPLUSPLUS__
#   define __FUNCTION__ __FUNC__
#else
#   pragma error "No known compiler. Abort! Abort!"

#endif


#endif //ZELOENGINE_ZELOPLATFORM_H