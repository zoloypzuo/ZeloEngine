// BufferLayout.h
// created on 2021/6/6
// author @zoloypzuo
#ifndef ZELOENGINE_BUFFERLAYOUT_H
#define ZELOENGINE_BUFFERLAYOUT_H

#include "ZeloPrerequisites.h"
#include "Core/RHI/Const/EShaderType.h"

// TODO OPTIMIZE pack alignment
struct BufferElement {
    std::string Name{};
    Zelo::Core::RHI::ShaderDataType Type{};
    uint32_t Size{};
    size_t Offset{};
    bool Normalized{};

    BufferElement() = default;

    BufferElement(
            Zelo::Core::RHI::ShaderDataType type,
            const std::string &name,
            bool normalized = false
    );

    uint32_t getComponentCount() const;
};

class BufferLayout {
    // 描述一个struct，自动计算所有字段的offset
public:
    BufferLayout() = default;

    BufferLayout(std::initializer_list<BufferElement> elements)
            : m_Elements(elements) {
        calculateOffsetsAndStride();
    }

    uint32_t getStride() const { return m_Stride; }

    const std::vector<BufferElement> &getElements() const { return m_Elements; }

    std::vector<BufferElement>::iterator begin() { return m_Elements.begin(); }

    std::vector<BufferElement>::iterator end() { return m_Elements.end(); }

    std::vector<BufferElement>::const_iterator begin() const { return m_Elements.begin(); }

    std::vector<BufferElement>::const_iterator end() const { return m_Elements.end(); }

private:
    void calculateOffsetsAndStride();

private:
    std::vector<BufferElement> m_Elements;
    uint32_t m_Stride = 0;
};

#endif //ZELOENGINE_BUFFERLAYOUT_H
