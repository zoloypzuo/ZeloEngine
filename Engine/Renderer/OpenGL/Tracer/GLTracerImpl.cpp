#include "GLTracer.h"
#include <string>
#include <spdlog/sinks/rotating_file_sink.h>
#include <spdlog/spdlog.h>

#include "Renderer/OpenGL/GLRenderSystem.h"

using namespace Zelo::Renderer::OpenGL;

#define E2S( en ) Enum2String( en ).c_str()
extern std::string Enum2String( GLenum e );

std::shared_ptr<spdlog::logger> s_logger{};

void initGLTracerLogger(){
    const int _50mb = 1048576 * 50;
    s_logger = spdlog::rotating_logger_mt("gltracer", "logs/gltracer.log", _50mb, 1);
    s_logger->set_pattern("[%T.%e] %v");
    s_logger->set_level(spdlog::level::debug);
}

#define GL_TRACER_LOG s_logger->debug

void APIENTRY glCullFace(GLenum mode)
{
    GL_TRACER_LOG("glCullFace(" "{})", E2S(mode));
    glad_glCullFace(mode);
}

void APIENTRY glFrontFace(GLenum mode)
{
    GL_TRACER_LOG("glFrontFace(" "{})", E2S(mode));
    glad_glFrontFace(mode);
}

void APIENTRY glHint(GLenum target, GLenum mode)
{
    GL_TRACER_LOG("glHint(" "{}, {})", E2S(target), E2S(mode));
    glad_glHint(target, mode);
}

void APIENTRY glLineWidth(GLfloat width)
{
    GL_TRACER_LOG("glLineWidth(" "{})", width);
    glad_glLineWidth(width);
}

void APIENTRY glPointSize(GLfloat size)
{
    GL_TRACER_LOG("glPointSize(" "{})", size);
    glad_glPointSize(size);
}

void APIENTRY glPolygonMode(GLenum face, GLenum mode)
{
    GL_TRACER_LOG("glPolygonMode(" "{}, {})", E2S(face), E2S(mode));
    glad_glPolygonMode(face, mode);
}

void APIENTRY glScissor(GLint x, GLint y, GLsizei width, GLsizei height)
{
    GL_TRACER_LOG("glScissor(" "{}, {}, {}, {})", x, y, width, height);
    glad_glScissor(x, y, width, height);
}

void APIENTRY glTexParameterf(GLenum target, GLenum pname, GLfloat param)
{
    GL_TRACER_LOG("glTexParameterf(" "{}, {}, {})", E2S(target), E2S(pname), param);
    glad_glTexParameterf(target, pname, param);
}

void APIENTRY glTexParameterfv(GLenum target, GLenum pname, const GLfloat* params)
{
    GL_TRACER_LOG("glTexParameterfv(" "{}, {}, {})", E2S(target), E2S(pname), fmt::ptr(params));
    glad_glTexParameterfv(target, pname, params);
}

void APIENTRY glTexParameteri(GLenum target, GLenum pname, GLint param)
{
    GL_TRACER_LOG("glTexParameteri(" "{}, {}, {})", E2S(target), E2S(pname), param);
    glad_glTexParameteri(target, pname, param);
}

void APIENTRY glTexParameteriv(GLenum target, GLenum pname, const GLint* params)
{
    GL_TRACER_LOG("glTexParameteriv(" "{}, {}, {})", E2S(target), E2S(pname), fmt::ptr(params));
    glad_glTexParameteriv(target, pname, params);
}

void APIENTRY glTexImage1D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLint border, GLenum format, GLenum type, const void* pixels)
{
    GL_TRACER_LOG("glTexImage1D(" "{}, {}, {}, {}, {}, {}, {}, {})", E2S(target), level, internalformat, width, border, E2S(format), E2S(type), fmt::ptr(pixels));
    glad_glTexImage1D(target, level, internalformat, width, border, format, type, pixels);
}

void APIENTRY glTexImage2D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const void* pixels)
{
    GL_TRACER_LOG("glTexImage2D(" "{}, {}, {}, {}, {}, {}, {}, {}, {})", E2S(target), level, internalformat, width, height, border, E2S(format), E2S(type), fmt::ptr(pixels));
    glad_glTexImage2D(target, level, internalformat, width, height, border, format, type, pixels);
}

void APIENTRY glDrawBuffer(GLenum buf)
{
    GL_TRACER_LOG("glDrawBuffer(" "{})", E2S(buf));
    glad_glDrawBuffer(buf);
}

void APIENTRY glClear(GLbitfield mask)
{
    GL_TRACER_LOG("glClear(" "{})", (unsigned int)(mask));
    glad_glClear(mask);
}

void APIENTRY glClearColor(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha)
{
    GL_TRACER_LOG("glClearColor(" "{}, {}, {}, {})", red, green, blue, alpha);
    glad_glClearColor(red, green, blue, alpha);
}

void APIENTRY glClearStencil(GLint s)
{
    GL_TRACER_LOG("glClearStencil(" "{})", s);
    glad_glClearStencil(s);
}

void APIENTRY glClearDepth(GLdouble depth)
{
    GL_TRACER_LOG("glClearDepth(" "{})", depth);
    glad_glClearDepth(depth);
}

void APIENTRY glStencilMask(GLuint mask)
{
    GL_TRACER_LOG("glStencilMask(" "{})", mask);
    glad_glStencilMask(mask);
}

void APIENTRY glColorMask(GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha)
{
    GL_TRACER_LOG("glColorMask(" "{}, {}, {}, {})", (unsigned int)(red), (unsigned int)(green), (unsigned int)(blue), (unsigned int)(alpha));
    glad_glColorMask(red, green, blue, alpha);
}

void APIENTRY glDepthMask(GLboolean flag)
{
    GL_TRACER_LOG("glDepthMask(" "{})", (unsigned int)(flag));
    glad_glDepthMask(flag);
}

void APIENTRY glDisable(GLenum cap)
{
    GL_TRACER_LOG("glDisable(" "{})", E2S(cap));
    glad_glDisable(cap);
}

void APIENTRY glEnable(GLenum cap)
{
    GL_TRACER_LOG("glEnable(" "{})", E2S(cap));
    glad_glEnable(cap);
}

void APIENTRY glFinish()
{
    GL_TRACER_LOG("glFinish()");
    glad_glFinish();
}

void APIENTRY glFlush()
{
    GL_TRACER_LOG("glFlush()");
    glad_glFlush();
}

void APIENTRY glBlendFunc(GLenum sfactor, GLenum dfactor)
{
    GL_TRACER_LOG("glBlendFunc(" "{}, {})", E2S(sfactor), E2S(dfactor));
    glad_glBlendFunc(sfactor, dfactor);
}

void APIENTRY glLogicOp(GLenum opcode)
{
    GL_TRACER_LOG("glLogicOp(" "{})", E2S(opcode));
    glad_glLogicOp(opcode);
}

void APIENTRY glStencilFunc(GLenum func, GLint ref, GLuint mask)
{
    GL_TRACER_LOG("glStencilFunc(" "{}, {}, {})", E2S(func), ref, mask);
    glad_glStencilFunc(func, ref, mask);
}

void APIENTRY glStencilOp(GLenum fail, GLenum zfail, GLenum zpass)
{
    GL_TRACER_LOG("glStencilOp(" "{}, {}, {})", E2S(fail), E2S(zfail), E2S(zpass));
    glad_glStencilOp(fail, zfail, zpass);
}

void APIENTRY glDepthFunc(GLenum func)
{
    GL_TRACER_LOG("glDepthFunc(" "{})", E2S(func));
    glad_glDepthFunc(func);
}

void APIENTRY glPixelStoref(GLenum pname, GLfloat param)
{
    GL_TRACER_LOG("glPixelStoref(" "{}, {})", E2S(pname), param);
    glad_glPixelStoref(pname, param);
}

void APIENTRY glPixelStorei(GLenum pname, GLint param)
{
    GL_TRACER_LOG("glPixelStorei(" "{}, {})", E2S(pname), param);
    glad_glPixelStorei(pname, param);
}

void APIENTRY glReadBuffer(GLenum src)
{
    GL_TRACER_LOG("glReadBuffer(" "{})", E2S(src));
    glad_glReadBuffer(src);
}

void APIENTRY glReadPixels(GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, void* pixels)
{
    GL_TRACER_LOG("glReadPixels(" "{}, {}, {}, {}, {}, {}, {})", x, y, width, height, E2S(format), E2S(type), fmt::ptr(pixels));
    glad_glReadPixels(x, y, width, height, format, type, pixels);
}

void APIENTRY glGetBooleanv(GLenum pname, GLboolean* data)
{
    GL_TRACER_LOG("glGetBooleanv(" "{}, {})", E2S(pname), fmt::ptr(data));
    glad_glGetBooleanv(pname, data);
}

void APIENTRY glGetDoublev(GLenum pname, GLdouble* data)
{
    GL_TRACER_LOG("glGetDoublev(" "{}, {})", E2S(pname), fmt::ptr(data));
    glad_glGetDoublev(pname, data);
}

GLenum APIENTRY glGetError()
{
    GL_TRACER_LOG("glGetError()");
    GLenum const r = glad_glGetError();
    return r;
}

void APIENTRY glGetFloatv(GLenum pname, GLfloat* data)
{
    GL_TRACER_LOG("glGetFloatv(" "{}, {})", E2S(pname), fmt::ptr(data));
    glad_glGetFloatv(pname, data);
}

void APIENTRY glGetIntegerv(GLenum pname, GLint* data)
{
    GL_TRACER_LOG("glGetIntegerv(" "{}, {})", E2S(pname), fmt::ptr(data));
    glad_glGetIntegerv(pname, data);
}

const GLubyte* APIENTRY glGetString(GLenum name)
{
    GL_TRACER_LOG("glGetString(" "{})", E2S(name));
    const GLubyte* const r = glad_glGetString(name);
    return r;
}

void APIENTRY glGetTexImage(GLenum target, GLint level, GLenum format, GLenum type, void* pixels)
{
    GL_TRACER_LOG("glGetTexImage(" "{}, {}, {}, {}, {})", E2S(target), level, E2S(format), E2S(type), fmt::ptr(pixels));
    glad_glGetTexImage(target, level, format, type, pixels);
}

void APIENTRY glGetTexParameterfv(GLenum target, GLenum pname, GLfloat* params)
{
    GL_TRACER_LOG("glGetTexParameterfv(" "{}, {}, {})", E2S(target), E2S(pname), fmt::ptr(params));
    glad_glGetTexParameterfv(target, pname, params);
}

void APIENTRY glGetTexParameteriv(GLenum target, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetTexParameteriv(" "{}, {}, {})", E2S(target), E2S(pname), fmt::ptr(params));
    glad_glGetTexParameteriv(target, pname, params);
}

void APIENTRY glGetTexLevelParameterfv(GLenum target, GLint level, GLenum pname, GLfloat* params)
{
    GL_TRACER_LOG("glGetTexLevelParameterfv(" "{}, {}, {}, {})", E2S(target), level, E2S(pname), fmt::ptr(params));
    glad_glGetTexLevelParameterfv(target, level, pname, params);
}

void APIENTRY glGetTexLevelParameteriv(GLenum target, GLint level, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetTexLevelParameteriv(" "{}, {}, {}, {})", E2S(target), level, E2S(pname), fmt::ptr(params));
    glad_glGetTexLevelParameteriv(target, level, pname, params);
}

GLboolean APIENTRY glIsEnabled(GLenum cap)
{
    GL_TRACER_LOG("glIsEnabled(" "{})", E2S(cap));
    GLboolean const r = glad_glIsEnabled(cap);
    return r;
}

void APIENTRY glDepthRange(GLdouble n, GLdouble f)
{
    GL_TRACER_LOG("glDepthRange(" "{}, {})", n, f);
    glad_glDepthRange(n, f);
}

void APIENTRY glViewport(GLint x, GLint y, GLsizei width, GLsizei height)
{
    GL_TRACER_LOG("glViewport(" "{}, {}, {}, {})", x, y, width, height);
    glad_glViewport(x, y, width, height);
}

void APIENTRY glDrawArrays(GLenum mode, GLint first, GLsizei count)
{
    GL_TRACER_LOG("glDrawArrays(" "{}, {}, {})", E2S(mode), first, count);
    glad_glDrawArrays(mode, first, count);
}

void APIENTRY glDrawElements(GLenum mode, GLsizei count, GLenum type, const void* indices)
{
    GL_TRACER_LOG("glDrawElements(" "{}, {}, {}, {})", E2S(mode), count, E2S(type), fmt::ptr(indices));
    glad_glDrawElements(mode, count, type, indices);
}

void APIENTRY glGetPointerv(GLenum pname, void** params)
{
    GL_TRACER_LOG("glGetPointerv(" "{}, {})", E2S(pname), fmt::ptr(params));
    glad_glGetPointerv(pname, params);
}

void APIENTRY glPolygonOffset(GLfloat factor, GLfloat units)
{
    GL_TRACER_LOG("glPolygonOffset(" "{}, {})", factor, units);
    glad_glPolygonOffset(factor, units);
}

void APIENTRY glCopyTexImage1D(GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLint border)
{
    GL_TRACER_LOG("glCopyTexImage1D(" "{}, {}, {}, {}, {}, {}, {})", E2S(target), level, E2S(internalformat), x, y, width, border);
    glad_glCopyTexImage1D(target, level, internalformat, x, y, width, border);
}

void APIENTRY glCopyTexImage2D(GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border)
{
    GL_TRACER_LOG("glCopyTexImage2D(" "{}, {}, {}, {}, {}, {}, {}, {})", E2S(target), level, E2S(internalformat), x, y, width, height, border);
    glad_glCopyTexImage2D(target, level, internalformat, x, y, width, height, border);
}

void APIENTRY glCopyTexSubImage1D(GLenum target, GLint level, GLint xoffset, GLint x, GLint y, GLsizei width)
{
    GL_TRACER_LOG("glCopyTexSubImage1D(" "{}, {}, {}, {}, {}, {})", E2S(target), level, xoffset, x, y, width);
    glad_glCopyTexSubImage1D(target, level, xoffset, x, y, width);
}

void APIENTRY glCopyTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height)
{
    GL_TRACER_LOG("glCopyTexSubImage2D(" "{}, {}, {}, {}, {}, {}, {}, {})", E2S(target), level, xoffset, yoffset, x, y, width, height);
    glad_glCopyTexSubImage2D(target, level, xoffset, yoffset, x, y, width, height);
}

void APIENTRY glTexSubImage1D(GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum type, const void* pixels)
{
    GL_TRACER_LOG("glTexSubImage1D(" "{}, {}, {}, {}, {}, {}, {})", E2S(target), level, xoffset, width, E2S(format), E2S(type), fmt::ptr(pixels));
    glad_glTexSubImage1D(target, level, xoffset, width, format, type, pixels);
}

void APIENTRY glTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const void* pixels)
{
    GL_TRACER_LOG("glTexSubImage2D(" "{}, {}, {}, {}, {}, {}, {}, {}, {})", E2S(target), level, xoffset, yoffset, width, height, E2S(format), E2S(type), fmt::ptr(pixels));
    glad_glTexSubImage2D(target, level, xoffset, yoffset, width, height, format, type, pixels);
}

void APIENTRY glBindTexture(GLenum target, GLuint texture)
{
    GL_TRACER_LOG("glBindTexture(" "{}, {})", E2S(target), texture);
    glad_glBindTexture(target, texture);
}

void APIENTRY glDeleteTextures(GLsizei n, const GLuint* textures)
{
    GL_TRACER_LOG("glDeleteTextures(" "{}, {})", n, fmt::ptr(textures));
    glad_glDeleteTextures(n, textures);
}

void APIENTRY glGenTextures(GLsizei n, GLuint* textures)
{
    GL_TRACER_LOG("glGenTextures(" "{}, {})", n, fmt::ptr(textures));
    glad_glGenTextures(n, textures);
}

GLboolean APIENTRY glIsTexture(GLuint texture)
{
    GL_TRACER_LOG("glIsTexture(" "{})", texture);
    GLboolean const r = glad_glIsTexture(texture);
    return r;
}

void APIENTRY glDrawRangeElements(GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum type, const void* indices)
{
    GL_TRACER_LOG("glDrawRangeElements(" "{}, {}, {}, {}, {}, {})", E2S(mode), start, end, count, E2S(type), fmt::ptr(indices));
    glad_glDrawRangeElements(mode, start, end, count, type, indices);
}

void APIENTRY glTexImage3D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum type, const void* pixels)
{
    GL_TRACER_LOG("glTexImage3D(" "{}, {}, {}, {}, {}, {}, {}, {}, {}, {})", E2S(target), level, internalformat, width, height, depth, border, E2S(format), E2S(type), fmt::ptr(pixels));
    glad_glTexImage3D(target, level, internalformat, width, height, depth, border, format, type, pixels);
}

void APIENTRY glTexSubImage3D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const void* pixels)
{
    GL_TRACER_LOG("glTexSubImage3D(" "{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {})", E2S(target), level, xoffset, yoffset, zoffset, width, height, depth, E2S(format), E2S(type), fmt::ptr(pixels));
    glad_glTexSubImage3D(target, level, xoffset, yoffset, zoffset, width, height, depth, format, type, pixels);
}

void APIENTRY glCopyTexSubImage3D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLint x, GLint y, GLsizei width, GLsizei height)
{
    GL_TRACER_LOG("glCopyTexSubImage3D(" "{}, {}, {}, {}, {}, {}, {}, {}, {})", E2S(target), level, xoffset, yoffset, zoffset, x, y, width, height);
    glad_glCopyTexSubImage3D(target, level, xoffset, yoffset, zoffset, x, y, width, height);
}

void APIENTRY glActiveTexture(GLenum texture)
{
    GL_TRACER_LOG("glActiveTexture(" "{})", E2S(texture));
    glad_glActiveTexture(texture);
}

void APIENTRY glSampleCoverage(GLfloat value, GLboolean invert)
{
    GL_TRACER_LOG("glSampleCoverage(" "{}, {})", value, (unsigned int)(invert));
    glad_glSampleCoverage(value, invert);
}

void APIENTRY glCompressedTexImage3D(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLsizei imageSize, const void* data)
{
    GL_TRACER_LOG("glCompressedTexImage3D(" "{}, {}, {}, {}, {}, {}, {}, {}, {})", E2S(target), level, E2S(internalformat), width, height, depth, border, imageSize, fmt::ptr(data));
    glad_glCompressedTexImage3D(target, level, internalformat, width, height, depth, border, imageSize, data);
}

void APIENTRY glCompressedTexImage2D(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, const void* data)
{
    GL_TRACER_LOG("glCompressedTexImage2D(" "{}, {}, {}, {}, {}, {}, {}, {})", E2S(target), level, E2S(internalformat), width, height, border, imageSize, fmt::ptr(data));
    glad_glCompressedTexImage2D(target, level, internalformat, width, height, border, imageSize, data);
}

void APIENTRY glCompressedTexImage1D(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLint border, GLsizei imageSize, const void* data)
{
    GL_TRACER_LOG("glCompressedTexImage1D(" "{}, {}, {}, {}, {}, {}, {})", E2S(target), level, E2S(internalformat), width, border, imageSize, fmt::ptr(data));
    glad_glCompressedTexImage1D(target, level, internalformat, width, border, imageSize, data);
}

void APIENTRY glCompressedTexSubImage3D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLsizei imageSize, const void* data)
{
    GL_TRACER_LOG("glCompressedTexSubImage3D(" "{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {})", E2S(target), level, xoffset, yoffset, zoffset, width, height, depth, E2S(format), imageSize, fmt::ptr(data));
    glad_glCompressedTexSubImage3D(target, level, xoffset, yoffset, zoffset, width, height, depth, format, imageSize, data);
}

void APIENTRY glCompressedTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, const void* data)
{
    GL_TRACER_LOG("glCompressedTexSubImage2D(" "{}, {}, {}, {}, {}, {}, {}, {}, {})", E2S(target), level, xoffset, yoffset, width, height, E2S(format), imageSize, fmt::ptr(data));
    glad_glCompressedTexSubImage2D(target, level, xoffset, yoffset, width, height, format, imageSize, data);
}

void APIENTRY glCompressedTexSubImage1D(GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLsizei imageSize, const void* data)
{
    GL_TRACER_LOG("glCompressedTexSubImage1D(" "{}, {}, {}, {}, {}, {}, {})", E2S(target), level, xoffset, width, E2S(format), imageSize, fmt::ptr(data));
    glad_glCompressedTexSubImage1D(target, level, xoffset, width, format, imageSize, data);
}

void APIENTRY glGetCompressedTexImage(GLenum target, GLint level, void* img)
{
    GL_TRACER_LOG("glGetCompressedTexImage(" "{}, {}, {})", E2S(target), level, fmt::ptr(img));
    glad_glGetCompressedTexImage(target, level, img);
}

void APIENTRY glBlendFuncSeparate(GLenum sfactorRGB, GLenum dfactorRGB, GLenum sfactorAlpha, GLenum dfactorAlpha)
{
    GL_TRACER_LOG("glBlendFuncSeparate(" "{}, {}, {}, {})", E2S(sfactorRGB), E2S(dfactorRGB), E2S(sfactorAlpha), E2S(dfactorAlpha));
    glad_glBlendFuncSeparate(sfactorRGB, dfactorRGB, sfactorAlpha, dfactorAlpha);
}

void APIENTRY glMultiDrawArrays(GLenum mode, const GLint* first, const GLsizei* count, GLsizei drawcount)
{
    GL_TRACER_LOG("glMultiDrawArrays(" "{}, {}, {}, {})", E2S(mode), fmt::ptr(first), fmt::ptr(count), drawcount);
    glad_glMultiDrawArrays(mode, first, count, drawcount);
}

void APIENTRY glMultiDrawElements(GLenum mode, const GLsizei* count, GLenum type, const void* const* indices, GLsizei drawcount)
{
    GL_TRACER_LOG("glMultiDrawElements(" "{}, {}, {}, {}, {})", E2S(mode), fmt::ptr(count), E2S(type), fmt::ptr(indices), drawcount);
    glad_glMultiDrawElements(mode, count, type, indices, drawcount);
}

void APIENTRY glPointParameterf(GLenum pname, GLfloat param)
{
    GL_TRACER_LOG("glPointParameterf(" "{}, {})", E2S(pname), param);
    glad_glPointParameterf(pname, param);
}

void APIENTRY glPointParameterfv(GLenum pname, const GLfloat* params)
{
    GL_TRACER_LOG("glPointParameterfv(" "{}, {})", E2S(pname), fmt::ptr(params));
    glad_glPointParameterfv(pname, params);
}

void APIENTRY glPointParameteri(GLenum pname, GLint param)
{
    GL_TRACER_LOG("glPointParameteri(" "{}, {})", E2S(pname), param);
    glad_glPointParameteri(pname, param);
}

void APIENTRY glPointParameteriv(GLenum pname, const GLint* params)
{
    GL_TRACER_LOG("glPointParameteriv(" "{}, {})", E2S(pname), fmt::ptr(params));
    glad_glPointParameteriv(pname, params);
}

void APIENTRY glBlendColor(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha)
{
    GL_TRACER_LOG("glBlendColor(" "{}, {}, {}, {})", red, green, blue, alpha);
    glad_glBlendColor(red, green, blue, alpha);
}

void APIENTRY glBlendEquation(GLenum mode)
{
    GL_TRACER_LOG("glBlendEquation(" "{})", E2S(mode));
    glad_glBlendEquation(mode);
}

void APIENTRY glGenQueries(GLsizei n, GLuint* ids)
{
    GL_TRACER_LOG("glGenQueries(" "{}, {})", n, fmt::ptr(ids));
    glad_glGenQueries(n, ids);
}

void APIENTRY glDeleteQueries(GLsizei n, const GLuint* ids)
{
    GL_TRACER_LOG("glDeleteQueries(" "{}, {})", n, fmt::ptr(ids));
    glad_glDeleteQueries(n, ids);
}

GLboolean APIENTRY glIsQuery(GLuint id)
{
    GL_TRACER_LOG("glIsQuery(" "{})", id);
    GLboolean const r = glad_glIsQuery(id);
    return r;
}

void APIENTRY glBeginQuery(GLenum target, GLuint id)
{
    GL_TRACER_LOG("glBeginQuery(" "{}, {})", E2S(target), id);
    glad_glBeginQuery(target, id);
}

void APIENTRY glEndQuery(GLenum target)
{
    GL_TRACER_LOG("glEndQuery(" "{})", E2S(target));
    glad_glEndQuery(target);
}

void APIENTRY glGetQueryiv(GLenum target, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetQueryiv(" "{}, {}, {})", E2S(target), E2S(pname), fmt::ptr(params));
    glad_glGetQueryiv(target, pname, params);
}

void APIENTRY glGetQueryObjectiv(GLuint id, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetQueryObjectiv(" "{}, {}, {})", id, E2S(pname), fmt::ptr(params));
    glad_glGetQueryObjectiv(id, pname, params);
}

