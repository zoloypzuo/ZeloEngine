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

#include <GL/glew.h>

#endif

class Shader {
public:
    Shader();

    explicit Shader(const std::string &shaderAssetName);

    Shader(const char *vert_src, const char *frag_src);

    ~Shader();

    void addVertex(const char *vert_src);

    void addFragment(const char *frag_src);

    void link() const;

    void createUniform(const std::string &uniformName);

    GLint getUniformLocation(const std::string &uniformName);

    void setAttribLocation(const char *name, int i) const;

    GLuint getProgram() const;

    void bind() const;

    void updateUniformDirectionalLight(const std::string &uniformName, DirectionalLight *directionalLight);

    void updateUniformPointLight(const std::string &uniformName, PointLight *pointLight);

    void updateUniformSpotLight(const std::string &uniformName, SpotLight *spotLight);

    void setUniformAttenuation(const std::string &uniformName, const std::shared_ptr<Attenuation>& attenuation);

    void setUniformVec3f(const std::string &uniformName, glm::vec3 vector);

    void setUniform1i(const std::string &uniformName, int value);

    void setUniform1f(const std::string &uniformName, float value);

    void setUniformMatrix4f(const std::string &uniformName, const glm::mat4 &matrix);

private:
    GLuint g_shVert{};
    GLuint g_shFrag{};
    GLuint g_shProg{};

    std::map<std::string, GLint> uniformLocation;
};


#endif //ZELOENGINE_SHADER_H