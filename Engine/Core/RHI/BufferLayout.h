// BufferLayout.h
// created on 2021/6/6
// author @zoloypzuo

#ifndef ZELOENGINE_BUFFERLAYOUT_H
#define ZELOENGINE_BUFFERLAYOUT_H

#include "ZeloPrerequisites.h"

enum class ShaderDataType {
    None = 0, Float, Float2, Float3, Float4, Mat3, Mat4, Int, Int2, Int3, Int4, Bool
};

struct BufferElement {
    std::string Name{};
    ShaderDataType Type{};
    uint32_t Size{};
    size_t Offset{};
    bool Normalized{};

    BufferElement() = default;

    BufferElement(
            ShaderDataType type,
            const std::string &name,
            bool normalized = false
    );

    uint32_t GetComponentCount() const;
};

class BufferLayout {
    // 描述一个struct，自动计算所有字段的offset
public:
    BufferLayout() = default;

    BufferLayout(std::initializer_list<BufferElement> elements)
            : m_Elements(elements) {
        CalculateOffsetsAndStride();
    }

    uint32_t GetStride() const { return m_Stride; }

    const std::vector<BufferElement> &GetElements() const { return m_Elements; }

    std::vector<BufferElement>::iterator begin() { return m_Elements.begin(); }

    std::vector<BufferElement>::iterator end() { return m_Elements.end(); }

    std::vector<BufferElement>::const_iterator begin() const { return m_Elements.begin(); }

    std::vector<BufferElement>::const_iterator end() const { return m_Elements.end(); }

private:
    void CalculateOffsetsAndStride();

private:
    std::vector<BufferElement> m_Elements;
    uint32_t m_Stride = 0;
};




#endif //ZELOENGINE_BUFFERLAYOUT_H
