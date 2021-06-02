// Shader.h
// created on 2021/6/2
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"

#include "glad/glad.h"

enum class ShaderType {
    VERTEX = GL_VERTEX_SHADER,
    FRAGMENT = GL_FRAGMENT_SHADER,
    GEOMETRY = GL_GEOMETRY_SHADER,
    TESS_CONTROL = GL_TESS_CONTROL_SHADER,
    TESS_EVALUATION = GL_TESS_EVALUATION_SHADER,
    COMPUTE = GL_COMPUTE_SHADER
};

class Shader {
public:
    virtual void loadShader(const std::string &fileName) const = 0;

    virtual void addShader(const std::string &fileName) const = 0;

    // TODO move shader type to here
    virtual void addShader(const std::string &fileName, ShaderType shaderType) const = 0;

    virtual void link() = 0;

    virtual void bind() const = 0;

    virtual void findUniformLocations() = 0;

    virtual void setUniformVec3f(const std::string &name, glm::vec3 vector) = 0;

    virtual void setUniformVec4f(const std::string &name, glm::vec4 vector) = 0;

    virtual void setUniform1i(const std::string &name, int value) = 0;

    virtual void setUniform1f(const std::string &name, float value) = 0;

    virtual void setUniformMatrix4f(const std::string &name, const glm::mat4 &matrix) = 0;

    virtual void setUniformMatrix4f(const std::string &name, const glm::mat3 &matrix) = 0;

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


