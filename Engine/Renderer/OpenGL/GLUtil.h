// GLUtil.h
// created on 2021/4/24
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Core/RHI/Const/EShaderType.h"
#include "Core/RHI/Const/EBufferDataType.h"

int checkForOpenGLError(const char *, int);

void initDebugCallback();

const char *getTypeString(GLenum type);

std::string getShaderTypeString(GLenum shaderType);

GLenum BufferDataTypeToOpenGLBaseType(const Zelo::Core::RHI::EBufferDataType &type);