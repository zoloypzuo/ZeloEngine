// GLSLShaderProgram.h
// created on 2021/3/31
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "Core/RHI/Resource/Shader.h"
#include "Core/Resource/Resource.h"
#include "Core/RHI/Const/EShaderType.h"
#include "Core/RHI/Object/Light.h"

#include <any>

enum class UniformType : uint32_t {
    // int float vec234 mat4 texture23
    UNIFORM_BOOL = 0x8B56,
    UNIFORM_INT = 0x1404,
    UNIFORM_FLOAT = 0x1406,
    UNIFORM_FLOAT_VEC2 = 0x8B50,
    UNIFORM_FLOAT_VEC3 = 0x8B51,
    UNIFORM_FLOAT_VEC4 = 0x8B52,
    UNIFORM_FLOAT_MAT4 = 0x8B5C,
    UNIFORM_DOUBLE_MAT4 = 0x8F48,
    UNIFORM_SAMPLER_2D = 0x8B5E,
    UNIFORM_SAMPLER_CUBE = 0x8B60
};

struct UniformInfo {
    UniformType type;
    std::string name;
    uint32_t location;
    std::any defaultValue;

public:
    UniformInfo(
            UniformType type_,
            const std::string &name_,
            uint32_t location_,
            const std::any &defaultValue_
    ) : type(type_), name(name_), location(location_), defaultValue(defaultValue_) {}
};

class GLSLShaderProgram : public Shader {
public:
    GLSLShaderProgram();

    explicit GLSLShaderProgram(const std::string &shaderAssetName);

    ~GLSLShaderProgram();

public:
    void loadShader(const std::string &fileName) const override;

    void addShader(const std::string &fileName) const override;

    void addShader(const std::string &fileName, Zelo::Core::RHI::EShaderType shaderType) const override;

    void link() override;

    void bind() const override;

    void findUniformLocations() override;

    void bindFragDataLocation(const std::string &name, uint32_t slot) override;

    GLint getUniformLocation(const std::string &name);

    void setUniformVec3f(const std::string &name, glm::vec3 vector) override;

    void setUniformVec4f(const std::string &name, glm::vec4 vector) override;

    void setUniform1i(const std::string &name, int value) override;

    void setUniform1f(const std::string &name, float value) override;

    void setUniformMatrix4f(const std::string &name, const glm::mat4 &matrix) override;

    void setUniformMatrix4f(const std::string &name, const glm::mat3 &matrix) override;

    // TODO decouple and remove these api
    void updateUniformDirectionalLight(const std::string &name, DirectionalLight *directionalLight);

    void updateUniformPointLight(const std::string &name, PointLight *pointLight);

    void updateUniformSpotLight(const std::string &name, SpotLight *spotLight);

    void setUniformAttenuation(const std::string &name, const std::shared_ptr<Attenuation> &attenuation);

    // debug
    void printActiveUniforms() const override;

    void printActiveUniformBlocks() const override;

    void printActiveAttributes() const override;

    void queryUniforms();

    UniformInfo *getUniformInfo(const std::string &name);

    static bool isEngineUBOMember(const std::string &uniformName);

private:
    std::map<std::string, GLint> m_uniformLocationMap;
    std::vector<UniformInfo> m_uniforms{};

    std::string m_name{};  // for debug

private:
    void createUniform(const std::string &name);

    void addShaderSrc(const std::string &fileName,
                      const Zelo::Core::RHI::EShaderType &shaderType,
                      const char *c_code) const;
};
