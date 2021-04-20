// Shader.cpp
// created on 2021/3/31
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Shader.h"
#include "Light.h"

Shader::Shader() : g_shProg(glCreateProgram()) {
}

Shader::Shader(const std::string &shaderAssetName) : Shader() {

#if defined(GLES2) || defined(GLES3) || defined(EMSCRIPTEN)
    addVertex(Asset(shaderAssetName + "-gles.vs").read());
    addFragment(Asset(shaderAssetName + "-gles.fs").read());
#else
    addVertex(Asset(shaderAssetName + ".vs").read());
    addFragment(Asset(shaderAssetName + ".fs").read());
#endif
}

Shader::Shader(const char *vert_src, const char *frag_src) : Shader() {
    addVertex(vert_src);
    addFragment(frag_src);
}

Shader::~Shader() {
    glDetachShader(g_shProg, g_shVert);
    glDeleteShader(g_shVert);

    glDetachShader(g_shProg, g_shFrag);
    glDeleteShader(g_shFrag);

    glDeleteProgram(g_shProg);
}

void Shader::addVertex(const char *vert_src) {
    char shErr[1024];
    int errlen = 0;
    GLint res = 0;

    // Generate some IDs for our shader programs
    g_shVert = glCreateShader(GL_VERTEX_SHADER);

    // Assign our above shader source code to these IDs
    glShaderSource(g_shVert, 1, &vert_src, nullptr);

    // Attempt to compile the source code
    glCompileShader(g_shVert);

    // check if compilation was successful
    glGetShaderiv(g_shVert, GL_COMPILE_STATUS, &res);
    if (GL_FALSE == res) {
        glGetShaderInfoLog(g_shVert, 1024, &errlen, shErr);
        spdlog::error("Failed to compile vertex shader: {}", shErr);
        return;
    }

    // Attach these shaders to the shader program
    glAttachShader(g_shProg, g_shVert);

    // flag the shaders to be deleted when the shader program is deleted
    glDeleteShader(g_shVert);
}

void Shader::addFragment(const char *frag_src) {
    char shErr[1024];
    int errlen = 0;
    GLint res = 0;

    // Generate some IDs for our shader programs
    g_shFrag = glCreateShader(GL_FRAGMENT_SHADER);

    // Assign our above shader source code to these IDs
    glShaderSource(g_shFrag, 1, &frag_src, nullptr);

    // Attempt to compile the source code
    glCompileShader(g_shFrag);

    // check if compilation was successful
    glGetShaderiv(g_shFrag, GL_COMPILE_STATUS, &res);
    if (GL_FALSE == res) {
        glGetShaderInfoLog(g_shFrag, 1024, &errlen, shErr);
        spdlog::error("Failed to compile fragment shader: {}", shErr);
        return;
    }

    // Attach these shaders to the shader program
    glAttachShader(g_shProg, g_shFrag);

    // flag the shaders to be deleted when the shader program is deleted
    glDeleteShader(g_shFrag);
}

void Shader::link() const {
    char shErr[1024];
    int errlen = 0;
    GLint res = 0;
    // Link the shaders
    glLinkProgram(g_shProg);
    glGetProgramiv(g_shProg, GL_LINK_STATUS, &res);

    if (GL_FALSE == res)
        spdlog::error("Failed to link shader program");

    glValidateProgram(g_shProg);
    glGetProgramiv(g_shProg, GL_VALIDATE_STATUS, &res);
    if (GL_FALSE == res) {
        glGetProgramInfoLog(g_shProg, 1024, &errlen, shErr);
        spdlog::error("Error validating shader: {}", shErr);
    }
}

GLuint Shader::getProgram() const {
    return g_shProg;
}

void Shader::createUniform(const std::string &uniformName) {
    uniformLocation[uniformName] = glGetUniformLocation(g_shProg, uniformName.c_str());
}

GLint Shader::getUniformLocation(const std::string &uniformName) {
    return uniformLocation[uniformName];
}

void Shader::setAttribLocation(const char *name, int i) const {
    glBindAttribLocation(g_shProg, i, name);
}

void Shader::bind() const {
    glUseProgram(g_shProg);
}

void Shader::updateUniformDirectionalLight(const std::string &uniformName, DirectionalLight *directionalLight) {
    bind();

    setUniformVec3f(uniformName + ".base.color", directionalLight->getColor());
    setUniform1f(uniformName + ".base.intensity", directionalLight->getIntensity());

    setUniformVec3f(uniformName + ".direction", directionalLight->getParent()->getDirection());
}

void Shader::updateUniformPointLight(const std::string &uniformName, PointLight *pointLight) {
    bind();

    setUniformVec3f(uniformName + ".base.color", pointLight->getColor());
    setUniform1f(uniformName + ".base.intensity", pointLight->getIntensity());

    setUniformAttenuation(uniformName + ".attenuation", pointLight->getAttenuation());
    setUniformVec3f(uniformName + ".position", pointLight->getParent()->getPosition());
    setUniform1f(uniformName + ".range", pointLight->getRange());
}

void Shader::updateUniformSpotLight(const std::string &uniformName, SpotLight *spotLight) {
    bind();

    setUniformVec3f(uniformName + ".pointLight.base.color", spotLight->getColor());
    setUniform1f(uniformName + ".pointLight.base.intensity", spotLight->getIntensity());

    setUniformAttenuation(uniformName + ".pointLight.attenuation", spotLight->getAttenuation());
    setUniformVec3f(uniformName + ".pointLight.position", spotLight->getParent()->getPosition());
    setUniform1f(uniformName + ".pointLight.range", spotLight->getRange());

    setUniformVec3f(uniformName + ".direction", spotLight->getParent()->getDirection());
    setUniform1f(uniformName + ".cutoff", spotLight->getCutoff());
}

void Shader::setUniformAttenuation(const std::string &uniformName, const std::shared_ptr<Attenuation> &attenuation) {
    setUniform1f(uniformName + ".constant", attenuation->getConstant());
    setUniform1f(uniformName + ".linear", attenuation->getLinear());
    setUniform1f(uniformName + ".exponent", attenuation->getExponent());
}

void Shader::setUniform1i(const std::string &uniformName, int value) {
    bind();

    createUniform(uniformName);
    glUniform1i(getUniformLocation(uniformName), value);
}

void Shader::setUniform1f(const std::string &uniformName, float value) {
    bind();

    createUniform(uniformName);
    glUniform1f(getUniformLocation(uniformName), value);
}

void Shader::setUniformVec3f(const std::string &uniformName, glm::vec3 vector) {
    bind();

    createUniform(uniformName);
    glUniform3f(getUniformLocation(uniformName), vector.x, vector.y, vector.z);
}

void Shader::setUniformMatrix4f(const std::string &uniformName, const glm::mat4 &matrix) {
    bind();

    createUniform(uniformName);
    glUniformMatrix4fv(getUniformLocation(uniformName), 1, GL_FALSE, &(matrix)[0][0]);
}