void APIENTRY glGetQueryObjectuiv(GLuint id, GLenum pname, GLuint* params)
{
    GL_TRACER_LOG("glGetQueryObjectuiv(" "{}, {}, {})", id, E2S(pname), fmt::ptr(params));
    glad_glGetQueryObjectuiv(id, pname, params);
}

void APIENTRY glBindBuffer(GLenum target, GLuint buffer)
{
    GL_TRACER_LOG("glBindBuffer(" "{}, {})", E2S(target), buffer);
    glad_glBindBuffer(target, buffer);
}

void APIENTRY glDeleteBuffers(GLsizei n, const GLuint* buffers)
{
    GL_TRACER_LOG("glDeleteBuffers(" "{}, {})", n, fmt::ptr(buffers));
    glad_glDeleteBuffers(n, buffers);
}

void APIENTRY glGenBuffers(GLsizei n, GLuint* buffers)
{
    GL_TRACER_LOG("glGenBuffers(" "{}, {})", n, fmt::ptr(buffers));
    glad_glGenBuffers(n, buffers);
}

GLboolean APIENTRY glIsBuffer(GLuint buffer)
{
    GL_TRACER_LOG("glIsBuffer(" "{})", buffer);
    GLboolean const r = glad_glIsBuffer(buffer);
    return r;
}

void APIENTRY glBufferData(GLenum target, GLsizeiptr size, const void* data, GLenum usage)
{
    GL_TRACER_LOG("glBufferData(" "{}, {}, {}, {})", E2S(target), size, fmt::ptr(data), E2S(usage));
    glad_glBufferData(target, size, data, usage);
}

void APIENTRY glBufferSubData(GLenum target, GLintptr offset, GLsizeiptr size, const void* data)
{
    GL_TRACER_LOG("glBufferSubData(" "{}, {}, {}, {})", E2S(target), offset, size, fmt::ptr(data));
    glad_glBufferSubData(target, offset, size, data);
}

void APIENTRY glGetBufferSubData(GLenum target, GLintptr offset, GLsizeiptr size, void* data)
{
    GL_TRACER_LOG("glGetBufferSubData(" "{}, {}, {}, {})", E2S(target), offset, size, fmt::ptr(data));
    glad_glGetBufferSubData(target, offset, size, data);
}

void* APIENTRY glMapBuffer(GLenum target, GLenum access)
{
    GL_TRACER_LOG("glMapBuffer(" "{}, {})", E2S(target), E2S(access));
    void* const r = glad_glMapBuffer(target, access);
    return r;
}

GLboolean APIENTRY glUnmapBuffer(GLenum target)
{
    GL_TRACER_LOG("glUnmapBuffer(" "{})", E2S(target));
    GLboolean const r = glad_glUnmapBuffer(target);
    return r;
}

void APIENTRY glGetBufferParameteriv(GLenum target, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetBufferParameteriv(" "{}, {}, {})", E2S(target), E2S(pname), fmt::ptr(params));
    glad_glGetBufferParameteriv(target, pname, params);
}

void APIENTRY glGetBufferPointerv(GLenum target, GLenum pname, void** params)
{
    GL_TRACER_LOG("glGetBufferPointerv(" "{}, {}, {})", E2S(target), E2S(pname), fmt::ptr(params));
    glad_glGetBufferPointerv(target, pname, params);
}

void APIENTRY glBlendEquationSeparate(GLenum modeRGB, GLenum modeAlpha)
{
    GL_TRACER_LOG("glBlendEquationSeparate(" "{}, {})", E2S(modeRGB), E2S(modeAlpha));
    glad_glBlendEquationSeparate(modeRGB, modeAlpha);
}

void APIENTRY glDrawBuffers(GLsizei n, const GLenum* bufs)
{
    GL_TRACER_LOG("glDrawBuffers(" "{}, {})", n, fmt::ptr(bufs));
    glad_glDrawBuffers(n, bufs);
}

void APIENTRY glStencilOpSeparate(GLenum face, GLenum sfail, GLenum dpfail, GLenum dppass)
{
    GL_TRACER_LOG("glStencilOpSeparate(" "{}, {}, {}, {})", E2S(face), E2S(sfail), E2S(dpfail), E2S(dppass));
    glad_glStencilOpSeparate(face, sfail, dpfail, dppass);
}

void APIENTRY glStencilFuncSeparate(GLenum face, GLenum func, GLint ref, GLuint mask)
{
    GL_TRACER_LOG("glStencilFuncSeparate(" "{}, {}, {}, {})", E2S(face), E2S(func), ref, mask);
    glad_glStencilFuncSeparate(face, func, ref, mask);
}

void APIENTRY glStencilMaskSeparate(GLenum face, GLuint mask)
{
    GL_TRACER_LOG("glStencilMaskSeparate(" "{}, {})", E2S(face), mask);
    glad_glStencilMaskSeparate(face, mask);
}

void APIENTRY glAttachShader(GLuint program, GLuint shader)
{
    GL_TRACER_LOG("glAttachShader(" "{}, {})", program, shader);
    glad_glAttachShader(program, shader);
}

void APIENTRY glBindAttribLocation(GLuint program, GLuint index, const GLchar* name)
{
    GL_TRACER_LOG("glBindAttribLocation(" "{}, {}, {})", program, index, fmt::ptr(name));
    glad_glBindAttribLocation(program, index, name);
}

void APIENTRY glCompileShader(GLuint shader)
{
    GL_TRACER_LOG("glCompileShader(" "{})", shader);
    glad_glCompileShader(shader);
}

GLuint APIENTRY glCreateProgram()
{
    GL_TRACER_LOG("glCreateProgram()");
    GLuint const r = glad_glCreateProgram();
    return r;
}

GLuint APIENTRY glCreateShader(GLenum type)
{
    GL_TRACER_LOG("glCreateShader(" "{})", E2S(type));
    GLuint const r = glad_glCreateShader(type);
    return r;
}

void APIENTRY glDeleteProgram(GLuint program)
{
    GL_TRACER_LOG("glDeleteProgram(" "{})", program);
    glad_glDeleteProgram(program);
}

void APIENTRY glDeleteShader(GLuint shader)
{
    GL_TRACER_LOG("glDeleteShader(" "{})", shader);
    glad_glDeleteShader(shader);
}

void APIENTRY glDetachShader(GLuint program, GLuint shader)
{
    GL_TRACER_LOG("glDetachShader(" "{}, {})", program, shader);
    glad_glDetachShader(program, shader);
}

void APIENTRY glDisableVertexAttribArray(GLuint index)
{
    GL_TRACER_LOG("glDisableVertexAttribArray(" "{})", index);
    glad_glDisableVertexAttribArray(index);
}

void APIENTRY glEnableVertexAttribArray(GLuint index)
{
    GL_TRACER_LOG("glEnableVertexAttribArray(" "{})", index);
    glad_glEnableVertexAttribArray(index);
}

void APIENTRY glGetActiveAttrib(GLuint program, GLuint index, GLsizei bufSize, GLsizei* length, GLint* size, GLenum* type, GLchar* name)
{
    GL_TRACER_LOG("glGetActiveAttrib(" "{}, {}, {}, {}, {}, {}, {})", program, index, bufSize, fmt::ptr(length), fmt::ptr(size), fmt::ptr(type), fmt::ptr(name));
    glad_glGetActiveAttrib(program, index, bufSize, length, size, type, name);
}

void APIENTRY glGetActiveUniform(GLuint program, GLuint index, GLsizei bufSize, GLsizei* length, GLint* size, GLenum* type, GLchar* name)
{
    GL_TRACER_LOG("glGetActiveUniform(" "{}, {}, {}, {}, {}, {}, {})", program, index, bufSize, fmt::ptr(length), fmt::ptr(size), fmt::ptr(type), fmt::ptr(name));
    glad_glGetActiveUniform(program, index, bufSize, length, size, type, name);
}

void APIENTRY glGetAttachedShaders(GLuint program, GLsizei maxCount, GLsizei* count, GLuint* shaders)
{
    GL_TRACER_LOG("glGetAttachedShaders(" "{}, {}, {}, {})", program, maxCount, fmt::ptr(count), fmt::ptr(shaders));
    glad_glGetAttachedShaders(program, maxCount, count, shaders);
}

GLint APIENTRY glGetAttribLocation(GLuint program, const GLchar* name)
{
    GL_TRACER_LOG("glGetAttribLocation(" "{}, {})", program, fmt::ptr(name));
    GLint const r = glad_glGetAttribLocation(program, name);
    return r;
}

void APIENTRY glGetProgramiv(GLuint program, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetProgramiv(" "{}, {}, {})", program, E2S(pname), fmt::ptr(params));
    glad_glGetProgramiv(program, pname, params);
}

void APIENTRY glGetProgramInfoLog(GLuint program, GLsizei bufSize, GLsizei* length, GLchar* infoLog)
{
    GL_TRACER_LOG("glGetProgramInfoLog(" "{}, {}, {}, {})", program, bufSize, fmt::ptr(length), fmt::ptr(infoLog));
    glad_glGetProgramInfoLog(program, bufSize, length, infoLog);
}

void APIENTRY glGetShaderiv(GLuint shader, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetShaderiv(" "{}, {}, {})", shader, E2S(pname), fmt::ptr(params));
    glad_glGetShaderiv(shader, pname, params);
}

void APIENTRY glGetShaderInfoLog(GLuint shader, GLsizei bufSize, GLsizei* length, GLchar* infoLog)
{
    GL_TRACER_LOG("glGetShaderInfoLog(" "{}, {}, {}, {})", shader, bufSize, fmt::ptr(length), fmt::ptr(infoLog));
    glad_glGetShaderInfoLog(shader, bufSize, length, infoLog);
}

void APIENTRY glGetShaderSource(GLuint shader, GLsizei bufSize, GLsizei* length, GLchar* source)
{
    GL_TRACER_LOG("glGetShaderSource(" "{}, {}, {}, {})", shader, bufSize, fmt::ptr(length), fmt::ptr(source));
    glad_glGetShaderSource(shader, bufSize, length, source);
}

GLint APIENTRY glGetUniformLocation(GLuint program, const GLchar* name)
{
    GL_TRACER_LOG("glGetUniformLocation(" "{}, {})", program, fmt::ptr(name));
    GLint const r = glad_glGetUniformLocation(program, name);
    return r;
}

void APIENTRY glGetUniformfv(GLuint program, GLint location, GLfloat* params)
{
    GL_TRACER_LOG("glGetUniformfv(" "{}, {}, {})", program, location, fmt::ptr(params));
    glad_glGetUniformfv(program, location, params);
}

void APIENTRY glGetUniformiv(GLuint program, GLint location, GLint* params)
{
    GL_TRACER_LOG("glGetUniformiv(" "{}, {}, {})", program, location, fmt::ptr(params));
    glad_glGetUniformiv(program, location, params);
}

void APIENTRY glGetVertexAttribdv(GLuint index, GLenum pname, GLdouble* params)
{
    GL_TRACER_LOG("glGetVertexAttribdv(" "{}, {}, {})", index, E2S(pname), fmt::ptr(params));
    glad_glGetVertexAttribdv(index, pname, params);
}

void APIENTRY glGetVertexAttribfv(GLuint index, GLenum pname, GLfloat* params)
{
    GL_TRACER_LOG("glGetVertexAttribfv(" "{}, {}, {})", index, E2S(pname), fmt::ptr(params));
    glad_glGetVertexAttribfv(index, pname, params);
}

void APIENTRY glGetVertexAttribiv(GLuint index, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetVertexAttribiv(" "{}, {}, {})", index, E2S(pname), fmt::ptr(params));
    glad_glGetVertexAttribiv(index, pname, params);
}

void APIENTRY glGetVertexAttribPointerv(GLuint index, GLenum pname, void** pointer)
{
    GL_TRACER_LOG("glGetVertexAttribPointerv(" "{}, {}, {})", index, E2S(pname), fmt::ptr(pointer));
    glad_glGetVertexAttribPointerv(index, pname, pointer);
}

GLboolean APIENTRY glIsProgram(GLuint program)
{
    GL_TRACER_LOG("glIsProgram(" "{})", program);
    GLboolean const r = glad_glIsProgram(program);
    return r;
}

GLboolean APIENTRY glIsShader(GLuint shader)
{
    GL_TRACER_LOG("glIsShader(" "{})", shader);
    GLboolean const r = glad_glIsShader(shader);
    return r;
}

void APIENTRY glLinkProgram(GLuint program)
{
    GL_TRACER_LOG("glLinkProgram(" "{})", program);
    glad_glLinkProgram(program);
}

void APIENTRY glShaderSource(GLuint shader, GLsizei count, const GLchar* const* string, const GLint* length)
{
    GL_TRACER_LOG("glShaderSource(" "{}, {}, {}, {})", shader, count, fmt::ptr(string), fmt::ptr(length));
    glad_glShaderSource(shader, count, string, length);
}

void APIENTRY glUseProgram(GLuint program)
{
    GL_TRACER_LOG("glUseProgram(" "{})", program);
    glad_glUseProgram(program);
}

void APIENTRY glUniform1f(GLint location, GLfloat v0)
{
    GL_TRACER_LOG("glUniform1f(" "{}, {})", location, v0);
    glad_glUniform1f(location, v0);
}

void APIENTRY glUniform2f(GLint location, GLfloat v0, GLfloat v1)
{
    GL_TRACER_LOG("glUniform2f(" "{}, {}, {})", location, v0, v1);
    glad_glUniform2f(location, v0, v1);
}

void APIENTRY glUniform3f(GLint location, GLfloat v0, GLfloat v1, GLfloat v2)
{
    GL_TRACER_LOG("glUniform3f(" "{}, {}, {}, {})", location, v0, v1, v2);
    glad_glUniform3f(location, v0, v1, v2);
}

void APIENTRY glUniform4f(GLint location, GLfloat v0, GLfloat v1, GLfloat v2, GLfloat v3)
{
    GL_TRACER_LOG("glUniform4f(" "{}, {}, {}, {}, {})", location, v0, v1, v2, v3);
    glad_glUniform4f(location, v0, v1, v2, v3);
}

void APIENTRY glUniform1i(GLint location, GLint v0)
{
    GL_TRACER_LOG("glUniform1i(" "{}, {})", location, v0);
    glad_glUniform1i(location, v0);
}

void APIENTRY glUniform2i(GLint location, GLint v0, GLint v1)
{
    GL_TRACER_LOG("glUniform2i(" "{}, {}, {})", location, v0, v1);
    glad_glUniform2i(location, v0, v1);
}

void APIENTRY glUniform3i(GLint location, GLint v0, GLint v1, GLint v2)
{
    GL_TRACER_LOG("glUniform3i(" "{}, {}, {}, {})", location, v0, v1, v2);
    glad_glUniform3i(location, v0, v1, v2);
}

void APIENTRY glUniform4i(GLint location, GLint v0, GLint v1, GLint v2, GLint v3)
{
    GL_TRACER_LOG("glUniform4i(" "{}, {}, {}, {}, {})", location, v0, v1, v2, v3);
    glad_glUniform4i(location, v0, v1, v2, v3);
}

void APIENTRY glUniform1fv(GLint location, GLsizei count, const GLfloat* value)
{
    GL_TRACER_LOG("glUniform1fv(" "{}, {}, {})", location, count, fmt::ptr(value));
    glad_glUniform1fv(location, count, value);
}

void APIENTRY glUniform2fv(GLint location, GLsizei count, const GLfloat* value)
{
    GL_TRACER_LOG("glUniform2fv(" "{}, {}, {})", location, count, fmt::ptr(value));
    glad_glUniform2fv(location, count, value);
}

void APIENTRY glUniform3fv(GLint location, GLsizei count, const GLfloat* value)
{
    GL_TRACER_LOG("glUniform3fv(" "{}, {}, {})", location, count, fmt::ptr(value));
    glad_glUniform3fv(location, count, value);
}

void APIENTRY glUniform4fv(GLint location, GLsizei count, const GLfloat* value)
{
    GL_TRACER_LOG("glUniform4fv(" "{}, {}, {})", location, count, fmt::ptr(value));
    glad_glUniform4fv(location, count, value);
}

void APIENTRY glUniform1iv(GLint location, GLsizei count, const GLint* value)
{
    GL_TRACER_LOG("glUniform1iv(" "{}, {}, {})", location, count, fmt::ptr(value));
    glad_glUniform1iv(location, count, value);
}

void APIENTRY glUniform2iv(GLint location, GLsizei count, const GLint* value)
{
    GL_TRACER_LOG("glUniform2iv(" "{}, {}, {})", location, count, fmt::ptr(value));
    glad_glUniform2iv(location, count, value);
}

void APIENTRY glUniform3iv(GLint location, GLsizei count, const GLint* value)
{
    GL_TRACER_LOG("glUniform3iv(" "{}, {}, {})", location, count, fmt::ptr(value));
    glad_glUniform3iv(location, count, value);
}

void APIENTRY glUniform4iv(GLint location, GLsizei count, const GLint* value)
{
    GL_TRACER_LOG("glUniform4iv(" "{}, {}, {})", location, count, fmt::ptr(value));
    glad_glUniform4iv(location, count, value);
}

