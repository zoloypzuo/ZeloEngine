// Shader.cpp
// created on 2021/3/31
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Shader.h"
#include "Light.h"
#include "GLUtil.h"

Shader::Shader() : m_handle(glCreateProgram()) {
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
    glDetachShader(m_handle, g_shVert);
    glDeleteShader(g_shVert);

    glDetachShader(m_handle, g_shFrag);
    glDeleteShader(g_shFrag);

    glDeleteProgram(m_handle);
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
    glAttachShader(m_handle, g_shVert);

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
    glAttachShader(m_handle, g_shFrag);

    // flag the shaders to be deleted when the shader program is deleted
    glDeleteShader(g_shFrag);
}

void Shader::link() {
    char shErr[1024];
    int errlen = 0;
    GLint res = 0;
    // Link the shaders
    glLinkProgram(m_handle);
    glGetProgramiv(m_handle, GL_LINK_STATUS, &res);

    if (GL_FALSE == res)
        spdlog::error("Failed to link shader program");

    // validate
    glValidateProgram(m_handle);
    glGetProgramiv(m_handle, GL_VALIDATE_STATUS, &res);
    if (GL_FALSE == res) {
        glGetProgramInfoLog(m_handle, 1024, &errlen, shErr);
        spdlog::error("Error validating shader: {}", shErr);
    }

    m_initialized = true;
}

GLuint Shader::getHandle() const {
    return m_handle;
}

void Shader::createUniform(const std::string &name) {
    m_uniformLocationMap[name] = glGetUniformLocation(m_handle, name.c_str());
}

GLint Shader::getUniformLocation(const std::string &name) {
    return m_uniformLocationMap[name];
}

void Shader::bind() const {
    glUseProgram(m_handle);
}

void Shader::updateUniformDirectionalLight(const std::string &name, DirectionalLight *directionalLight) {
    bind();

    setUniformVec3f(name + ".base.color", directionalLight->getColor());
    setUniform1f(name + ".base.intensity", directionalLight->getIntensity());

    setUniformVec3f(name + ".direction", directionalLight->getParent()->getDirection());
}

void Shader::updateUniformPointLight(const std::string &name, PointLight *pointLight) {
    bind();

    setUniformVec3f(name + ".base.color", pointLight->getColor());
    setUniform1f(name + ".base.intensity", pointLight->getIntensity());

    setUniformAttenuation(name + ".attenuation", pointLight->getAttenuation());
    setUniformVec3f(name + ".position", pointLight->getParent()->getPosition());
    setUniform1f(name + ".range", pointLight->getRange());
}

void Shader::updateUniformSpotLight(const std::string &name, SpotLight *spotLight) {
    bind();

    setUniformVec3f(name + ".pointLight.base.color", spotLight->getColor());
    setUniform1f(name + ".pointLight.base.intensity", spotLight->getIntensity());

    setUniformAttenuation(name + ".pointLight.attenuation", spotLight->getAttenuation());
    setUniformVec3f(name + ".pointLight.position", spotLight->getParent()->getPosition());
    setUniform1f(name + ".pointLight.range", spotLight->getRange());

    setUniformVec3f(name + ".direction", spotLight->getParent()->getDirection());
    setUniform1f(name + ".cutoff", spotLight->getCutoff());
}

void Shader::setUniformAttenuation(const std::string &name, const std::shared_ptr<Attenuation> &attenuation) {
    setUniform1f(name + ".constant", attenuation->getConstant());
    setUniform1f(name + ".linear", attenuation->getLinear());
    setUniform1f(name + ".exponent", attenuation->getExponent());
}

void Shader::setUniform1i(const std::string &name, int value) {
    bind();

    createUniform(name);
    glUniform1i(getUniformLocation(name), value);
}

void Shader::setUniform1f(const std::string &name, float value) {
    bind();

    createUniform(name);
    glUniform1f(getUniformLocation(name), value);
}

void Shader::setUniformVec3f(const std::string &name, glm::vec3 vector) {
    bind();

    createUniform(name);
    glUniform3f(getUniformLocation(name), vector.x, vector.y, vector.z);
}

