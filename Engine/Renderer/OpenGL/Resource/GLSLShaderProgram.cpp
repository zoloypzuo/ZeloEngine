// GLSLShaderProgram.cpp
// created on 2021/3/31
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLSLShaderProgram.h"
#include "Renderer/OpenGL/Light.h"
#include "Renderer/OpenGL/GLUtil.h"
#include "sol/sol.hpp"
#include "Core/ECS/Entity.h"

using namespace Zelo::Core::RHI;
struct shader_file_extension {
    const std::string &ext;
    EShaderType type;
};

const struct shader_file_extension extensions[] =
        {
                {".vs",   EShaderType::VERTEX},
                {".vert", EShaderType::VERTEX},
                {".gs",   EShaderType::GEOMETRY},
                {".geom", EShaderType::GEOMETRY},
                {".tcs",  EShaderType::TESS_CONTROL},
                {".tes",  EShaderType::TESS_EVALUATION},
                {".fs",   EShaderType::FRAGMENT},
                {".frag", EShaderType::FRAGMENT},
                {".cs",   EShaderType::COMPUTE}
        };

static GLenum GetGLShaderType(const EShaderType &shaderType) {
    switch (shaderType) {
        case EShaderType::VERTEX:
            return GL_VERTEX_SHADER;
        case EShaderType::FRAGMENT:
            return GL_FRAGMENT_SHADER;
        case EShaderType::GEOMETRY:
            return GL_GEOMETRY_SHADER;
        case EShaderType::TESS_CONTROL:
            return GL_TESS_CONTROL_SHADER;
        case EShaderType::TESS_EVALUATION:
            return GL_TESS_EVALUATION_SHADER;
        case EShaderType::COMPUTE:
            return GL_COMPUTE_SHADER;
        default:
            ZELO_ASSERT(false, "unhandled shader type");
            return GL_NONE;
    }
}

GLSLShaderProgram::GLSLShaderProgram() {
    m_handle = glCreateProgram();
}

GLSLShaderProgram::GLSLShaderProgram(const std::string &shaderAssetName) : m_name(shaderAssetName) {
    m_handle = glCreateProgram();
    GLSLShaderProgram::loadShader(shaderAssetName);
}

GLSLShaderProgram::~GLSLShaderProgram() {
    ZELO_ASSERT(m_handle, "shader handle not initialized");

    // Query the number of attached shaders
    GLint numShaders = 0;
    glGetProgramiv(m_handle, GL_ATTACHED_SHADERS, &numShaders);

    // Get the shader names
    GLuint *shaderNames = new GLuint[numShaders];
    glGetAttachedShaders(m_handle, numShaders, NULL, shaderNames);

    // Delete the shaders
    for (int i = 0; i < numShaders; i++) {
        glDetachShader(m_handle, shaderNames[i]);
        glDeleteShader(shaderNames[i]);
    }

    // Delete the program
    glDeleteProgram(m_handle);

    delete[] shaderNames;
}

void GLSLShaderProgram::link() {
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
        return;
    } else {
        findUniformLocations();
        m_initialized = true;
    }
}

void GLSLShaderProgram::createUniform(const std::string &name) {
    m_uniformLocationMap[name] = glGetUniformLocation(m_handle, name.c_str());
}

GLint GLSLShaderProgram::getUniformLocation(const std::string &name) {
    auto result = m_uniformLocationMap.find(name);
    if (result == m_uniformLocationMap.end()) {
        createUniform(name);
    }
    return m_uniformLocationMap[name];
}

void GLSLShaderProgram::bind() const {
    if (!isInitialized()) {
        spdlog::error("shader {} not linked before use", m_name);
    }
    glUseProgram(m_handle);
}

void GLSLShaderProgram::updateUniformDirectionalLight(const std::string &name, DirectionalLight *directionalLight) {
    bind();

    setUniformVec3f(name + ".base.color", directionalLight->getColor());
    setUniform1f(name + ".base.intensity", directionalLight->getIntensity());

    setUniformVec3f(name + ".direction", directionalLight->getParent()->getDirection());
}

void GLSLShaderProgram::updateUniformPointLight(const std::string &name, PointLight *pointLight) {
    bind();

    setUniformVec3f(name + ".base.color", pointLight->getColor());
    setUniform1f(name + ".base.intensity", pointLight->getIntensity());

    setUniformAttenuation(name + ".attenuation", pointLight->getAttenuation());
    setUniformVec3f(name + ".position", pointLight->getParent()->getPosition());
    setUniform1f(name + ".range", pointLight->getRange());
}