void APIENTRY glUniformMatrix2fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    GL_TRACER_LOG("glUniformMatrix2fv(" "{}, {}, {}, {})", location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glUniformMatrix2fv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix3fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    GL_TRACER_LOG("glUniformMatrix3fv(" "{}, {}, {}, {})", location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glUniformMatrix3fv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix4fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    GL_TRACER_LOG("glUniformMatrix4fv(" "{}, {}, {}, {})", location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glUniformMatrix4fv(location, count, transpose, value);
}

void APIENTRY glValidateProgram(GLuint program)
{
    GL_TRACER_LOG("glValidateProgram(" "{})", program);
    glad_glValidateProgram(program);
}

void APIENTRY glVertexAttrib1d(GLuint index, GLdouble x)
{
    GL_TRACER_LOG("glVertexAttrib1d(" "{}, {})", index, x);
    glad_glVertexAttrib1d(index, x);
}

void APIENTRY glVertexAttrib1dv(GLuint index, const GLdouble* v)
{
    GL_TRACER_LOG("glVertexAttrib1dv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib1dv(index, v);
}

void APIENTRY glVertexAttrib1f(GLuint index, GLfloat x)
{
    GL_TRACER_LOG("glVertexAttrib1f(" "{}, {})", index, x);
    glad_glVertexAttrib1f(index, x);
}

void APIENTRY glVertexAttrib1fv(GLuint index, const GLfloat* v)
{
    GL_TRACER_LOG("glVertexAttrib1fv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib1fv(index, v);
}

void APIENTRY glVertexAttrib1s(GLuint index, GLshort x)
{
    GL_TRACER_LOG("glVertexAttrib1s(" "{}, {})", index, x);
    glad_glVertexAttrib1s(index, x);
}

void APIENTRY glVertexAttrib1sv(GLuint index, const GLshort* v)
{
    GL_TRACER_LOG("glVertexAttrib1sv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib1sv(index, v);
}

void APIENTRY glVertexAttrib2d(GLuint index, GLdouble x, GLdouble y)
{
    GL_TRACER_LOG("glVertexAttrib2d(" "{}, {}, {})", index, x, y);
    glad_glVertexAttrib2d(index, x, y);
}

void APIENTRY glVertexAttrib2dv(GLuint index, const GLdouble* v)
{
    GL_TRACER_LOG("glVertexAttrib2dv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib2dv(index, v);
}

void APIENTRY glVertexAttrib2f(GLuint index, GLfloat x, GLfloat y)
{
    GL_TRACER_LOG("glVertexAttrib2f(" "{}, {}, {})", index, x, y);
    glad_glVertexAttrib2f(index, x, y);
}

void APIENTRY glVertexAttrib2fv(GLuint index, const GLfloat* v)
{
    GL_TRACER_LOG("glVertexAttrib2fv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib2fv(index, v);
}

void APIENTRY glVertexAttrib2s(GLuint index, GLshort x, GLshort y)
{
    GL_TRACER_LOG("glVertexAttrib2s(" "{}, {}, {})", index, x, y);
    glad_glVertexAttrib2s(index, x, y);
}

void APIENTRY glVertexAttrib2sv(GLuint index, const GLshort* v)
{
    GL_TRACER_LOG("glVertexAttrib2sv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib2sv(index, v);
}

void APIENTRY glVertexAttrib3d(GLuint index, GLdouble x, GLdouble y, GLdouble z)
{
    GL_TRACER_LOG("glVertexAttrib3d(" "{}, {}, {}, {})", index, x, y, z);
    glad_glVertexAttrib3d(index, x, y, z);
}

void APIENTRY glVertexAttrib3dv(GLuint index, const GLdouble* v)
{
    GL_TRACER_LOG("glVertexAttrib3dv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib3dv(index, v);
}

void APIENTRY glVertexAttrib3f(GLuint index, GLfloat x, GLfloat y, GLfloat z)
{
    GL_TRACER_LOG("glVertexAttrib3f(" "{}, {}, {}, {})", index, x, y, z);
    glad_glVertexAttrib3f(index, x, y, z);
}

void APIENTRY glVertexAttrib3fv(GLuint index, const GLfloat* v)
{
    GL_TRACER_LOG("glVertexAttrib3fv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib3fv(index, v);
}

void APIENTRY glVertexAttrib3s(GLuint index, GLshort x, GLshort y, GLshort z)
{
    GL_TRACER_LOG("glVertexAttrib3s(" "{}, {}, {}, {})", index, x, y, z);
    glad_glVertexAttrib3s(index, x, y, z);
}

void APIENTRY glVertexAttrib3sv(GLuint index, const GLshort* v)
{
    GL_TRACER_LOG("glVertexAttrib3sv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib3sv(index, v);
}

void APIENTRY glVertexAttrib4Nbv(GLuint index, const GLbyte* v)
{
    GL_TRACER_LOG("glVertexAttrib4Nbv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib4Nbv(index, v);
}

void APIENTRY glVertexAttrib4Niv(GLuint index, const GLint* v)
{
    GL_TRACER_LOG("glVertexAttrib4Niv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib4Niv(index, v);
}

void APIENTRY glVertexAttrib4Nsv(GLuint index, const GLshort* v)
{
    GL_TRACER_LOG("glVertexAttrib4Nsv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib4Nsv(index, v);
}

void APIENTRY glVertexAttrib4Nub(GLuint index, GLubyte x, GLubyte y, GLubyte z, GLubyte w)
{
    GL_TRACER_LOG("glVertexAttrib4Nub(" "{}, {}, {}, {}, {})", index, x, y, z, w);
    glad_glVertexAttrib4Nub(index, x, y, z, w);
}

void APIENTRY glVertexAttrib4Nubv(GLuint index, const GLubyte* v)
{
    GL_TRACER_LOG("glVertexAttrib4Nubv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib4Nubv(index, v);
}

void APIENTRY glVertexAttrib4Nuiv(GLuint index, const GLuint* v)
{
    GL_TRACER_LOG("glVertexAttrib4Nuiv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib4Nuiv(index, v);
}

void APIENTRY glVertexAttrib4Nusv(GLuint index, const GLushort* v)
{
    GL_TRACER_LOG("glVertexAttrib4Nusv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib4Nusv(index, v);
}

void APIENTRY glVertexAttrib4bv(GLuint index, const GLbyte* v)
{
    GL_TRACER_LOG("glVertexAttrib4bv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib4bv(index, v);
}

void APIENTRY glVertexAttrib4d(GLuint index, GLdouble x, GLdouble y, GLdouble z, GLdouble w)
{
    GL_TRACER_LOG("glVertexAttrib4d(" "{}, {}, {}, {}, {})", index, x, y, z, w);
    glad_glVertexAttrib4d(index, x, y, z, w);
}

void APIENTRY glVertexAttrib4dv(GLuint index, const GLdouble* v)
{
    GL_TRACER_LOG("glVertexAttrib4dv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib4dv(index, v);
}

void APIENTRY glVertexAttrib4f(GLuint index, GLfloat x, GLfloat y, GLfloat z, GLfloat w)
{
    GL_TRACER_LOG("glVertexAttrib4f(" "{}, {}, {}, {}, {})", index, x, y, z, w);
    glad_glVertexAttrib4f(index, x, y, z, w);
}

void APIENTRY glVertexAttrib4fv(GLuint index, const GLfloat* v)
{
    GL_TRACER_LOG("glVertexAttrib4fv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib4fv(index, v);
}

void APIENTRY glVertexAttrib4iv(GLuint index, const GLint* v)
{
    GL_TRACER_LOG("glVertexAttrib4iv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib4iv(index, v);
}

void APIENTRY glVertexAttrib4s(GLuint index, GLshort x, GLshort y, GLshort z, GLshort w)
{
    GL_TRACER_LOG("glVertexAttrib4s(" "{}, {}, {}, {}, {})", index, x, y, z, w);
    glad_glVertexAttrib4s(index, x, y, z, w);
}

void APIENTRY glVertexAttrib4sv(GLuint index, const GLshort* v)
{
    GL_TRACER_LOG("glVertexAttrib4sv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib4sv(index, v);
}

void APIENTRY glVertexAttrib4ubv(GLuint index, const GLubyte* v)
{
    GL_TRACER_LOG("glVertexAttrib4ubv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib4ubv(index, v);
}

void APIENTRY glVertexAttrib4uiv(GLuint index, const GLuint* v)
{
    GL_TRACER_LOG("glVertexAttrib4uiv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib4uiv(index, v);
}

void APIENTRY glVertexAttrib4usv(GLuint index, const GLushort* v)
{
    GL_TRACER_LOG("glVertexAttrib4usv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttrib4usv(index, v);
}

void APIENTRY glVertexAttribPointer(GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const void* pointer)
{
    GL_TRACER_LOG("glVertexAttribPointer(" "{}, {}, {}, {}, {}, {})", index, size, E2S(type), (unsigned int)(normalized), stride, fmt::ptr(pointer));
    glad_glVertexAttribPointer(index, size, type, normalized, stride, pointer);
}

void APIENTRY glUniformMatrix2x3fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    GL_TRACER_LOG("glUniformMatrix2x3fv(" "{}, {}, {}, {})", location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glUniformMatrix2x3fv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix3x2fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    GL_TRACER_LOG("glUniformMatrix3x2fv(" "{}, {}, {}, {})", location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glUniformMatrix3x2fv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix2x4fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    GL_TRACER_LOG("glUniformMatrix2x4fv(" "{}, {}, {}, {})", location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glUniformMatrix2x4fv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix4x2fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    GL_TRACER_LOG("glUniformMatrix4x2fv(" "{}, {}, {}, {})", location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glUniformMatrix4x2fv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix3x4fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    GL_TRACER_LOG("glUniformMatrix3x4fv(" "{}, {}, {}, {})", location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glUniformMatrix3x4fv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix4x3fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    GL_TRACER_LOG("glUniformMatrix4x3fv(" "{}, {}, {}, {})", location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glUniformMatrix4x3fv(location, count, transpose, value);
}

void APIENTRY glColorMaski(GLuint index, GLboolean r, GLboolean g, GLboolean b, GLboolean a)
{
    GL_TRACER_LOG("glColorMaski(" "{}, {}, {}, {}, {})", index, (unsigned int)(r), (unsigned int)(g), (unsigned int)(b), (unsigned int)(a));
    glad_glColorMaski(index, r, g, b, a);
}

void APIENTRY glGetBooleani_v(GLenum target, GLuint index, GLboolean* data)
{
    GL_TRACER_LOG("glGetBooleani_v(" "{}, {}, {})", E2S(target), index, fmt::ptr(data));
    glad_glGetBooleani_v(target, index, data);
}

void APIENTRY glGetIntegeri_v(GLenum target, GLuint index, GLint* data)
{
    GL_TRACER_LOG("glGetIntegeri_v(" "{}, {}, {})", E2S(target), index, fmt::ptr(data));
    glad_glGetIntegeri_v(target, index, data);
}

void APIENTRY glEnablei(GLenum target, GLuint index)
{
    GL_TRACER_LOG("glEnablei(" "{}, {})", E2S(target), index);
    glad_glEnablei(target, index);
}

void APIENTRY glDisablei(GLenum target, GLuint index)
{
    GL_TRACER_LOG("glDisablei(" "{}, {})", E2S(target), index);
    glad_glDisablei(target, index);
}

GLboolean APIENTRY glIsEnabledi(GLenum target, GLuint index)
{
    GL_TRACER_LOG("glIsEnabledi(" "{}, {})", E2S(target), index);
    GLboolean const r = glad_glIsEnabledi(target, index);
    return r;
}

void APIENTRY glBeginTransformFeedback(GLenum primitiveMode)
{
    GL_TRACER_LOG("glBeginTransformFeedback(" "{})", E2S(primitiveMode));
    glad_glBeginTransformFeedback(primitiveMode);
}

void APIENTRY glEndTransformFeedback()
{
    GL_TRACER_LOG("glEndTransformFeedback()");
    glad_glEndTransformFeedback();
}

void APIENTRY glBindBufferRange(GLenum target, GLuint index, GLuint buffer, GLintptr offset, GLsizeiptr size)
{
    GL_TRACER_LOG("glBindBufferRange(" "{}, {}, {}, {}, {})", E2S(target), index, buffer, offset, size);
    glad_glBindBufferRange(target, index, buffer, offset, size);
}

void APIENTRY glBindBufferBase(GLenum target, GLuint index, GLuint buffer)
{
    GL_TRACER_LOG("glBindBufferBase(" "{}, {}, {})", E2S(target), index, buffer);
    glad_glBindBufferBase(target, index, buffer);
}

void APIENTRY glTransformFeedbackVaryings(GLuint program, GLsizei count, const GLchar* const* varyings, GLenum bufferMode)
{
    GL_TRACER_LOG("glTransformFeedbackVaryings(" "{}, {}, {}, {})", program, count, fmt::ptr(varyings), E2S(bufferMode));
    glad_glTransformFeedbackVaryings(program, count, varyings, bufferMode);
}

void APIENTRY glGetTransformFeedbackVarying(GLuint program, GLuint index, GLsizei bufSize, GLsizei* length, GLsizei* size, GLenum* type, GLchar* name)
{
    GL_TRACER_LOG("glGetTransformFeedbackVarying(" "{}, {}, {}, {}, {}, {}, {})", program, index, bufSize, fmt::ptr(length), fmt::ptr(size), fmt::ptr(type), fmt::ptr(name));
    glad_glGetTransformFeedbackVarying(program, index, bufSize, length, size, type, name);
}

void APIENTRY glClampColor(GLenum target, GLenum clamp)
{
    GL_TRACER_LOG("glClampColor(" "{}, {})", E2S(target), E2S(clamp));
    glad_glClampColor(target, clamp);
}

void APIENTRY glBeginConditionalRender(GLuint id, GLenum mode)
{
    GL_TRACER_LOG("glBeginConditionalRender(" "{}, {})", id, E2S(mode));
    glad_glBeginConditionalRender(id, mode);
}

void APIENTRY glEndConditionalRender()
{
    GL_TRACER_LOG("glEndConditionalRender()");
    glad_glEndConditionalRender();
}

void APIENTRY glVertexAttribIPointer(GLuint index, GLint size, GLenum type, GLsizei stride, const void* pointer)
{
    GL_TRACER_LOG("glVertexAttribIPointer(" "{}, {}, {}, {}, {})", index, size, E2S(type), stride, fmt::ptr(pointer));
    glad_glVertexAttribIPointer(index, size, type, stride, pointer);
}

void APIENTRY glGetVertexAttribIiv(GLuint index, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetVertexAttribIiv(" "{}, {}, {})", index, E2S(pname), fmt::ptr(params));
    glad_glGetVertexAttribIiv(index, pname, params);
}

void APIENTRY glGetVertexAttribIuiv(GLuint index, GLenum pname, GLuint* params)
{
    GL_TRACER_LOG("glGetVertexAttribIuiv(" "{}, {}, {})", index, E2S(pname), fmt::ptr(params));
    glad_glGetVertexAttribIuiv(index, pname, params);
}

void APIENTRY glVertexAttribI1i(GLuint index, GLint x)
{
    GL_TRACER_LOG("glVertexAttribI1i(" "{}, {})", index, x);
    glad_glVertexAttribI1i(index, x);
}

void APIENTRY glVertexAttribI2i(GLuint index, GLint x, GLint y)
{
    GL_TRACER_LOG("glVertexAttribI2i(" "{}, {}, {})", index, x, y);
    glad_glVertexAttribI2i(index, x, y);
}

void APIENTRY glVertexAttribI3i(GLuint index, GLint x, GLint y, GLint z)
{
    GL_TRACER_LOG("glVertexAttribI3i(" "{}, {}, {}, {})", index, x, y, z);
    glad_glVertexAttribI3i(index, x, y, z);
}

void APIENTRY glVertexAttribI4i(GLuint index, GLint x, GLint y, GLint z, GLint w)
{
    GL_TRACER_LOG("glVertexAttribI4i(" "{}, {}, {}, {}, {})", index, x, y, z, w);
    glad_glVertexAttribI4i(index, x, y, z, w);
}

void APIENTRY glVertexAttribI1ui(GLuint index, GLuint x)
{
    GL_TRACER_LOG("glVertexAttribI1ui(" "{}, {})", index, x);
    glad_glVertexAttribI1ui(index, x);
}

void APIENTRY glVertexAttribI2ui(GLuint index, GLuint x, GLuint y)
{
    GL_TRACER_LOG("glVertexAttribI2ui(" "{}, {}, {})", index, x, y);
    glad_glVertexAttribI2ui(index, x, y);
}

void APIENTRY glVertexAttribI3ui(GLuint index, GLuint x, GLuint y, GLuint z)
{
    GL_TRACER_LOG("glVertexAttribI3ui(" "{}, {}, {}, {})", index, x, y, z);
    glad_glVertexAttribI3ui(index, x, y, z);
}

void APIENTRY glVertexAttribI4ui(GLuint index, GLuint x, GLuint y, GLuint z, GLuint w)
{
    GL_TRACER_LOG("glVertexAttribI4ui(" "{}, {}, {}, {}, {})", index, x, y, z, w);
    glad_glVertexAttribI4ui(index, x, y, z, w);
}

void APIENTRY glVertexAttribI1iv(GLuint index, const GLint* v)
{
    GL_TRACER_LOG("glVertexAttribI1iv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttribI1iv(index, v);
}

void APIENTRY glVertexAttribI2iv(GLuint index, const GLint* v)
{
    GL_TRACER_LOG("glVertexAttribI2iv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttribI2iv(index, v);
}

void APIENTRY glVertexAttribI3iv(GLuint index, const GLint* v)
{
    GL_TRACER_LOG("glVertexAttribI3iv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttribI3iv(index, v);
}

void APIENTRY glVertexAttribI4iv(GLuint index, const GLint* v)
{
    GL_TRACER_LOG("glVertexAttribI4iv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttribI4iv(index, v);
}

void APIENTRY glVertexAttribI1uiv(GLuint index, const GLuint* v)
{
    GL_TRACER_LOG("glVertexAttribI1uiv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttribI1uiv(index, v);
}

void APIENTRY glVertexAttribI2uiv(GLuint index, const GLuint* v)
{
    GL_TRACER_LOG("glVertexAttribI2uiv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttribI2uiv(index, v);
}

void APIENTRY glVertexAttribI3uiv(GLuint index, const GLuint* v)
{
    GL_TRACER_LOG("glVertexAttribI3uiv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttribI3uiv(index, v);
}

void APIENTRY glVertexAttribI4uiv(GLuint index, const GLuint* v)
{
    GL_TRACER_LOG("glVertexAttribI4uiv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttribI4uiv(index, v);
}

void APIENTRY glVertexAttribI4bv(GLuint index, const GLbyte* v)
{
    GL_TRACER_LOG("glVertexAttribI4bv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttribI4bv(index, v);
}

void APIENTRY glVertexAttribI4sv(GLuint index, const GLshort* v)
{
    GL_TRACER_LOG("glVertexAttribI4sv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttribI4sv(index, v);
}

void APIENTRY glVertexAttribI4ubv(GLuint index, const GLubyte* v)
{
    GL_TRACER_LOG("glVertexAttribI4ubv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttribI4ubv(index, v);
}

void APIENTRY glVertexAttribI4usv(GLuint index, const GLushort* v)
{
    GL_TRACER_LOG("glVertexAttribI4usv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttribI4usv(index, v);
}

void APIENTRY glGetUniformuiv(GLuint program, GLint location, GLuint* params)
{
    GL_TRACER_LOG("glGetUniformuiv(" "{}, {}, {})", program, location, fmt::ptr(params));
    glad_glGetUniformuiv(program, location, params);
}

void APIENTRY glBindFragDataLocation(GLuint program, GLuint color, const GLchar* name)
{
    GL_TRACER_LOG("glBindFragDataLocation(" "{}, {}, {})", program, color, fmt::ptr(name));
    glad_glBindFragDataLocation(program, color, name);
}

GLint APIENTRY glGetFragDataLocation(GLuint program, const GLchar* name)
{
    GL_TRACER_LOG("glGetFragDataLocation(" "{}, {})", program, fmt::ptr(name));
    GLint const r = glad_glGetFragDataLocation(program, name);
    return r;
}

void APIENTRY glUniform1ui(GLint location, GLuint v0)
{
    GL_TRACER_LOG("glUniform1ui(" "{}, {})", location, v0);
    glad_glUniform1ui(location, v0);
}

void APIENTRY glUniform2ui(GLint location, GLuint v0, GLuint v1)
{
    GL_TRACER_LOG("glUniform2ui(" "{}, {}, {})", location, v0, v1);
    glad_glUniform2ui(location, v0, v1);
}

void APIENTRY glUniform3ui(GLint location, GLuint v0, GLuint v1, GLuint v2)
{
    GL_TRACER_LOG("glUniform3ui(" "{}, {}, {}, {})", location, v0, v1, v2);
    glad_glUniform3ui(location, v0, v1, v2);
}

void APIENTRY glUniform4ui(GLint location, GLuint v0, GLuint v1, GLuint v2, GLuint v3)
{
    GL_TRACER_LOG("glUniform4ui(" "{}, {}, {}, {}, {})", location, v0, v1, v2, v3);
    glad_glUniform4ui(location, v0, v1, v2, v3);
}

void APIENTRY glUniform1uiv(GLint location, GLsizei count, const GLuint* value)
{
    GL_TRACER_LOG("glUniform1uiv(" "{}, {}, {})", location, count, fmt::ptr(value));
    glad_glUniform1uiv(location, count, value);
}

void APIENTRY glUniform2uiv(GLint location, GLsizei count, const GLuint* value)
{
    GL_TRACER_LOG("glUniform2uiv(" "{}, {}, {})", location, count, fmt::ptr(value));
    glad_glUniform2uiv(location, count, value);
}

void APIENTRY glUniform3uiv(GLint location, GLsizei count, const GLuint* value)
{
    GL_TRACER_LOG("glUniform3uiv(" "{}, {}, {})", location, count, fmt::ptr(value));
    glad_glUniform3uiv(location, count, value);
}

void APIENTRY glUniform4uiv(GLint location, GLsizei count, const GLuint* value)
{
    GL_TRACER_LOG("glUniform4uiv(" "{}, {}, {})", location, count, fmt::ptr(value));
    glad_glUniform4uiv(location, count, value);
}

void APIENTRY glTexParameterIiv(GLenum target, GLenum pname, const GLint* params)
{
    GL_TRACER_LOG("glTexParameterIiv(" "{}, {}, {})", E2S(target), E2S(pname), fmt::ptr(params));
    glad_glTexParameterIiv(target, pname, params);
}

void APIENTRY glTexParameterIuiv(GLenum target, GLenum pname, const GLuint* params)
{
    GL_TRACER_LOG("glTexParameterIuiv(" "{}, {}, {})", E2S(target), E2S(pname), fmt::ptr(params));
    glad_glTexParameterIuiv(target, pname, params);
}

void APIENTRY glGetTexParameterIiv(GLenum target, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetTexParameterIiv(" "{}, {}, {})", E2S(target), E2S(pname), fmt::ptr(params));
    glad_glGetTexParameterIiv(target, pname, params);
}

void APIENTRY glGetTexParameterIuiv(GLenum target, GLenum pname, GLuint* params)
{
    GL_TRACER_LOG("glGetTexParameterIuiv(" "{}, {}, {})", E2S(target), E2S(pname), fmt::ptr(params));
    glad_glGetTexParameterIuiv(target, pname, params);
}

void APIENTRY glClearBufferiv(GLenum buffer, GLint drawbuffer, const GLint* value)
{
    GL_TRACER_LOG("glClearBufferiv(" "{}, {}, {})", E2S(buffer), drawbuffer, fmt::ptr(value));
    glad_glClearBufferiv(buffer, drawbuffer, value);
}

void APIENTRY glClearBufferuiv(GLenum buffer, GLint drawbuffer, const GLuint* value)
{
    GL_TRACER_LOG("glClearBufferuiv(" "{}, {}, {})", E2S(buffer), drawbuffer, fmt::ptr(value));
    glad_glClearBufferuiv(buffer, drawbuffer, value);
}

void APIENTRY glClearBufferfv(GLenum buffer, GLint drawbuffer, const GLfloat* value)
{
    GL_TRACER_LOG("glClearBufferfv(" "{}, {}, {})", E2S(buffer), drawbuffer, fmt::ptr(value));
    glad_glClearBufferfv(buffer, drawbuffer, value);
}

void APIENTRY glClearBufferfi(GLenum buffer, GLint drawbuffer, GLfloat depth, GLint stencil)
{
    GL_TRACER_LOG("glClearBufferfi(" "{}, {}, {}, {})", E2S(buffer), drawbuffer, depth, stencil);
    glad_glClearBufferfi(buffer, drawbuffer, depth, stencil);
}

const GLubyte* APIENTRY glGetStringi(GLenum name, GLuint index)
{
    GL_TRACER_LOG("glGetStringi(" "{}, {})", E2S(name), index);
    const GLubyte* const r = glad_glGetStringi(name, index);
    return r;
}

GLboolean APIENTRY glIsRenderbuffer(GLuint renderbuffer)
{
    GL_TRACER_LOG("glIsRenderbuffer(" "{})", renderbuffer);
    GLboolean const r = glad_glIsRenderbuffer(renderbuffer);
    return r;
}

void APIENTRY glBindRenderbuffer(GLenum target, GLuint renderbuffer)
{
    GL_TRACER_LOG("glBindRenderbuffer(" "{}, {})", E2S(target), renderbuffer);
    glad_glBindRenderbuffer(target, renderbuffer);
}

void APIENTRY glDeleteRenderbuffers(GLsizei n, const GLuint* renderbuffers)
{
    GL_TRACER_LOG("glDeleteRenderbuffers(" "{}, {})", n, fmt::ptr(renderbuffers));
    glad_glDeleteRenderbuffers(n, renderbuffers);
}

void APIENTRY glGenRenderbuffers(GLsizei n, GLuint* renderbuffers)
{
    GL_TRACER_LOG("glGenRenderbuffers(" "{}, {})", n, fmt::ptr(renderbuffers));
    glad_glGenRenderbuffers(n, renderbuffers);
}

void APIENTRY glRenderbufferStorage(GLenum target, GLenum internalformat, GLsizei width, GLsizei height)
{
    GL_TRACER_LOG("glRenderbufferStorage(" "{}, {}, {}, {})", E2S(target), E2S(internalformat), width, height);
    glad_glRenderbufferStorage(target, internalformat, width, height);
}

void APIENTRY glGetRenderbufferParameteriv(GLenum target, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetRenderbufferParameteriv(" "{}, {}, {})", E2S(target), E2S(pname), fmt::ptr(params));
    glad_glGetRenderbufferParameteriv(target, pname, params);
}

GLboolean APIENTRY glIsFramebuffer(GLuint framebuffer)
{
    GL_TRACER_LOG("glIsFramebuffer(" "{})", framebuffer);
    GLboolean const r = glad_glIsFramebuffer(framebuffer);
    return r;
}

void APIENTRY glBindFramebuffer(GLenum target, GLuint framebuffer)
{
    GL_TRACER_LOG("glBindFramebuffer(" "{}, {})", E2S(target), framebuffer);
    glad_glBindFramebuffer(target, framebuffer);
}

void APIENTRY glDeleteFramebuffers(GLsizei n, const GLuint* framebuffers)
{
    GL_TRACER_LOG("glDeleteFramebuffers(" "{}, {})", n, fmt::ptr(framebuffers));
    glad_glDeleteFramebuffers(n, framebuffers);
}

void APIENTRY glGenFramebuffers(GLsizei n, GLuint* framebuffers)
{
    GL_TRACER_LOG("glGenFramebuffers(" "{}, {})", n, fmt::ptr(framebuffers));
    glad_glGenFramebuffers(n, framebuffers);
}

GLenum APIENTRY glCheckFramebufferStatus(GLenum target)
{
    GL_TRACER_LOG("glCheckFramebufferStatus(" "{})", E2S(target));
    GLenum const r = glad_glCheckFramebufferStatus(target);
    return r;
}

void APIENTRY glFramebufferTexture1D(GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level)
{
    GL_TRACER_LOG("glFramebufferTexture1D(" "{}, {}, {}, {}, {})", E2S(target), E2S(attachment), E2S(textarget), texture, level);
    glad_glFramebufferTexture1D(target, attachment, textarget, texture, level);
}

void APIENTRY glFramebufferTexture2D(GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level)
{
    GL_TRACER_LOG("glFramebufferTexture2D(" "{}, {}, {}, {}, {})", E2S(target), E2S(attachment), E2S(textarget), texture, level);
    glad_glFramebufferTexture2D(target, attachment, textarget, texture, level);
}

void APIENTRY glFramebufferTexture3D(GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level, GLint zoffset)
{
    GL_TRACER_LOG("glFramebufferTexture3D(" "{}, {}, {}, {}, {}, {})", E2S(target), E2S(attachment), E2S(textarget), texture, level, zoffset);
    glad_glFramebufferTexture3D(target, attachment, textarget, texture, level, zoffset);
}

void APIENTRY glFramebufferRenderbuffer(GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer)
{
    GL_TRACER_LOG("glFramebufferRenderbuffer(" "{}, {}, {}, {})", E2S(target), E2S(attachment), E2S(renderbuffertarget), renderbuffer);
    glad_glFramebufferRenderbuffer(target, attachment, renderbuffertarget, renderbuffer);
}

void APIENTRY glGetFramebufferAttachmentParameteriv(GLenum target, GLenum attachment, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetFramebufferAttachmentParameteriv(" "{}, {}, {}, {})", E2S(target), E2S(attachment), E2S(pname), fmt::ptr(params));
    glad_glGetFramebufferAttachmentParameteriv(target, attachment, pname, params);
}

void APIENTRY glGenerateMipmap(GLenum target)
{
    GL_TRACER_LOG("glGenerateMipmap(" "{})", E2S(target));
    glad_glGenerateMipmap(target);
}

void APIENTRY glBlitFramebuffer(GLint srcX0, GLint srcY0, GLint srcX1, GLint srcY1, GLint dstX0, GLint dstY0, GLint dstX1, GLint dstY1, GLbitfield mask, GLenum filter)
{
    GL_TRACER_LOG("glBlitFramebuffer(" "{}, {}, {}, {}, {}, {}, {}, {}, {}, {})", srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, (unsigned int)(mask), E2S(filter));
    glad_glBlitFramebuffer(srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, mask, filter);
}

void APIENTRY glRenderbufferStorageMultisample(GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height)
{
    GL_TRACER_LOG("glRenderbufferStorageMultisample(" "{}, {}, {}, {}, {})", E2S(target), samples, E2S(internalformat), width, height);
    glad_glRenderbufferStorageMultisample(target, samples, internalformat, width, height);
}

void APIENTRY glFramebufferTextureLayer(GLenum target, GLenum attachment, GLuint texture, GLint level, GLint layer)
{
    GL_TRACER_LOG("glFramebufferTextureLayer(" "{}, {}, {}, {}, {})", E2S(target), E2S(attachment), texture, level, layer);
    glad_glFramebufferTextureLayer(target, attachment, texture, level, layer);
}

void* APIENTRY glMapBufferRange(GLenum target, GLintptr offset, GLsizeiptr length, GLbitfield access)
{
    GL_TRACER_LOG("glMapBufferRange(" "{}, {}, {}, {})", E2S(target), offset, length, (unsigned int)(access));
    void* const r = glad_glMapBufferRange(target, offset, length, access);
    return r;
}

void APIENTRY glFlushMappedBufferRange(GLenum target, GLintptr offset, GLsizeiptr length)
{
    GL_TRACER_LOG("glFlushMappedBufferRange(" "{}, {}, {})", E2S(target), offset, length);
    glad_glFlushMappedBufferRange(target, offset, length);
}

void APIENTRY glBindVertexArray(GLuint array)
{
    GL_TRACER_LOG("glBindVertexArray(" "{})", array);
    glad_glBindVertexArray(array);
}

void APIENTRY glDeleteVertexArrays(GLsizei n, const GLuint* arrays)
{
    GL_TRACER_LOG("glDeleteVertexArrays(" "{}, {})", n, fmt::ptr(arrays));
    glad_glDeleteVertexArrays(n, arrays);
}

void APIENTRY glGenVertexArrays(GLsizei n, GLuint* arrays)
{
    GL_TRACER_LOG("glGenVertexArrays(" "{}, {})", n, fmt::ptr(arrays));
    glad_glGenVertexArrays(n, arrays);
}

GLboolean APIENTRY glIsVertexArray(GLuint array)
{
    GL_TRACER_LOG("glIsVertexArray(" "{})", array);
    GLboolean const r = glad_glIsVertexArray(array);
    return r;
}

void APIENTRY glDrawArraysInstanced(GLenum mode, GLint first, GLsizei count, GLsizei instancecount)
{
    GL_TRACER_LOG("glDrawArraysInstanced(" "{}, {}, {}, {})", E2S(mode), first, count, instancecount);
    glad_glDrawArraysInstanced(mode, first, count, instancecount);
}

void APIENTRY glDrawElementsInstanced(GLenum mode, GLsizei count, GLenum type, const void* indices, GLsizei instancecount)
{
    GL_TRACER_LOG("glDrawElementsInstanced(" "{}, {}, {}, {}, {})", E2S(mode), count, E2S(type), fmt::ptr(indices), instancecount);
    glad_glDrawElementsInstanced(mode, count, type, indices, instancecount);
}

void APIENTRY glTexBuffer(GLenum target, GLenum internalformat, GLuint buffer)
{
    GL_TRACER_LOG("glTexBuffer(" "{}, {}, {})", E2S(target), E2S(internalformat), buffer);
    glad_glTexBuffer(target, internalformat, buffer);
}

void APIENTRY glPrimitiveRestartIndex(GLuint index)
{
    GL_TRACER_LOG("glPrimitiveRestartIndex(" "{})", index);
    glad_glPrimitiveRestartIndex(index);
}

void APIENTRY glCopyBufferSubData(GLenum readTarget, GLenum writeTarget, GLintptr readOffset, GLintptr writeOffset, GLsizeiptr size)
{
    GL_TRACER_LOG("glCopyBufferSubData(" "{}, {}, {}, {}, {})", E2S(readTarget), E2S(writeTarget), readOffset, writeOffset, size);
    glad_glCopyBufferSubData(readTarget, writeTarget, readOffset, writeOffset, size);
}

void APIENTRY glGetUniformIndices(GLuint program, GLsizei uniformCount, const GLchar* const* uniformNames, GLuint* uniformIndices)
{
    GL_TRACER_LOG("glGetUniformIndices(" "{}, {}, {}, {})", program, uniformCount, fmt::ptr(uniformNames), fmt::ptr(uniformIndices));
    glad_glGetUniformIndices(program, uniformCount, uniformNames, uniformIndices);
}

void APIENTRY glGetActiveUniformsiv(GLuint program, GLsizei uniformCount, const GLuint* uniformIndices, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetActiveUniformsiv(" "{}, {}, {}, {}, {})", program, uniformCount, fmt::ptr(uniformIndices), E2S(pname), fmt::ptr(params));
    glad_glGetActiveUniformsiv(program, uniformCount, uniformIndices, pname, params);
}

void APIENTRY glGetActiveUniformName(GLuint program, GLuint uniformIndex, GLsizei bufSize, GLsizei* length, GLchar* uniformName)
{
    GL_TRACER_LOG("glGetActiveUniformName(" "{}, {}, {}, {}, {})", program, uniformIndex, bufSize, fmt::ptr(length), fmt::ptr(uniformName));
    glad_glGetActiveUniformName(program, uniformIndex, bufSize, length, uniformName);
}

GLuint APIENTRY glGetUniformBlockIndex(GLuint program, const GLchar* uniformBlockName)
{
    GL_TRACER_LOG("glGetUniformBlockIndex(" "{}, {})", program, fmt::ptr(uniformBlockName));
    GLuint const r = glad_glGetUniformBlockIndex(program, uniformBlockName);
    return r;
}

void APIENTRY glGetActiveUniformBlockiv(GLuint program, GLuint uniformBlockIndex, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetActiveUniformBlockiv(" "{}, {}, {}, {})", program, uniformBlockIndex, E2S(pname), fmt::ptr(params));
    glad_glGetActiveUniformBlockiv(program, uniformBlockIndex, pname, params);
}

void APIENTRY glGetActiveUniformBlockName(GLuint program, GLuint uniformBlockIndex, GLsizei bufSize, GLsizei* length, GLchar* uniformBlockName)
{
    GL_TRACER_LOG("glGetActiveUniformBlockName(" "{}, {}, {}, {}, {})", program, uniformBlockIndex, bufSize, fmt::ptr(length), fmt::ptr(uniformBlockName));
    glad_glGetActiveUniformBlockName(program, uniformBlockIndex, bufSize, length, uniformBlockName);
}

void APIENTRY glUniformBlockBinding(GLuint program, GLuint uniformBlockIndex, GLuint uniformBlockBinding)
{
    GL_TRACER_LOG("glUniformBlockBinding(" "{}, {}, {})", program, uniformBlockIndex, uniformBlockBinding);
    glad_glUniformBlockBinding(program, uniformBlockIndex, uniformBlockBinding);
}

void APIENTRY glDrawElementsBaseVertex(GLenum mode, GLsizei count, GLenum type, const void* indices, GLint basevertex)
{
    GL_TRACER_LOG("glDrawElementsBaseVertex(" "{}, {}, {}, {}, {})", E2S(mode), count, E2S(type), fmt::ptr(indices), basevertex);
    glad_glDrawElementsBaseVertex(mode, count, type, indices, basevertex);
}

void APIENTRY glDrawRangeElementsBaseVertex(GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum type, const void* indices, GLint basevertex)
{
    GL_TRACER_LOG("glDrawRangeElementsBaseVertex(" "{}, {}, {}, {}, {}, {}, {})", E2S(mode), start, end, count, E2S(type), fmt::ptr(indices), basevertex);
    glad_glDrawRangeElementsBaseVertex(mode, start, end, count, type, indices, basevertex);
}

void APIENTRY glDrawElementsInstancedBaseVertex(GLenum mode, GLsizei count, GLenum type, const void* indices, GLsizei instancecount, GLint basevertex)
{
    GL_TRACER_LOG("glDrawElementsInstancedBaseVertex(" "{}, {}, {}, {}, {}, {})", E2S(mode), count, E2S(type), fmt::ptr(indices), instancecount, basevertex);
    glad_glDrawElementsInstancedBaseVertex(mode, count, type, indices, instancecount, basevertex);
}

void APIENTRY glMultiDrawElementsBaseVertex(GLenum mode, const GLsizei* count, GLenum type, const void* const* indices, GLsizei drawcount, const GLint* basevertex)
{
    GL_TRACER_LOG("glMultiDrawElementsBaseVertex(" "{}, {}, {}, {}, {}, {})", E2S(mode), fmt::ptr(count), E2S(type), fmt::ptr(indices), drawcount, fmt::ptr(basevertex));
    glad_glMultiDrawElementsBaseVertex(mode, count, type, indices, drawcount, basevertex);
}

void APIENTRY glProvokingVertex(GLenum mode)
{
    GL_TRACER_LOG("glProvokingVertex(" "{})", E2S(mode));
    glad_glProvokingVertex(mode);
}

GLsync APIENTRY glFenceSync(GLenum condition, GLbitfield flags)
{
    GL_TRACER_LOG("glFenceSync(" "{}, {})", E2S(condition), (unsigned int)(flags));
    GLsync const r = glad_glFenceSync(condition, flags);
    return r;
}

GLboolean APIENTRY glIsSync(GLsync sync)
{
    GL_TRACER_LOG("glIsSync(" "{})", fmt::ptr(sync));
    GLboolean const r = glad_glIsSync(sync);
    return r;
}

void APIENTRY glDeleteSync(GLsync sync)
{
    GL_TRACER_LOG("glDeleteSync(" "{})", fmt::ptr(sync));
    glad_glDeleteSync(sync);
}

GLenum APIENTRY glClientWaitSync(GLsync sync, GLbitfield flags, GLuint64 timeout)
{
    GL_TRACER_LOG("glClientWaitSync(" "{}, {}, {})", fmt::ptr(sync), (unsigned int)(flags), timeout);
    GLenum const r = glad_glClientWaitSync(sync, flags, timeout);
    return r;
}

void APIENTRY glWaitSync(GLsync sync, GLbitfield flags, GLuint64 timeout)
{
    GL_TRACER_LOG("glWaitSync(" "{}, {}, {})", fmt::ptr(sync), (unsigned int)(flags), timeout);
    glad_glWaitSync(sync, flags, timeout);
}

void APIENTRY glGetInteger64v(GLenum pname, GLint64* data)
{
    GL_TRACER_LOG("glGetInteger64v(" "{}, {})", E2S(pname), fmt::ptr(data));
    glad_glGetInteger64v(pname, data);
}

void APIENTRY glGetSynciv(GLsync sync, GLenum pname, GLsizei count, GLsizei* length, GLint* values)
{
    GL_TRACER_LOG("glGetSynciv(" "{}, {}, {}, {}, {})", fmt::ptr(sync), E2S(pname), count, fmt::ptr(length), fmt::ptr(values));
    glad_glGetSynciv(sync, pname, count, length, values);
}

void APIENTRY glGetInteger64i_v(GLenum target, GLuint index, GLint64* data)
{
    GL_TRACER_LOG("glGetInteger64i_v(" "{}, {}, {})", E2S(target), index, fmt::ptr(data));
    glad_glGetInteger64i_v(target, index, data);
}

void APIENTRY glGetBufferParameteri64v(GLenum target, GLenum pname, GLint64* params)
{
    GL_TRACER_LOG("glGetBufferParameteri64v(" "{}, {}, {})", E2S(target), E2S(pname), fmt::ptr(params));
    glad_glGetBufferParameteri64v(target, pname, params);
}

void APIENTRY glFramebufferTexture(GLenum target, GLenum attachment, GLuint texture, GLint level)
{
    GL_TRACER_LOG("glFramebufferTexture(" "{}, {}, {}, {})", E2S(target), E2S(attachment), texture, level);
    glad_glFramebufferTexture(target, attachment, texture, level);
}

void APIENTRY glTexImage2DMultisample(GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLboolean fixedsamplelocations)
{
    GL_TRACER_LOG("glTexImage2DMultisample(" "{}, {}, {}, {}, {}, {})", E2S(target), samples, E2S(internalformat), width, height, (unsigned int)(fixedsamplelocations));
    glad_glTexImage2DMultisample(target, samples, internalformat, width, height, fixedsamplelocations);
}

void APIENTRY glTexImage3DMultisample(GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLboolean fixedsamplelocations)
{
    GL_TRACER_LOG("glTexImage3DMultisample(" "{}, {}, {}, {}, {}, {}, {})", E2S(target), samples, E2S(internalformat), width, height, depth, (unsigned int)(fixedsamplelocations));
    glad_glTexImage3DMultisample(target, samples, internalformat, width, height, depth, fixedsamplelocations);
}

void APIENTRY glGetMultisamplefv(GLenum pname, GLuint index, GLfloat* val)
{
    GL_TRACER_LOG("glGetMultisamplefv(" "{}, {}, {})", E2S(pname), index, fmt::ptr(val));
    glad_glGetMultisamplefv(pname, index, val);
}

void APIENTRY glSampleMaski(GLuint maskNumber, GLbitfield mask)
{
    GL_TRACER_LOG("glSampleMaski(" "{}, {})", maskNumber, (unsigned int)(mask));
    glad_glSampleMaski(maskNumber, mask);
}

void APIENTRY glBindFragDataLocationIndexed(GLuint program, GLuint colorNumber, GLuint index, const GLchar* name)
{
    GL_TRACER_LOG("glBindFragDataLocationIndexed(" "{}, {}, {}, {})", program, colorNumber, index, fmt::ptr(name));
    glad_glBindFragDataLocationIndexed(program, colorNumber, index, name);
}

GLint APIENTRY glGetFragDataIndex(GLuint program, const GLchar* name)
{
    GL_TRACER_LOG("glGetFragDataIndex(" "{}, {})", program, fmt::ptr(name));
    GLint const r = glad_glGetFragDataIndex(program, name);
    return r;
}

void APIENTRY glGenSamplers(GLsizei count, GLuint* samplers)
{
    GL_TRACER_LOG("glGenSamplers(" "{}, {})", count, fmt::ptr(samplers));
    glad_glGenSamplers(count, samplers);
}

void APIENTRY glDeleteSamplers(GLsizei count, const GLuint* samplers)
{
    GL_TRACER_LOG("glDeleteSamplers(" "{}, {})", count, fmt::ptr(samplers));
    glad_glDeleteSamplers(count, samplers);
}

GLboolean APIENTRY glIsSampler(GLuint sampler)
{
    GL_TRACER_LOG("glIsSampler(" "{})", sampler);
    GLboolean const r = glad_glIsSampler(sampler);
    return r;
}

void APIENTRY glBindSampler(GLuint unit, GLuint sampler)
{
    GL_TRACER_LOG("glBindSampler(" "{}, {})", unit, sampler);
    glad_glBindSampler(unit, sampler);
}

void APIENTRY glSamplerParameteri(GLuint sampler, GLenum pname, GLint param)
{
    GL_TRACER_LOG("glSamplerParameteri(" "{}, {}, {})", sampler, E2S(pname), param);
    glad_glSamplerParameteri(sampler, pname, param);
}

void APIENTRY glSamplerParameteriv(GLuint sampler, GLenum pname, const GLint* param)
{
    GL_TRACER_LOG("glSamplerParameteriv(" "{}, {}, {})", sampler, E2S(pname), fmt::ptr(param));
    glad_glSamplerParameteriv(sampler, pname, param);
}

void APIENTRY glSamplerParameterf(GLuint sampler, GLenum pname, GLfloat param)
{
    GL_TRACER_LOG("glSamplerParameterf(" "{}, {}, {})", sampler, E2S(pname), param);
    glad_glSamplerParameterf(sampler, pname, param);
}

void APIENTRY glSamplerParameterfv(GLuint sampler, GLenum pname, const GLfloat* param)
{
    GL_TRACER_LOG("glSamplerParameterfv(" "{}, {}, {})", sampler, E2S(pname), fmt::ptr(param));
    glad_glSamplerParameterfv(sampler, pname, param);
}

void APIENTRY glSamplerParameterIiv(GLuint sampler, GLenum pname, const GLint* param)
{
    GL_TRACER_LOG("glSamplerParameterIiv(" "{}, {}, {})", sampler, E2S(pname), fmt::ptr(param));
    glad_glSamplerParameterIiv(sampler, pname, param);
}

void APIENTRY glSamplerParameterIuiv(GLuint sampler, GLenum pname, const GLuint* param)
{
    GL_TRACER_LOG("glSamplerParameterIuiv(" "{}, {}, {})", sampler, E2S(pname), fmt::ptr(param));
    glad_glSamplerParameterIuiv(sampler, pname, param);
}

void APIENTRY glGetSamplerParameteriv(GLuint sampler, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetSamplerParameteriv(" "{}, {}, {})", sampler, E2S(pname), fmt::ptr(params));
    glad_glGetSamplerParameteriv(sampler, pname, params);
}

void APIENTRY glGetSamplerParameterIiv(GLuint sampler, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetSamplerParameterIiv(" "{}, {}, {})", sampler, E2S(pname), fmt::ptr(params));
    glad_glGetSamplerParameterIiv(sampler, pname, params);
}

void APIENTRY glGetSamplerParameterfv(GLuint sampler, GLenum pname, GLfloat* params)
{
    GL_TRACER_LOG("glGetSamplerParameterfv(" "{}, {}, {})", sampler, E2S(pname), fmt::ptr(params));
    glad_glGetSamplerParameterfv(sampler, pname, params);
}

void APIENTRY glGetSamplerParameterIuiv(GLuint sampler, GLenum pname, GLuint* params)
{
    GL_TRACER_LOG("glGetSamplerParameterIuiv(" "{}, {}, {})", sampler, E2S(pname), fmt::ptr(params));
    glad_glGetSamplerParameterIuiv(sampler, pname, params);
}

void APIENTRY glQueryCounter(GLuint id, GLenum target)
{
    GL_TRACER_LOG("glQueryCounter(" "{}, {})", id, E2S(target));
    glad_glQueryCounter(id, target);
}

void APIENTRY glGetQueryObjecti64v(GLuint id, GLenum pname, GLint64* params)
{
    GL_TRACER_LOG("glGetQueryObjecti64v(" "{}, {}, {})", id, E2S(pname), fmt::ptr(params));
    glad_glGetQueryObjecti64v(id, pname, params);
}

void APIENTRY glGetQueryObjectui64v(GLuint id, GLenum pname, GLuint64* params)
{
    GL_TRACER_LOG("glGetQueryObjectui64v(" "{}, {}, {})", id, E2S(pname), fmt::ptr(params));
    glad_glGetQueryObjectui64v(id, pname, params);
}

void APIENTRY glVertexAttribDivisor(GLuint index, GLuint divisor)
{
    GL_TRACER_LOG("glVertexAttribDivisor(" "{}, {})", index, divisor);
    glad_glVertexAttribDivisor(index, divisor);
}

void APIENTRY glVertexAttribP1ui(GLuint index, GLenum type, GLboolean normalized, GLuint value)
{
    GL_TRACER_LOG("glVertexAttribP1ui(" "{}, {}, {}, {})", index, E2S(type), (unsigned int)(normalized), value);
    glad_glVertexAttribP1ui(index, type, normalized, value);
}

void APIENTRY glVertexAttribP1uiv(GLuint index, GLenum type, GLboolean normalized, const GLuint* value)
{
    GL_TRACER_LOG("glVertexAttribP1uiv(" "{}, {}, {}, {})", index, E2S(type), (unsigned int)(normalized), fmt::ptr(value));
    glad_glVertexAttribP1uiv(index, type, normalized, value);
}

void APIENTRY glVertexAttribP2ui(GLuint index, GLenum type, GLboolean normalized, GLuint value)
{
    GL_TRACER_LOG("glVertexAttribP2ui(" "{}, {}, {}, {})", index, E2S(type), (unsigned int)(normalized), value);
    glad_glVertexAttribP2ui(index, type, normalized, value);
}

void APIENTRY glVertexAttribP2uiv(GLuint index, GLenum type, GLboolean normalized, const GLuint* value)
{
    GL_TRACER_LOG("glVertexAttribP2uiv(" "{}, {}, {}, {})", index, E2S(type), (unsigned int)(normalized), fmt::ptr(value));
    glad_glVertexAttribP2uiv(index, type, normalized, value);
}

void APIENTRY glVertexAttribP3ui(GLuint index, GLenum type, GLboolean normalized, GLuint value)
{
    GL_TRACER_LOG("glVertexAttribP3ui(" "{}, {}, {}, {})", index, E2S(type), (unsigned int)(normalized), value);
    glad_glVertexAttribP3ui(index, type, normalized, value);
}

void APIENTRY glVertexAttribP3uiv(GLuint index, GLenum type, GLboolean normalized, const GLuint* value)
{
    GL_TRACER_LOG("glVertexAttribP3uiv(" "{}, {}, {}, {})", index, E2S(type), (unsigned int)(normalized), fmt::ptr(value));
    glad_glVertexAttribP3uiv(index, type, normalized, value);
}

void APIENTRY glVertexAttribP4ui(GLuint index, GLenum type, GLboolean normalized, GLuint value)
{
    GL_TRACER_LOG("glVertexAttribP4ui(" "{}, {}, {}, {})", index, E2S(type), (unsigned int)(normalized), value);
    glad_glVertexAttribP4ui(index, type, normalized, value);
}

void APIENTRY glVertexAttribP4uiv(GLuint index, GLenum type, GLboolean normalized, const GLuint* value)
{
    GL_TRACER_LOG("glVertexAttribP4uiv(" "{}, {}, {}, {})", index, E2S(type), (unsigned int)(normalized), fmt::ptr(value));
    glad_glVertexAttribP4uiv(index, type, normalized, value);
}

void APIENTRY glMinSampleShading(GLfloat value)
{
    GL_TRACER_LOG("glMinSampleShading(" "{})", value);
    glad_glMinSampleShading(value);
}

void APIENTRY glBlendEquationi(GLuint buf, GLenum mode)
{
    GL_TRACER_LOG("glBlendEquationi(" "{}, {})", buf, E2S(mode));
    glad_glBlendEquationi(buf, mode);
}

void APIENTRY glBlendEquationSeparatei(GLuint buf, GLenum modeRGB, GLenum modeAlpha)
{
    GL_TRACER_LOG("glBlendEquationSeparatei(" "{}, {}, {})", buf, E2S(modeRGB), E2S(modeAlpha));
    glad_glBlendEquationSeparatei(buf, modeRGB, modeAlpha);
}

void APIENTRY glBlendFunci(GLuint buf, GLenum src, GLenum dst)
{
    GL_TRACER_LOG("glBlendFunci(" "{}, {}, {})", buf, E2S(src), E2S(dst));
    glad_glBlendFunci(buf, src, dst);
}

void APIENTRY glBlendFuncSeparatei(GLuint buf, GLenum srcRGB, GLenum dstRGB, GLenum srcAlpha, GLenum dstAlpha)
{
    GL_TRACER_LOG("glBlendFuncSeparatei(" "{}, {}, {}, {}, {})", buf, E2S(srcRGB), E2S(dstRGB), E2S(srcAlpha), E2S(dstAlpha));
    glad_glBlendFuncSeparatei(buf, srcRGB, dstRGB, srcAlpha, dstAlpha);
}

void APIENTRY glDrawArraysIndirect(GLenum mode, const void* indirect)
{
    GL_TRACER_LOG("glDrawArraysIndirect(" "{}, {})", E2S(mode), fmt::ptr(indirect));
    glad_glDrawArraysIndirect(mode, indirect);
}

void APIENTRY glDrawElementsIndirect(GLenum mode, GLenum type, const void* indirect)
{
    GL_TRACER_LOG("glDrawElementsIndirect(" "{}, {}, {})", E2S(mode), E2S(type), fmt::ptr(indirect));
    glad_glDrawElementsIndirect(mode, type, indirect);
}

void APIENTRY glUniform1d(GLint location, GLdouble x)
{
    GL_TRACER_LOG("glUniform1d(" "{}, {})", location, x);
    glad_glUniform1d(location, x);
}

void APIENTRY glUniform2d(GLint location, GLdouble x, GLdouble y)
{
    GL_TRACER_LOG("glUniform2d(" "{}, {}, {})", location, x, y);
    glad_glUniform2d(location, x, y);
}

void APIENTRY glUniform3d(GLint location, GLdouble x, GLdouble y, GLdouble z)
{
    GL_TRACER_LOG("glUniform3d(" "{}, {}, {}, {})", location, x, y, z);
    glad_glUniform3d(location, x, y, z);
}

void APIENTRY glUniform4d(GLint location, GLdouble x, GLdouble y, GLdouble z, GLdouble w)
{
    GL_TRACER_LOG("glUniform4d(" "{}, {}, {}, {}, {})", location, x, y, z, w);
    glad_glUniform4d(location, x, y, z, w);
}

void APIENTRY glUniform1dv(GLint location, GLsizei count, const GLdouble* value)
{
    GL_TRACER_LOG("glUniform1dv(" "{}, {}, {})", location, count, fmt::ptr(value));
    glad_glUniform1dv(location, count, value);
}

void APIENTRY glUniform2dv(GLint location, GLsizei count, const GLdouble* value)
{
    GL_TRACER_LOG("glUniform2dv(" "{}, {}, {})", location, count, fmt::ptr(value));
    glad_glUniform2dv(location, count, value);
}

void APIENTRY glUniform3dv(GLint location, GLsizei count, const GLdouble* value)
{
    GL_TRACER_LOG("glUniform3dv(" "{}, {}, {})", location, count, fmt::ptr(value));
    glad_glUniform3dv(location, count, value);
}

void APIENTRY glUniform4dv(GLint location, GLsizei count, const GLdouble* value)
{
    GL_TRACER_LOG("glUniform4dv(" "{}, {}, {})", location, count, fmt::ptr(value));
    glad_glUniform4dv(location, count, value);
}

void APIENTRY glUniformMatrix2dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    GL_TRACER_LOG("glUniformMatrix2dv(" "{}, {}, {}, {})", location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glUniformMatrix2dv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix3dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    GL_TRACER_LOG("glUniformMatrix3dv(" "{}, {}, {}, {})", location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glUniformMatrix3dv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix4dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    GL_TRACER_LOG("glUniformMatrix4dv(" "{}, {}, {}, {})", location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glUniformMatrix4dv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix2x3dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    GL_TRACER_LOG("glUniformMatrix2x3dv(" "{}, {}, {}, {})", location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glUniformMatrix2x3dv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix2x4dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    GL_TRACER_LOG("glUniformMatrix2x4dv(" "{}, {}, {}, {})", location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glUniformMatrix2x4dv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix3x2dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    GL_TRACER_LOG("glUniformMatrix3x2dv(" "{}, {}, {}, {})", location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glUniformMatrix3x2dv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix3x4dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    GL_TRACER_LOG("glUniformMatrix3x4dv(" "{}, {}, {}, {})", location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glUniformMatrix3x4dv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix4x2dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    GL_TRACER_LOG("glUniformMatrix4x2dv(" "{}, {}, {}, {})", location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glUniformMatrix4x2dv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix4x3dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    GL_TRACER_LOG("glUniformMatrix4x3dv(" "{}, {}, {}, {})", location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glUniformMatrix4x3dv(location, count, transpose, value);
}

void APIENTRY glGetUniformdv(GLuint program, GLint location, GLdouble* params)
{
    GL_TRACER_LOG("glGetUniformdv(" "{}, {}, {})", program, location, fmt::ptr(params));
    glad_glGetUniformdv(program, location, params);
}

GLint APIENTRY glGetSubroutineUniformLocation(GLuint program, GLenum shadertype, const GLchar* name)
{
    GL_TRACER_LOG("glGetSubroutineUniformLocation(" "{}, {}, {})", program, E2S(shadertype), fmt::ptr(name));
    GLint const r = glad_glGetSubroutineUniformLocation(program, shadertype, name);
    return r;
}

GLuint APIENTRY glGetSubroutineIndex(GLuint program, GLenum shadertype, const GLchar* name)
{
    GL_TRACER_LOG("glGetSubroutineIndex(" "{}, {}, {})", program, E2S(shadertype), fmt::ptr(name));
    GLuint const r = glad_glGetSubroutineIndex(program, shadertype, name);
    return r;
}

void APIENTRY glGetActiveSubroutineUniformiv(GLuint program, GLenum shadertype, GLuint index, GLenum pname, GLint* values)
{
    GL_TRACER_LOG("glGetActiveSubroutineUniformiv(" "{}, {}, {}, {}, {})", program, E2S(shadertype), index, E2S(pname), fmt::ptr(values));
    glad_glGetActiveSubroutineUniformiv(program, shadertype, index, pname, values);
}

void APIENTRY glGetActiveSubroutineUniformName(GLuint program, GLenum shadertype, GLuint index, GLsizei bufSize, GLsizei* length, GLchar* name)
{
    GL_TRACER_LOG("glGetActiveSubroutineUniformName(" "{}, {}, {}, {}, {}, {})", program, E2S(shadertype), index, bufSize, fmt::ptr(length), fmt::ptr(name));
    glad_glGetActiveSubroutineUniformName(program, shadertype, index, bufSize, length, name);
}

void APIENTRY glGetActiveSubroutineName(GLuint program, GLenum shadertype, GLuint index, GLsizei bufSize, GLsizei* length, GLchar* name)
{
    GL_TRACER_LOG("glGetActiveSubroutineName(" "{}, {}, {}, {}, {}, {})", program, E2S(shadertype), index, bufSize, fmt::ptr(length), fmt::ptr(name));
    glad_glGetActiveSubroutineName(program, shadertype, index, bufSize, length, name);
}

void APIENTRY glUniformSubroutinesuiv(GLenum shadertype, GLsizei count, const GLuint* indices)
{
    GL_TRACER_LOG("glUniformSubroutinesuiv(" "{}, {}, {})", E2S(shadertype), count, fmt::ptr(indices));
    glad_glUniformSubroutinesuiv(shadertype, count, indices);
}

void APIENTRY glGetUniformSubroutineuiv(GLenum shadertype, GLint location, GLuint* params)
{
    GL_TRACER_LOG("glGetUniformSubroutineuiv(" "{}, {}, {})", E2S(shadertype), location, fmt::ptr(params));
    glad_glGetUniformSubroutineuiv(shadertype, location, params);
}

void APIENTRY glGetProgramStageiv(GLuint program, GLenum shadertype, GLenum pname, GLint* values)
{
    GL_TRACER_LOG("glGetProgramStageiv(" "{}, {}, {}, {})", program, E2S(shadertype), E2S(pname), fmt::ptr(values));
    glad_glGetProgramStageiv(program, shadertype, pname, values);
}

void APIENTRY glPatchParameteri(GLenum pname, GLint value)
{
    GL_TRACER_LOG("glPatchParameteri(" "{}, {})", E2S(pname), value);
    glad_glPatchParameteri(pname, value);
}

void APIENTRY glPatchParameterfv(GLenum pname, const GLfloat* values)
{
    GL_TRACER_LOG("glPatchParameterfv(" "{}, {})", E2S(pname), fmt::ptr(values));
    glad_glPatchParameterfv(pname, values);
}

void APIENTRY glBindTransformFeedback(GLenum target, GLuint id)
{
    GL_TRACER_LOG("glBindTransformFeedback(" "{}, {})", E2S(target), id);
    glad_glBindTransformFeedback(target, id);
}

void APIENTRY glDeleteTransformFeedbacks(GLsizei n, const GLuint* ids)
{
    GL_TRACER_LOG("glDeleteTransformFeedbacks(" "{}, {})", n, fmt::ptr(ids));
    glad_glDeleteTransformFeedbacks(n, ids);
}

void APIENTRY glGenTransformFeedbacks(GLsizei n, GLuint* ids)
{
    GL_TRACER_LOG("glGenTransformFeedbacks(" "{}, {})", n, fmt::ptr(ids));
    glad_glGenTransformFeedbacks(n, ids);
}

GLboolean APIENTRY glIsTransformFeedback(GLuint id)
{
    GL_TRACER_LOG("glIsTransformFeedback(" "{})", id);
    GLboolean const r = glad_glIsTransformFeedback(id);
    return r;
}

void APIENTRY glPauseTransformFeedback()
{
    GL_TRACER_LOG("glPauseTransformFeedback()");
    glad_glPauseTransformFeedback();
}

void APIENTRY glResumeTransformFeedback()
{
    GL_TRACER_LOG("glResumeTransformFeedback()");
    glad_glResumeTransformFeedback();
}

void APIENTRY glDrawTransformFeedback(GLenum mode, GLuint id)
{
    GL_TRACER_LOG("glDrawTransformFeedback(" "{}, {})", E2S(mode), id);
    glad_glDrawTransformFeedback(mode, id);
}

void APIENTRY glDrawTransformFeedbackStream(GLenum mode, GLuint id, GLuint stream)
{
    GL_TRACER_LOG("glDrawTransformFeedbackStream(" "{}, {}, {})", E2S(mode), id, stream);
    glad_glDrawTransformFeedbackStream(mode, id, stream);
}

void APIENTRY glBeginQueryIndexed(GLenum target, GLuint index, GLuint id)
{
    GL_TRACER_LOG("glBeginQueryIndexed(" "{}, {}, {})", E2S(target), index, id);
    glad_glBeginQueryIndexed(target, index, id);
}

void APIENTRY glEndQueryIndexed(GLenum target, GLuint index)
{
    GL_TRACER_LOG("glEndQueryIndexed(" "{}, {})", E2S(target), index);
    glad_glEndQueryIndexed(target, index);
}

void APIENTRY glGetQueryIndexediv(GLenum target, GLuint index, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetQueryIndexediv(" "{}, {}, {}, {})", E2S(target), index, E2S(pname), fmt::ptr(params));
    glad_glGetQueryIndexediv(target, index, pname, params);
}

void APIENTRY glReleaseShaderCompiler()
{
    GL_TRACER_LOG("glReleaseShaderCompiler()");
    glad_glReleaseShaderCompiler();
}

void APIENTRY glShaderBinary(GLsizei count, const GLuint* shaders, GLenum binaryformat, const void* binary, GLsizei length)
{
    GL_TRACER_LOG("glShaderBinary(" "{}, {}, {}, {}, {})", count, fmt::ptr(shaders), E2S(binaryformat), fmt::ptr(binary), length);
    glad_glShaderBinary(count, shaders, binaryformat, binary, length);
}

void APIENTRY glGetShaderPrecisionFormat(GLenum shadertype, GLenum precisiontype, GLint* range, GLint* precision)
{
    GL_TRACER_LOG("glGetShaderPrecisionFormat(" "{}, {}, {}, {})", E2S(shadertype), E2S(precisiontype), fmt::ptr(range), fmt::ptr(precision));
    glad_glGetShaderPrecisionFormat(shadertype, precisiontype, range, precision);
}

void APIENTRY glDepthRangef(GLfloat n, GLfloat f)
{
    GL_TRACER_LOG("glDepthRangef(" "{}, {})", n, f);
    glad_glDepthRangef(n, f);
}

void APIENTRY glClearDepthf(GLfloat d)
{
    GL_TRACER_LOG("glClearDepthf(" "{})", d);
    glad_glClearDepthf(d);
}

void APIENTRY glGetProgramBinary(GLuint program, GLsizei bufSize, GLsizei* length, GLenum* binaryFormat, void* binary)
{
    GL_TRACER_LOG("glGetProgramBinary(" "{}, {}, {}, {}, {})", program, bufSize, fmt::ptr(length), fmt::ptr(binaryFormat), fmt::ptr(binary));
    glad_glGetProgramBinary(program, bufSize, length, binaryFormat, binary);
}

void APIENTRY glProgramBinary(GLuint program, GLenum binaryFormat, const void* binary, GLsizei length)
{
    GL_TRACER_LOG("glProgramBinary(" "{}, {}, {}, {})", program, E2S(binaryFormat), fmt::ptr(binary), length);
    glad_glProgramBinary(program, binaryFormat, binary, length);
}

void APIENTRY glProgramParameteri(GLuint program, GLenum pname, GLint value)
{
    GL_TRACER_LOG("glProgramParameteri(" "{}, {}, {})", program, E2S(pname), value);
    glad_glProgramParameteri(program, pname, value);
}

void APIENTRY glUseProgramStages(GLuint pipeline, GLbitfield stages, GLuint program)
{
    GL_TRACER_LOG("glUseProgramStages(" "{}, {}, {})", pipeline, (unsigned int)(stages), program);
    glad_glUseProgramStages(pipeline, stages, program);
}

void APIENTRY glActiveShaderProgram(GLuint pipeline, GLuint program)
{
    GL_TRACER_LOG("glActiveShaderProgram(" "{}, {})", pipeline, program);
    glad_glActiveShaderProgram(pipeline, program);
}

GLuint APIENTRY glCreateShaderProgramv(GLenum type, GLsizei count, const GLchar* const* strings)
{
    GL_TRACER_LOG("glCreateShaderProgramv(" "{}, {}, {})", E2S(type), count, fmt::ptr(strings));
    GLuint const r = glad_glCreateShaderProgramv(type, count, strings);
    return r;
}

void APIENTRY glBindProgramPipeline(GLuint pipeline)
{
    GL_TRACER_LOG("glBindProgramPipeline(" "{})", pipeline);
    glad_glBindProgramPipeline(pipeline);
}

void APIENTRY glDeleteProgramPipelines(GLsizei n, const GLuint* pipelines)
{
    GL_TRACER_LOG("glDeleteProgramPipelines(" "{}, {})", n, fmt::ptr(pipelines));
    glad_glDeleteProgramPipelines(n, pipelines);
}

void APIENTRY glGenProgramPipelines(GLsizei n, GLuint* pipelines)
{
    GL_TRACER_LOG("glGenProgramPipelines(" "{}, {})", n, fmt::ptr(pipelines));
    glad_glGenProgramPipelines(n, pipelines);
}

GLboolean APIENTRY glIsProgramPipeline(GLuint pipeline)
{
    GL_TRACER_LOG("glIsProgramPipeline(" "{})", pipeline);
    GLboolean const r = glad_glIsProgramPipeline(pipeline);
    return r;
}

void APIENTRY glGetProgramPipelineiv(GLuint pipeline, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetProgramPipelineiv(" "{}, {}, {})", pipeline, E2S(pname), fmt::ptr(params));
    glad_glGetProgramPipelineiv(pipeline, pname, params);
}

void APIENTRY glProgramUniform1i(GLuint program, GLint location, GLint v0)
{
    GL_TRACER_LOG("glProgramUniform1i(" "{}, {}, {})", program, location, v0);
    glad_glProgramUniform1i(program, location, v0);
}

void APIENTRY glProgramUniform1iv(GLuint program, GLint location, GLsizei count, const GLint* value)
{
    GL_TRACER_LOG("glProgramUniform1iv(" "{}, {}, {}, {})", program, location, count, fmt::ptr(value));
    glad_glProgramUniform1iv(program, location, count, value);
}

void APIENTRY glProgramUniform1f(GLuint program, GLint location, GLfloat v0)
{
    GL_TRACER_LOG("glProgramUniform1f(" "{}, {}, {})", program, location, v0);
    glad_glProgramUniform1f(program, location, v0);
}

void APIENTRY glProgramUniform1fv(GLuint program, GLint location, GLsizei count, const GLfloat* value)
{
    GL_TRACER_LOG("glProgramUniform1fv(" "{}, {}, {}, {})", program, location, count, fmt::ptr(value));
    glad_glProgramUniform1fv(program, location, count, value);
}

void APIENTRY glProgramUniform1d(GLuint program, GLint location, GLdouble v0)
{
    GL_TRACER_LOG("glProgramUniform1d(" "{}, {}, {})", program, location, v0);
    glad_glProgramUniform1d(program, location, v0);
}

void APIENTRY glProgramUniform1dv(GLuint program, GLint location, GLsizei count, const GLdouble* value)
{
    GL_TRACER_LOG("glProgramUniform1dv(" "{}, {}, {}, {})", program, location, count, fmt::ptr(value));
    glad_glProgramUniform1dv(program, location, count, value);
}

void APIENTRY glProgramUniform1ui(GLuint program, GLint location, GLuint v0)
{
    GL_TRACER_LOG("glProgramUniform1ui(" "{}, {}, {})", program, location, v0);
    glad_glProgramUniform1ui(program, location, v0);
}

void APIENTRY glProgramUniform1uiv(GLuint program, GLint location, GLsizei count, const GLuint* value)
{
    GL_TRACER_LOG("glProgramUniform1uiv(" "{}, {}, {}, {})", program, location, count, fmt::ptr(value));
    glad_glProgramUniform1uiv(program, location, count, value);
}

void APIENTRY glProgramUniform2i(GLuint program, GLint location, GLint v0, GLint v1)
{
    GL_TRACER_LOG("glProgramUniform2i(" "{}, {}, {}, {})", program, location, v0, v1);
    glad_glProgramUniform2i(program, location, v0, v1);
}

void APIENTRY glProgramUniform2iv(GLuint program, GLint location, GLsizei count, const GLint* value)
{
    GL_TRACER_LOG("glProgramUniform2iv(" "{}, {}, {}, {})", program, location, count, fmt::ptr(value));
    glad_glProgramUniform2iv(program, location, count, value);
}

void APIENTRY glProgramUniform2f(GLuint program, GLint location, GLfloat v0, GLfloat v1)
{
    GL_TRACER_LOG("glProgramUniform2f(" "{}, {}, {}, {})", program, location, v0, v1);
    glad_glProgramUniform2f(program, location, v0, v1);
}

void APIENTRY glProgramUniform2fv(GLuint program, GLint location, GLsizei count, const GLfloat* value)
{
    GL_TRACER_LOG("glProgramUniform2fv(" "{}, {}, {}, {})", program, location, count, fmt::ptr(value));
    glad_glProgramUniform2fv(program, location, count, value);
}

void APIENTRY glProgramUniform2d(GLuint program, GLint location, GLdouble v0, GLdouble v1)
{
    GL_TRACER_LOG("glProgramUniform2d(" "{}, {}, {}, {})", program, location, v0, v1);
    glad_glProgramUniform2d(program, location, v0, v1);
}

void APIENTRY glProgramUniform2dv(GLuint program, GLint location, GLsizei count, const GLdouble* value)
{
    GL_TRACER_LOG("glProgramUniform2dv(" "{}, {}, {}, {})", program, location, count, fmt::ptr(value));
    glad_glProgramUniform2dv(program, location, count, value);
}

void APIENTRY glProgramUniform2ui(GLuint program, GLint location, GLuint v0, GLuint v1)
{
    GL_TRACER_LOG("glProgramUniform2ui(" "{}, {}, {}, {})", program, location, v0, v1);
    glad_glProgramUniform2ui(program, location, v0, v1);
}

void APIENTRY glProgramUniform2uiv(GLuint program, GLint location, GLsizei count, const GLuint* value)
{
    GL_TRACER_LOG("glProgramUniform2uiv(" "{}, {}, {}, {})", program, location, count, fmt::ptr(value));
    glad_glProgramUniform2uiv(program, location, count, value);
}

void APIENTRY glProgramUniform3i(GLuint program, GLint location, GLint v0, GLint v1, GLint v2)
{
    GL_TRACER_LOG("glProgramUniform3i(" "{}, {}, {}, {}, {})", program, location, v0, v1, v2);
    glad_glProgramUniform3i(program, location, v0, v1, v2);
}

void APIENTRY glProgramUniform3iv(GLuint program, GLint location, GLsizei count, const GLint* value)
{
    GL_TRACER_LOG("glProgramUniform3iv(" "{}, {}, {}, {})", program, location, count, fmt::ptr(value));
    glad_glProgramUniform3iv(program, location, count, value);
}

void APIENTRY glProgramUniform3f(GLuint program, GLint location, GLfloat v0, GLfloat v1, GLfloat v2)
{
    GL_TRACER_LOG("glProgramUniform3f(" "{}, {}, {}, {}, {})", program, location, v0, v1, v2);
    glad_glProgramUniform3f(program, location, v0, v1, v2);
}

void APIENTRY glProgramUniform3fv(GLuint program, GLint location, GLsizei count, const GLfloat* value)
{
    GL_TRACER_LOG("glProgramUniform3fv(" "{}, {}, {}, {})", program, location, count, fmt::ptr(value));
    glad_glProgramUniform3fv(program, location, count, value);
}

void APIENTRY glProgramUniform3d(GLuint program, GLint location, GLdouble v0, GLdouble v1, GLdouble v2)
{
    GL_TRACER_LOG("glProgramUniform3d(" "{}, {}, {}, {}, {})", program, location, v0, v1, v2);
    glad_glProgramUniform3d(program, location, v0, v1, v2);
}

void APIENTRY glProgramUniform3dv(GLuint program, GLint location, GLsizei count, const GLdouble* value)
{
    GL_TRACER_LOG("glProgramUniform3dv(" "{}, {}, {}, {})", program, location, count, fmt::ptr(value));
    glad_glProgramUniform3dv(program, location, count, value);
}

void APIENTRY glProgramUniform3ui(GLuint program, GLint location, GLuint v0, GLuint v1, GLuint v2)
{
    GL_TRACER_LOG("glProgramUniform3ui(" "{}, {}, {}, {}, {})", program, location, v0, v1, v2);
    glad_glProgramUniform3ui(program, location, v0, v1, v2);
}

void APIENTRY glProgramUniform3uiv(GLuint program, GLint location, GLsizei count, const GLuint* value)
{
    GL_TRACER_LOG("glProgramUniform3uiv(" "{}, {}, {}, {})", program, location, count, fmt::ptr(value));
    glad_glProgramUniform3uiv(program, location, count, value);
}

void APIENTRY glProgramUniform4i(GLuint program, GLint location, GLint v0, GLint v1, GLint v2, GLint v3)
{
    GL_TRACER_LOG("glProgramUniform4i(" "{}, {}, {}, {}, {}, {})", program, location, v0, v1, v2, v3);
    glad_glProgramUniform4i(program, location, v0, v1, v2, v3);
}

void APIENTRY glProgramUniform4iv(GLuint program, GLint location, GLsizei count, const GLint* value)
{
    GL_TRACER_LOG("glProgramUniform4iv(" "{}, {}, {}, {})", program, location, count, fmt::ptr(value));
    glad_glProgramUniform4iv(program, location, count, value);
}

void APIENTRY glProgramUniform4f(GLuint program, GLint location, GLfloat v0, GLfloat v1, GLfloat v2, GLfloat v3)
{
    GL_TRACER_LOG("glProgramUniform4f(" "{}, {}, {}, {}, {}, {})", program, location, v0, v1, v2, v3);
    glad_glProgramUniform4f(program, location, v0, v1, v2, v3);
}

void APIENTRY glProgramUniform4fv(GLuint program, GLint location, GLsizei count, const GLfloat* value)
{
    GL_TRACER_LOG("glProgramUniform4fv(" "{}, {}, {}, {})", program, location, count, fmt::ptr(value));
    glad_glProgramUniform4fv(program, location, count, value);
}

void APIENTRY glProgramUniform4d(GLuint program, GLint location, GLdouble v0, GLdouble v1, GLdouble v2, GLdouble v3)
{
    GL_TRACER_LOG("glProgramUniform4d(" "{}, {}, {}, {}, {}, {})", program, location, v0, v1, v2, v3);
    glad_glProgramUniform4d(program, location, v0, v1, v2, v3);
}

void APIENTRY glProgramUniform4dv(GLuint program, GLint location, GLsizei count, const GLdouble* value)
{
    GL_TRACER_LOG("glProgramUniform4dv(" "{}, {}, {}, {})", program, location, count, fmt::ptr(value));
    glad_glProgramUniform4dv(program, location, count, value);
}

void APIENTRY glProgramUniform4ui(GLuint program, GLint location, GLuint v0, GLuint v1, GLuint v2, GLuint v3)
{
    GL_TRACER_LOG("glProgramUniform4ui(" "{}, {}, {}, {}, {}, {})", program, location, v0, v1, v2, v3);
    glad_glProgramUniform4ui(program, location, v0, v1, v2, v3);
}

void APIENTRY glProgramUniform4uiv(GLuint program, GLint location, GLsizei count, const GLuint* value)
{
    GL_TRACER_LOG("glProgramUniform4uiv(" "{}, {}, {}, {})", program, location, count, fmt::ptr(value));
    glad_glProgramUniform4uiv(program, location, count, value);
}

void APIENTRY glProgramUniformMatrix2fv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    GL_TRACER_LOG("glProgramUniformMatrix2fv(" "{}, {}, {}, {}, {})", program, location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glProgramUniformMatrix2fv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix3fv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    GL_TRACER_LOG("glProgramUniformMatrix3fv(" "{}, {}, {}, {}, {})", program, location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glProgramUniformMatrix3fv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix4fv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    GL_TRACER_LOG("glProgramUniformMatrix4fv(" "{}, {}, {}, {}, {})", program, location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glProgramUniformMatrix4fv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix2dv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    GL_TRACER_LOG("glProgramUniformMatrix2dv(" "{}, {}, {}, {}, {})", program, location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glProgramUniformMatrix2dv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix3dv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    GL_TRACER_LOG("glProgramUniformMatrix3dv(" "{}, {}, {}, {}, {})", program, location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glProgramUniformMatrix3dv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix4dv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    GL_TRACER_LOG("glProgramUniformMatrix4dv(" "{}, {}, {}, {}, {})", program, location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glProgramUniformMatrix4dv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix2x3fv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    GL_TRACER_LOG("glProgramUniformMatrix2x3fv(" "{}, {}, {}, {}, {})", program, location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glProgramUniformMatrix2x3fv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix3x2fv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    GL_TRACER_LOG("glProgramUniformMatrix3x2fv(" "{}, {}, {}, {}, {})", program, location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glProgramUniformMatrix3x2fv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix2x4fv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    GL_TRACER_LOG("glProgramUniformMatrix2x4fv(" "{}, {}, {}, {}, {})", program, location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glProgramUniformMatrix2x4fv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix4x2fv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    GL_TRACER_LOG("glProgramUniformMatrix4x2fv(" "{}, {}, {}, {}, {})", program, location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glProgramUniformMatrix4x2fv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix3x4fv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    GL_TRACER_LOG("glProgramUniformMatrix3x4fv(" "{}, {}, {}, {}, {})", program, location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glProgramUniformMatrix3x4fv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix4x3fv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    GL_TRACER_LOG("glProgramUniformMatrix4x3fv(" "{}, {}, {}, {}, {})", program, location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glProgramUniformMatrix4x3fv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix2x3dv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    GL_TRACER_LOG("glProgramUniformMatrix2x3dv(" "{}, {}, {}, {}, {})", program, location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glProgramUniformMatrix2x3dv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix3x2dv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    GL_TRACER_LOG("glProgramUniformMatrix3x2dv(" "{}, {}, {}, {}, {})", program, location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glProgramUniformMatrix3x2dv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix2x4dv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    GL_TRACER_LOG("glProgramUniformMatrix2x4dv(" "{}, {}, {}, {}, {})", program, location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glProgramUniformMatrix2x4dv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix4x2dv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    GL_TRACER_LOG("glProgramUniformMatrix4x2dv(" "{}, {}, {}, {}, {})", program, location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glProgramUniformMatrix4x2dv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix3x4dv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    GL_TRACER_LOG("glProgramUniformMatrix3x4dv(" "{}, {}, {}, {}, {})", program, location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glProgramUniformMatrix3x4dv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix4x3dv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    GL_TRACER_LOG("glProgramUniformMatrix4x3dv(" "{}, {}, {}, {}, {})", program, location, count, (unsigned int)(transpose), fmt::ptr(value));
    glad_glProgramUniformMatrix4x3dv(program, location, count, transpose, value);
}

void APIENTRY glValidateProgramPipeline(GLuint pipeline)
{
    GL_TRACER_LOG("glValidateProgramPipeline(" "{})", pipeline);
    glad_glValidateProgramPipeline(pipeline);
}

void APIENTRY glGetProgramPipelineInfoLog(GLuint pipeline, GLsizei bufSize, GLsizei* length, GLchar* infoLog)
{
    GL_TRACER_LOG("glGetProgramPipelineInfoLog(" "{}, {}, {}, {})", pipeline, bufSize, fmt::ptr(length), fmt::ptr(infoLog));
    glad_glGetProgramPipelineInfoLog(pipeline, bufSize, length, infoLog);
}

void APIENTRY glVertexAttribL1d(GLuint index, GLdouble x)
{
    GL_TRACER_LOG("glVertexAttribL1d(" "{}, {})", index, x);
    glad_glVertexAttribL1d(index, x);
}

void APIENTRY glVertexAttribL2d(GLuint index, GLdouble x, GLdouble y)
{
    GL_TRACER_LOG("glVertexAttribL2d(" "{}, {}, {})", index, x, y);
    glad_glVertexAttribL2d(index, x, y);
}

void APIENTRY glVertexAttribL3d(GLuint index, GLdouble x, GLdouble y, GLdouble z)
{
    GL_TRACER_LOG("glVertexAttribL3d(" "{}, {}, {}, {})", index, x, y, z);
    glad_glVertexAttribL3d(index, x, y, z);
}

void APIENTRY glVertexAttribL4d(GLuint index, GLdouble x, GLdouble y, GLdouble z, GLdouble w)
{
    GL_TRACER_LOG("glVertexAttribL4d(" "{}, {}, {}, {}, {})", index, x, y, z, w);
    glad_glVertexAttribL4d(index, x, y, z, w);
}

void APIENTRY glVertexAttribL1dv(GLuint index, const GLdouble* v)
{
    GL_TRACER_LOG("glVertexAttribL1dv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttribL1dv(index, v);
}

void APIENTRY glVertexAttribL2dv(GLuint index, const GLdouble* v)
{
    GL_TRACER_LOG("glVertexAttribL2dv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttribL2dv(index, v);
}

void APIENTRY glVertexAttribL3dv(GLuint index, const GLdouble* v)
{
    GL_TRACER_LOG("glVertexAttribL3dv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttribL3dv(index, v);
}

void APIENTRY glVertexAttribL4dv(GLuint index, const GLdouble* v)
{
    GL_TRACER_LOG("glVertexAttribL4dv(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttribL4dv(index, v);
}

void APIENTRY glVertexAttribLPointer(GLuint index, GLint size, GLenum type, GLsizei stride, const void* pointer)
{
    GL_TRACER_LOG("glVertexAttribLPointer(" "{}, {}, {}, {}, {})", index, size, E2S(type), stride, fmt::ptr(pointer));
    glad_glVertexAttribLPointer(index, size, type, stride, pointer);
}

void APIENTRY glGetVertexAttribLdv(GLuint index, GLenum pname, GLdouble* params)
{
    GL_TRACER_LOG("glGetVertexAttribLdv(" "{}, {}, {})", index, E2S(pname), fmt::ptr(params));
    glad_glGetVertexAttribLdv(index, pname, params);
}

void APIENTRY glViewportArrayv(GLuint first, GLsizei count, const GLfloat* v)
{
    GL_TRACER_LOG("glViewportArrayv(" "{}, {}, {})", first, count, fmt::ptr(v));
    glad_glViewportArrayv(first, count, v);
}

void APIENTRY glViewportIndexedf(GLuint index, GLfloat x, GLfloat y, GLfloat w, GLfloat h)
{
    GL_TRACER_LOG("glViewportIndexedf(" "{}, {}, {}, {}, {})", index, x, y, w, h);
    glad_glViewportIndexedf(index, x, y, w, h);
}

void APIENTRY glViewportIndexedfv(GLuint index, const GLfloat* v)
{
    GL_TRACER_LOG("glViewportIndexedfv(" "{}, {})", index, fmt::ptr(v));
    glad_glViewportIndexedfv(index, v);
}

void APIENTRY glScissorArrayv(GLuint first, GLsizei count, const GLint* v)
{
    GL_TRACER_LOG("glScissorArrayv(" "{}, {}, {})", first, count, fmt::ptr(v));
    glad_glScissorArrayv(first, count, v);
}

void APIENTRY glScissorIndexed(GLuint index, GLint left, GLint bottom, GLsizei width, GLsizei height)
{
    GL_TRACER_LOG("glScissorIndexed(" "{}, {}, {}, {}, {})", index, left, bottom, width, height);
    glad_glScissorIndexed(index, left, bottom, width, height);
}

void APIENTRY glScissorIndexedv(GLuint index, const GLint* v)
{
    GL_TRACER_LOG("glScissorIndexedv(" "{}, {})", index, fmt::ptr(v));
    glad_glScissorIndexedv(index, v);
}

void APIENTRY glDepthRangeArrayv(GLuint first, GLsizei count, const GLdouble* v)
{
    GL_TRACER_LOG("glDepthRangeArrayv(" "{}, {}, {})", first, count, fmt::ptr(v));
    glad_glDepthRangeArrayv(first, count, v);
}

void APIENTRY glDepthRangeIndexed(GLuint index, GLdouble n, GLdouble f)
{
    GL_TRACER_LOG("glDepthRangeIndexed(" "{}, {}, {})", index, n, f);
    glad_glDepthRangeIndexed(index, n, f);
}

void APIENTRY glGetFloati_v(GLenum target, GLuint index, GLfloat* data)
{
    GL_TRACER_LOG("glGetFloati_v(" "{}, {}, {})", E2S(target), index, fmt::ptr(data));
    glad_glGetFloati_v(target, index, data);
}

void APIENTRY glGetDoublei_v(GLenum target, GLuint index, GLdouble* data)
{
    GL_TRACER_LOG("glGetDoublei_v(" "{}, {}, {})", E2S(target), index, fmt::ptr(data));
    glad_glGetDoublei_v(target, index, data);
}

void APIENTRY glDrawArraysInstancedBaseInstance(GLenum mode, GLint first, GLsizei count, GLsizei instancecount, GLuint baseinstance)
{
    GL_TRACER_LOG("glDrawArraysInstancedBaseInstance(" "{}, {}, {}, {}, {})", E2S(mode), first, count, instancecount, baseinstance);
    glad_glDrawArraysInstancedBaseInstance(mode, first, count, instancecount, baseinstance);
}

void APIENTRY glDrawElementsInstancedBaseInstance(GLenum mode, GLsizei count, GLenum type, const void* indices, GLsizei instancecount, GLuint baseinstance)
{
    GL_TRACER_LOG("glDrawElementsInstancedBaseInstance(" "{}, {}, {}, {}, {}, {})", E2S(mode), count, E2S(type), fmt::ptr(indices), instancecount, baseinstance);
    glad_glDrawElementsInstancedBaseInstance(mode, count, type, indices, instancecount, baseinstance);
}

void APIENTRY glDrawElementsInstancedBaseVertexBaseInstance(GLenum mode, GLsizei count, GLenum type, const void* indices, GLsizei instancecount, GLint basevertex, GLuint baseinstance)
{
    GL_TRACER_LOG("glDrawElementsInstancedBaseVertexBaseInstance(" "{}, {}, {}, {}, {}, {}, {})", E2S(mode), count, E2S(type), fmt::ptr(indices), instancecount, basevertex, baseinstance);
    glad_glDrawElementsInstancedBaseVertexBaseInstance(mode, count, type, indices, instancecount, basevertex, baseinstance);
}

void APIENTRY glGetInternalformativ(GLenum target, GLenum internalformat, GLenum pname, GLsizei count, GLint* params)
{
    GL_TRACER_LOG("glGetInternalformativ(" "{}, {}, {}, {}, {})", E2S(target), E2S(internalformat), E2S(pname), count, fmt::ptr(params));
    glad_glGetInternalformativ(target, internalformat, pname, count, params);
}

void APIENTRY glGetActiveAtomicCounterBufferiv(GLuint program, GLuint bufferIndex, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetActiveAtomicCounterBufferiv(" "{}, {}, {}, {})", program, bufferIndex, E2S(pname), fmt::ptr(params));
    glad_glGetActiveAtomicCounterBufferiv(program, bufferIndex, pname, params);
}

void APIENTRY glBindImageTexture(GLuint unit, GLuint texture, GLint level, GLboolean layered, GLint layer, GLenum access, GLenum format)
{
    GL_TRACER_LOG("glBindImageTexture(" "{}, {}, {}, {}, {}, {}, {})", unit, texture, level, (unsigned int)(layered), layer, E2S(access), E2S(format));
    glad_glBindImageTexture(unit, texture, level, layered, layer, access, format);
}

void APIENTRY glMemoryBarrier(GLbitfield barriers)
{
    GL_TRACER_LOG("glMemoryBarrier(" "{})", (unsigned int)(barriers));
    glad_glMemoryBarrier(barriers);
}

void APIENTRY glTexStorage1D(GLenum target, GLsizei levels, GLenum internalformat, GLsizei width)
{
    GL_TRACER_LOG("glTexStorage1D(" "{}, {}, {}, {})", E2S(target), levels, E2S(internalformat), width);
    glad_glTexStorage1D(target, levels, internalformat, width);
}

void APIENTRY glTexStorage2D(GLenum target, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height)
{
    GL_TRACER_LOG("glTexStorage2D(" "{}, {}, {}, {}, {})", E2S(target), levels, E2S(internalformat), width, height);
    glad_glTexStorage2D(target, levels, internalformat, width, height);
}

void APIENTRY glTexStorage3D(GLenum target, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth)
{
    GL_TRACER_LOG("glTexStorage3D(" "{}, {}, {}, {}, {}, {})", E2S(target), levels, E2S(internalformat), width, height, depth);
    glad_glTexStorage3D(target, levels, internalformat, width, height, depth);
}

void APIENTRY glDrawTransformFeedbackInstanced(GLenum mode, GLuint id, GLsizei instancecount)
{
    GL_TRACER_LOG("glDrawTransformFeedbackInstanced(" "{}, {}, {})", E2S(mode), id, instancecount);
    glad_glDrawTransformFeedbackInstanced(mode, id, instancecount);
}

void APIENTRY glDrawTransformFeedbackStreamInstanced(GLenum mode, GLuint id, GLuint stream, GLsizei instancecount)
{
    GL_TRACER_LOG("glDrawTransformFeedbackStreamInstanced(" "{}, {}, {}, {})", E2S(mode), id, stream, instancecount);
    glad_glDrawTransformFeedbackStreamInstanced(mode, id, stream, instancecount);
}

void APIENTRY glClearBufferData(GLenum target, GLenum internalformat, GLenum format, GLenum type, const void* data)
{
    GL_TRACER_LOG("glClearBufferData(" "{}, {}, {}, {}, {})", E2S(target), E2S(internalformat), E2S(format), E2S(type), fmt::ptr(data));
    glad_glClearBufferData(target, internalformat, format, type, data);
}

void APIENTRY glClearBufferSubData(GLenum target, GLenum internalformat, GLintptr offset, GLsizeiptr size, GLenum format, GLenum type, const void* data)
{
    GL_TRACER_LOG("glClearBufferSubData(" "{}, {}, {}, {}, {}, {}, {})", E2S(target), E2S(internalformat), offset, size, E2S(format), E2S(type), fmt::ptr(data));
    glad_glClearBufferSubData(target, internalformat, offset, size, format, type, data);
}

void APIENTRY glDispatchCompute(GLuint num_groups_x, GLuint num_groups_y, GLuint num_groups_z)
{
    GL_TRACER_LOG("glDispatchCompute(" "{}, {}, {})", num_groups_x, num_groups_y, num_groups_z);
    glad_glDispatchCompute(num_groups_x, num_groups_y, num_groups_z);
}

void APIENTRY glDispatchComputeIndirect(GLintptr indirect)
{
    GL_TRACER_LOG("glDispatchComputeIndirect(" "{})", indirect);
    glad_glDispatchComputeIndirect(indirect);
}

void APIENTRY glCopyImageSubData(GLuint srcName, GLenum srcTarget, GLint srcLevel, GLint srcX, GLint srcY, GLint srcZ, GLuint dstName, GLenum dstTarget, GLint dstLevel, GLint dstX, GLint dstY, GLint dstZ, GLsizei srcWidth, GLsizei srcHeight, GLsizei srcDepth)
{
    GL_TRACER_LOG("glCopyImageSubData(" "{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {})", srcName, E2S(srcTarget), srcLevel, srcX, srcY, srcZ, dstName, E2S(dstTarget), dstLevel, dstX, dstY, dstZ, srcWidth, srcHeight, srcDepth);
    glad_glCopyImageSubData(srcName, srcTarget, srcLevel, srcX, srcY, srcZ, dstName, dstTarget, dstLevel, dstX, dstY, dstZ, srcWidth, srcHeight, srcDepth);
}

void APIENTRY glFramebufferParameteri(GLenum target, GLenum pname, GLint param)
{
    GL_TRACER_LOG("glFramebufferParameteri(" "{}, {}, {})", E2S(target), E2S(pname), param);
    glad_glFramebufferParameteri(target, pname, param);
}

void APIENTRY glGetFramebufferParameteriv(GLenum target, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetFramebufferParameteriv(" "{}, {}, {})", E2S(target), E2S(pname), fmt::ptr(params));
    glad_glGetFramebufferParameteriv(target, pname, params);
}

void APIENTRY glGetInternalformati64v(GLenum target, GLenum internalformat, GLenum pname, GLsizei count, GLint64* params)
{
    GL_TRACER_LOG("glGetInternalformati64v(" "{}, {}, {}, {}, {})", E2S(target), E2S(internalformat), E2S(pname), count, fmt::ptr(params));
    glad_glGetInternalformati64v(target, internalformat, pname, count, params);
}

void APIENTRY glInvalidateTexSubImage(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth)
{
    GL_TRACER_LOG("glInvalidateTexSubImage(" "{}, {}, {}, {}, {}, {}, {}, {})", texture, level, xoffset, yoffset, zoffset, width, height, depth);
    glad_glInvalidateTexSubImage(texture, level, xoffset, yoffset, zoffset, width, height, depth);
}

void APIENTRY glInvalidateTexImage(GLuint texture, GLint level)
{
    GL_TRACER_LOG("glInvalidateTexImage(" "{}, {})", texture, level);
    glad_glInvalidateTexImage(texture, level);
}

void APIENTRY glInvalidateBufferSubData(GLuint buffer, GLintptr offset, GLsizeiptr length)
{
    GL_TRACER_LOG("glInvalidateBufferSubData(" "{}, {}, {})", buffer, offset, length);
    glad_glInvalidateBufferSubData(buffer, offset, length);
}

void APIENTRY glInvalidateBufferData(GLuint buffer)
{
    GL_TRACER_LOG("glInvalidateBufferData(" "{})", buffer);
    glad_glInvalidateBufferData(buffer);
}

void APIENTRY glInvalidateFramebuffer(GLenum target, GLsizei numAttachments, const GLenum* attachments)
{
    GL_TRACER_LOG("glInvalidateFramebuffer(" "{}, {}, {})", E2S(target), numAttachments, fmt::ptr(attachments));
    glad_glInvalidateFramebuffer(target, numAttachments, attachments);
}

void APIENTRY glInvalidateSubFramebuffer(GLenum target, GLsizei numAttachments, const GLenum* attachments, GLint x, GLint y, GLsizei width, GLsizei height)
{
    GL_TRACER_LOG("glInvalidateSubFramebuffer(" "{}, {}, {}, {}, {}, {}, {})", E2S(target), numAttachments, fmt::ptr(attachments), x, y, width, height);
    glad_glInvalidateSubFramebuffer(target, numAttachments, attachments, x, y, width, height);
}

void APIENTRY glMultiDrawArraysIndirect(GLenum mode, const void* indirect, GLsizei drawcount, GLsizei stride)
{
    GL_TRACER_LOG("glMultiDrawArraysIndirect(" "{}, {}, {}, {})", E2S(mode), fmt::ptr(indirect), drawcount, stride);
    glad_glMultiDrawArraysIndirect(mode, indirect, drawcount, stride);
}

void APIENTRY glMultiDrawElementsIndirect(GLenum mode, GLenum type, const void* indirect, GLsizei drawcount, GLsizei stride)
{
    GL_TRACER_LOG("glMultiDrawElementsIndirect(" "{}, {}, {}, {}, {})", E2S(mode), E2S(type), fmt::ptr(indirect), drawcount, stride);
    glad_glMultiDrawElementsIndirect(mode, type, indirect, drawcount, stride);
}

void APIENTRY glGetProgramInterfaceiv(GLuint program, GLenum programInterface, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetProgramInterfaceiv(" "{}, {}, {}, {})", program, E2S(programInterface), E2S(pname), fmt::ptr(params));
    glad_glGetProgramInterfaceiv(program, programInterface, pname, params);
}

GLuint APIENTRY glGetProgramResourceIndex(GLuint program, GLenum programInterface, const GLchar* name)
{
    GL_TRACER_LOG("glGetProgramResourceIndex(" "{}, {}, {})", program, E2S(programInterface), fmt::ptr(name));
    GLuint const r = glad_glGetProgramResourceIndex(program, programInterface, name);
    return r;
}

void APIENTRY glGetProgramResourceName(GLuint program, GLenum programInterface, GLuint index, GLsizei bufSize, GLsizei* length, GLchar* name)
{
    GL_TRACER_LOG("glGetProgramResourceName(" "{}, {}, {}, {}, {}, {})", program, E2S(programInterface), index, bufSize, fmt::ptr(length), fmt::ptr(name));
    glad_glGetProgramResourceName(program, programInterface, index, bufSize, length, name);
}

void APIENTRY glGetProgramResourceiv(GLuint program, GLenum programInterface, GLuint index, GLsizei propCount, const GLenum* props, GLsizei count, GLsizei* length, GLint* params)
{
    GL_TRACER_LOG("glGetProgramResourceiv(" "{}, {}, {}, {}, {}, {}, {}, {})", program, E2S(programInterface), index, propCount, fmt::ptr(props), count, fmt::ptr(length), fmt::ptr(params));
    glad_glGetProgramResourceiv(program, programInterface, index, propCount, props, count, length, params);
}

GLint APIENTRY glGetProgramResourceLocation(GLuint program, GLenum programInterface, const GLchar* name)
{
    GL_TRACER_LOG("glGetProgramResourceLocation(" "{}, {}, {})", program, E2S(programInterface), fmt::ptr(name));
    GLint const r = glad_glGetProgramResourceLocation(program, programInterface, name);
    return r;
}

GLint APIENTRY glGetProgramResourceLocationIndex(GLuint program, GLenum programInterface, const GLchar* name)
{
    GL_TRACER_LOG("glGetProgramResourceLocationIndex(" "{}, {}, {})", program, E2S(programInterface), fmt::ptr(name));
    GLint const r = glad_glGetProgramResourceLocationIndex(program, programInterface, name);
    return r;
}

void APIENTRY glShaderStorageBlockBinding(GLuint program, GLuint storageBlockIndex, GLuint storageBlockBinding)
{
    GL_TRACER_LOG("glShaderStorageBlockBinding(" "{}, {}, {})", program, storageBlockIndex, storageBlockBinding);
    glad_glShaderStorageBlockBinding(program, storageBlockIndex, storageBlockBinding);
}

void APIENTRY glTexBufferRange(GLenum target, GLenum internalformat, GLuint buffer, GLintptr offset, GLsizeiptr size)
{
    GL_TRACER_LOG("glTexBufferRange(" "{}, {}, {}, {}, {})", E2S(target), E2S(internalformat), buffer, offset, size);
    glad_glTexBufferRange(target, internalformat, buffer, offset, size);
}

void APIENTRY glTexStorage2DMultisample(GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLboolean fixedsamplelocations)
{
    GL_TRACER_LOG("glTexStorage2DMultisample(" "{}, {}, {}, {}, {}, {})", E2S(target), samples, E2S(internalformat), width, height, (unsigned int)(fixedsamplelocations));
    glad_glTexStorage2DMultisample(target, samples, internalformat, width, height, fixedsamplelocations);
}

void APIENTRY glTexStorage3DMultisample(GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLboolean fixedsamplelocations)
{
    GL_TRACER_LOG("glTexStorage3DMultisample(" "{}, {}, {}, {}, {}, {}, {})", E2S(target), samples, E2S(internalformat), width, height, depth, (unsigned int)(fixedsamplelocations));
    glad_glTexStorage3DMultisample(target, samples, internalformat, width, height, depth, fixedsamplelocations);
}

void APIENTRY glTextureView(GLuint texture, GLenum target, GLuint origtexture, GLenum internalformat, GLuint minlevel, GLuint numlevels, GLuint minlayer, GLuint numlayers)
{
    GL_TRACER_LOG("glTextureView(" "{}, {}, {}, {}, {}, {}, {}, {})", texture, E2S(target), origtexture, E2S(internalformat), minlevel, numlevels, minlayer, numlayers);
    glad_glTextureView(texture, target, origtexture, internalformat, minlevel, numlevels, minlayer, numlayers);
}

void APIENTRY glBindVertexBuffer(GLuint bindingindex, GLuint buffer, GLintptr offset, GLsizei stride)
{
    GL_TRACER_LOG("glBindVertexBuffer(" "{}, {}, {}, {})", bindingindex, buffer, offset, stride);
    glad_glBindVertexBuffer(bindingindex, buffer, offset, stride);
}

void APIENTRY glVertexAttribFormat(GLuint attribindex, GLint size, GLenum type, GLboolean normalized, GLuint relativeoffset)
{
    GL_TRACER_LOG("glVertexAttribFormat(" "{}, {}, {}, {}, {})", attribindex, size, E2S(type), (unsigned int)(normalized), relativeoffset);
    glad_glVertexAttribFormat(attribindex, size, type, normalized, relativeoffset);
}

void APIENTRY glVertexAttribIFormat(GLuint attribindex, GLint size, GLenum type, GLuint relativeoffset)
{
    GL_TRACER_LOG("glVertexAttribIFormat(" "{}, {}, {}, {})", attribindex, size, E2S(type), relativeoffset);
    glad_glVertexAttribIFormat(attribindex, size, type, relativeoffset);
}

void APIENTRY glVertexAttribLFormat(GLuint attribindex, GLint size, GLenum type, GLuint relativeoffset)
{
    GL_TRACER_LOG("glVertexAttribLFormat(" "{}, {}, {}, {})", attribindex, size, E2S(type), relativeoffset);
    glad_glVertexAttribLFormat(attribindex, size, type, relativeoffset);
}

void APIENTRY glVertexAttribBinding(GLuint attribindex, GLuint bindingindex)
{
    GL_TRACER_LOG("glVertexAttribBinding(" "{}, {})", attribindex, bindingindex);
    glad_glVertexAttribBinding(attribindex, bindingindex);
}

void APIENTRY glVertexBindingDivisor(GLuint bindingindex, GLuint divisor)
{
    GL_TRACER_LOG("glVertexBindingDivisor(" "{}, {})", bindingindex, divisor);
    glad_glVertexBindingDivisor(bindingindex, divisor);
}

void APIENTRY glDebugMessageControl(GLenum source, GLenum type, GLenum severity, GLsizei count, const GLuint* ids, GLboolean enabled)
{
    glad_glDebugMessageControl(source, type, severity, count, ids, enabled);
}

void APIENTRY glDebugMessageInsert(GLenum source, GLenum type, GLuint id, GLenum severity, GLsizei length, const GLchar* buf)
{
    glad_glDebugMessageInsert(source, type, id, severity, length, buf);
}

void APIENTRY glDebugMessageCallback(GLDEBUGPROC callback, const void* userParam)
{
    glad_glDebugMessageCallback(callback, userParam);
}

GLuint APIENTRY glGetDebugMessageLog(GLuint count, GLsizei bufSize, GLenum* sources, GLenum* types, GLuint* ids, GLenum* severities, GLsizei* lengths, GLchar* messageLog)
{
    GLuint const r = glad_glGetDebugMessageLog(count, bufSize, sources, types, ids, severities, lengths, messageLog);
    return r;
}

void APIENTRY glPushDebugGroup(GLenum source, GLuint id, GLsizei length, const GLchar* message)
{
    glad_glPushDebugGroup(source, id, length, message);
}

void APIENTRY glPopDebugGroup()
{
    glad_glPopDebugGroup();
}

void APIENTRY glObjectLabel(GLenum identifier, GLuint name, GLsizei length, const GLchar* label)
{
    GL_TRACER_LOG("glObjectLabel(" "{}, {}, {}, {})", E2S(identifier), name, length, fmt::ptr(label));
    glad_glObjectLabel(identifier, name, length, label);
}

void APIENTRY glGetObjectLabel(GLenum identifier, GLuint name, GLsizei bufSize, GLsizei* length, GLchar* label)
{
    GL_TRACER_LOG("glGetObjectLabel(" "{}, {}, {}, {}, {})", E2S(identifier), name, bufSize, fmt::ptr(length), fmt::ptr(label));
    glad_glGetObjectLabel(identifier, name, bufSize, length, label);
}

void APIENTRY glObjectPtrLabel(const void* ptr, GLsizei length, const GLchar* label)
{
    GL_TRACER_LOG("glObjectPtrLabel(" "{}, {}, {})", fmt::ptr(ptr), length, fmt::ptr(label));
    glad_glObjectPtrLabel(ptr, length, label);
}

void APIENTRY glGetObjectPtrLabel(const void* ptr, GLsizei bufSize, GLsizei* length, GLchar* label)
{
    GL_TRACER_LOG("glGetObjectPtrLabel(" "{}, {}, {}, {})", fmt::ptr(ptr), bufSize, fmt::ptr(length), fmt::ptr(label));
    glad_glGetObjectPtrLabel(ptr, bufSize, length, label);
}

void APIENTRY glBufferStorage(GLenum target, GLsizeiptr size, const void* data, GLbitfield flags)
{
    GL_TRACER_LOG("glBufferStorage(" "{}, {}, {}, {})", E2S(target), size, fmt::ptr(data), (unsigned int)(flags));
    glad_glBufferStorage(target, size, data, flags);
}

void APIENTRY glClearTexImage(GLuint texture, GLint level, GLenum format, GLenum type, const void* data)
{
    GL_TRACER_LOG("glClearTexImage(" "{}, {}, {}, {}, {})", texture, level, E2S(format), E2S(type), fmt::ptr(data));
    glad_glClearTexImage(texture, level, format, type, data);
}

void APIENTRY glClearTexSubImage(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const void* data)
{
    GL_TRACER_LOG("glClearTexSubImage(" "{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {})", texture, level, xoffset, yoffset, zoffset, width, height, depth, E2S(format), E2S(type), fmt::ptr(data));
    glad_glClearTexSubImage(texture, level, xoffset, yoffset, zoffset, width, height, depth, format, type, data);
}

void APIENTRY glBindBuffersBase(GLenum target, GLuint first, GLsizei count, const GLuint* buffers)
{
    GL_TRACER_LOG("glBindBuffersBase(" "{}, {}, {}, {})", E2S(target), first, count, fmt::ptr(buffers));
    glad_glBindBuffersBase(target, first, count, buffers);
}

void APIENTRY glBindBuffersRange(GLenum target, GLuint first, GLsizei count, const GLuint* buffers, const GLintptr* offsets, const GLsizeiptr* sizes)
{
    GL_TRACER_LOG("glBindBuffersRange(" "{}, {}, {}, {}, {}, {})", E2S(target), first, count, fmt::ptr(buffers), fmt::ptr(offsets), fmt::ptr(sizes));
    glad_glBindBuffersRange(target, first, count, buffers, offsets, sizes);
}

void APIENTRY glBindTextures(GLuint first, GLsizei count, const GLuint* textures)
{
    GL_TRACER_LOG("glBindTextures(" "{}, {}, {})", first, count, fmt::ptr(textures));
    glad_glBindTextures(first, count, textures);
}

void APIENTRY glBindSamplers(GLuint first, GLsizei count, const GLuint* samplers)
{
    GL_TRACER_LOG("glBindSamplers(" "{}, {}, {})", first, count, fmt::ptr(samplers));
    glad_glBindSamplers(first, count, samplers);
}

void APIENTRY glBindImageTextures(GLuint first, GLsizei count, const GLuint* textures)
{
    GL_TRACER_LOG("glBindImageTextures(" "{}, {}, {})", first, count, fmt::ptr(textures));
    glad_glBindImageTextures(first, count, textures);
}

void APIENTRY glBindVertexBuffers(GLuint first, GLsizei count, const GLuint* buffers, const GLintptr* offsets, const GLsizei* strides)
{
    GL_TRACER_LOG("glBindVertexBuffers(" "{}, {}, {}, {}, {})", first, count, fmt::ptr(buffers), fmt::ptr(offsets), fmt::ptr(strides));
    glad_glBindVertexBuffers(first, count, buffers, offsets, strides);
}

void APIENTRY glClipControl(GLenum origin, GLenum depth)
{
    GL_TRACER_LOG("glClipControl(" "{}, {})", E2S(origin), E2S(depth));
    glad_glClipControl(origin, depth);
}

void APIENTRY glCreateTransformFeedbacks(GLsizei n, GLuint* ids)
{
    GL_TRACER_LOG("glCreateTransformFeedbacks(" "{}, {})", n, fmt::ptr(ids));
    glad_glCreateTransformFeedbacks(n, ids);
}

void APIENTRY glTransformFeedbackBufferBase(GLuint xfb, GLuint index, GLuint buffer)
{
    GL_TRACER_LOG("glTransformFeedbackBufferBase(" "{}, {}, {})", xfb, index, buffer);
    glad_glTransformFeedbackBufferBase(xfb, index, buffer);
}

void APIENTRY glTransformFeedbackBufferRange(GLuint xfb, GLuint index, GLuint buffer, GLintptr offset, GLsizeiptr size)
{
    GL_TRACER_LOG("glTransformFeedbackBufferRange(" "{}, {}, {}, {}, {})", xfb, index, buffer, offset, size);
    glad_glTransformFeedbackBufferRange(xfb, index, buffer, offset, size);
}

void APIENTRY glGetTransformFeedbackiv(GLuint xfb, GLenum pname, GLint* param)
{
    GL_TRACER_LOG("glGetTransformFeedbackiv(" "{}, {}, {})", xfb, E2S(pname), fmt::ptr(param));
    glad_glGetTransformFeedbackiv(xfb, pname, param);
}

void APIENTRY glGetTransformFeedbacki_v(GLuint xfb, GLenum pname, GLuint index, GLint* param)
{
    GL_TRACER_LOG("glGetTransformFeedbacki_v(" "{}, {}, {}, {})", xfb, E2S(pname), index, fmt::ptr(param));
    glad_glGetTransformFeedbacki_v(xfb, pname, index, param);
}

void APIENTRY glGetTransformFeedbacki64_v(GLuint xfb, GLenum pname, GLuint index, GLint64* param)
{
    GL_TRACER_LOG("glGetTransformFeedbacki64_v(" "{}, {}, {}, {})", xfb, E2S(pname), index, fmt::ptr(param));
    glad_glGetTransformFeedbacki64_v(xfb, pname, index, param);
}

void APIENTRY glCreateBuffers(GLsizei n, GLuint* buffers)
{
    GL_TRACER_LOG("glCreateBuffers(" "{}, {})", n, fmt::ptr(buffers));
    glad_glCreateBuffers(n, buffers);
}

void APIENTRY glNamedBufferStorage(GLuint buffer, GLsizeiptr size, const void* data, GLbitfield flags)
{
    GL_TRACER_LOG("glNamedBufferStorage(" "{}, {}, {}, {})", buffer, size, fmt::ptr(data), (unsigned int)(flags));
    glad_glNamedBufferStorage(buffer, size, data, flags);
}

void APIENTRY glNamedBufferData(GLuint buffer, GLsizeiptr size, const void* data, GLenum usage)
{
    GL_TRACER_LOG("glNamedBufferData(" "{}, {}, {}, {})", buffer, size, fmt::ptr(data), E2S(usage));
    glad_glNamedBufferData(buffer, size, data, usage);
}

void APIENTRY glNamedBufferSubData(GLuint buffer, GLintptr offset, GLsizeiptr size, const void* data)
{
    GL_TRACER_LOG("glNamedBufferSubData(" "{}, {}, {}, {})", buffer, offset, size, fmt::ptr(data));
    glad_glNamedBufferSubData(buffer, offset, size, data);
}

void APIENTRY glCopyNamedBufferSubData(GLuint readBuffer, GLuint writeBuffer, GLintptr readOffset, GLintptr writeOffset, GLsizeiptr size)
{
    GL_TRACER_LOG("glCopyNamedBufferSubData(" "{}, {}, {}, {}, {})", readBuffer, writeBuffer, readOffset, writeOffset, size);
    glad_glCopyNamedBufferSubData(readBuffer, writeBuffer, readOffset, writeOffset, size);
}

void APIENTRY glClearNamedBufferData(GLuint buffer, GLenum internalformat, GLenum format, GLenum type, const void* data)
{
    GL_TRACER_LOG("glClearNamedBufferData(" "{}, {}, {}, {}, {})", buffer, E2S(internalformat), E2S(format), E2S(type), fmt::ptr(data));
    glad_glClearNamedBufferData(buffer, internalformat, format, type, data);
}

void APIENTRY glClearNamedBufferSubData(GLuint buffer, GLenum internalformat, GLintptr offset, GLsizeiptr size, GLenum format, GLenum type, const void* data)
{
    GL_TRACER_LOG("glClearNamedBufferSubData(" "{}, {}, {}, {}, {}, {}, {})", buffer, E2S(internalformat), offset, size, E2S(format), E2S(type), fmt::ptr(data));
    glad_glClearNamedBufferSubData(buffer, internalformat, offset, size, format, type, data);
}

void* APIENTRY glMapNamedBuffer(GLuint buffer, GLenum access)
{
    GL_TRACER_LOG("glMapNamedBuffer(" "{}, {})", buffer, E2S(access));
    void* const r = glad_glMapNamedBuffer(buffer, access);
    return r;
}

void* APIENTRY glMapNamedBufferRange(GLuint buffer, GLintptr offset, GLsizeiptr length, GLbitfield access)
{
    GL_TRACER_LOG("glMapNamedBufferRange(" "{}, {}, {}, {})", buffer, offset, length, (unsigned int)(access));
    void* const r = glad_glMapNamedBufferRange(buffer, offset, length, access);
    return r;
}

GLboolean APIENTRY glUnmapNamedBuffer(GLuint buffer)
{
    GL_TRACER_LOG("glUnmapNamedBuffer(" "{})", buffer);
    GLboolean const r = glad_glUnmapNamedBuffer(buffer);
    return r;
}

void APIENTRY glFlushMappedNamedBufferRange(GLuint buffer, GLintptr offset, GLsizeiptr length)
{
    GL_TRACER_LOG("glFlushMappedNamedBufferRange(" "{}, {}, {})", buffer, offset, length);
    glad_glFlushMappedNamedBufferRange(buffer, offset, length);
}

void APIENTRY glGetNamedBufferParameteriv(GLuint buffer, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetNamedBufferParameteriv(" "{}, {}, {})", buffer, E2S(pname), fmt::ptr(params));
    glad_glGetNamedBufferParameteriv(buffer, pname, params);
}

void APIENTRY glGetNamedBufferParameteri64v(GLuint buffer, GLenum pname, GLint64* params)
{
    GL_TRACER_LOG("glGetNamedBufferParameteri64v(" "{}, {}, {})", buffer, E2S(pname), fmt::ptr(params));
    glad_glGetNamedBufferParameteri64v(buffer, pname, params);
}

void APIENTRY glGetNamedBufferPointerv(GLuint buffer, GLenum pname, void** params)
{
    GL_TRACER_LOG("glGetNamedBufferPointerv(" "{}, {}, {})", buffer, E2S(pname), fmt::ptr(params));
    glad_glGetNamedBufferPointerv(buffer, pname, params);
}

void APIENTRY glGetNamedBufferSubData(GLuint buffer, GLintptr offset, GLsizeiptr size, void* data)
{
    GL_TRACER_LOG("glGetNamedBufferSubData(" "{}, {}, {}, {})", buffer, offset, size, fmt::ptr(data));
    glad_glGetNamedBufferSubData(buffer, offset, size, data);
}

void APIENTRY glCreateFramebuffers(GLsizei n, GLuint* framebuffers)
{
    GL_TRACER_LOG("glCreateFramebuffers(" "{}, {})", n, fmt::ptr(framebuffers));
    glad_glCreateFramebuffers(n, framebuffers);
}

void APIENTRY glNamedFramebufferRenderbuffer(GLuint framebuffer, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer)
{
    GL_TRACER_LOG("glNamedFramebufferRenderbuffer(" "{}, {}, {}, {})", framebuffer, E2S(attachment), E2S(renderbuffertarget), renderbuffer);
    glad_glNamedFramebufferRenderbuffer(framebuffer, attachment, renderbuffertarget, renderbuffer);
}

void APIENTRY glNamedFramebufferParameteri(GLuint framebuffer, GLenum pname, GLint param)
{
    GL_TRACER_LOG("glNamedFramebufferParameteri(" "{}, {}, {})", framebuffer, E2S(pname), param);
    glad_glNamedFramebufferParameteri(framebuffer, pname, param);
}

void APIENTRY glNamedFramebufferTexture(GLuint framebuffer, GLenum attachment, GLuint texture, GLint level)
{
    GL_TRACER_LOG("glNamedFramebufferTexture(" "{}, {}, {}, {})", framebuffer, E2S(attachment), texture, level);
    glad_glNamedFramebufferTexture(framebuffer, attachment, texture, level);
}

void APIENTRY glNamedFramebufferTextureLayer(GLuint framebuffer, GLenum attachment, GLuint texture, GLint level, GLint layer)
{
    GL_TRACER_LOG("glNamedFramebufferTextureLayer(" "{}, {}, {}, {}, {})", framebuffer, E2S(attachment), texture, level, layer);
    glad_glNamedFramebufferTextureLayer(framebuffer, attachment, texture, level, layer);
}

void APIENTRY glNamedFramebufferDrawBuffer(GLuint framebuffer, GLenum buf)
{
    GL_TRACER_LOG("glNamedFramebufferDrawBuffer(" "{}, {})", framebuffer, E2S(buf));
    glad_glNamedFramebufferDrawBuffer(framebuffer, buf);
}

void APIENTRY glNamedFramebufferDrawBuffers(GLuint framebuffer, GLsizei n, const GLenum* bufs)
{
    GL_TRACER_LOG("glNamedFramebufferDrawBuffers(" "{}, {}, {})", framebuffer, n, fmt::ptr(bufs));
    glad_glNamedFramebufferDrawBuffers(framebuffer, n, bufs);
}

void APIENTRY glNamedFramebufferReadBuffer(GLuint framebuffer, GLenum src)
{
    GL_TRACER_LOG("glNamedFramebufferReadBuffer(" "{}, {})", framebuffer, E2S(src));
    glad_glNamedFramebufferReadBuffer(framebuffer, src);
}

void APIENTRY glInvalidateNamedFramebufferData(GLuint framebuffer, GLsizei numAttachments, const GLenum* attachments)
{
    GL_TRACER_LOG("glInvalidateNamedFramebufferData(" "{}, {}, {})", framebuffer, numAttachments, fmt::ptr(attachments));
    glad_glInvalidateNamedFramebufferData(framebuffer, numAttachments, attachments);
}

void APIENTRY glInvalidateNamedFramebufferSubData(GLuint framebuffer, GLsizei numAttachments, const GLenum* attachments, GLint x, GLint y, GLsizei width, GLsizei height)
{
    GL_TRACER_LOG("glInvalidateNamedFramebufferSubData(" "{}, {}, {}, {}, {}, {}, {})", framebuffer, numAttachments, fmt::ptr(attachments), x, y, width, height);
    glad_glInvalidateNamedFramebufferSubData(framebuffer, numAttachments, attachments, x, y, width, height);
}

void APIENTRY glClearNamedFramebufferiv(GLuint framebuffer, GLenum buffer, GLint drawbuffer, const GLint* value)
{
    GL_TRACER_LOG("glClearNamedFramebufferiv(" "{}, {}, {}, {})", framebuffer, E2S(buffer), drawbuffer, fmt::ptr(value));
    glad_glClearNamedFramebufferiv(framebuffer, buffer, drawbuffer, value);
}

void APIENTRY glClearNamedFramebufferuiv(GLuint framebuffer, GLenum buffer, GLint drawbuffer, const GLuint* value)
{
    GL_TRACER_LOG("glClearNamedFramebufferuiv(" "{}, {}, {}, {})", framebuffer, E2S(buffer), drawbuffer, fmt::ptr(value));
    glad_glClearNamedFramebufferuiv(framebuffer, buffer, drawbuffer, value);
}

void APIENTRY glClearNamedFramebufferfv(GLuint framebuffer, GLenum buffer, GLint drawbuffer, const GLfloat* value)
{
    GL_TRACER_LOG("glClearNamedFramebufferfv(" "{}, {}, {}, {})", framebuffer, E2S(buffer), drawbuffer, fmt::ptr(value));
    glad_glClearNamedFramebufferfv(framebuffer, buffer, drawbuffer, value);
}

void APIENTRY glClearNamedFramebufferfi(GLuint framebuffer, GLenum buffer, GLint drawbuffer, GLfloat depth, GLint stencil)
{
    GL_TRACER_LOG("glClearNamedFramebufferfi(" "{}, {}, {}, {}, {})", framebuffer, E2S(buffer), drawbuffer, depth, stencil);
    glad_glClearNamedFramebufferfi(framebuffer, buffer, drawbuffer, depth, stencil);
}

void APIENTRY glBlitNamedFramebuffer(GLuint readFramebuffer, GLuint drawFramebuffer, GLint srcX0, GLint srcY0, GLint srcX1, GLint srcY1, GLint dstX0, GLint dstY0, GLint dstX1, GLint dstY1, GLbitfield mask, GLenum filter)
{
    GL_TRACER_LOG("glBlitNamedFramebuffer(" "{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {})", readFramebuffer, drawFramebuffer, srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, (unsigned int)(mask), E2S(filter));
    glad_glBlitNamedFramebuffer(readFramebuffer, drawFramebuffer, srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, mask, filter);
}

GLenum APIENTRY glCheckNamedFramebufferStatus(GLuint framebuffer, GLenum target)
{
    GL_TRACER_LOG("glCheckNamedFramebufferStatus(" "{}, {})", framebuffer, E2S(target));
    GLenum const r = glad_glCheckNamedFramebufferStatus(framebuffer, target);
    return r;
}

void APIENTRY glGetNamedFramebufferParameteriv(GLuint framebuffer, GLenum pname, GLint* param)
{
    GL_TRACER_LOG("glGetNamedFramebufferParameteriv(" "{}, {}, {})", framebuffer, E2S(pname), fmt::ptr(param));
    glad_glGetNamedFramebufferParameteriv(framebuffer, pname, param);
}

void APIENTRY glGetNamedFramebufferAttachmentParameteriv(GLuint framebuffer, GLenum attachment, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetNamedFramebufferAttachmentParameteriv(" "{}, {}, {}, {})", framebuffer, E2S(attachment), E2S(pname), fmt::ptr(params));
    glad_glGetNamedFramebufferAttachmentParameteriv(framebuffer, attachment, pname, params);
}

void APIENTRY glCreateRenderbuffers(GLsizei n, GLuint* renderbuffers)
{
    GL_TRACER_LOG("glCreateRenderbuffers(" "{}, {})", n, fmt::ptr(renderbuffers));
    glad_glCreateRenderbuffers(n, renderbuffers);
}

void APIENTRY glNamedRenderbufferStorage(GLuint renderbuffer, GLenum internalformat, GLsizei width, GLsizei height)
{
    GL_TRACER_LOG("glNamedRenderbufferStorage(" "{}, {}, {}, {})", renderbuffer, E2S(internalformat), width, height);
    glad_glNamedRenderbufferStorage(renderbuffer, internalformat, width, height);
}

void APIENTRY glNamedRenderbufferStorageMultisample(GLuint renderbuffer, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height)
{
    GL_TRACER_LOG("glNamedRenderbufferStorageMultisample(" "{}, {}, {}, {}, {})", renderbuffer, samples, E2S(internalformat), width, height);
    glad_glNamedRenderbufferStorageMultisample(renderbuffer, samples, internalformat, width, height);
}

void APIENTRY glGetNamedRenderbufferParameteriv(GLuint renderbuffer, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetNamedRenderbufferParameteriv(" "{}, {}, {})", renderbuffer, E2S(pname), fmt::ptr(params));
    glad_glGetNamedRenderbufferParameteriv(renderbuffer, pname, params);
}

void APIENTRY glCreateTextures(GLenum target, GLsizei n, GLuint* textures)
{
    GL_TRACER_LOG("glCreateTextures(" "{}, {}, {})", E2S(target), n, fmt::ptr(textures));
    glad_glCreateTextures(target, n, textures);
}

void APIENTRY glTextureBuffer(GLuint texture, GLenum internalformat, GLuint buffer)
{
    GL_TRACER_LOG("glTextureBuffer(" "{}, {}, {})", texture, E2S(internalformat), buffer);
    glad_glTextureBuffer(texture, internalformat, buffer);
}

void APIENTRY glTextureBufferRange(GLuint texture, GLenum internalformat, GLuint buffer, GLintptr offset, GLsizeiptr size)
{
    GL_TRACER_LOG("glTextureBufferRange(" "{}, {}, {}, {}, {})", texture, E2S(internalformat), buffer, offset, size);
    glad_glTextureBufferRange(texture, internalformat, buffer, offset, size);
}

void APIENTRY glTextureStorage1D(GLuint texture, GLsizei levels, GLenum internalformat, GLsizei width)
{
    GL_TRACER_LOG("glTextureStorage1D(" "{}, {}, {}, {})", texture, levels, E2S(internalformat), width);
    glad_glTextureStorage1D(texture, levels, internalformat, width);
}

void APIENTRY glTextureStorage2D(GLuint texture, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height)
{
    GL_TRACER_LOG("glTextureStorage2D(" "{}, {}, {}, {}, {})", texture, levels, E2S(internalformat), width, height);
    glad_glTextureStorage2D(texture, levels, internalformat, width, height);
}

void APIENTRY glTextureStorage3D(GLuint texture, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth)
{
    GL_TRACER_LOG("glTextureStorage3D(" "{}, {}, {}, {}, {}, {})", texture, levels, E2S(internalformat), width, height, depth);
    glad_glTextureStorage3D(texture, levels, internalformat, width, height, depth);
}

void APIENTRY glTextureStorage2DMultisample(GLuint texture, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLboolean fixedsamplelocations)
{
    GL_TRACER_LOG("glTextureStorage2DMultisample(" "{}, {}, {}, {}, {}, {})", texture, samples, E2S(internalformat), width, height, (unsigned int)(fixedsamplelocations));
    glad_glTextureStorage2DMultisample(texture, samples, internalformat, width, height, fixedsamplelocations);
}

void APIENTRY glTextureStorage3DMultisample(GLuint texture, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLboolean fixedsamplelocations)
{
    GL_TRACER_LOG("glTextureStorage3DMultisample(" "{}, {}, {}, {}, {}, {}, {})", texture, samples, E2S(internalformat), width, height, depth, (unsigned int)(fixedsamplelocations));
    glad_glTextureStorage3DMultisample(texture, samples, internalformat, width, height, depth, fixedsamplelocations);
}

void APIENTRY glTextureSubImage1D(GLuint texture, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum type, const void* pixels)
{
    GL_TRACER_LOG("glTextureSubImage1D(" "{}, {}, {}, {}, {}, {}, {})", texture, level, xoffset, width, E2S(format), E2S(type), fmt::ptr(pixels));
    glad_glTextureSubImage1D(texture, level, xoffset, width, format, type, pixels);
}

void APIENTRY glTextureSubImage2D(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const void* pixels)
{
    GL_TRACER_LOG("glTextureSubImage2D(" "{}, {}, {}, {}, {}, {}, {}, {}, {})", texture, level, xoffset, yoffset, width, height, E2S(format), E2S(type), fmt::ptr(pixels));
    glad_glTextureSubImage2D(texture, level, xoffset, yoffset, width, height, format, type, pixels);
}

void APIENTRY glTextureSubImage3D(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const void* pixels)
{
    GL_TRACER_LOG("glTextureSubImage3D(" "{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {})", texture, level, xoffset, yoffset, zoffset, width, height, depth, E2S(format), E2S(type), fmt::ptr(pixels));
    glad_glTextureSubImage3D(texture, level, xoffset, yoffset, zoffset, width, height, depth, format, type, pixels);
}

void APIENTRY glCompressedTextureSubImage1D(GLuint texture, GLint level, GLint xoffset, GLsizei width, GLenum format, GLsizei imageSize, const void* data)
{
    GL_TRACER_LOG("glCompressedTextureSubImage1D(" "{}, {}, {}, {}, {}, {}, {})", texture, level, xoffset, width, E2S(format), imageSize, fmt::ptr(data));
    glad_glCompressedTextureSubImage1D(texture, level, xoffset, width, format, imageSize, data);
}

void APIENTRY glCompressedTextureSubImage2D(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, const void* data)
{
    GL_TRACER_LOG("glCompressedTextureSubImage2D(" "{}, {}, {}, {}, {}, {}, {}, {}, {})", texture, level, xoffset, yoffset, width, height, E2S(format), imageSize, fmt::ptr(data));
    glad_glCompressedTextureSubImage2D(texture, level, xoffset, yoffset, width, height, format, imageSize, data);
}

void APIENTRY glCompressedTextureSubImage3D(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLsizei imageSize, const void* data)
{
    GL_TRACER_LOG("glCompressedTextureSubImage3D(" "{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {})", texture, level, xoffset, yoffset, zoffset, width, height, depth, E2S(format), imageSize, fmt::ptr(data));
    glad_glCompressedTextureSubImage3D(texture, level, xoffset, yoffset, zoffset, width, height, depth, format, imageSize, data);
}

void APIENTRY glCopyTextureSubImage1D(GLuint texture, GLint level, GLint xoffset, GLint x, GLint y, GLsizei width)
{
    GL_TRACER_LOG("glCopyTextureSubImage1D(" "{}, {}, {}, {}, {}, {})", texture, level, xoffset, x, y, width);
    glad_glCopyTextureSubImage1D(texture, level, xoffset, x, y, width);
}

void APIENTRY glCopyTextureSubImage2D(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height)
{
    GL_TRACER_LOG("glCopyTextureSubImage2D(" "{}, {}, {}, {}, {}, {}, {}, {})", texture, level, xoffset, yoffset, x, y, width, height);
    glad_glCopyTextureSubImage2D(texture, level, xoffset, yoffset, x, y, width, height);
}

void APIENTRY glCopyTextureSubImage3D(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLint x, GLint y, GLsizei width, GLsizei height)
{
    GL_TRACER_LOG("glCopyTextureSubImage3D(" "{}, {}, {}, {}, {}, {}, {}, {}, {})", texture, level, xoffset, yoffset, zoffset, x, y, width, height);
    glad_glCopyTextureSubImage3D(texture, level, xoffset, yoffset, zoffset, x, y, width, height);
}

void APIENTRY glTextureParameterf(GLuint texture, GLenum pname, GLfloat param)
{
    GL_TRACER_LOG("glTextureParameterf(" "{}, {}, {})", texture, E2S(pname), param);
    glad_glTextureParameterf(texture, pname, param);
}

void APIENTRY glTextureParameterfv(GLuint texture, GLenum pname, const GLfloat* param)
{
    GL_TRACER_LOG("glTextureParameterfv(" "{}, {}, {})", texture, E2S(pname), fmt::ptr(param));
    glad_glTextureParameterfv(texture, pname, param);
}

void APIENTRY glTextureParameteri(GLuint texture, GLenum pname, GLint param)
{
    GL_TRACER_LOG("glTextureParameteri(" "{}, {}, {})", texture, E2S(pname), param);
    glad_glTextureParameteri(texture, pname, param);
}

void APIENTRY glTextureParameterIiv(GLuint texture, GLenum pname, const GLint* params)
{
    GL_TRACER_LOG("glTextureParameterIiv(" "{}, {}, {})", texture, E2S(pname), fmt::ptr(params));
    glad_glTextureParameterIiv(texture, pname, params);
}

void APIENTRY glTextureParameterIuiv(GLuint texture, GLenum pname, const GLuint* params)
{
    GL_TRACER_LOG("glTextureParameterIuiv(" "{}, {}, {})", texture, E2S(pname), fmt::ptr(params));
    glad_glTextureParameterIuiv(texture, pname, params);
}

void APIENTRY glTextureParameteriv(GLuint texture, GLenum pname, const GLint* param)
{
    GL_TRACER_LOG("glTextureParameteriv(" "{}, {}, {})", texture, E2S(pname), fmt::ptr(param));
    glad_glTextureParameteriv(texture, pname, param);
}

void APIENTRY glGenerateTextureMipmap(GLuint texture)
{
    GL_TRACER_LOG("glGenerateTextureMipmap(" "{})", texture);
    glad_glGenerateTextureMipmap(texture);
}

void APIENTRY glBindTextureUnit(GLuint unit, GLuint texture)
{
    GL_TRACER_LOG("glBindTextureUnit(" "{}, {})", unit, texture);
    glad_glBindTextureUnit(unit, texture);
}

void APIENTRY glGetTextureImage(GLuint texture, GLint level, GLenum format, GLenum type, GLsizei bufSize, void* pixels)
{
    GL_TRACER_LOG("glGetTextureImage(" "{}, {}, {}, {}, {}, {})", texture, level, E2S(format), E2S(type), bufSize, fmt::ptr(pixels));
    glad_glGetTextureImage(texture, level, format, type, bufSize, pixels);
}

void APIENTRY glGetCompressedTextureImage(GLuint texture, GLint level, GLsizei bufSize, void* pixels)
{
    GL_TRACER_LOG("glGetCompressedTextureImage(" "{}, {}, {}, {})", texture, level, bufSize, fmt::ptr(pixels));
    glad_glGetCompressedTextureImage(texture, level, bufSize, pixels);
}

void APIENTRY glGetTextureLevelParameterfv(GLuint texture, GLint level, GLenum pname, GLfloat* params)
{
    GL_TRACER_LOG("glGetTextureLevelParameterfv(" "{}, {}, {}, {})", texture, level, E2S(pname), fmt::ptr(params));
    glad_glGetTextureLevelParameterfv(texture, level, pname, params);
}

void APIENTRY glGetTextureLevelParameteriv(GLuint texture, GLint level, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetTextureLevelParameteriv(" "{}, {}, {}, {})", texture, level, E2S(pname), fmt::ptr(params));
    glad_glGetTextureLevelParameteriv(texture, level, pname, params);
}

void APIENTRY glGetTextureParameterfv(GLuint texture, GLenum pname, GLfloat* params)
{
    GL_TRACER_LOG("glGetTextureParameterfv(" "{}, {}, {})", texture, E2S(pname), fmt::ptr(params));
    glad_glGetTextureParameterfv(texture, pname, params);
}

void APIENTRY glGetTextureParameterIiv(GLuint texture, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetTextureParameterIiv(" "{}, {}, {})", texture, E2S(pname), fmt::ptr(params));
    glad_glGetTextureParameterIiv(texture, pname, params);
}

void APIENTRY glGetTextureParameterIuiv(GLuint texture, GLenum pname, GLuint* params)
{
    GL_TRACER_LOG("glGetTextureParameterIuiv(" "{}, {}, {})", texture, E2S(pname), fmt::ptr(params));
    glad_glGetTextureParameterIuiv(texture, pname, params);
}

void APIENTRY glGetTextureParameteriv(GLuint texture, GLenum pname, GLint* params)
{
    GL_TRACER_LOG("glGetTextureParameteriv(" "{}, {}, {})", texture, E2S(pname), fmt::ptr(params));
    glad_glGetTextureParameteriv(texture, pname, params);
}

void APIENTRY glCreateVertexArrays(GLsizei n, GLuint* arrays)
{
    GL_TRACER_LOG("glCreateVertexArrays(" "{}, {})", n, fmt::ptr(arrays));
    glad_glCreateVertexArrays(n, arrays);
}

void APIENTRY glDisableVertexArrayAttrib(GLuint vaobj, GLuint index)
{
    GL_TRACER_LOG("glDisableVertexArrayAttrib(" "{}, {})", vaobj, index);
    glad_glDisableVertexArrayAttrib(vaobj, index);
}

void APIENTRY glEnableVertexArrayAttrib(GLuint vaobj, GLuint index)
{
    GL_TRACER_LOG("glEnableVertexArrayAttrib(" "{}, {})", vaobj, index);
    glad_glEnableVertexArrayAttrib(vaobj, index);
}

void APIENTRY glVertexArrayElementBuffer(GLuint vaobj, GLuint buffer)
{
    GL_TRACER_LOG("glVertexArrayElementBuffer(" "{}, {})", vaobj, buffer);
    glad_glVertexArrayElementBuffer(vaobj, buffer);
}

void APIENTRY glVertexArrayVertexBuffer(GLuint vaobj, GLuint bindingindex, GLuint buffer, GLintptr offset, GLsizei stride)
{
    GL_TRACER_LOG("glVertexArrayVertexBuffer(" "{}, {}, {}, {}, {})", vaobj, bindingindex, buffer, offset, stride);
    glad_glVertexArrayVertexBuffer(vaobj, bindingindex, buffer, offset, stride);
}

void APIENTRY glVertexArrayVertexBuffers(GLuint vaobj, GLuint first, GLsizei count, const GLuint* buffers, const GLintptr* offsets, const GLsizei* strides)
{
    GL_TRACER_LOG("glVertexArrayVertexBuffers(" "{}, {}, {}, {}, {}, {})", vaobj, first, count, fmt::ptr(buffers), fmt::ptr(offsets), fmt::ptr(strides));
    glad_glVertexArrayVertexBuffers(vaobj, first, count, buffers, offsets, strides);
}

void APIENTRY glVertexArrayAttribBinding(GLuint vaobj, GLuint attribindex, GLuint bindingindex)
{
    GL_TRACER_LOG("glVertexArrayAttribBinding(" "{}, {}, {})", vaobj, attribindex, bindingindex);
    glad_glVertexArrayAttribBinding(vaobj, attribindex, bindingindex);
}

void APIENTRY glVertexArrayAttribFormat(GLuint vaobj, GLuint attribindex, GLint size, GLenum type, GLboolean normalized, GLuint relativeoffset)
{
    GL_TRACER_LOG("glVertexArrayAttribFormat(" "{}, {}, {}, {}, {}, {})", vaobj, attribindex, size, E2S(type), (unsigned int)(normalized), relativeoffset);
    glad_glVertexArrayAttribFormat(vaobj, attribindex, size, type, normalized, relativeoffset);
}

void APIENTRY glVertexArrayAttribIFormat(GLuint vaobj, GLuint attribindex, GLint size, GLenum type, GLuint relativeoffset)
{
    GL_TRACER_LOG("glVertexArrayAttribIFormat(" "{}, {}, {}, {}, {})", vaobj, attribindex, size, E2S(type), relativeoffset);
    glad_glVertexArrayAttribIFormat(vaobj, attribindex, size, type, relativeoffset);
}

void APIENTRY glVertexArrayAttribLFormat(GLuint vaobj, GLuint attribindex, GLint size, GLenum type, GLuint relativeoffset)
{
    GL_TRACER_LOG("glVertexArrayAttribLFormat(" "{}, {}, {}, {}, {})", vaobj, attribindex, size, E2S(type), relativeoffset);
    glad_glVertexArrayAttribLFormat(vaobj, attribindex, size, type, relativeoffset);
}

void APIENTRY glVertexArrayBindingDivisor(GLuint vaobj, GLuint bindingindex, GLuint divisor)
{
    GL_TRACER_LOG("glVertexArrayBindingDivisor(" "{}, {}, {})", vaobj, bindingindex, divisor);
    glad_glVertexArrayBindingDivisor(vaobj, bindingindex, divisor);
}

void APIENTRY glGetVertexArrayiv(GLuint vaobj, GLenum pname, GLint* param)
{
    GL_TRACER_LOG("glGetVertexArrayiv(" "{}, {}, {})", vaobj, E2S(pname), fmt::ptr(param));
    glad_glGetVertexArrayiv(vaobj, pname, param);
}

void APIENTRY glGetVertexArrayIndexediv(GLuint vaobj, GLuint index, GLenum pname, GLint* param)
{
    GL_TRACER_LOG("glGetVertexArrayIndexediv(" "{}, {}, {}, {})", vaobj, index, E2S(pname), fmt::ptr(param));
    glad_glGetVertexArrayIndexediv(vaobj, index, pname, param);
}

void APIENTRY glGetVertexArrayIndexed64iv(GLuint vaobj, GLuint index, GLenum pname, GLint64* param)
{
    GL_TRACER_LOG("glGetVertexArrayIndexed64iv(" "{}, {}, {}, {})", vaobj, index, E2S(pname), fmt::ptr(param));
    glad_glGetVertexArrayIndexed64iv(vaobj, index, pname, param);
}

void APIENTRY glCreateSamplers(GLsizei n, GLuint* samplers)
{
    GL_TRACER_LOG("glCreateSamplers(" "{}, {})", n, fmt::ptr(samplers));
    glad_glCreateSamplers(n, samplers);
}

void APIENTRY glCreateProgramPipelines(GLsizei n, GLuint* pipelines)
{
    GL_TRACER_LOG("glCreateProgramPipelines(" "{}, {})", n, fmt::ptr(pipelines));
    glad_glCreateProgramPipelines(n, pipelines);
}

void APIENTRY glCreateQueries(GLenum target, GLsizei n, GLuint* ids)
{
    GL_TRACER_LOG("glCreateQueries(" "{}, {}, {})", E2S(target), n, fmt::ptr(ids));
    glad_glCreateQueries(target, n, ids);
}

void APIENTRY glGetQueryBufferObjecti64v(GLuint id, GLuint buffer, GLenum pname, GLintptr offset)
{
    GL_TRACER_LOG("glGetQueryBufferObjecti64v(" "{}, {}, {}, {})", id, buffer, E2S(pname), offset);
    glad_glGetQueryBufferObjecti64v(id, buffer, pname, offset);
}

void APIENTRY glGetQueryBufferObjectiv(GLuint id, GLuint buffer, GLenum pname, GLintptr offset)
{
    GL_TRACER_LOG("glGetQueryBufferObjectiv(" "{}, {}, {}, {})", id, buffer, E2S(pname), offset);
    glad_glGetQueryBufferObjectiv(id, buffer, pname, offset);
}

void APIENTRY glGetQueryBufferObjectui64v(GLuint id, GLuint buffer, GLenum pname, GLintptr offset)
{
    GL_TRACER_LOG("glGetQueryBufferObjectui64v(" "{}, {}, {}, {})", id, buffer, E2S(pname), offset);
    glad_glGetQueryBufferObjectui64v(id, buffer, pname, offset);
}

void APIENTRY glGetQueryBufferObjectuiv(GLuint id, GLuint buffer, GLenum pname, GLintptr offset)
{
    GL_TRACER_LOG("glGetQueryBufferObjectuiv(" "{}, {}, {}, {})", id, buffer, E2S(pname), offset);
    glad_glGetQueryBufferObjectuiv(id, buffer, pname, offset);
}

void APIENTRY glMemoryBarrierByRegion(GLbitfield barriers)
{
    GL_TRACER_LOG("glMemoryBarrierByRegion(" "{})", (unsigned int)(barriers));
    glad_glMemoryBarrierByRegion(barriers);
}

void APIENTRY glGetTextureSubImage(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, GLsizei bufSize, void* pixels)
{
    GL_TRACER_LOG("glGetTextureSubImage(" "{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {})", texture, level, xoffset, yoffset, zoffset, width, height, depth, E2S(format), E2S(type), bufSize, fmt::ptr(pixels));
    glad_glGetTextureSubImage(texture, level, xoffset, yoffset, zoffset, width, height, depth, format, type, bufSize, pixels);
}

void APIENTRY glGetCompressedTextureSubImage(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLsizei bufSize, void* pixels)
{
    GL_TRACER_LOG("glGetCompressedTextureSubImage(" "{}, {}, {}, {}, {}, {}, {}, {}, {}, {})", texture, level, xoffset, yoffset, zoffset, width, height, depth, bufSize, fmt::ptr(pixels));
    glad_glGetCompressedTextureSubImage(texture, level, xoffset, yoffset, zoffset, width, height, depth, bufSize, pixels);
}

GLenum APIENTRY glGetGraphicsResetStatus()
{
    GL_TRACER_LOG("glGetGraphicsResetStatus()");
    GLenum const r = glad_glGetGraphicsResetStatus();
    return r;
}

void APIENTRY glGetnCompressedTexImage(GLenum target, GLint lod, GLsizei bufSize, void* pixels)
{
    GL_TRACER_LOG("glGetnCompressedTexImage(" "{}, {}, {}, {})", E2S(target), lod, bufSize, fmt::ptr(pixels));
    glad_glGetnCompressedTexImage(target, lod, bufSize, pixels);
}

void APIENTRY glGetnTexImage(GLenum target, GLint level, GLenum format, GLenum type, GLsizei bufSize, void* pixels)
{
    GL_TRACER_LOG("glGetnTexImage(" "{}, {}, {}, {}, {}, {})", E2S(target), level, E2S(format), E2S(type), bufSize, fmt::ptr(pixels));
    glad_glGetnTexImage(target, level, format, type, bufSize, pixels);
}

void APIENTRY glGetnUniformdv(GLuint program, GLint location, GLsizei bufSize, GLdouble* params)
{
    GL_TRACER_LOG("glGetnUniformdv(" "{}, {}, {}, {})", program, location, bufSize, fmt::ptr(params));
    glad_glGetnUniformdv(program, location, bufSize, params);
}

void APIENTRY glGetnUniformfv(GLuint program, GLint location, GLsizei bufSize, GLfloat* params)
{
    GL_TRACER_LOG("glGetnUniformfv(" "{}, {}, {}, {})", program, location, bufSize, fmt::ptr(params));
    glad_glGetnUniformfv(program, location, bufSize, params);
}

void APIENTRY glGetnUniformiv(GLuint program, GLint location, GLsizei bufSize, GLint* params)
{
    GL_TRACER_LOG("glGetnUniformiv(" "{}, {}, {}, {})", program, location, bufSize, fmt::ptr(params));
    glad_glGetnUniformiv(program, location, bufSize, params);
}

void APIENTRY glGetnUniformuiv(GLuint program, GLint location, GLsizei bufSize, GLuint* params)
{
    GL_TRACER_LOG("glGetnUniformuiv(" "{}, {}, {}, {})", program, location, bufSize, fmt::ptr(params));
    glad_glGetnUniformuiv(program, location, bufSize, params);
}

void APIENTRY glReadnPixels(GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLsizei bufSize, void* data)
{
    GL_TRACER_LOG("glReadnPixels(" "{}, {}, {}, {}, {}, {}, {}, {})", x, y, width, height, E2S(format), E2S(type), bufSize, fmt::ptr(data));
    glad_glReadnPixels(x, y, width, height, format, type, bufSize, data);
}

void APIENTRY glTextureBarrier()
{
    GL_TRACER_LOG("glTextureBarrier()");
    glad_glTextureBarrier();
}

void APIENTRY glSpecializeShader(GLuint shader, const GLchar* pEntryPoint, GLuint numSpecializationConstants, const GLuint* pConstantIndex, const GLuint* pConstantValue)
{
    GL_TRACER_LOG("glSpecializeShader(" "{}, {}, {}, {}, {})", shader, fmt::ptr(pEntryPoint), numSpecializationConstants, fmt::ptr(pConstantIndex), fmt::ptr(pConstantValue));
    glad_glSpecializeShader(shader, pEntryPoint, numSpecializationConstants, pConstantIndex, pConstantValue);
}

void APIENTRY glMultiDrawArraysIndirectCount(GLenum mode, const void* indirect, GLintptr drawcount, GLsizei maxdrawcount, GLsizei stride)
{
    GL_TRACER_LOG("glMultiDrawArraysIndirectCount(" "{}, {}, {}, {}, {})", E2S(mode), fmt::ptr(indirect), drawcount, maxdrawcount, stride);
    glad_glMultiDrawArraysIndirectCount(mode, indirect, drawcount, maxdrawcount, stride);
}

void APIENTRY glMultiDrawElementsIndirectCount(GLenum mode, GLenum type, const void* indirect, GLintptr drawcount, GLsizei maxdrawcount, GLsizei stride)
{
    GL_TRACER_LOG("glMultiDrawElementsIndirectCount(" "{}, {}, {}, {}, {}, {})", E2S(mode), E2S(type), fmt::ptr(indirect), drawcount, maxdrawcount, stride);
    glad_glMultiDrawElementsIndirectCount(mode, type, indirect, drawcount, maxdrawcount, stride);
}

void APIENTRY glPolygonOffsetClamp(GLfloat factor, GLfloat units, GLfloat clamp)
{
    GL_TRACER_LOG("glPolygonOffsetClamp(" "{}, {}, {})", factor, units, clamp);
    glad_glPolygonOffsetClamp(factor, units, clamp);
}

GLuint64 APIENTRY glGetTextureHandleARB(GLuint texture)
{
    GL_TRACER_LOG("glGetTextureHandleARB(" "{})", texture);
    GLuint64 const r = glad_glGetTextureHandleARB(texture);
    return r;
}

GLuint64 APIENTRY glGetTextureSamplerHandleARB(GLuint texture, GLuint sampler)
{
    GL_TRACER_LOG("glGetTextureSamplerHandleARB(" "{}, {})", texture, sampler);
    GLuint64 const r = glad_glGetTextureSamplerHandleARB(texture, sampler);
    return r;
}

void APIENTRY glMakeTextureHandleResidentARB(GLuint64 handle)
{
    GL_TRACER_LOG("glMakeTextureHandleResidentARB(" "{})", handle);
    glad_glMakeTextureHandleResidentARB(handle);
}

void APIENTRY glMakeTextureHandleNonResidentARB(GLuint64 handle)
{
    GL_TRACER_LOG("glMakeTextureHandleNonResidentARB(" "{})", handle);
    glad_glMakeTextureHandleNonResidentARB(handle);
}

GLuint64 APIENTRY glGetImageHandleARB(GLuint texture, GLint level, GLboolean layered, GLint layer, GLenum format)
{
    GL_TRACER_LOG("glGetImageHandleARB(" "{}, {}, {}, {}, {})", texture, level, (unsigned int)(layered), layer, E2S(format));
    GLuint64 const r = glad_glGetImageHandleARB(texture, level, layered, layer, format);
    return r;
}

void APIENTRY glMakeImageHandleResidentARB(GLuint64 handle, GLenum access)
{
    GL_TRACER_LOG("glMakeImageHandleResidentARB(" "{}, {})", handle, E2S(access));
    glad_glMakeImageHandleResidentARB(handle, access);
}

void APIENTRY glMakeImageHandleNonResidentARB(GLuint64 handle)
{
    GL_TRACER_LOG("glMakeImageHandleNonResidentARB(" "{})", handle);
    glad_glMakeImageHandleNonResidentARB(handle);
}

void APIENTRY glUniformHandleui64ARB(GLint location, GLuint64 value)
{
    GL_TRACER_LOG("glUniformHandleui64ARB(" "{}, {})", location, value);
    glad_glUniformHandleui64ARB(location, value);
}

void APIENTRY glUniformHandleui64vARB(GLint location, GLsizei count, const GLuint64* value)
{
    GL_TRACER_LOG("glUniformHandleui64vARB(" "{}, {}, {})", location, count, fmt::ptr(value));
    glad_glUniformHandleui64vARB(location, count, value);
}

void APIENTRY glProgramUniformHandleui64ARB(GLuint program, GLint location, GLuint64 value)
{
    GL_TRACER_LOG("glProgramUniformHandleui64ARB(" "{}, {}, {})", program, location, value);
    glad_glProgramUniformHandleui64ARB(program, location, value);
}

void APIENTRY glProgramUniformHandleui64vARB(GLuint program, GLint location, GLsizei count, const GLuint64* values)
{
    GL_TRACER_LOG("glProgramUniformHandleui64vARB(" "{}, {}, {}, {})", program, location, count, fmt::ptr(values));
    glad_glProgramUniformHandleui64vARB(program, location, count, values);
}

GLboolean APIENTRY glIsTextureHandleResidentARB(GLuint64 handle)
{
    GL_TRACER_LOG("glIsTextureHandleResidentARB(" "{})", handle);
    GLboolean const r = glad_glIsTextureHandleResidentARB(handle);
    return r;
}

GLboolean APIENTRY glIsImageHandleResidentARB(GLuint64 handle)
{
    GL_TRACER_LOG("glIsImageHandleResidentARB(" "{})", handle);
    GLboolean const r = glad_glIsImageHandleResidentARB(handle);
    return r;
}

void APIENTRY glVertexAttribL1ui64ARB(GLuint index, GLuint64EXT x)
{
    GL_TRACER_LOG("glVertexAttribL1ui64ARB(" "{}, {})", index, x);
    glad_glVertexAttribL1ui64ARB(index, x);
}

void APIENTRY glVertexAttribL1ui64vARB(GLuint index, const GLuint64EXT* v)
{
    GL_TRACER_LOG("glVertexAttribL1ui64vARB(" "{}, {})", index, fmt::ptr(v));
    glad_glVertexAttribL1ui64vARB(index, v);
}

void APIENTRY glGetVertexAttribLui64vARB(GLuint index, GLenum pname, GLuint64EXT* params)
{
    GL_TRACER_LOG("glGetVertexAttribLui64vARB(" "{}, {}, {})", index, E2S(pname), fmt::ptr(params));
    glad_glGetVertexAttribLui64vARB(index, pname, params);
}