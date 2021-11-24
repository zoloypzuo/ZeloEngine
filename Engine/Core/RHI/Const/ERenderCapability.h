// ERenderCapability.h
// created on 2021/8/1
// author @zoloypzuo
#pragma once

namespace Zelo::Core::RHI {
// glEnable, glDisable
enum class ERenderCapability {
    BLEND = 0x0BE2,
    CULL_FACE = 0x0B44,
    DEPTH_TEST = 0x0B71,
    DITHER = 0x0BD0,
    POLYGON_OFFSET_FILL = 0x8037,
    SAMPLE_ALPHA_TO_COVERAGE = 0x809E,
    SAMPLE_COVERAGE = 0x80A0,
    SCISSOR_TEST = 0x0C11,
    STENCIL_TEST = 0x0B90,
    MULTISAMPLE = 0x809D
};

enum class EComparaisonAlgorithm {
    NEVER = 0x0200,
    LESS = 0x0201,
    EQUAL = 0x0202,
    LESS_EQUAL = 0x0203,
    GREATER = 0x0204,
    NOTEQUAL = 0x0205,
    GREATER_EQUAL = 0x0206,
    ALWAYS = 0x0207
};

enum class ECullFace {
    FRONT = 0x0404,
    BACK = 0x0405,
    FRONT_AND_BACK = 0x0408
};

enum class ECullingOptions {
    NONE = 0x0,
    FRUSTUM_PER_MODEL = 0x1,
    FRUSTUM_PER_MESH = 0x2
};

inline ECullingOptions operator~(ECullingOptions a) { return (ECullingOptions) ~(int) a; }

inline ECullingOptions operator|(ECullingOptions a, ECullingOptions b) { return (ECullingOptions) ((int) a | (int) b); }

inline ECullingOptions operator&(ECullingOptions a, ECullingOptions b) { return (ECullingOptions) ((int) a & (int) b); }

inline ECullingOptions operator^(ECullingOptions a, ECullingOptions b) { return (ECullingOptions) ((int) a ^ (int) b); }

inline ECullingOptions &
operator|=(ECullingOptions &a, ECullingOptions b) { return (ECullingOptions &) ((int &) a |= (int) b); }

inline ECullingOptions &
operator&=(ECullingOptions &a, ECullingOptions b) { return (ECullingOptions &) ((int &) a &= (int) b); }

inline ECullingOptions &
operator^=(ECullingOptions &a, ECullingOptions b) { return (ECullingOptions &) ((int &) a ^= (int) b); }

inline bool IsFlagSet(ECullingOptions flag, ECullingOptions mask) { return (int) flag & (int) mask; }

enum class EOperation {
    KEEP = 0x1E00,
    ZERO = 0,
    REPLACE = 0x1E01,
    INCREMENT = 0x1E02,
    INCREMENT_WRAP = 0x8507,
    DECREMENT = 0x1E03,
    DECREMENT_WRAP = 0x8508,
    INVERT = 0x150A
};

enum class EPixelDataFormat {
    COLOR_INDEX = 0x1900,
    STENCIL_INDEX = 0x1901,
    DEPTH_COMPONENT = 0x1902,
    RED = 0x1903,
    GREEN = 0x1904,
    BLUE = 0x1905,
    ALPHA = 0x1906,
    RGB = 0x1907,
    BGR = 0x80E0,
    RGBA = 0x1908,
    BGRA = 0x80E1,
    LUMINANCE = 0x1909,
    LUMINANCE_ALPHA = 0x190A,
};

enum class EPixelDataType {
    BYTE = 0x1400,
    UNSIGNED_BYTE = 0x1401,
    BITMAP = 0x1A00,
    SHORT = 0x1402,
    UNSIGNED_SHORT = 0x1403,
    INT = 0x1404,
    UNSIGNED_INT = 0x1405,
    FLOAT = 0x1406,
    UNSIGNED_BYTE_3_3_2 = 0x8032,
    UNSIGNED_BYTE_2_3_3_REV = 0x8362,
    UNSIGNED_SHORT_5_6_5 = 0x8363,
    UNSIGNED_SHORT_5_6_5_REV = 0x8364,
    UNSIGNED_SHORT_4_4_4_4 = 0x8033,
    UNSIGNED_SHORT_4_4_4_4_REV = 0x8365,
    UNSIGNED_SHORT_5_5_5_1 = 0x8034,
    UNSIGNED_SHORT_1_5_5_5_REV = 0x8366,
    UNSIGNED_INT_8_8_8_8 = 0x8035,
    UNSIGNED_INT_8_8_8_8_REV = 0x8367,
    UNSIGNED_INT_10_10_10_2 = 0x8036,
    UNSIGNED_INT_2_10_10_10_REV = 0x8368
};
}
