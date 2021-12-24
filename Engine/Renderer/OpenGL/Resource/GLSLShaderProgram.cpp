// GLSLShaderProgram.cpp
// created on 2021/3/31
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLSLShaderProgram.h"

#include "Core/LuaScript/LuaScriptManager.h"

#include "Renderer/OpenGL/Resource/GLTexture.h"
#include "Renderer/OpenGL/GLUtil.h"

using namespace Zelo::Core::RHI;
using namespace Zelo::Core::LuaScript;
using namespace Zelo::Renderer::OpenGL;

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

std::string prettyShaderSource(const char *text) {
    std::stringstream ss{};
    int line = 1;

    ss << "\n(" << line << ") ";
    while (text && *text++) {
        if (*text == '\n') {
            ss << "\n(" << ++line << ") ";
        } else if (*text == '\r') {
        } else {
            ss << *text;
        }
    }
    ss << "\n";

    return ss.str();
}

std::string loadHeader(const std::string &headerName) {
    sol::state &luam = LuaScriptManager::getSingleton();
    std::string glsl_src(Zelo::Resource(headerName).read());
    Zelo::ReplaceString(glsl_src, "//", "");  // generate lua code
    return luam.script(glsl_src);
}

void handleInclude(std::string &code) {
    while (code.find("#include ") != std::string::npos) {
        const auto pos = code.find("#include ");
        const auto p1 = code.find('"', pos);
        const auto p2 = code.find('"', p1 + 1);
        ZELO_ASSERT(p1 != std::string::npos && p2 != std::string::npos && p2 > p1, "include stmt syntax error");
        const std::string name = code.substr(p1 + 1, p2 - p1 - 1);
        const std::string include = loadHeader(name);
        code.replace(pos, p2 - pos + 1, include.c_str());
    }
}

GLSLShaderProgram::GLSLShaderProgram() {
    m_handle = glCreateProgram();
}

GLSLShaderProgram::GLSLShaderProgram(const std::string &shaderAssetName) : m_name(shaderAssetName) {
    m_handle = glCreateProgram();
    GLSLShaderProgram::loadShader(shaderAssetName);
    link();
}

GLSLShaderProgram::~GLSLShaderProgram() {
    ZELO_ASSERT(m_handle, "shader handle not initialized");

    // Delete the program
    glDeleteProgram(m_handle);
}