void Shader::setUniformMatrix4f(const std::string &name, const glm::mat4 &matrix) {
    bind();

    createUniform(name);
    glUniformMatrix4fv(getUniformLocation(name), 1, GL_FALSE, &(matrix)[0][0]);
}

bool Shader::isInitialized() const {
    return m_initialized;
}

void Shader::printActiveUniforms() const {
#ifdef __APPLE__
    // For OpenGL 4.1, use glGetActiveUniform
    GLint nUniforms, size, location, maxLen;
    GLchar *name;
    GLsizei written;
    GLenum type;

    glGetProgramiv(m_handle, GL_ACTIVE_UNIFORM_MAX_LENGTH, &maxLen);
    glGetProgramiv(m_handle, GL_ACTIVE_UNIFORMS, &nUniforms);

    name = new GLchar[maxLen];

    spdlog::debug("Active uniforms:\n");
    spdlog::debug("------------------------------------------------\n");
    for (GLuint i = 0; i < nUniforms; ++i) {
        glGetActiveUniform(m_handle, i, maxLen, &written, &size, &type, name);
        location = glGetUniformLocation(m_handle, name);
        spdlog::debug(" %-5d {} ({})\n", location, name, getTypeString(type));
    }

    delete[] name;
#else
    // For OpenGL 4.3 and above, use glGetProgramResource
    GLint numUniforms = 0;
    glGetProgramInterfaceiv(m_handle, GL_UNIFORM, GL_ACTIVE_RESOURCES, &numUniforms);

    GLenum properties[] = {GL_NAME_LENGTH, GL_TYPE, GL_LOCATION, GL_BLOCK_INDEX};

    spdlog::debug("Active uniforms:\n");
    for (int i = 0; i < numUniforms; ++i) {
        GLint results[4];
        glGetProgramResourceiv(m_handle, GL_UNIFORM, i, 4, properties, 4, NULL, results);

        if (results[3] != -1) continue;  // Skip uniforms in blocks
        GLint nameBufSize = results[0] + 1;
        char *name = new char[nameBufSize];
        glGetProgramResourceName(m_handle, GL_UNIFORM, i, nameBufSize, NULL, name);
        spdlog::debug("%-5d {} ({})\n", results[2], name, getTypeString(results[1]));
        delete[] name;
    }
#endif
}

