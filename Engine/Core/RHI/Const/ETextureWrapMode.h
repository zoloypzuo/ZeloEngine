#pragma once

namespace Zelo::Core::RHI {
enum class ETextureFilterMode {
    REPEAT = 0x2901;
    CLAMP_TO_EDGE = 0x812F;
    MIRRORED_REPEAT = 0x8370;
};
}