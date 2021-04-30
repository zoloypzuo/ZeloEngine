// Shader.h
// created on 2021/3/31
// author @zoloypzuo

#ifndef ZELOENGINE_SHADER_H
#define ZELOENGINE_SHADER_H

#include "ZeloPrerequisites.h"

#include "Asset.h"
#include "Attenuation.h"

class DirectionalLight;

class PointLight;

class SpotLight;

#if defined(GLES2)
#include <GLES2/gl2.h>
#elif defined(GLES3)
#include <GLES3/gl3.h>
#else

#include <gl/glew.h>

#endif

enum class GLSLShaderType {
    VERTEX = GL_VERTEX_SHADER,
    FRAGMENT = GL_FRAGMENT_SHADER,
    GEOMETRY = GL_GEOMETRY_SHADER,
    TESS_CONTROL = GL_TESS_CONTROL_SHADER,
    TESS_EVALUATION = GL_TESS_EVALUATION_SHADER,
    COMPUTE = GL_COMPUTE_SHADER
};

// TODO zyp rename to GLSLShaderProgram, inherit from ShaderBase class
class Shader {
public:
    Shader();

    explicit Shader(const std::string &shaderAssetName);

    ~Shader();

public:
    void loadShader(const std::string &fileName) const;

    void addShader(const std::string &fileName) const;

    void addShader(const std::string &fileName, GLSLShaderType shaderType) const;

    void link();

    void bind() const;

    void findUniformLocations();

    void setUniformVec3f(const std::string &name, glm::vec3 vector);

    void setUniform1i(const std::string &name, int value);

    void setUniform1f(const std::string &name, float value);

    void setUniformMatrix4f(const std::string &name, const glm::mat4 &matrix);

    // TODO decouple and remove these api
    void updateUniformDirectionalLight(const std::string &name, DirectionalLight *directionalLight);

    void updateUniformPointLight(const std::string &name, PointLight *pointLight);

    void updateUniformSpotLight(const std::string &name, SpotLight *spotLight);

    void setUniformAttenuation(const std::string &name, const std::shared_ptr<Attenuation> &attenuation);

    // debug
    void printActiveUniforms() const;

    void printActiveUniformBlocks() const;

    void printActiveAttributes() const;

public:
    GLuint getHandle() const;

    bool isInitialized() const;

private:
    GLuint m_handle{};
    bool m_initialized{};

    std::map<std::string, GLint> m_uniformLocationMap;

    std::string m_name{};  // for debug

private:
    void createUniform(const std::string &name);

    GLint getUniformLocation(const std::string &name);

    void addShaderSrc(const std::string &fileName, const GLSLShaderType &shaderType, const char *c_code) const;
};


#endif //ZELOENGINE_SHADER_H