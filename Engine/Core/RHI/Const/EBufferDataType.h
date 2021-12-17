#pragma once

namespace Zelo::Core::RHI {
enum class EBufferDataType {
    None = 0,
    Float, Float2, Float3, Float4, UByte,
    Mat3, Mat4,
    Int, Int2, Int3, Int4, Bool
};
}
