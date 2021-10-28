// EAccessSpecifier.h
// created on 2021/10/29
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

namespace Zelo::Core::RHI {
enum class EAccessSpecifier {
    STREAM_DRAW = 0x88E0,
    STREAM_READ = 0x88E1,
    STREAM_COPY = 0x88E2,
    DYNAMIC_DRAW = 0x88E8,
    DYNAMIC_READ = 0x88E9,
    DYNAMIC_COPY = 0x88EA,
    STATIC_DRAW = 0x88E4,
    STATIC_READ = 0x88E5,
    STATIC_COPY = 0x88E6
};
}
