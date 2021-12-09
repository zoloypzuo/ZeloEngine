// GLLoader.cpp
// created on 2021/12/5
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLLoader.h"

#include "Foundation/ZeloSDL.h"  // SDL_GL_GetProcAddress

static auto logger = spdlog::default_logger()->clone("gl");

static void dumpGLInfo(bool dumpExtensions);

void loadGL() {
    // Load the OpenGL functions.
    logger->info("start loadGL with GLAD");
    ZELO_ASSERT(gladLoadGLLoader((GLADloadproc) SDL_GL_GetProcAddress), "GLAD failed to initialize");
    dumpGLInfo(false);
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

    logger->info("-------------------------------------------------------------");
    logger->info("GL Vendor    : {}", vendor);
    logger->info("GL Renderer  : {}", renderer);
    logger->info("GL Version   : {}", version);
    logger->info("GL Version   : {}.{}", major, minor);
    logger->info("GLSL Version : {}", glslVersion);
    logger->info("-------------------------------------------------------------");

    if (dumpExtensions) {
        GLint nExtensions = 0;
        glGetIntegerv(GL_NUM_EXTENSIONS, &nExtensions);
        for (int i = 0; i < nExtensions; i++) {
            logger->info("{}", glGetStringi(GL_EXTENSIONS, i));
        }
    }
}