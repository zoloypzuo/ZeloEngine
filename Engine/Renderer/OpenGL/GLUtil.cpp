// GLUtil.cpp
// created on 2021/4/24
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLUtil.h"

using namespace Zelo::Core::RHI;

void ZELO_CALLBACK debugCallback(GLenum source, GLenum type, GLuint id,
                                 GLenum severity, GLsizei length,
                                 const GLchar *msg, const void *param) {
    auto logger = spdlog::get("gl");
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
            return;
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
    if (type == GL_DEBUG_TYPE_ERROR || type == GL_DEBUG_TYPE_UNDEFINED_BEHAVIOR) {
        logger->error("{}:{}[{}]({}): {}", sourceStr.c_str(), typeStr.c_str(), sevStr.c_str(), id, msg);
        ZELO_DEBUGBREAK();  // break here to backtrace to the wrong gl call
    } else {
        logger->info("{}:{}[{}]({}): {}", sourceStr.c_str(), typeStr.c_str(), sevStr.c_str(), id, msg);
    }
}

int checkForOpenGLError(const char *file, int line) {
    auto logger = spdlog::get("gl");

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

        logger->error("glError in file {} @ line {}: {}", file, line, message);
        retCode = 1;
        glErr = glGetError();
    }
    return retCode;
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

void initDebugCallback() {
    auto logger = spdlog::get("gl");

    int flags{};
    glGetIntegerv(GL_CONTEXT_FLAGS, &flags);
    if (flags & GL_CONTEXT_FLAG_DEBUG_BIT) {
        // initialize debug output
        logger->info("GL debug context initialized, hook glDebugMessageCallback");
        glEnable(GL_DEBUG_OUTPUT_SYNCHRONOUS);
        glDebugMessageCallback(debugCallback, NULL);
        glDebugMessageControl(GL_DONT_CARE, GL_DONT_CARE, GL_DONT_CARE, 0, NULL, GL_TRUE);
        glDebugMessageInsert(GL_DEBUG_SOURCE_APPLICATION, GL_DEBUG_TYPE_MARKER, 0,
                             GL_DEBUG_SEVERITY_NOTIFICATION, -1, "start debugging");
    }
}

GLenum BufferDataTypeToOpenGLBaseType(const EBufferDataType &type) {
    switch (type) {
        case EBufferDataType::Float:
            return GL_FLOAT;
        case EBufferDataType::Float2:
            return GL_FLOAT;
        case EBufferDataType::Float3:
            return GL_FLOAT;
        case EBufferDataType::Float4:
            return GL_FLOAT;
        case EBufferDataType::UByte:
            return GL_UNSIGNED_BYTE;
        case EBufferDataType::Mat3:
            return GL_FLOAT;
        case EBufferDataType::Mat4:
            return GL_FLOAT;
        case EBufferDataType::Int:
            return GL_INT;
        case EBufferDataType::Int2:
            return GL_INT;
        case EBufferDataType::Int3:
            return GL_INT;
        case EBufferDataType::Int4:
            return GL_INT;
        case EBufferDataType::Bool:
            return GL_BOOL;
        default:
            break;
    }

    ZELO_CORE_ASSERT(false, "Unknown ShaderDataType!");
    return 0;
}