void GLSLShaderProgram::link() {
    char shErr[1024];
    int errlen = 0;
    GLint res = 0;
    // Link the shaders
    glLinkProgram(m_handle);
    glGetProgramiv(m_handle, GL_LINK_STATUS, &res);

    if (GL_FALSE == res) {
        spdlog::error("Failed to link shader program");
    }

    // validate
    glValidateProgram(m_handle);
    glGetProgramiv(m_handle, GL_VALIDATE_STATUS, &res);
    if (GL_FALSE == res) {
        glGetProgramInfoLog(m_handle, 1024, &errlen, shErr);
        spdlog::error("Error validating shader: {}", shErr);
        return;
    } else {
        findUniformLocations();
        queryUniforms();
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

void GLSLShaderProgram::unbind() const {
    glUseProgram(0);
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

int GLSLShaderProgram::getUniform1i(const std::string &name) {
    int i{};
    glGetUniformiv(m_handle, getUniformLocation(name), &i);
    return i;
}

float GLSLShaderProgram::getUniform1f(const std::string &name) {
    float f{};
    glGetUniformfv(m_handle, getUniformLocation(name), &f);
    return f;
}

glm::vec2 GLSLShaderProgram::getUniformVec2(const std::string &name) {
    glm::vec2 v2{};
    glGetUniformfv(m_handle, getUniformLocation(name), glm::value_ptr(v2));
    return v2;
}

glm::vec3 GLSLShaderProgram::getUniformVec3(const std::string &name) {
    glm::vec3 v3{};
    glGetUniformfv(m_handle, getUniformLocation(name), glm::value_ptr(v3));
    return v3;
}

glm::vec4 GLSLShaderProgram::getUniformVec4(const std::string &name) {
    glm::vec4 v4{};
    glGetUniformfv(m_handle, getUniformLocation(name), glm::value_ptr(v4));
    return v4;
}

void GLSLShaderProgram::printActiveUniforms() const {
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
}

void GLSLShaderProgram::printActiveUniformBlocks() const {
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
}

void GLSLShaderProgram::printActiveAttributes() const {
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

void GLSLShaderProgram::addShaderSrc(const std::string &fileName,
                                     const EShaderType &shaderType,
                                     const char *c_code) const {
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
        spdlog::error("{}: shader compliation failed{}\n{}", fileName, logString, prettyShaderSource(c_code));
        ZELO_ASSERT(false);
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
}

void GLSLShaderProgram::loadShader(const std::string &fileName) const {
    auto ext = std::filesystem::path(fileName).extension();
    if (ext == ".glsl") {
        sol::state &luam = LuaScriptManager::getSingleton();
        std::string glsl_src(Zelo::Resource(fileName).read());
        Zelo::ReplaceString(glsl_src, "//", "");  // generate lua code
        sol::table result = luam.script(glsl_src);

        // compute shader is compiled alone
        auto cs_src = result.get<sol::optional<std::string>>("compute_shader");
        if (cs_src.has_value()) {
            addShaderSrc(fileName, EShaderType::COMPUTE, cs_src.value().c_str());
            return;
        }

        std::string vertex_src = result["vertex_shader"];
        std::string fragment_src = result["fragment_shader"];

        // include common code
        auto common_src = result.get<sol::optional<std::string>>("common_shader");
        if (common_src.has_value()) {
            std::string common_src_vs(common_src.value());
            Zelo::ReplaceString(common_src_vs, "varying", "out");
            std::string common_src_fs(common_src.value());
            Zelo::ReplaceString(common_src_fs, "varying", "in");
            Zelo::ReplaceString(vertex_src, "#include <common_shader>", common_src_vs);
            Zelo::ReplaceString(fragment_src, "#include <common_shader>", common_src_fs);
        }

        // include header
        handleInclude(vertex_src);
        handleInclude(fragment_src);

        // compiler and attach shader
        addShaderSrc(fileName, EShaderType::VERTEX, vertex_src.c_str());
        addShaderSrc(fileName, EShaderType::FRAGMENT, fragment_src.c_str());

        // optional geometry shader
        auto gs_src = result.get<sol::optional<std::string>>("geometry_shader");
        if (gs_src.has_value()) {
            addShaderSrc(fileName, EShaderType::GEOMETRY, gs_src.value().c_str());
        }

    } else if (ext == ".lua") {
        // load in simple mode
        sol::state &lua = LuaScriptManager::getSingleton();
        sol::table result = lua.script(Zelo::Resource(fileName).read());
        std::string vertex_src = result["vertex_shader"];
        std::string fragment_src = result["fragment_shader"];
        addShaderSrc(fileName, EShaderType::VERTEX, vertex_src.c_str());
        addShaderSrc(fileName, EShaderType::FRAGMENT, fragment_src.c_str());
    } else {
        spdlog::error("Unrecognized extension: {}", ext.string());
        ZELO_ASSERT(false);
        return;
    }
}

void GLSLShaderProgram::setUniformMatrix4f(const std::string &name, const glm::mat3 &matrix) {
    bind();

    glUniformMatrix3fv(getUniformLocation(name), 1, GL_FALSE, &(matrix)[0][0]);
}

void GLSLShaderProgram::bindFragDataLocation(const std::string &name, uint32_t slot) {
    bind();

    glBindFragDataLocation(m_handle, slot, name.c_str());
}

void GLSLShaderProgram::queryUniforms() {
    GLint numActiveUniforms = 0;
    m_uniforms.clear();
    glGetProgramiv(m_handle, GL_ACTIVE_UNIFORMS, &numActiveUniforms);
    std::vector<GLchar> nameData(256);
    for (int unif = 0; unif < numActiveUniforms; ++unif) {
        GLint arraySize = 0;
        GLenum type = 0;
        GLsizei actualLength = 0;
        glGetActiveUniform(m_handle, unif, static_cast<GLsizei>(nameData.size()),
                           &actualLength, &arraySize, &type, &nameData[0]);
        std::string name(static_cast<char *>(nameData.data()), actualLength);

        if (isEngineUBOMember(name)) continue;
        std::any defaultValue;
// TODO getUniform*
        switch (static_cast<UniformType>(type)) {
            case UniformType::UNIFORM_BOOL:
            case UniformType::UNIFORM_INT:
                defaultValue = std::make_any<int>(getUniform1i(name));
                break;
            case UniformType::UNIFORM_FLOAT:
                defaultValue = std::make_any<float>(getUniform1f(name));
                break;
            case UniformType::UNIFORM_FLOAT_VEC2:
                defaultValue = std::make_any<glm::vec2>(getUniformVec2(name));
                break;
            case UniformType::UNIFORM_FLOAT_VEC3:
                defaultValue = std::make_any<glm::vec3>(getUniformVec3(name));
                break;
            case UniformType::UNIFORM_FLOAT_VEC4:
                defaultValue = std::make_any<glm::vec4>(getUniformVec4(name));
                break;
            case UniformType::UNIFORM_SAMPLER_2D:
                defaultValue = std::make_any<GLTexture *>(nullptr);
                break;
        }

        if (defaultValue.has_value()) {
            m_uniforms.emplace_back(
                    static_cast<UniformType>(type), name,
                    getUniformLocation(nameData.data()), defaultValue
            );
        }
    }
}

UniformInfo *GLSLShaderProgram::getUniformInfo(const std::string &name) {
    auto found = Zelo::FindIf(m_uniforms, [&name](const UniformInfo &element) {
        return name == element.name;
    });

    if (found != m_uniforms.end())
        return &*found;
    else
        return nullptr;
}

bool GLSLShaderProgram::isEngineUBOMember(const std::string &uniformName) {
    return uniformName.rfind("ubo_", 0) == 0;
}

