// GLSLShaderProgram.h
// created on 2021/3/31
// author @zoloypzuo

#ifndef ZELOENGINE_GLSLSHADERPROGRAM_H
#define ZELOENGINE_GLSLSHADERPROGRAM_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "Core/RHI/Resource/Shader.h"
#include "Core/Resource/Resource.h"
#include "Renderer/OpenGL/Attenuation.h"
#include "Core/RHI/Const/EShaderType.h"
#include "Light.h"

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

private:
    std::map<std::string, GLint> m_uniformLocationMap;

    std::string m_name{};  // for debug

private:
    void createUniform(const std::string &name);

    void addShaderSrc(const std::string &fileName, const Zelo::Core::RHI::EShaderType &shaderType, const char *c_code) const;
};

#endif //ZELOENGINE_GLSLSHADERPROGRAM_H