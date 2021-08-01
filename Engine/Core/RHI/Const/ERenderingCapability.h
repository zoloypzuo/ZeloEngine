// ERenderingCapability.h
// created on 2021/8/1
// author @zoloypzuo
#pragma once

namespace Zelo::Core::RHI {
// glEnable, glDisable
enum class ERenderingCapability {
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

enum class EComparaisonAlgorithm
{
    NEVER			= 0x0200,
    LESS			= 0x0201,
    EQUAL			= 0x0202,
    LESS_EQUAL		= 0x0203,
    GREATER			= 0x0204,
    NOTEQUAL		= 0x0205,
    GREATER_EQUAL	= 0x0206,
    ALWAYS			= 0x0207
};

enum class ECullFace
{
    FRONT			= 0x0404,
    BACK			= 0x0405,
    FRONT_AND_BACK	= 0x0408
};

enum class ECullingOptions
{
    NONE				= 0x0,
    FRUSTUM_PER_MODEL	= 0x1,
    FRUSTUM_PER_MESH	= 0x2
};

inline ECullingOptions operator~ (ECullingOptions a) { return (ECullingOptions)~(int)a; }
inline ECullingOptions operator| (ECullingOptions a, ECullingOptions b) { return (ECullingOptions)((int)a | (int)b); }
inline ECullingOptions operator& (ECullingOptions a, ECullingOptions b) { return (ECullingOptions)((int)a & (int)b); }
inline ECullingOptions operator^ (ECullingOptions a, ECullingOptions b) { return (ECullingOptions)((int)a ^ (int)b); }
inline ECullingOptions& operator|= (ECullingOptions& a, ECullingOptions b) { return (ECullingOptions&)((int&)a |= (int)b); }
inline ECullingOptions& operator&= (ECullingOptions& a, ECullingOptions b) { return (ECullingOptions&)((int&)a &= (int)b); }
inline ECullingOptions& operator^= (ECullingOptions& a, ECullingOptions b) { return (ECullingOptions&)((int&)a ^= (int)b); }
inline bool IsFlagSet(ECullingOptions flag, ECullingOptions mask) { return (int)flag & (int)mask; }

enum class EOperation
{
    KEEP			= 0x1E00,
    ZERO			= 0,
    REPLACE			= 0x1E01,
    INCREMENT		= 0x1E02,
    INCREMENT_WRAP	= 0x8507,
    DECREMENT		= 0x1E03,
    DECREMENT_WRAP	= 0x8508,
    INVERT			= 0x150A
};
}