void GLSLShaderProgram::updateUniformSpotLight(const std::string &name, SpotLight *spotLight) {
    bind();

    setUniformVec3f(name + ".pointLight.base.color", spotLight->getColor());
    setUniform1f(name + ".pointLight.base.intensity", spotLight->getIntensity());

    setUniformAttenuation(name + ".pointLight.attenuation", spotLight->getAttenuation());
    setUniformVec3f(name + ".pointLight.position", spotLight->getParent()->getPosition());
    setUniform1f(name + ".pointLight.range", spotLight->getRange());

    setUniformVec3f(name + ".direction", spotLight->getParent()->getDirection());
    setUniform1f(name + ".cutoff", spotLight->getCutoff());
}

void
GLSLShaderProgram::setUniformAttenuation(const std::string &name, const std::shared_ptr<Attenuation> &attenuation) {
    setUniform1f(name + ".constant", attenuation->getConstant());
    setUniform1f(name + ".linear", attenuation->getLinear());
    setUniform1f(name + ".exponent", attenuation->getExponent());
}

void GLSLShaderProgram::setUniform1i(const std::string &name, int value) {
    bind();

    glUniform1i(getUniformLocation(name), value);
}

void GLSLShaderProgram::setUniform1f(const std::string &name, float value) {
    bind();

    glUniform1f(getUniformLocation(name), value);
}

void GLSLShaderProgram::setUniformVec3f(const std::string &name, glm::vec3 vector) {
    bind();

    glUniform3f(getUniformLocation(name), vector.x, vector.y, vector.z);
}

void GLSLShaderProgram::setUniformVec4f(const std::string &name, glm::vec4 vector) {
    bind();

    glUniform4f(getUniformLocation(name), vector.x, vector.y, vector.z, vector.w);
}

void GLSLShaderProgram::setUniformMatrix4f(const std::string &name, const glm::mat4 &matrix) {
    bind();

    glUniformMatrix4fv(getUniformLocation(name), 1, GL_FALSE, &(matrix)[0][0]);
}

void GLSLShaderProgram::printActiveUniforms() const {
#ifdef __APPLE__
    // For OpenGL 4.1, use glGetActiveUniform
    GLint nUniforms, size, location, maxLen;
    GLchar *name;
    GLsizei written;
    GLenum type;

    glGetProgramiv(m_handle, GL_ACTIVE_UNIFORM_MAX_LENGTH, &maxLen);
    glGetProgramiv(m_handle, GL_ACTIVE_UNIFORMS, &nUniforms);

    name = new GLchar[maxLen];

    spdlog::debug("Active uniforms:");
    spdlog::debug("------------------------------------------------");
    for (GLuint i = 0; i < nUniforms; ++i) {
        glGetActiveUniform(m_handle, i, maxLen, &written, &size, &type, name);
        location = glGetUniformLocation(m_handle, name);
        spdlog::debug(" {} {} ({})", location, name, getTypeString(type));
    }

    delete[] name;
#else
    // For OpenGL 4.3 and above, use glGetProgramResource
    GLint numUniforms = 0;
    glGetProgramInterfaceiv(m_handle, GL_UNIFORM, GL_ACTIVE_RESOURCES, &numUniforms);

    GLenum properties[] = {GL_NAME_LENGTH, GL_TYPE, GL_LOCATION, GL_BLOCK_INDEX};

    spdlog::debug("Active uniforms:");
    for (int i = 0; i < numUniforms; ++i) {
        GLint results[4];
        glGetProgramResourceiv(m_handle, GL_UNIFORM, i, 4, properties, 4, NULL, results);

        if (results[3] != -1) continue;  // Skip uniforms in blocks
        GLint nameBufSize = results[0] + 1;
        char *name = new char[nameBufSize];
        glGetProgramResourceName(m_handle, GL_UNIFORM, i, nameBufSize, NULL, name);
        spdlog::debug("{} {} ({})", results[2], name, getTypeString(results[1]));
        delete[] name;
    }
#endif
}

