// ShaderType.h
// created on 2021/6/6
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"

enum class ShaderDataType {
    None = 0, Float, Float2, Float3, Float4, Mat3, Mat4, Int, Int2, Int3, Int4, Bool
};

enum class ShaderType {
    VERTEX,
    FRAGMENT,
    GEOMETRY,
    TESS_CONTROL,
    TESS_EVALUATION,
    COMPUTE,
};