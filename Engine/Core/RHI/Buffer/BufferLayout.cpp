// BufferLayout.cpp
// created on 2021/6/6
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "BufferLayout.h"

using namespace Zelo::Core::RHI;

uint32_t ShaderDataTypeSize(EBufferDataType type) {
    switch (type) {
        case EBufferDataType::Float:
            return 4;
        case EBufferDataType::Float2:
            return 4 * 2;
        case EBufferDataType::Float3:
            return 4 * 3;
        case EBufferDataType::Float4:
            return 4 * 4;
        case EBufferDataType::UByte:
            return 4 * 1;
        case EBufferDataType::Mat3:
            return 4 * 3 * 3;
        case EBufferDataType::Mat4:
            return 4 * 4 * 4;
        case EBufferDataType::Int:
            return 4;
        case EBufferDataType::Int2:
            return 4 * 2;
        case EBufferDataType::Int3:
            return 4 * 3;
        case EBufferDataType::Int4:
            return 4 * 4;
        case EBufferDataType::Bool:
            return 1;
        case EBufferDataType::None:
            break;
    }

    ZELO_CORE_ASSERT(false, "Unknown ShaderDataType!");
    return 0;
}

BufferElement::BufferElement(
        EBufferDataType type,
        const std::string &name,
        bool normalized
) : Name(name),
    Type(type),
    Size(ShaderDataTypeSize(type)),
    Offset(0),
    Normalized(normalized) {
}

uint32_t BufferElement::getComponentCount() const {
    switch (Type) {
        case EBufferDataType::Float:
            return 1;
        case EBufferDataType::Float2:
            return 2;
        case EBufferDataType::Float3:
            return 3;
        case EBufferDataType::Float4:
            return 4;
        case EBufferDataType::UByte:
            return 4;
        case EBufferDataType::Mat3:
            return 3; // 3* float3
        case EBufferDataType::Mat4:
            return 4; // 4* float4
        case EBufferDataType::Int:
            return 1;
        case EBufferDataType::Int2:
            return 2;
        case EBufferDataType::Int3:
            return 3;
        case EBufferDataType::Int4:
            return 4;
        case EBufferDataType::Bool:
            return 1;
        case EBufferDataType::None:
            break;
    }

    ZELO_CORE_ASSERT(false, "Unknown ShaderDataType!");
    return 0;
}

void BufferLayout::calculateOffsetsAndStride() {
    size_t offset = 0;
    m_Stride = 0;
    for (auto &element: m_Elements) {
        element.Offset = offset;
        offset += element.Size;
        m_Stride += element.Size;
    }
}
