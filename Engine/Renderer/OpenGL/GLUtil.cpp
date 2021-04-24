// GLUtil.cpp.cc
// created on 2021/4/24
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLUtil.h"

void /*APIENTRY*/ debugCallback(GLenum source, GLenum type, GLuint id,
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

    spdlog::info("%s:%s[%s](%d): %s\n",
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

        spdlog::error("glError in file %s @ line %d: %s\n", file, line, message);
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

    spdlog::info("-------------------------------------------------------------\n");
    spdlog::info("GL Vendor    : %s\n", vendor);
    spdlog::info("GL Renderer  : %s\n", renderer);
    spdlog::info("GL Version   : %s\n", version);
    spdlog::info("GL Version   : %d.%d\n", major, minor);
    spdlog::info("GLSL Version : %s\n", glslVersion);
    spdlog::info("-------------------------------------------------------------\n");

    if (dumpExtensions) {
        GLint nExtensions = 0;
        glGetIntegerv(GL_NUM_EXTENSIONS, &nExtensions);
        for (int i = 0; i < nExtensions; i++) {
            spdlog::info("%s\n", glGetStringi(GL_EXTENSIONS, i));
        }
    }
}