void GLSLShaderProgram::printActiveUniformBlocks() const {
#ifdef __APPLE__
    // For OpenGL 4.1, use glGetActiveUniformBlockiv
    GLint written, maxLength, maxUniLen, nBlocks, binding;
    GLchar *name;

    glGetProgramiv(m_handle, GL_ACTIVE_UNIFORM_BLOCK_MAX_NAME_LENGTH, &maxLength);
    glGetProgramiv(m_handle, GL_ACTIVE_UNIFORM_BLOCKS, &nBlocks);
    glGetProgramiv(m_handle, GL_ACTIVE_UNIFORM_MAX_LENGTH, &maxUniLen);
    GLchar *uniName = new GLchar[maxUniLen];
    name = new GLchar[maxLength];

    spdlog::debug("Active Uniform blocks: ");
    spdlog::debug("------------------------------------------------");
    for (GLuint i = 0; i < nBlocks; i++) {
        glGetActiveUniformBlockName(m_handle, i, maxLength, &written, name);
        glGetActiveUniformBlockiv(m_handle, i, GL_UNIFORM_BLOCK_BINDING, &binding);
        spdlog::debug("Uniform block \"{}\" ({}):", name, binding);

        GLint nUnis;
        glGetActiveUniformBlockiv(m_handle, i, GL_UNIFORM_BLOCK_ACTIVE_UNIFORMS, &nUnis);
        GLint *unifIndexes = new GLint[nUnis];
        glGetActiveUniformBlockiv(m_handle, i, GL_UNIFORM_BLOCK_ACTIVE_UNIFORM_INDICES, unifIndexes);

        for (int unif = 0; unif < nUnis; ++unif) {
            GLuint uniIndex = unifIndexes[unif];
            GLint size;
            GLenum type;

            glGetActiveUniform(m_handle, uniIndex, maxUniLen, &written, &size, &type, uniName);
            spdlog::debug("    {} ({})", name, getTypeString(type));
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
        spdlog::debug("Uniform block \"{}\":", blockName);
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
            spdlog::debug("{} {} ({})", name, getTypeString(results[1]));
            delete[] name;
        }

        delete[] unifIndexes;
    }
#endif
}

void GLSLShaderProgram::printActiveAttributes() const {
#ifdef __APPLE__
    // For OpenGL 4.1, use glGetActiveAttrib
    GLint written, size, location, maxLength, nAttribs;
    GLenum type;
    GLchar *name;

    glGetProgramiv(m_handle, GL_ACTIVE_ATTRIBUTE_MAX_LENGTH, &maxLength);
    glGetProgramiv(m_handle, GL_ACTIVE_ATTRIBUTES, &nAttribs);

    name = new GLchar[maxLength];
    spdlog::debug("Active Attributes: ");
    spdlog::debug("------------------------------------------------");
    for (int i = 0; i < nAttribs; i++) {
        glGetActiveAttrib(m_handle, i, maxLength, &written, &size, &type, name);
        location = glGetAttribLocation(m_handle, name);
        spdlog::debug("{} {} ({})", location, name, getTypeString(type));
    }
    delete[] name;
#else
    // >= OpenGL 4.3, use glGetProgramResource
    GLint numAttribs = 0;
    glGetProgramInterfaceiv(m_handle, GL_PROGRAM_INPUT, GL_ACTIVE_RESOURCES, &numAttribs);

    GLenum properties[] = {GL_NAME_LENGTH, GL_TYPE, GL_LOCATION};

    spdlog::debug("Active attributes:");
    for (int i = 0; i < numAttribs; ++i) {
        GLint results[3];
        glGetProgramResourceiv(m_handle, GL_PROGRAM_INPUT, i, 3, properties, 3, NULL, results);

        GLint nameBufSize = results[0] + 1;
        char *name = new char[nameBufSize];
        glGetProgramResourceName(m_handle, GL_PROGRAM_INPUT, i, nameBufSize, NULL, name);
        spdlog::debug("{} {} ({})", results[2], name, getTypeString(results[1]));
        delete[] name;
    }
#endif
}

void GLSLShaderProgram::addShader(const std::string &fileName) const {
    // Check the file name's extension to determine the shader type
    auto ext = std::filesystem::path(fileName).extension();
    auto shaderType = EShaderType::VERTEX;
    bool matchFound = false;
    int numExt = sizeof(extensions) / sizeof(shader_file_extension);
    for (int i = 0; i < numExt; i++) {
        if (ext == extensions[i].ext) {
            matchFound = true;
            shaderType = extensions[i].type;
            break;
        }
    }

    // If we didn't find a match, throw an exception
    if (!matchFound) {
        spdlog::error("Unrecognized extension: {}", ext.string());
        return;
    }

    // Pass the discovered shader type along
    addShader(fileName, shaderType);
}

