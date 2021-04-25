// GLUtil.cpp.cc
// created on 2021/4/24
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLUtil.h"

void /*APIENTRY*/ __stdcall debugCallback(GLenum source, GLenum type, GLuint id,
                                          GLenum severity, GLsizei length,
                                          const GLchar *msg, const void *param) {

    std::string sourceStr;
    switch (source) {
        case GL_DEBUG_SOURCE_WINDOW_SYSTEM:
            sourceStr = "WindowSys";
            break;
        case GL_DEBUG_SOURCE_APPLICATION:
            sourceStr = "App";
            break;
        case GL_DEBUG_SOURCE_API:
            sourceStr = "OpenGL";
            break;
        case GL_DEBUG_SOURCE_SHADER_COMPILER:
            sourceStr = "ShaderCompiler";
            break;
        case GL_DEBUG_SOURCE_THIRD_PARTY:
            sourceStr = "3rdParty";
            break;
        case GL_DEBUG_SOURCE_OTHER:
            sourceStr = "Other";
            break;
        default:
            sourceStr = "Unknown";
    }

    std::string typeStr;
    switch (type) {
        case GL_DEBUG_TYPE_ERROR:
            typeStr = "Error";
            break;
        case GL_DEBUG_TYPE_DEPRECATED_BEHAVIOR:
            typeStr = "Deprecated";
            break;
        case GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR:
            typeStr = "Undefined";
            break;
        case GL_DEBUG_TYPE_PORTABILITY:
            typeStr = "Portability";
            break;
        case GL_DEBUG_TYPE_PERFORMANCE:
            typeStr = "Performance";
            break;
        case GL_DEBUG_TYPE_MARKER:
            typeStr = "Marker";
            break;
        case GL_DEBUG_TYPE_PUSH_GROUP:
            typeStr = "PushGrp";
            break;
        case GL_DEBUG_TYPE_POP_GROUP:
            typeStr = "PopGrp";
            break;
        case GL_DEBUG_TYPE_OTHER:
            typeStr = "Other";
            break;
        default:
            typeStr = "Unknown";
    }

    std::string sevStr;
    switch (severity) {
        case GL_DEBUG_SEVERITY_HIGH:
            sevStr = "HIGH";
            break;
        case GL_DEBUG_SEVERITY_MEDIUM:
            sevStr = "MED";
            break;
        case GL_DEBUG_SEVERITY_LOW:
            sevStr = "LOW";
            break;
        case GL_DEBUG_SEVERITY_NOTIFICATION:
            sevStr = "NOTIFY";
            break;
        default:
            sevStr = "UNK";
    }

    spdlog::info("{}:{}[{}]({}): {}",
                 sourceStr.c_str(), typeStr.c_str(), sevStr.c_str(),
                 id, msg);
}


int checkForOpenGLError(const char *file, int line) {
    //
    // Returns 1 if an OpenGL error occurred, 0 otherwise.
    //
    int retCode = 0;

    auto glErr = glGetError();
    while (glErr != GL_NO_ERROR) {
        const char *message = "";
        switch (glErr) {
            case GL_INVALID_ENUM:
                message = "Invalid enum";
                break;
            case GL_INVALID_VALUE:
                message = "Invalid value";
                break;
            case GL_INVALID_OPERATION:
                message = "Invalid operation";
                break;
            case GL_INVALID_FRAMEBUFFER_OPERATION:
                message = "Invalid framebuffer operation";
                break;
            case GL_OUT_OF_MEMORY:
                message = "Out of memory";
                break;
            default:
                message = "Unknown error";
        }

        spdlog::error("glError in file {} @ line {}: {}", file, line, message);
        retCode = 1;
        glErr = glGetError();
    }
    return retCode;
}

void dumpGLInfo(bool dumpExtensions) {
    const GLubyte *renderer = glGetString(GL_RENDERER);
    const GLubyte *vendor = glGetString(GL_VENDOR);
    const GLubyte *version = glGetString(GL_VERSION);
    const GLubyte *glslVersion = glGetString(GL_SHADING_LANGUAGE_VERSION);

    GLint major = 0;
    GLint minor = 0;
    glGetIntegerv(GL_MAJOR_VERSION, &major);
    glGetIntegerv(GL_MINOR_VERSION, &minor);

    spdlog::info("-------------------------------------------------------------");
    spdlog::info("GL Vendor    : {}", vendor);
    spdlog::info("GL Renderer  : {}", renderer);
    spdlog::info("GL Version   : {}", version);
    spdlog::info("GL Version   : {}.{}", major, minor);
    spdlog::info("GLSL Version : {}", glslVersion);
    spdlog::info("-------------------------------------------------------------");

    if (dumpExtensions) {
        GLint nExtensions = 0;
        glGetIntegerv(GL_NUM_EXTENSIONS, &nExtensions);
        for (int i = 0; i < nExtensions; i++) {
            spdlog::info("{}", glGetStringi(GL_EXTENSIONS, i));
        }
    }
}


const char *getTypeString(GLenum type) {
    // There are many more types than are covered here, but
    // these are the most common in these examples.
    switch (type) {
        case GL_FLOAT:
            return "float";
        case GL_FLOAT_VEC2:
            return "vec2";
        case GL_FLOAT_VEC3:
            return "vec3";
        case GL_FLOAT_VEC4:
            return "vec4";
        case GL_DOUBLE:
            return "double";
        case GL_INT:
            return "int";
        case GL_UNSIGNED_INT:
            return "unsigned int";
        case GL_BOOL:
            return "bool";
        case GL_FLOAT_MAT2:
            return "mat2";
        case GL_FLOAT_MAT3:
            return "mat3";
        case GL_FLOAT_MAT4:
            return "mat4";
        default:
            return "?";
    }
}

std::string getShaderTypeString(GLenum shaderType) {
    switch (shaderType) {
        case GL_VERTEX_SHADER:
            return "GL_VERTEX_SHADER";
        case GL_FRAGMENT_SHADER:
            return "GL_FRAGMENT_SHADER";
        case GL_GEOMETRY_SHADER:
            return "GL_GEOMETRY_SHADER";
        case GL_TESS_CONTROL_SHADER:
            return "GL_TESS_CONTROL_SHADER";
        case GL_TESS_EVALUATION_SHADER:
            return "GL_TESS_EVALUATION_SHADER";
        case GL_COMPUTE_SHADER:
            return "GL_COMPUTE_SHADER";
        default:
            return "?";
    }
}