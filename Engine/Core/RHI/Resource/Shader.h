// Shader.h
// created on 2021/6/2
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Core/RHI/Const/EShaderType.h"

class Shader {
public:
    virtual void loadShader(std::string_view fileName) const = 0;

    virtual void addShader(std::string_view fileName) const = 0;

    virtual void addShader(std::string_view fileName, Zelo::Core::RHI::EShaderType shaderType) const = 0;

    virtual void link() = 0;

    virtual void bind() const = 0;

    virtual void findUniformLocations() = 0;

    virtual void bindFragDataLocation(std::string_view name, uint32_t slot) = 0;

    virtual void setUniformVec3f(std::string_view name, glm::vec3 vector) = 0;

    virtual void setUniformVec4f(std::string_view name, glm::vec4 vector) = 0;

    virtual void setUniform1i(std::string_view name, int value) = 0;

    virtual void setUniform1f(std::string_view name, float value) = 0;

    virtual void setUniformMatrix4f(std::string_view name, const glm::mat4 &matrix) = 0;

    virtual void setUniformMatrix4f(std::string_view name, const glm::mat3 &matrix) = 0;

    virtual void printActiveUniforms() const = 0;

    virtual void printActiveUniformBlocks() const = 0;

    virtual void printActiveAttributes() const = 0;

public:
    uint32_t getHandle() const { return m_handle; }

    bool isInitialized() const { return m_initialized; }

protected:
    uint32_t m_handle{};
    bool m_initialized{};
};