void GLSLShaderProgram::addShader(const std::string &fileName, EShaderType shaderType) const {
    spdlog::debug("addShader {} {}", fileName, getShaderTypeString(static_cast<GLenum>(shaderType)));
    const Zelo::Resource &asset = Zelo::Resource(fileName);
    const char *c_code = asset.read();

    addShaderSrc(fileName, shaderType, c_code);
}

void
GLSLShaderProgram::addShaderSrc(const std::string &fileName, const EShaderType &shaderType, const char *c_code) const {
    GLuint shaderHandle = glCreateShader(GetGLShaderType(shaderType));

    glShaderSource(shaderHandle, 1, &c_code, NULL);

    // Compile the shader
    glCompileShader(shaderHandle);

    // Check for errors
    int result{};
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &result);
    if (GL_FALSE == result) {
        // Compile failed, get log
        int length = 0;
        std::string logString;
        glGetShaderiv(shaderHandle, GL_INFO_LOG_LENGTH, &length);
        if (length > 0) {
            char *c_log = new char[length];
            int written = 0;
            glGetShaderInfoLog(shaderHandle, length, &written, c_log);
            logString = c_log;
            delete[] c_log;
        }
        spdlog::error("{}: shader compliation failed{}", fileName, logString);
        return;
    } else {
        // Compile succeeded, attach shader
        glAttachShader(m_handle, shaderHandle);

        // flag the shaders to be deleted when the shader program is deleted
        glDeleteShader(shaderHandle);
    }
}

void GLSLShaderProgram::findUniformLocations() {
    m_uniformLocationMap.clear();

    GLint numUniforms = 0;
#ifdef __APPLE__
    // For OpenGL 4.1, use glGetActiveUniform
    GLint maxLen;
    GLchar *name;

    glGetProgramiv(m_handle, GL_ACTIVE_UNIFORM_MAX_LENGTH, &maxLen);
    glGetProgramiv(m_handle, GL_ACTIVE_UNIFORMS, &numUniforms);

    name = new GLchar[maxLen];
    for (GLuint i = 0; i < numUniforms; ++i) {
        GLint size;
        GLenum type;
        GLsizei written;
        glGetActiveUniform(m_handle, i, maxLen, &written, &size, &type, name);
        GLint location = glGetUniformLocation(m_handle, name);
        m_uniformLocationMap[name] = glGetUniformLocation(m_handle, name);
    }
    delete[] name;
#else
    // For OpenGL 4.3 and above, use glGetProgramResource
    glGetProgramInterfaceiv(m_handle, GL_UNIFORM, GL_ACTIVE_RESOURCES, &numUniforms);

    GLenum properties[] = {GL_NAME_LENGTH, GL_TYPE, GL_LOCATION, GL_BLOCK_INDEX};

    for (GLint i = 0; i < numUniforms; ++i) {
        GLint results[4];
        glGetProgramResourceiv(m_handle, GL_UNIFORM, i, 4, properties, 4, NULL, results);

        if (results[3] != -1) continue;  // Skip uniforms in blocks
        GLint nameBufSize = results[0] + 1;
        char *name = new char[nameBufSize];
        glGetProgramResourceName(m_handle, GL_UNIFORM, i, nameBufSize, NULL, name);
        m_uniformLocationMap[name] = results[2];
        delete[] name;
    }
#endif
}

void GLSLShaderProgram::loadShader(const std::string &fileName) const {
    auto asset = Zelo::Resource(fileName);
    sol::state lua;  // TODO 一个资源管理器维护一个lua
    sol::table result = lua.script(asset.read());
    std::string vertex_src = result["vertex_shader"];
    std::string fragment_src = result["fragment_shader"];
    addShaderSrc(fileName, EShaderType::VERTEX, vertex_src.c_str());
    addShaderSrc(fileName, EShaderType::FRAGMENT, fragment_src.c_str());
}

void GLSLShaderProgram::setUniformMatrix4f(const std::string &name, const glm::mat3 &matrix) {
    bind();

    glUniformMatrix3fv(getUniformLocation(name), 1, GL_FALSE, &(matrix)[0][0]);
}

void GLSLShaderProgram::bindFragDataLocation(const std::string &name, uint32_t slot) {
    bind();

    glBindFragDataLocation(m_handle, slot, name.c_str());
}
