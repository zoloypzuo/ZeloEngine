// ZeloPlatform.h
// created on 2021/3/28
// author @zoloypzuo

#ifndef ZELOENGINE_ZELOPLATFORM_H
#define ZELOENGINE_ZELOPLATFORM_H

#include "ZeloPrerequisites.h"


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