void Shader::printActiveUniformBlocks() const {
#ifdef __APPLE__
    // For OpenGL 4.1, use glGetActiveUniformBlockiv
    GLint written, maxLength, maxUniLen, nBlocks, binding;
    GLchar *name;

    glGetProgramiv(m_handle, GL_ACTIVE_UNIFORM_BLOCK_MAX_NAME_LENGTH, &maxLength);
    glGetProgramiv(m_handle, GL_ACTIVE_UNIFORM_BLOCKS, &nBlocks);
    glGetProgramiv(m_handle, GL_ACTIVE_UNIFORM_MAX_LENGTH, &maxUniLen);
    GLchar *uniName = new GLchar[maxUniLen];
    name = new GLchar[maxLength];

    spdlog::debug("Active Uniform blocks: \n");
    spdlog::debug("------------------------------------------------\n");
    for (GLuint i = 0; i < nBlocks; i++) {
        glGetActiveUniformBlockName(m_handle, i, maxLength, &written, name);
        glGetActiveUniformBlockiv(m_handle, i, GL_UNIFORM_BLOCK_BINDING, &binding);
        spdlog::debug("Uniform block \"{}\" ({}):\n", name, binding);

        GLint nUnis;
        glGetActiveUniformBlockiv(m_handle, i, GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS, &nUnis);
        GLint *unifIndexes = new GLint[nUnis];
        glGetActiveUniformBlockiv(m_handle, i, GL_UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES, unifIndexes);

        for (int unif = 0; unif < nUnis; ++unif) {
            GLuint uniIndex = unifIndexes[unif];
            GLint size;
            GLenum type;

            glGetActiveUniform(m_handle, uniIndex, maxUniLen, &written, &size, &type, uniName);
            spdlog::debug("    {} ({})\n", name, getTypeString(type));
        }

        delete[] unifIndexes;
    }
    delete[] name;
    delete[] uniName;
#else
    GLint numBlocks = 0;

    glGetProgramInterfaceiv(m_handle, GL_UNIFORM_BLOCK, GL_ACTIVE_RESOURCES, &numBlocks);
    GLenum blockProps[] = {GL_NUM_ACTIVE_VARIABLES, GL_NAME_LENGTH};
    GLenum blockIndex[] = {GL_ACTIVE_VARIABLES};
    GLenum props[] = {GL_NAME_LENGTH, GL_TYPE, GL_BLOCK_INDEX};

    for (int block = 0; block < numBlocks; ++block) {
        GLint blockInfo[2];
        glGetProgramResourceiv(m_handle, GL_UNIFORM_BLOCK, block, 2, blockProps, 2, NULL, blockInfo);
        GLint numUnis = blockInfo[0];

        char *blockName = new char[blockInfo[1] + 1];
        glGetProgramResourceName(m_handle, GL_UNIFORM_BLOCK, block, blockInfo[1] + 1, NULL, blockName);
        spdlog::debug("Uniform block \"{}\":\n", blockName);
        delete[] blockName;

        auto *unifIndexes = new GLint[numUnis];
        glGetProgramResourceiv(m_handle, GL_UNIFORM_BLOCK, block, 1, blockIndex, numUnis, NULL, unifIndexes);

        for (int unif = 0; unif < numUnis; ++unif) {
            GLint uniIndex = unifIndexes[unif];
            GLint results[3];
            glGetProgramResourceiv(m_handle, GL_UNIFORM, uniIndex, 3, props, 3, NULL, results);

            GLint nameBufSize = results[0] + 1;
            char *name = new char[nameBufSize];
            glGetProgramResourceName(m_handle, GL_UNIFORM, uniIndex, nameBufSize, NULL, name);
            spdlog::debug("    {} ({})\n", name, getTypeString(results[1]));
            delete[] name;
        }

        delete[] unifIndexes;
    }
#endif
}

void Shader::printActiveAttributes() const {
#ifdef __APPLE__
    // For OpenGL 4.1, use glGetActiveAttrib
    GLint written, size, location, maxLength, nAttribs;
    GLenum type;
    GLchar *name;

    glGetProgramiv(m_handle, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &maxLength);
    glGetProgramiv(m_handle, GL_ACTIVE_ATTRIBUTES, &nAttribs);

    name = new GLchar[maxLength];
    spdlog::debug("Active Attributes: \n");
    spdlog::debug("------------------------------------------------\n");
    for (int i = 0; i < nAttribs; i++) {
        glGetActiveAttrib(m_handle, i, maxLength, &written, &size, &type, name);
        location = glGetAttribLocation(m_handle, name);
        spdlog::debug(" %-5d {} ({})\n", location, name, getTypeString(type));
    }
    delete[] name;
#else
    // >= OpenGL 4.3, use glGetProgramResource
    GLint numAttribs = 0;
    glGetProgramInterfaceiv(m_handle, GL_PROGRAM_INPUT, GL_ACTIVE_RESOURCES, &numAttribs);

    GLenum properties[] = {GL_NAME_LENGTH, GL_TYPE, GL_LOCATION};

    spdlog::debug("Active attributes:\n");
    for (int i = 0; i < numAttribs; ++i) {
        GLint results[3];
        glGetProgramResourceiv(m_handle, GL_PROGRAM_INPUT, i, 3, properties, 3, NULL, results);

        GLint nameBufSize = results[0] + 1;
        char *name = new char[nameBufSize];
        glGetProgramResourceName(m_handle, GL_PROGRAM_INPUT, i, nameBufSize, NULL, name);
        spdlog::debug("%-5d {} ({})\n", results[2], name, getTypeString(results[1]));
        delete[] name;
    }
#endif
}
