// GLUtil.h
// created on 2021/4/24
// author @zoloypzuo

#pragma once

#include "ZeloPrerequisites.h"

int checkForOpenGLError(const char *, int);

void dumpGLInfo(bool dumpExtensions = false);

void /*APIENTRY*/ __stdcall debugCallback(GLenum source, GLenum type, GLuint id,
                                GLenum severity, GLsizei length,
                                const GLchar *msg, const void *param);

const char *getTypeString(GLenum type);

std::string getShaderTypeString(GLenum shaderType);
