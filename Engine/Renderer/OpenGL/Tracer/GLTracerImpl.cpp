#include "GLTracer.h"

#include <string>
#include <cinttypes>

#define E2S( en ) Enum2String( en ).c_str()
extern std::string Enum2String( GLenum e );

void APIENTRY glCullFace(GLenum mode)
{
    printf("glCullFace(" "%s)\n", E2S(mode));
    glad_glCullFace(mode);
}

void APIENTRY glFrontFace(GLenum mode)
{
    printf("glFrontFace(" "%s)\n", E2S(mode));
    glad_glFrontFace(mode);
}

void APIENTRY glHint(GLenum target, GLenum mode)
{
    printf("glHint(" "%s, %s)\n", E2S(target), E2S(mode));
    glad_glHint(target, mode);
}

void APIENTRY glLineWidth(GLfloat width)
{
    printf("glLineWidth(" "%f)\n", width);
    glad_glLineWidth(width);
}

void APIENTRY glPointSize(GLfloat size)
{
    printf("glPointSize(" "%f)\n", size);
    glad_glPointSize(size);
}

void APIENTRY glPolygonMode(GLenum face, GLenum mode)
{
    printf("glPolygonMode(" "%s, %s)\n", E2S(face), E2S(mode));
    glad_glPolygonMode(face, mode);
}

void APIENTRY glScissor(GLint x, GLint y, GLsizei width, GLsizei height)
{
    printf("glScissor(" "%i, %i, %i, %i)\n", x, y, width, height);
    glad_glScissor(x, y, width, height);
}

void APIENTRY glTexParameterf(GLenum target, GLenum pname, GLfloat param)
{
    printf("glTexParameterf(" "%s, %s, %f)\n", E2S(target), E2S(pname), param);
    glad_glTexParameterf(target, pname, param);
}

void APIENTRY glTexParameterfv(GLenum target, GLenum pname, const GLfloat* params)
{
    printf("glTexParameterfv(" "%s, %s, %p)\n", E2S(target), E2S(pname), params);
    glad_glTexParameterfv(target, pname, params);
}

void APIENTRY glTexParameteri(GLenum target, GLenum pname, GLint param)
{
    printf("glTexParameteri(" "%s, %s, %i)\n", E2S(target), E2S(pname), param);
    glad_glTexParameteri(target, pname, param);
}

void APIENTRY glTexParameteriv(GLenum target, GLenum pname, const GLint* params)
{
    printf("glTexParameteriv(" "%s, %s, %p)\n", E2S(target), E2S(pname), params);
    glad_glTexParameteriv(target, pname, params);
}

void APIENTRY glTexImage1D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLint border, GLenum format, GLenum type, const void* pixels)
{
    printf("glTexImage1D(" "%s, %i, %i, %i, %i, %s, %s, %p)\n", E2S(target), level, internalformat, width, border, E2S(format), E2S(type), pixels);
    glad_glTexImage1D(target, level, internalformat, width, border, format, type, pixels);
}

void APIENTRY glTexImage2D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const void* pixels)
{
    printf("glTexImage2D(" "%s, %i, %i, %i, %i, %i, %s, %s, %p)\n", E2S(target), level, internalformat, width, height, border, E2S(format), E2S(type), pixels);
    glad_glTexImage2D(target, level, internalformat, width, height, border, format, type, pixels);
}

void APIENTRY glDrawBuffer(GLenum buf)
{
    printf("glDrawBuffer(" "%s)\n", E2S(buf));
    glad_glDrawBuffer(buf);
}

void APIENTRY glClear(GLbitfield mask)
{
    printf("glClear(" "%u)\n", (unsigned int)(mask));
    glad_glClear(mask);
}

void APIENTRY glClearColor(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha)
{
    printf("glClearColor(" "%f, %f, %f, %f)\n", red, green, blue, alpha);
    glad_glClearColor(red, green, blue, alpha);
}

void APIENTRY glClearStencil(GLint s)
{
    printf("glClearStencil(" "%i)\n", s);
    glad_glClearStencil(s);
}

void APIENTRY glClearDepth(GLdouble depth)
{
    printf("glClearDepth(" "%f)\n", depth);
    glad_glClearDepth(depth);
}

void APIENTRY glStencilMask(GLuint mask)
{
    printf("glStencilMask(" "%u)\n", mask);
    glad_glStencilMask(mask);
}

void APIENTRY glColorMask(GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha)
{
    printf("glColorMask(" "%u, %u, %u, %u)\n", (unsigned int)(red), (unsigned int)(green), (unsigned int)(blue), (unsigned int)(alpha));
    glad_glColorMask(red, green, blue, alpha);
}

void APIENTRY glDepthMask(GLboolean flag)
{
    printf("glDepthMask(" "%u)\n", (unsigned int)(flag));
    glad_glDepthMask(flag);
}

void APIENTRY glDisable(GLenum cap)
{
    printf("glDisable(" "%s)\n", E2S(cap));
    glad_glDisable(cap);
}

void APIENTRY glEnable(GLenum cap)
{
    printf("glEnable(" "%s)\n", E2S(cap));
    glad_glEnable(cap);
}

void APIENTRY glFinish()
{
    printf("glFinish()\n");
    glad_glFinish();
}

void APIENTRY glFlush()
{
    printf("glFlush()\n");
    glad_glFlush();
}

void APIENTRY glBlendFunc(GLenum sfactor, GLenum dfactor)
{
    printf("glBlendFunc(" "%s, %s)\n", E2S(sfactor), E2S(dfactor));
    glad_glBlendFunc(sfactor, dfactor);
}

void APIENTRY glLogicOp(GLenum opcode)
{
    printf("glLogicOp(" "%s)\n", E2S(opcode));
    glad_glLogicOp(opcode);
}

void APIENTRY glStencilFunc(GLenum func, GLint ref, GLuint mask)
{
    printf("glStencilFunc(" "%s, %i, %u)\n", E2S(func), ref, mask);
    glad_glStencilFunc(func, ref, mask);
}

void APIENTRY glStencilOp(GLenum fail, GLenum zfail, GLenum zpass)
{
    printf("glStencilOp(" "%s, %s, %s)\n", E2S(fail), E2S(zfail), E2S(zpass));
    glad_glStencilOp(fail, zfail, zpass);
}

void APIENTRY glDepthFunc(GLenum func)
{
    printf("glDepthFunc(" "%s)\n", E2S(func));
    glad_glDepthFunc(func);
}

void APIENTRY glPixelStoref(GLenum pname, GLfloat param)
{
    printf("glPixelStoref(" "%s, %f)\n", E2S(pname), param);
    glad_glPixelStoref(pname, param);
}

void APIENTRY glPixelStorei(GLenum pname, GLint param)
{
    printf("glPixelStorei(" "%s, %i)\n", E2S(pname), param);
    glad_glPixelStorei(pname, param);
}

void APIENTRY glReadBuffer(GLenum src)
{
    printf("glReadBuffer(" "%s)\n", E2S(src));
    glad_glReadBuffer(src);
}

void APIENTRY glReadPixels(GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, void* pixels)
{
    printf("glReadPixels(" "%i, %i, %i, %i, %s, %s, %p)\n", x, y, width, height, E2S(format), E2S(type), pixels);
    glad_glReadPixels(x, y, width, height, format, type, pixels);
}

void APIENTRY glGetBooleanv(GLenum pname, GLboolean* data)
{
    printf("glGetBooleanv(" "%s, %p)\n", E2S(pname), data);
    glad_glGetBooleanv(pname, data);
}

void APIENTRY glGetDoublev(GLenum pname, GLdouble* data)
{
    printf("glGetDoublev(" "%s, %p)\n", E2S(pname), data);
    glad_glGetDoublev(pname, data);
}

GLenum APIENTRY glGetError()
{
    printf("glGetError()\n");
    GLenum const r = glad_glGetError();
    return r;
}

void APIENTRY glGetFloatv(GLenum pname, GLfloat* data)
{
    printf("glGetFloatv(" "%s, %p)\n", E2S(pname), data);
    glad_glGetFloatv(pname, data);
}

void APIENTRY glGetIntegerv(GLenum pname, GLint* data)
{
    printf("glGetIntegerv(" "%s, %p)\n", E2S(pname), data);
    glad_glGetIntegerv(pname, data);
}

const GLubyte* APIENTRY glGetString(GLenum name)
{
    printf("glGetString(" "%s)\n", E2S(name));
    const GLubyte* const r = glad_glGetString(name);
    return r;
}

void APIENTRY glGetTexImage(GLenum target, GLint level, GLenum format, GLenum type, void* pixels)
{
    printf("glGetTexImage(" "%s, %i, %s, %s, %p)\n", E2S(target), level, E2S(format), E2S(type), pixels);
    glad_glGetTexImage(target, level, format, type, pixels);
}

void APIENTRY glGetTexParameterfv(GLenum target, GLenum pname, GLfloat* params)
{
    printf("glGetTexParameterfv(" "%s, %s, %p)\n", E2S(target), E2S(pname), params);
    glad_glGetTexParameterfv(target, pname, params);
}

void APIENTRY glGetTexParameteriv(GLenum target, GLenum pname, GLint* params)
{
    printf("glGetTexParameteriv(" "%s, %s, %p)\n", E2S(target), E2S(pname), params);
    glad_glGetTexParameteriv(target, pname, params);
}

void APIENTRY glGetTexLevelParameterfv(GLenum target, GLint level, GLenum pname, GLfloat* params)
{
    printf("glGetTexLevelParameterfv(" "%s, %i, %s, %p)\n", E2S(target), level, E2S(pname), params);
    glad_glGetTexLevelParameterfv(target, level, pname, params);
}

void APIENTRY glGetTexLevelParameteriv(GLenum target, GLint level, GLenum pname, GLint* params)
{
    printf("glGetTexLevelParameteriv(" "%s, %i, %s, %p)\n", E2S(target), level, E2S(pname), params);
    glad_glGetTexLevelParameteriv(target, level, pname, params);
}

GLboolean APIENTRY glIsEnabled(GLenum cap)
{
    printf("glIsEnabled(" "%s)\n", E2S(cap));
    GLboolean const r = glad_glIsEnabled(cap);
    return r;
}

void APIENTRY glDepthRange(GLdouble n, GLdouble f)
{
    printf("glDepthRange(" "%f, %f)\n", n, f);
    glad_glDepthRange(n, f);
}

void APIENTRY glViewport(GLint x, GLint y, GLsizei width, GLsizei height)
{
    printf("glViewport(" "%i, %i, %i, %i)\n", x, y, width, height);
    glad_glViewport(x, y, width, height);
}

void APIENTRY glDrawArrays(GLenum mode, GLint first, GLsizei count)
{
    printf("glDrawArrays(" "%s, %i, %i)\n", E2S(mode), first, count);
    glad_glDrawArrays(mode, first, count);
}

void APIENTRY glDrawElements(GLenum mode, GLsizei count, GLenum type, const void* indices)
{
    printf("glDrawElements(" "%s, %i, %s, %p)\n", E2S(mode), count, E2S(type), indices);
    glad_glDrawElements(mode, count, type, indices);
}

void APIENTRY glGetPointerv(GLenum pname, void** params)
{
    printf("glGetPointerv(" "%s, %p)\n", E2S(pname), params);
    glad_glGetPointerv(pname, params);
}

void APIENTRY glPolygonOffset(GLfloat factor, GLfloat units)
{
    printf("glPolygonOffset(" "%f, %f)\n", factor, units);
    glad_glPolygonOffset(factor, units);
}

void APIENTRY glCopyTexImage1D(GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLint border)
{
    printf("glCopyTexImage1D(" "%s, %i, %s, %i, %i, %i, %i)\n", E2S(target), level, E2S(internalformat), x, y, width, border);
    glad_glCopyTexImage1D(target, level, internalformat, x, y, width, border);
}

void APIENTRY glCopyTexImage2D(GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border)
{
    printf("glCopyTexImage2D(" "%s, %i, %s, %i, %i, %i, %i, %i)\n", E2S(target), level, E2S(internalformat), x, y, width, height, border);
    glad_glCopyTexImage2D(target, level, internalformat, x, y, width, height, border);
}

void APIENTRY glCopyTexSubImage1D(GLenum target, GLint level, GLint xoffset, GLint x, GLint y, GLsizei width)
{
    printf("glCopyTexSubImage1D(" "%s, %i, %i, %i, %i, %i)\n", E2S(target), level, xoffset, x, y, width);
    glad_glCopyTexSubImage1D(target, level, xoffset, x, y, width);
}

void APIENTRY glCopyTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height)
{
    printf("glCopyTexSubImage2D(" "%s, %i, %i, %i, %i, %i, %i, %i)\n", E2S(target), level, xoffset, yoffset, x, y, width, height);
    glad_glCopyTexSubImage2D(target, level, xoffset, yoffset, x, y, width, height);
}

void APIENTRY glTexSubImage1D(GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum type, const void* pixels)
{
    printf("glTexSubImage1D(" "%s, %i, %i, %i, %s, %s, %p)\n", E2S(target), level, xoffset, width, E2S(format), E2S(type), pixels);
    glad_glTexSubImage1D(target, level, xoffset, width, format, type, pixels);
}

void APIENTRY glTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const void* pixels)
{
    printf("glTexSubImage2D(" "%s, %i, %i, %i, %i, %i, %s, %s, %p)\n", E2S(target), level, xoffset, yoffset, width, height, E2S(format), E2S(type), pixels);
    glad_glTexSubImage2D(target, level, xoffset, yoffset, width, height, format, type, pixels);
}

void APIENTRY glBindTexture(GLenum target, GLuint texture)
{
    printf("glBindTexture(" "%s, %u)\n", E2S(target), texture);
    glad_glBindTexture(target, texture);
}

void APIENTRY glDeleteTextures(GLsizei n, const GLuint* textures)
{
    printf("glDeleteTextures(" "%i, %p)\n", n, textures);
    glad_glDeleteTextures(n, textures);
}

void APIENTRY glGenTextures(GLsizei n, GLuint* textures)
{
    printf("glGenTextures(" "%i, %p)\n", n, textures);
    glad_glGenTextures(n, textures);
}

GLboolean APIENTRY glIsTexture(GLuint texture)
{
    printf("glIsTexture(" "%u)\n", texture);
    GLboolean const r = glad_glIsTexture(texture);
    return r;
}

void APIENTRY glDrawRangeElements(GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum type, const void* indices)
{
    printf("glDrawRangeElements(" "%s, %u, %u, %i, %s, %p)\n", E2S(mode), start, end, count, E2S(type), indices);
    glad_glDrawRangeElements(mode, start, end, count, type, indices);
}

void APIENTRY glTexImage3D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum type, const void* pixels)
{
    printf("glTexImage3D(" "%s, %i, %i, %i, %i, %i, %i, %s, %s, %p)\n", E2S(target), level, internalformat, width, height, depth, border, E2S(format), E2S(type), pixels);
    glad_glTexImage3D(target, level, internalformat, width, height, depth, border, format, type, pixels);
}

void APIENTRY glTexSubImage3D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const void* pixels)
{
    printf("glTexSubImage3D(" "%s, %i, %i, %i, %i, %i, %i, %i, %s, %s, %p)\n", E2S(target), level, xoffset, yoffset, zoffset, width, height, depth, E2S(format), E2S(type), pixels);
    glad_glTexSubImage3D(target, level, xoffset, yoffset, zoffset, width, height, depth, format, type, pixels);
}

void APIENTRY glCopyTexSubImage3D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLint x, GLint y, GLsizei width, GLsizei height)
{
    printf("glCopyTexSubImage3D(" "%s, %i, %i, %i, %i, %i, %i, %i, %i)\n", E2S(target), level, xoffset, yoffset, zoffset, x, y, width, height);
    glad_glCopyTexSubImage3D(target, level, xoffset, yoffset, zoffset, x, y, width, height);
}

void APIENTRY glActiveTexture(GLenum texture)
{
    printf("glActiveTexture(" "%s)\n", E2S(texture));
    glad_glActiveTexture(texture);
}

void APIENTRY glSampleCoverage(GLfloat value, GLboolean invert)
{
    printf("glSampleCoverage(" "%f, %u)\n", value, (unsigned int)(invert));
    glad_glSampleCoverage(value, invert);
}

void APIENTRY glCompressedTexImage3D(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLsizei imageSize, const void* data)
{
    printf("glCompressedTexImage3D(" "%s, %i, %s, %i, %i, %i, %i, %i, %p)\n", E2S(target), level, E2S(internalformat), width, height, depth, border, imageSize, data);
    glad_glCompressedTexImage3D(target, level, internalformat, width, height, depth, border, imageSize, data);
}

void APIENTRY glCompressedTexImage2D(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, const void* data)
{
    printf("glCompressedTexImage2D(" "%s, %i, %s, %i, %i, %i, %i, %p)\n", E2S(target), level, E2S(internalformat), width, height, border, imageSize, data);
    glad_glCompressedTexImage2D(target, level, internalformat, width, height, border, imageSize, data);
}

void APIENTRY glCompressedTexImage1D(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLint border, GLsizei imageSize, const void* data)
{
    printf("glCompressedTexImage1D(" "%s, %i, %s, %i, %i, %i, %p)\n", E2S(target), level, E2S(internalformat), width, border, imageSize, data);
    glad_glCompressedTexImage1D(target, level, internalformat, width, border, imageSize, data);
}

void APIENTRY glCompressedTexSubImage3D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLsizei imageSize, const void* data)
{
    printf("glCompressedTexSubImage3D(" "%s, %i, %i, %i, %i, %i, %i, %i, %s, %i, %p)\n", E2S(target), level, xoffset, yoffset, zoffset, width, height, depth, E2S(format), imageSize, data);
    glad_glCompressedTexSubImage3D(target, level, xoffset, yoffset, zoffset, width, height, depth, format, imageSize, data);
}

void APIENTRY glCompressedTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, const void* data)
{
    printf("glCompressedTexSubImage2D(" "%s, %i, %i, %i, %i, %i, %s, %i, %p)\n", E2S(target), level, xoffset, yoffset, width, height, E2S(format), imageSize, data);
    glad_glCompressedTexSubImage2D(target, level, xoffset, yoffset, width, height, format, imageSize, data);
}

void APIENTRY glCompressedTexSubImage1D(GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLsizei imageSize, const void* data)
{
    printf("glCompressedTexSubImage1D(" "%s, %i, %i, %i, %s, %i, %p)\n", E2S(target), level, xoffset, width, E2S(format), imageSize, data);
    glad_glCompressedTexSubImage1D(target, level, xoffset, width, format, imageSize, data);
}

void APIENTRY glGetCompressedTexImage(GLenum target, GLint level, void* img)
{
    printf("glGetCompressedTexImage(" "%s, %i, %p)\n", E2S(target), level, img);
    glad_glGetCompressedTexImage(target, level, img);
}

void APIENTRY glBlendFuncSeparate(GLenum sfactorRGB, GLenum dfactorRGB, GLenum sfactorAlpha, GLenum dfactorAlpha)
{
    printf("glBlendFuncSeparate(" "%s, %s, %s, %s)\n", E2S(sfactorRGB), E2S(dfactorRGB), E2S(sfactorAlpha), E2S(dfactorAlpha));
    glad_glBlendFuncSeparate(sfactorRGB, dfactorRGB, sfactorAlpha, dfactorAlpha);
}

void APIENTRY glMultiDrawArrays(GLenum mode, const GLint* first, const GLsizei* count, GLsizei drawcount)
{
    printf("glMultiDrawArrays(" "%s, %p, %p, %i)\n", E2S(mode), first, count, drawcount);
    glad_glMultiDrawArrays(mode, first, count, drawcount);
}

void APIENTRY glMultiDrawElements(GLenum mode, const GLsizei* count, GLenum type, const void* const* indices, GLsizei drawcount)
{
    printf("glMultiDrawElements(" "%s, %p, %s, %p, %i)\n", E2S(mode), count, E2S(type), indices, drawcount);
    glad_glMultiDrawElements(mode, count, type, indices, drawcount);
}

void APIENTRY glPointParameterf(GLenum pname, GLfloat param)
{
    printf("glPointParameterf(" "%s, %f)\n", E2S(pname), param);
    glad_glPointParameterf(pname, param);
}

void APIENTRY glPointParameterfv(GLenum pname, const GLfloat* params)
{
    printf("glPointParameterfv(" "%s, %p)\n", E2S(pname), params);
    glad_glPointParameterfv(pname, params);
}

void APIENTRY glPointParameteri(GLenum pname, GLint param)
{
    printf("glPointParameteri(" "%s, %i)\n", E2S(pname), param);
    glad_glPointParameteri(pname, param);
}

void APIENTRY glPointParameteriv(GLenum pname, const GLint* params)
{
    printf("glPointParameteriv(" "%s, %p)\n", E2S(pname), params);
    glad_glPointParameteriv(pname, params);
}

void APIENTRY glBlendColor(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha)
{
    printf("glBlendColor(" "%f, %f, %f, %f)\n", red, green, blue, alpha);
    glad_glBlendColor(red, green, blue, alpha);
}

void APIENTRY glBlendEquation(GLenum mode)
{
    printf("glBlendEquation(" "%s)\n", E2S(mode));
    glad_glBlendEquation(mode);
}

void APIENTRY glGenQueries(GLsizei n, GLuint* ids)
{
    printf("glGenQueries(" "%i, %p)\n", n, ids);
    glad_glGenQueries(n, ids);
}

void APIENTRY glDeleteQueries(GLsizei n, const GLuint* ids)
{
    printf("glDeleteQueries(" "%i, %p)\n", n, ids);
    glad_glDeleteQueries(n, ids);
}

GLboolean APIENTRY glIsQuery(GLuint id)
{
    printf("glIsQuery(" "%u)\n", id);
    GLboolean const r = glad_glIsQuery(id);
    return r;
}

void APIENTRY glBeginQuery(GLenum target, GLuint id)
{
    printf("glBeginQuery(" "%s, %u)\n", E2S(target), id);
    glad_glBeginQuery(target, id);
}

void APIENTRY glEndQuery(GLenum target)
{
    printf("glEndQuery(" "%s)\n", E2S(target));
    glad_glEndQuery(target);
}

void APIENTRY glGetQueryiv(GLenum target, GLenum pname, GLint* params)
{
    printf("glGetQueryiv(" "%s, %s, %p)\n", E2S(target), E2S(pname), params);
    glad_glGetQueryiv(target, pname, params);
}

void APIENTRY glGetQueryObjectiv(GLuint id, GLenum pname, GLint* params)
{
    printf("glGetQueryObjectiv(" "%u, %s, %p)\n", id, E2S(pname), params);
    glad_glGetQueryObjectiv(id, pname, params);
}

void APIENTRY glGetQueryObjectuiv(GLuint id, GLenum pname, GLuint* params)
{
    printf("glGetQueryObjectuiv(" "%u, %s, %p)\n", id, E2S(pname), params);
    glad_glGetQueryObjectuiv(id, pname, params);
}

void APIENTRY glBindBuffer(GLenum target, GLuint buffer)
{
    printf("glBindBuffer(" "%s, %u)\n", E2S(target), buffer);
    glad_glBindBuffer(target, buffer);
}

void APIENTRY glDeleteBuffers(GLsizei n, const GLuint* buffers)
{
    printf("glDeleteBuffers(" "%i, %p)\n", n, buffers);
    glad_glDeleteBuffers(n, buffers);
}

void APIENTRY glGenBuffers(GLsizei n, GLuint* buffers)
{
    printf("glGenBuffers(" "%i, %p)\n", n, buffers);
    glad_glGenBuffers(n, buffers);
}

GLboolean APIENTRY glIsBuffer(GLuint buffer)
{
    printf("glIsBuffer(" "%u)\n", buffer);
    GLboolean const r = glad_glIsBuffer(buffer);
    return r;
}

void APIENTRY glBufferData(GLenum target, GLsizeiptr size, const void* data, GLenum usage)
{
    printf("glBufferData(" "%s, %" PRId32", %p, %s)\n", E2S(target), size, data, E2S(usage));
    glad_glBufferData(target, size, data, usage);
}

void APIENTRY glBufferSubData(GLenum target, GLintptr offset, GLsizeiptr size, const void* data)
{
    printf("glBufferSubData(" "%s, %" PRId32", %" PRId32", %p)\n", E2S(target), offset, size, data);
    glad_glBufferSubData(target, offset, size, data);
}

void APIENTRY glGetBufferSubData(GLenum target, GLintptr offset, GLsizeiptr size, void* data)
{
    printf("glGetBufferSubData(" "%s, %" PRId32", %" PRId32", %p)\n", E2S(target), offset, size, data);
    glad_glGetBufferSubData(target, offset, size, data);
}

void* APIENTRY glMapBuffer(GLenum target, GLenum access)
{
    printf("glMapBuffer(" "%s, %s)\n", E2S(target), E2S(access));
    void* const r = glad_glMapBuffer(target, access);
    return r;
}

GLboolean APIENTRY glUnmapBuffer(GLenum target)
{
    printf("glUnmapBuffer(" "%s)\n", E2S(target));
    GLboolean const r = glad_glUnmapBuffer(target);
    return r;
}

void APIENTRY glGetBufferParameteriv(GLenum target, GLenum pname, GLint* params)
{
    printf("glGetBufferParameteriv(" "%s, %s, %p)\n", E2S(target), E2S(pname), params);
    glad_glGetBufferParameteriv(target, pname, params);
}

void APIENTRY glGetBufferPointerv(GLenum target, GLenum pname, void** params)
{
    printf("glGetBufferPointerv(" "%s, %s, %p)\n", E2S(target), E2S(pname), params);
    glad_glGetBufferPointerv(target, pname, params);
}

void APIENTRY glBlendEquationSeparate(GLenum modeRGB, GLenum modeAlpha)
{
    printf("glBlendEquationSeparate(" "%s, %s)\n", E2S(modeRGB), E2S(modeAlpha));
    glad_glBlendEquationSeparate(modeRGB, modeAlpha);
}

void APIENTRY glDrawBuffers(GLsizei n, const GLenum* bufs)
{
    printf("glDrawBuffers(" "%i, %p)\n", n, bufs);
    glad_glDrawBuffers(n, bufs);
}

void APIENTRY glStencilOpSeparate(GLenum face, GLenum sfail, GLenum dpfail, GLenum dppass)
{
    printf("glStencilOpSeparate(" "%s, %s, %s, %s)\n", E2S(face), E2S(sfail), E2S(dpfail), E2S(dppass));
    glad_glStencilOpSeparate(face, sfail, dpfail, dppass);
}

void APIENTRY glStencilFuncSeparate(GLenum face, GLenum func, GLint ref, GLuint mask)
{
    printf("glStencilFuncSeparate(" "%s, %s, %i, %u)\n", E2S(face), E2S(func), ref, mask);
    glad_glStencilFuncSeparate(face, func, ref, mask);
}

void APIENTRY glStencilMaskSeparate(GLenum face, GLuint mask)
{
    printf("glStencilMaskSeparate(" "%s, %u)\n", E2S(face), mask);
    glad_glStencilMaskSeparate(face, mask);
}

void APIENTRY glAttachShader(GLuint program, GLuint shader)
{
    printf("glAttachShader(" "%u, %u)\n", program, shader);
    glad_glAttachShader(program, shader);
}

void APIENTRY glBindAttribLocation(GLuint program, GLuint index, const GLchar* name)
{
    printf("glBindAttribLocation(" "%u, %u, %p)\n", program, index, name);
    glad_glBindAttribLocation(program, index, name);
}

void APIENTRY glCompileShader(GLuint shader)
{
    printf("glCompileShader(" "%u)\n", shader);
    glad_glCompileShader(shader);
}

GLuint APIENTRY glCreateProgram()
{
    printf("glCreateProgram()\n");
    GLuint const r = glad_glCreateProgram();
    return r;
}

GLuint APIENTRY glCreateShader(GLenum type)
{
    printf("glCreateShader(" "%s)\n", E2S(type));
    GLuint const r = glad_glCreateShader(type);
    return r;
}

void APIENTRY glDeleteProgram(GLuint program)
{
    printf("glDeleteProgram(" "%u)\n", program);
    glad_glDeleteProgram(program);
}

void APIENTRY glDeleteShader(GLuint shader)
{
    printf("glDeleteShader(" "%u)\n", shader);
    glad_glDeleteShader(shader);
}

void APIENTRY glDetachShader(GLuint program, GLuint shader)
{
    printf("glDetachShader(" "%u, %u)\n", program, shader);
    glad_glDetachShader(program, shader);
}

void APIENTRY glDisableVertexAttribArray(GLuint index)
{
    printf("glDisableVertexAttribArray(" "%u)\n", index);
    glad_glDisableVertexAttribArray(index);
}

void APIENTRY glEnableVertexAttribArray(GLuint index)
{
    printf("glEnableVertexAttribArray(" "%u)\n", index);
    glad_glEnableVertexAttribArray(index);
}

void APIENTRY glGetActiveAttrib(GLuint program, GLuint index, GLsizei bufSize, GLsizei* length, GLint* size, GLenum* type, GLchar* name)
{
    printf("glGetActiveAttrib(" "%u, %u, %i, %p, %p, %p, %p)\n", program, index, bufSize, length, size, type, name);
    glad_glGetActiveAttrib(program, index, bufSize, length, size, type, name);
}

void APIENTRY glGetActiveUniform(GLuint program, GLuint index, GLsizei bufSize, GLsizei* length, GLint* size, GLenum* type, GLchar* name)
{
    printf("glGetActiveUniform(" "%u, %u, %i, %p, %p, %p, %p)\n", program, index, bufSize, length, size, type, name);
    glad_glGetActiveUniform(program, index, bufSize, length, size, type, name);
}

void APIENTRY glGetAttachedShaders(GLuint program, GLsizei maxCount, GLsizei* count, GLuint* shaders)
{
    printf("glGetAttachedShaders(" "%u, %i, %p, %p)\n", program, maxCount, count, shaders);
    glad_glGetAttachedShaders(program, maxCount, count, shaders);
}

GLint APIENTRY glGetAttribLocation(GLuint program, const GLchar* name)
{
    printf("glGetAttribLocation(" "%u, %p)\n", program, name);
    GLint const r = glad_glGetAttribLocation(program, name);
    return r;
}

void APIENTRY glGetProgramiv(GLuint program, GLenum pname, GLint* params)
{
    printf("glGetProgramiv(" "%u, %s, %p)\n", program, E2S(pname), params);
    glad_glGetProgramiv(program, pname, params);
}

void APIENTRY glGetProgramInfoLog(GLuint program, GLsizei bufSize, GLsizei* length, GLchar* infoLog)
{
    printf("glGetProgramInfoLog(" "%u, %i, %p, %p)\n", program, bufSize, length, infoLog);
    glad_glGetProgramInfoLog(program, bufSize, length, infoLog);
}

void APIENTRY glGetShaderiv(GLuint shader, GLenum pname, GLint* params)
{
    printf("glGetShaderiv(" "%u, %s, %p)\n", shader, E2S(pname), params);
    glad_glGetShaderiv(shader, pname, params);
}

void APIENTRY glGetShaderInfoLog(GLuint shader, GLsizei bufSize, GLsizei* length, GLchar* infoLog)
{
    printf("glGetShaderInfoLog(" "%u, %i, %p, %p)\n", shader, bufSize, length, infoLog);
    glad_glGetShaderInfoLog(shader, bufSize, length, infoLog);
}

void APIENTRY glGetShaderSource(GLuint shader, GLsizei bufSize, GLsizei* length, GLchar* source)
{
    printf("glGetShaderSource(" "%u, %i, %p, %p)\n", shader, bufSize, length, source);
    glad_glGetShaderSource(shader, bufSize, length, source);
}

GLint APIENTRY glGetUniformLocation(GLuint program, const GLchar* name)
{
    printf("glGetUniformLocation(" "%u, %p)\n", program, name);
    GLint const r = glad_glGetUniformLocation(program, name);
    return r;
}

void APIENTRY glGetUniformfv(GLuint program, GLint location, GLfloat* params)
{
    printf("glGetUniformfv(" "%u, %i, %p)\n", program, location, params);
    glad_glGetUniformfv(program, location, params);
}

void APIENTRY glGetUniformiv(GLuint program, GLint location, GLint* params)
{
    printf("glGetUniformiv(" "%u, %i, %p)\n", program, location, params);
    glad_glGetUniformiv(program, location, params);
}

void APIENTRY glGetVertexAttribdv(GLuint index, GLenum pname, GLdouble* params)
{
    printf("glGetVertexAttribdv(" "%u, %s, %p)\n", index, E2S(pname), params);
    glad_glGetVertexAttribdv(index, pname, params);
}

void APIENTRY glGetVertexAttribfv(GLuint index, GLenum pname, GLfloat* params)
{
    printf("glGetVertexAttribfv(" "%u, %s, %p)\n", index, E2S(pname), params);
    glad_glGetVertexAttribfv(index, pname, params);
}

void APIENTRY glGetVertexAttribiv(GLuint index, GLenum pname, GLint* params)
{
    printf("glGetVertexAttribiv(" "%u, %s, %p)\n", index, E2S(pname), params);
    glad_glGetVertexAttribiv(index, pname, params);
}

void APIENTRY glGetVertexAttribPointerv(GLuint index, GLenum pname, void** pointer)
{
    printf("glGetVertexAttribPointerv(" "%u, %s, %p)\n", index, E2S(pname), pointer);
    glad_glGetVertexAttribPointerv(index, pname, pointer);
}

GLboolean APIENTRY glIsProgram(GLuint program)
{
    printf("glIsProgram(" "%u)\n", program);
    GLboolean const r = glad_glIsProgram(program);
    return r;
}

GLboolean APIENTRY glIsShader(GLuint shader)
{
    printf("glIsShader(" "%u)\n", shader);
    GLboolean const r = glad_glIsShader(shader);
    return r;
}

void APIENTRY glLinkProgram(GLuint program)
{
    printf("glLinkProgram(" "%u)\n", program);
    glad_glLinkProgram(program);
}

void APIENTRY glShaderSource(GLuint shader, GLsizei count, const GLchar* const* string, const GLint* length)
{
    printf("glShaderSource(" "%u, %i, %p, %p)\n", shader, count, string, length);
    glad_glShaderSource(shader, count, string, length);
}

void APIENTRY glUseProgram(GLuint program)
{
    printf("glUseProgram(" "%u)\n", program);
    glad_glUseProgram(program);
}

void APIENTRY glUniform1f(GLint location, GLfloat v0)
{
    printf("glUniform1f(" "%i, %f)\n", location, v0);
    glad_glUniform1f(location, v0);
}

void APIENTRY glUniform2f(GLint location, GLfloat v0, GLfloat v1)
{
    printf("glUniform2f(" "%i, %f, %f)\n", location, v0, v1);
    glad_glUniform2f(location, v0, v1);
}

void APIENTRY glUniform3f(GLint location, GLfloat v0, GLfloat v1, GLfloat v2)
{
    printf("glUniform3f(" "%i, %f, %f, %f)\n", location, v0, v1, v2);
    glad_glUniform3f(location, v0, v1, v2);
}

void APIENTRY glUniform4f(GLint location, GLfloat v0, GLfloat v1, GLfloat v2, GLfloat v3)
{
    printf("glUniform4f(" "%i, %f, %f, %f, %f)\n", location, v0, v1, v2, v3);
    glad_glUniform4f(location, v0, v1, v2, v3);
}

void APIENTRY glUniform1i(GLint location, GLint v0)
{
    printf("glUniform1i(" "%i, %i)\n", location, v0);
    glad_glUniform1i(location, v0);
}

void APIENTRY glUniform2i(GLint location, GLint v0, GLint v1)
{
    printf("glUniform2i(" "%i, %i, %i)\n", location, v0, v1);
    glad_glUniform2i(location, v0, v1);
}

void APIENTRY glUniform3i(GLint location, GLint v0, GLint v1, GLint v2)
{
    printf("glUniform3i(" "%i, %i, %i, %i)\n", location, v0, v1, v2);
    glad_glUniform3i(location, v0, v1, v2);
}

void APIENTRY glUniform4i(GLint location, GLint v0, GLint v1, GLint v2, GLint v3)
{
    printf("glUniform4i(" "%i, %i, %i, %i, %i)\n", location, v0, v1, v2, v3);
    glad_glUniform4i(location, v0, v1, v2, v3);
}

void APIENTRY glUniform1fv(GLint location, GLsizei count, const GLfloat* value)
{
    printf("glUniform1fv(" "%i, %i, %p)\n", location, count, value);
    glad_glUniform1fv(location, count, value);
}

void APIENTRY glUniform2fv(GLint location, GLsizei count, const GLfloat* value)
{
    printf("glUniform2fv(" "%i, %i, %p)\n", location, count, value);
    glad_glUniform2fv(location, count, value);
}

void APIENTRY glUniform3fv(GLint location, GLsizei count, const GLfloat* value)
{
    printf("glUniform3fv(" "%i, %i, %p)\n", location, count, value);
    glad_glUniform3fv(location, count, value);
}

void APIENTRY glUniform4fv(GLint location, GLsizei count, const GLfloat* value)
{
    printf("glUniform4fv(" "%i, %i, %p)\n", location, count, value);
    glad_glUniform4fv(location, count, value);
}

void APIENTRY glUniform1iv(GLint location, GLsizei count, const GLint* value)
{
    printf("glUniform1iv(" "%i, %i, %p)\n", location, count, value);
    glad_glUniform1iv(location, count, value);
}

void APIENTRY glUniform2iv(GLint location, GLsizei count, const GLint* value)
{
    printf("glUniform2iv(" "%i, %i, %p)\n", location, count, value);
    glad_glUniform2iv(location, count, value);
}

void APIENTRY glUniform3iv(GLint location, GLsizei count, const GLint* value)
{
    printf("glUniform3iv(" "%i, %i, %p)\n", location, count, value);
    glad_glUniform3iv(location, count, value);
}

void APIENTRY glUniform4iv(GLint location, GLsizei count, const GLint* value)
{
    printf("glUniform4iv(" "%i, %i, %p)\n", location, count, value);
    glad_glUniform4iv(location, count, value);
}

void APIENTRY glUniformMatrix2fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    printf("glUniformMatrix2fv(" "%i, %i, %u, %p)\n", location, count, (unsigned int)(transpose), value);
    glad_glUniformMatrix2fv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix3fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    printf("glUniformMatrix3fv(" "%i, %i, %u, %p)\n", location, count, (unsigned int)(transpose), value);
    glad_glUniformMatrix3fv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix4fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    printf("glUniformMatrix4fv(" "%i, %i, %u, %p)\n", location, count, (unsigned int)(transpose), value);
    glad_glUniformMatrix4fv(location, count, transpose, value);
}

void APIENTRY glValidateProgram(GLuint program)
{
    printf("glValidateProgram(" "%u)\n", program);
    glad_glValidateProgram(program);
}

void APIENTRY glVertexAttrib1d(GLuint index, GLdouble x)
{
    printf("glVertexAttrib1d(" "%u, %f)\n", index, x);
    glad_glVertexAttrib1d(index, x);
}

void APIENTRY glVertexAttrib1dv(GLuint index, const GLdouble* v)
{
    printf("glVertexAttrib1dv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib1dv(index, v);
}

void APIENTRY glVertexAttrib1f(GLuint index, GLfloat x)
{
    printf("glVertexAttrib1f(" "%u, %f)\n", index, x);
    glad_glVertexAttrib1f(index, x);
}

void APIENTRY glVertexAttrib1fv(GLuint index, const GLfloat* v)
{
    printf("glVertexAttrib1fv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib1fv(index, v);
}

void APIENTRY glVertexAttrib1s(GLuint index, GLshort x)
{
    printf("glVertexAttrib1s(" "%u, %p)\n", index, x);
    glad_glVertexAttrib1s(index, x);
}

void APIENTRY glVertexAttrib1sv(GLuint index, const GLshort* v)
{
    printf("glVertexAttrib1sv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib1sv(index, v);
}

void APIENTRY glVertexAttrib2d(GLuint index, GLdouble x, GLdouble y)
{
    printf("glVertexAttrib2d(" "%u, %f, %f)\n", index, x, y);
    glad_glVertexAttrib2d(index, x, y);
}

void APIENTRY glVertexAttrib2dv(GLuint index, const GLdouble* v)
{
    printf("glVertexAttrib2dv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib2dv(index, v);
}

void APIENTRY glVertexAttrib2f(GLuint index, GLfloat x, GLfloat y)
{
    printf("glVertexAttrib2f(" "%u, %f, %f)\n", index, x, y);
    glad_glVertexAttrib2f(index, x, y);
}

void APIENTRY glVertexAttrib2fv(GLuint index, const GLfloat* v)
{
    printf("glVertexAttrib2fv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib2fv(index, v);
}

void APIENTRY glVertexAttrib2s(GLuint index, GLshort x, GLshort y)
{
    printf("glVertexAttrib2s(" "%u, %p, %p)\n", index, x, y);
    glad_glVertexAttrib2s(index, x, y);
}

void APIENTRY glVertexAttrib2sv(GLuint index, const GLshort* v)
{
    printf("glVertexAttrib2sv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib2sv(index, v);
}

void APIENTRY glVertexAttrib3d(GLuint index, GLdouble x, GLdouble y, GLdouble z)
{
    printf("glVertexAttrib3d(" "%u, %f, %f, %f)\n", index, x, y, z);
    glad_glVertexAttrib3d(index, x, y, z);
}

void APIENTRY glVertexAttrib3dv(GLuint index, const GLdouble* v)
{
    printf("glVertexAttrib3dv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib3dv(index, v);
}

void APIENTRY glVertexAttrib3f(GLuint index, GLfloat x, GLfloat y, GLfloat z)
{
    printf("glVertexAttrib3f(" "%u, %f, %f, %f)\n", index, x, y, z);
    glad_glVertexAttrib3f(index, x, y, z);
}

void APIENTRY glVertexAttrib3fv(GLuint index, const GLfloat* v)
{
    printf("glVertexAttrib3fv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib3fv(index, v);
}

void APIENTRY glVertexAttrib3s(GLuint index, GLshort x, GLshort y, GLshort z)
{
    printf("glVertexAttrib3s(" "%u, %p, %p, %p)\n", index, x, y, z);
    glad_glVertexAttrib3s(index, x, y, z);
}

void APIENTRY glVertexAttrib3sv(GLuint index, const GLshort* v)
{
    printf("glVertexAttrib3sv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib3sv(index, v);
}

void APIENTRY glVertexAttrib4Nbv(GLuint index, const GLbyte* v)
{
    printf("glVertexAttrib4Nbv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib4Nbv(index, v);
}

void APIENTRY glVertexAttrib4Niv(GLuint index, const GLint* v)
{
    printf("glVertexAttrib4Niv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib4Niv(index, v);
}

void APIENTRY glVertexAttrib4Nsv(GLuint index, const GLshort* v)
{
    printf("glVertexAttrib4Nsv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib4Nsv(index, v);
}

void APIENTRY glVertexAttrib4Nub(GLuint index, GLubyte x, GLubyte y, GLubyte z, GLubyte w)
{
    printf("glVertexAttrib4Nub(" "%u, %p, %p, %p, %p)\n", index, x, y, z, w);
    glad_glVertexAttrib4Nub(index, x, y, z, w);
}

void APIENTRY glVertexAttrib4Nubv(GLuint index, const GLubyte* v)
{
    printf("glVertexAttrib4Nubv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib4Nubv(index, v);
}

void APIENTRY glVertexAttrib4Nuiv(GLuint index, const GLuint* v)
{
    printf("glVertexAttrib4Nuiv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib4Nuiv(index, v);
}

void APIENTRY glVertexAttrib4Nusv(GLuint index, const GLushort* v)
{
    printf("glVertexAttrib4Nusv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib4Nusv(index, v);
}

void APIENTRY glVertexAttrib4bv(GLuint index, const GLbyte* v)
{
    printf("glVertexAttrib4bv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib4bv(index, v);
}

void APIENTRY glVertexAttrib4d(GLuint index, GLdouble x, GLdouble y, GLdouble z, GLdouble w)
{
    printf("glVertexAttrib4d(" "%u, %f, %f, %f, %f)\n", index, x, y, z, w);
    glad_glVertexAttrib4d(index, x, y, z, w);
}

void APIENTRY glVertexAttrib4dv(GLuint index, const GLdouble* v)
{
    printf("glVertexAttrib4dv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib4dv(index, v);
}

void APIENTRY glVertexAttrib4f(GLuint index, GLfloat x, GLfloat y, GLfloat z, GLfloat w)
{
    printf("glVertexAttrib4f(" "%u, %f, %f, %f, %f)\n", index, x, y, z, w);
    glad_glVertexAttrib4f(index, x, y, z, w);
}

void APIENTRY glVertexAttrib4fv(GLuint index, const GLfloat* v)
{
    printf("glVertexAttrib4fv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib4fv(index, v);
}

void APIENTRY glVertexAttrib4iv(GLuint index, const GLint* v)
{
    printf("glVertexAttrib4iv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib4iv(index, v);
}

void APIENTRY glVertexAttrib4s(GLuint index, GLshort x, GLshort y, GLshort z, GLshort w)
{
    printf("glVertexAttrib4s(" "%u, %p, %p, %p, %p)\n", index, x, y, z, w);
    glad_glVertexAttrib4s(index, x, y, z, w);
}

void APIENTRY glVertexAttrib4sv(GLuint index, const GLshort* v)
{
    printf("glVertexAttrib4sv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib4sv(index, v);
}

void APIENTRY glVertexAttrib4ubv(GLuint index, const GLubyte* v)
{
    printf("glVertexAttrib4ubv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib4ubv(index, v);
}

void APIENTRY glVertexAttrib4uiv(GLuint index, const GLuint* v)
{
    printf("glVertexAttrib4uiv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib4uiv(index, v);
}

void APIENTRY glVertexAttrib4usv(GLuint index, const GLushort* v)
{
    printf("glVertexAttrib4usv(" "%u, %p)\n", index, v);
    glad_glVertexAttrib4usv(index, v);
}

void APIENTRY glVertexAttribPointer(GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const void* pointer)
{
    printf("glVertexAttribPointer(" "%u, %i, %s, %u, %i, %p)\n", index, size, E2S(type), (unsigned int)(normalized), stride, pointer);
    glad_glVertexAttribPointer(index, size, type, normalized, stride, pointer);
}

void APIENTRY glUniformMatrix2x3fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    printf("glUniformMatrix2x3fv(" "%i, %i, %u, %p)\n", location, count, (unsigned int)(transpose), value);
    glad_glUniformMatrix2x3fv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix3x2fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    printf("glUniformMatrix3x2fv(" "%i, %i, %u, %p)\n", location, count, (unsigned int)(transpose), value);
    glad_glUniformMatrix3x2fv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix2x4fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    printf("glUniformMatrix2x4fv(" "%i, %i, %u, %p)\n", location, count, (unsigned int)(transpose), value);
    glad_glUniformMatrix2x4fv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix4x2fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    printf("glUniformMatrix4x2fv(" "%i, %i, %u, %p)\n", location, count, (unsigned int)(transpose), value);
    glad_glUniformMatrix4x2fv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix3x4fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    printf("glUniformMatrix3x4fv(" "%i, %i, %u, %p)\n", location, count, (unsigned int)(transpose), value);
    glad_glUniformMatrix3x4fv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix4x3fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    printf("glUniformMatrix4x3fv(" "%i, %i, %u, %p)\n", location, count, (unsigned int)(transpose), value);
    glad_glUniformMatrix4x3fv(location, count, transpose, value);
}

void APIENTRY glColorMaski(GLuint index, GLboolean r, GLboolean g, GLboolean b, GLboolean a)
{
    printf("glColorMaski(" "%u, %u, %u, %u, %u)\n", index, (unsigned int)(r), (unsigned int)(g), (unsigned int)(b), (unsigned int)(a));
    glad_glColorMaski(index, r, g, b, a);
}

void APIENTRY glGetBooleani_v(GLenum target, GLuint index, GLboolean* data)
{
    printf("glGetBooleani_v(" "%s, %u, %p)\n", E2S(target), index, data);
    glad_glGetBooleani_v(target, index, data);
}

void APIENTRY glGetIntegeri_v(GLenum target, GLuint index, GLint* data)
{
    printf("glGetIntegeri_v(" "%s, %u, %p)\n", E2S(target), index, data);
    glad_glGetIntegeri_v(target, index, data);
}

void APIENTRY glEnablei(GLenum target, GLuint index)
{
    printf("glEnablei(" "%s, %u)\n", E2S(target), index);
    glad_glEnablei(target, index);
}

void APIENTRY glDisablei(GLenum target, GLuint index)
{
    printf("glDisablei(" "%s, %u)\n", E2S(target), index);
    glad_glDisablei(target, index);
}

GLboolean APIENTRY glIsEnabledi(GLenum target, GLuint index)
{
    printf("glIsEnabledi(" "%s, %u)\n", E2S(target), index);
    GLboolean const r = glad_glIsEnabledi(target, index);
    return r;
}

void APIENTRY glBeginTransformFeedback(GLenum primitiveMode)
{
    printf("glBeginTransformFeedback(" "%s)\n", E2S(primitiveMode));
    glad_glBeginTransformFeedback(primitiveMode);
}

void APIENTRY glEndTransformFeedback()
{
    printf("glEndTransformFeedback()\n");
    glad_glEndTransformFeedback();
}

void APIENTRY glBindBufferRange(GLenum target, GLuint index, GLuint buffer, GLintptr offset, GLsizeiptr size)
{
    printf("glBindBufferRange(" "%s, %u, %u, %" PRId32", %" PRId32")\n", E2S(target), index, buffer, offset, size);
    glad_glBindBufferRange(target, index, buffer, offset, size);
}

void APIENTRY glBindBufferBase(GLenum target, GLuint index, GLuint buffer)
{
    printf("glBindBufferBase(" "%s, %u, %u)\n", E2S(target), index, buffer);
    glad_glBindBufferBase(target, index, buffer);
}

void APIENTRY glTransformFeedbackVaryings(GLuint program, GLsizei count, const GLchar* const* varyings, GLenum bufferMode)
{
    printf("glTransformFeedbackVaryings(" "%u, %i, %p, %s)\n", program, count, varyings, E2S(bufferMode));
    glad_glTransformFeedbackVaryings(program, count, varyings, bufferMode);
}

void APIENTRY glGetTransformFeedbackVarying(GLuint program, GLuint index, GLsizei bufSize, GLsizei* length, GLsizei* size, GLenum* type, GLchar* name)
{
    printf("glGetTransformFeedbackVarying(" "%u, %u, %i, %p, %p, %p, %p)\n", program, index, bufSize, length, size, type, name);
    glad_glGetTransformFeedbackVarying(program, index, bufSize, length, size, type, name);
}

void APIENTRY glClampColor(GLenum target, GLenum clamp)
{
    printf("glClampColor(" "%s, %s)\n", E2S(target), E2S(clamp));
    glad_glClampColor(target, clamp);
}

void APIENTRY glBeginConditionalRender(GLuint id, GLenum mode)
{
    printf("glBeginConditionalRender(" "%u, %s)\n", id, E2S(mode));
    glad_glBeginConditionalRender(id, mode);
}

void APIENTRY glEndConditionalRender()
{
    printf("glEndConditionalRender()\n");
    glad_glEndConditionalRender();
}

void APIENTRY glVertexAttribIPointer(GLuint index, GLint size, GLenum type, GLsizei stride, const void* pointer)
{
    printf("glVertexAttribIPointer(" "%u, %i, %s, %i, %p)\n", index, size, E2S(type), stride, pointer);
    glad_glVertexAttribIPointer(index, size, type, stride, pointer);
}

void APIENTRY glGetVertexAttribIiv(GLuint index, GLenum pname, GLint* params)
{
    printf("glGetVertexAttribIiv(" "%u, %s, %p)\n", index, E2S(pname), params);
    glad_glGetVertexAttribIiv(index, pname, params);
}

void APIENTRY glGetVertexAttribIuiv(GLuint index, GLenum pname, GLuint* params)
{
    printf("glGetVertexAttribIuiv(" "%u, %s, %p)\n", index, E2S(pname), params);
    glad_glGetVertexAttribIuiv(index, pname, params);
}

void APIENTRY glVertexAttribI1i(GLuint index, GLint x)
{
    printf("glVertexAttribI1i(" "%u, %i)\n", index, x);
    glad_glVertexAttribI1i(index, x);
}

void APIENTRY glVertexAttribI2i(GLuint index, GLint x, GLint y)
{
    printf("glVertexAttribI2i(" "%u, %i, %i)\n", index, x, y);
    glad_glVertexAttribI2i(index, x, y);
}

void APIENTRY glVertexAttribI3i(GLuint index, GLint x, GLint y, GLint z)
{
    printf("glVertexAttribI3i(" "%u, %i, %i, %i)\n", index, x, y, z);
    glad_glVertexAttribI3i(index, x, y, z);
}

void APIENTRY glVertexAttribI4i(GLuint index, GLint x, GLint y, GLint z, GLint w)
{
    printf("glVertexAttribI4i(" "%u, %i, %i, %i, %i)\n", index, x, y, z, w);
    glad_glVertexAttribI4i(index, x, y, z, w);
}

void APIENTRY glVertexAttribI1ui(GLuint index, GLuint x)
{
    printf("glVertexAttribI1ui(" "%u, %u)\n", index, x);
    glad_glVertexAttribI1ui(index, x);
}

void APIENTRY glVertexAttribI2ui(GLuint index, GLuint x, GLuint y)
{
    printf("glVertexAttribI2ui(" "%u, %u, %u)\n", index, x, y);
    glad_glVertexAttribI2ui(index, x, y);
}

void APIENTRY glVertexAttribI3ui(GLuint index, GLuint x, GLuint y, GLuint z)
{
    printf("glVertexAttribI3ui(" "%u, %u, %u, %u)\n", index, x, y, z);
    glad_glVertexAttribI3ui(index, x, y, z);
}

void APIENTRY glVertexAttribI4ui(GLuint index, GLuint x, GLuint y, GLuint z, GLuint w)
{
    printf("glVertexAttribI4ui(" "%u, %u, %u, %u, %u)\n", index, x, y, z, w);
    glad_glVertexAttribI4ui(index, x, y, z, w);
}

void APIENTRY glVertexAttribI1iv(GLuint index, const GLint* v)
{
    printf("glVertexAttribI1iv(" "%u, %p)\n", index, v);
    glad_glVertexAttribI1iv(index, v);
}

void APIENTRY glVertexAttribI2iv(GLuint index, const GLint* v)
{
    printf("glVertexAttribI2iv(" "%u, %p)\n", index, v);
    glad_glVertexAttribI2iv(index, v);
}

void APIENTRY glVertexAttribI3iv(GLuint index, const GLint* v)
{
    printf("glVertexAttribI3iv(" "%u, %p)\n", index, v);
    glad_glVertexAttribI3iv(index, v);
}

void APIENTRY glVertexAttribI4iv(GLuint index, const GLint* v)
{
    printf("glVertexAttribI4iv(" "%u, %p)\n", index, v);
    glad_glVertexAttribI4iv(index, v);
}

void APIENTRY glVertexAttribI1uiv(GLuint index, const GLuint* v)
{
    printf("glVertexAttribI1uiv(" "%u, %p)\n", index, v);
    glad_glVertexAttribI1uiv(index, v);
}

void APIENTRY glVertexAttribI2uiv(GLuint index, const GLuint* v)
{
    printf("glVertexAttribI2uiv(" "%u, %p)\n", index, v);
    glad_glVertexAttribI2uiv(index, v);
}

void APIENTRY glVertexAttribI3uiv(GLuint index, const GLuint* v)
{
    printf("glVertexAttribI3uiv(" "%u, %p)\n", index, v);
    glad_glVertexAttribI3uiv(index, v);
}

void APIENTRY glVertexAttribI4uiv(GLuint index, const GLuint* v)
{
    printf("glVertexAttribI4uiv(" "%u, %p)\n", index, v);
    glad_glVertexAttribI4uiv(index, v);
}

void APIENTRY glVertexAttribI4bv(GLuint index, const GLbyte* v)
{
    printf("glVertexAttribI4bv(" "%u, %p)\n", index, v);
    glad_glVertexAttribI4bv(index, v);
}

void APIENTRY glVertexAttribI4sv(GLuint index, const GLshort* v)
{
    printf("glVertexAttribI4sv(" "%u, %p)\n", index, v);
    glad_glVertexAttribI4sv(index, v);
}

void APIENTRY glVertexAttribI4ubv(GLuint index, const GLubyte* v)
{
    printf("glVertexAttribI4ubv(" "%u, %p)\n", index, v);
    glad_glVertexAttribI4ubv(index, v);
}

void APIENTRY glVertexAttribI4usv(GLuint index, const GLushort* v)
{
    printf("glVertexAttribI4usv(" "%u, %p)\n", index, v);
    glad_glVertexAttribI4usv(index, v);
}

void APIENTRY glGetUniformuiv(GLuint program, GLint location, GLuint* params)
{
    printf("glGetUniformuiv(" "%u, %i, %p)\n", program, location, params);
    glad_glGetUniformuiv(program, location, params);
}

void APIENTRY glBindFragDataLocation(GLuint program, GLuint color, const GLchar* name)
{
    printf("glBindFragDataLocation(" "%u, %u, %p)\n", program, color, name);
    glad_glBindFragDataLocation(program, color, name);
}

GLint APIENTRY glGetFragDataLocation(GLuint program, const GLchar* name)
{
    printf("glGetFragDataLocation(" "%u, %p)\n", program, name);
    GLint const r = glad_glGetFragDataLocation(program, name);
    return r;
}

void APIENTRY glUniform1ui(GLint location, GLuint v0)
{
    printf("glUniform1ui(" "%i, %u)\n", location, v0);
    glad_glUniform1ui(location, v0);
}

void APIENTRY glUniform2ui(GLint location, GLuint v0, GLuint v1)
{
    printf("glUniform2ui(" "%i, %u, %u)\n", location, v0, v1);
    glad_glUniform2ui(location, v0, v1);
}

void APIENTRY glUniform3ui(GLint location, GLuint v0, GLuint v1, GLuint v2)
{
    printf("glUniform3ui(" "%i, %u, %u, %u)\n", location, v0, v1, v2);
    glad_glUniform3ui(location, v0, v1, v2);
}

void APIENTRY glUniform4ui(GLint location, GLuint v0, GLuint v1, GLuint v2, GLuint v3)
{
    printf("glUniform4ui(" "%i, %u, %u, %u, %u)\n", location, v0, v1, v2, v3);
    glad_glUniform4ui(location, v0, v1, v2, v3);
}

void APIENTRY glUniform1uiv(GLint location, GLsizei count, const GLuint* value)
{
    printf("glUniform1uiv(" "%i, %i, %p)\n", location, count, value);
    glad_glUniform1uiv(location, count, value);
}

void APIENTRY glUniform2uiv(GLint location, GLsizei count, const GLuint* value)
{
    printf("glUniform2uiv(" "%i, %i, %p)\n", location, count, value);
    glad_glUniform2uiv(location, count, value);
}

void APIENTRY glUniform3uiv(GLint location, GLsizei count, const GLuint* value)
{
    printf("glUniform3uiv(" "%i, %i, %p)\n", location, count, value);
    glad_glUniform3uiv(location, count, value);
}

void APIENTRY glUniform4uiv(GLint location, GLsizei count, const GLuint* value)
{
    printf("glUniform4uiv(" "%i, %i, %p)\n", location, count, value);
    glad_glUniform4uiv(location, count, value);
}

void APIENTRY glTexParameterIiv(GLenum target, GLenum pname, const GLint* params)
{
    printf("glTexParameterIiv(" "%s, %s, %p)\n", E2S(target), E2S(pname), params);
    glad_glTexParameterIiv(target, pname, params);
}

void APIENTRY glTexParameterIuiv(GLenum target, GLenum pname, const GLuint* params)
{
    printf("glTexParameterIuiv(" "%s, %s, %p)\n", E2S(target), E2S(pname), params);
    glad_glTexParameterIuiv(target, pname, params);
}

void APIENTRY glGetTexParameterIiv(GLenum target, GLenum pname, GLint* params)
{
    printf("glGetTexParameterIiv(" "%s, %s, %p)\n", E2S(target), E2S(pname), params);
    glad_glGetTexParameterIiv(target, pname, params);
}

void APIENTRY glGetTexParameterIuiv(GLenum target, GLenum pname, GLuint* params)
{
    printf("glGetTexParameterIuiv(" "%s, %s, %p)\n", E2S(target), E2S(pname), params);
    glad_glGetTexParameterIuiv(target, pname, params);
}

void APIENTRY glClearBufferiv(GLenum buffer, GLint drawbuffer, const GLint* value)
{
    printf("glClearBufferiv(" "%s, %i, %p)\n", E2S(buffer), drawbuffer, value);
    glad_glClearBufferiv(buffer, drawbuffer, value);
}

void APIENTRY glClearBufferuiv(GLenum buffer, GLint drawbuffer, const GLuint* value)
{
    printf("glClearBufferuiv(" "%s, %i, %p)\n", E2S(buffer), drawbuffer, value);
    glad_glClearBufferuiv(buffer, drawbuffer, value);
}

void APIENTRY glClearBufferfv(GLenum buffer, GLint drawbuffer, const GLfloat* value)
{
    printf("glClearBufferfv(" "%s, %i, %p)\n", E2S(buffer), drawbuffer, value);
    glad_glClearBufferfv(buffer, drawbuffer, value);
}

void APIENTRY glClearBufferfi(GLenum buffer, GLint drawbuffer, GLfloat depth, GLint stencil)
{
    printf("glClearBufferfi(" "%s, %i, %f, %i)\n", E2S(buffer), drawbuffer, depth, stencil);
    glad_glClearBufferfi(buffer, drawbuffer, depth, stencil);
}

const GLubyte* APIENTRY glGetStringi(GLenum name, GLuint index)
{
    printf("glGetStringi(" "%s, %u)\n", E2S(name), index);
    const GLubyte* const r = glad_glGetStringi(name, index);
    return r;
}

GLboolean APIENTRY glIsRenderbuffer(GLuint renderbuffer)
{
    printf("glIsRenderbuffer(" "%u)\n", renderbuffer);
    GLboolean const r = glad_glIsRenderbuffer(renderbuffer);
    return r;
}

void APIENTRY glBindRenderbuffer(GLenum target, GLuint renderbuffer)
{
    printf("glBindRenderbuffer(" "%s, %u)\n", E2S(target), renderbuffer);
    glad_glBindRenderbuffer(target, renderbuffer);
}

void APIENTRY glDeleteRenderbuffers(GLsizei n, const GLuint* renderbuffers)
{
    printf("glDeleteRenderbuffers(" "%i, %p)\n", n, renderbuffers);
    glad_glDeleteRenderbuffers(n, renderbuffers);
}

void APIENTRY glGenRenderbuffers(GLsizei n, GLuint* renderbuffers)
{
    printf("glGenRenderbuffers(" "%i, %p)\n", n, renderbuffers);
    glad_glGenRenderbuffers(n, renderbuffers);
}

void APIENTRY glRenderbufferStorage(GLenum target, GLenum internalformat, GLsizei width, GLsizei height)
{
    printf("glRenderbufferStorage(" "%s, %s, %i, %i)\n", E2S(target), E2S(internalformat), width, height);
    glad_glRenderbufferStorage(target, internalformat, width, height);
}

void APIENTRY glGetRenderbufferParameteriv(GLenum target, GLenum pname, GLint* params)
{
    printf("glGetRenderbufferParameteriv(" "%s, %s, %p)\n", E2S(target), E2S(pname), params);
    glad_glGetRenderbufferParameteriv(target, pname, params);
}

GLboolean APIENTRY glIsFramebuffer(GLuint framebuffer)
{
    printf("glIsFramebuffer(" "%u)\n", framebuffer);
    GLboolean const r = glad_glIsFramebuffer(framebuffer);
    return r;
}

void APIENTRY glBindFramebuffer(GLenum target, GLuint framebuffer)
{
    printf("glBindFramebuffer(" "%s, %u)\n", E2S(target), framebuffer);
    glad_glBindFramebuffer(target, framebuffer);
}

void APIENTRY glDeleteFramebuffers(GLsizei n, const GLuint* framebuffers)
{
    printf("glDeleteFramebuffers(" "%i, %p)\n", n, framebuffers);
    glad_glDeleteFramebuffers(n, framebuffers);
}

void APIENTRY glGenFramebuffers(GLsizei n, GLuint* framebuffers)
{
    printf("glGenFramebuffers(" "%i, %p)\n", n, framebuffers);
    glad_glGenFramebuffers(n, framebuffers);
}

GLenum APIENTRY glCheckFramebufferStatus(GLenum target)
{
    printf("glCheckFramebufferStatus(" "%s)\n", E2S(target));
    GLenum const r = glad_glCheckFramebufferStatus(target);
    return r;
}

void APIENTRY glFramebufferTexture1D(GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level)
{
    printf("glFramebufferTexture1D(" "%s, %s, %s, %u, %i)\n", E2S(target), E2S(attachment), E2S(textarget), texture, level);
    glad_glFramebufferTexture1D(target, attachment, textarget, texture, level);
}

void APIENTRY glFramebufferTexture2D(GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level)
{
    printf("glFramebufferTexture2D(" "%s, %s, %s, %u, %i)\n", E2S(target), E2S(attachment), E2S(textarget), texture, level);
    glad_glFramebufferTexture2D(target, attachment, textarget, texture, level);
}

void APIENTRY glFramebufferTexture3D(GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level, GLint zoffset)
{
    printf("glFramebufferTexture3D(" "%s, %s, %s, %u, %i, %i)\n", E2S(target), E2S(attachment), E2S(textarget), texture, level, zoffset);
    glad_glFramebufferTexture3D(target, attachment, textarget, texture, level, zoffset);
}

void APIENTRY glFramebufferRenderbuffer(GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer)
{
    printf("glFramebufferRenderbuffer(" "%s, %s, %s, %u)\n", E2S(target), E2S(attachment), E2S(renderbuffertarget), renderbuffer);
    glad_glFramebufferRenderbuffer(target, attachment, renderbuffertarget, renderbuffer);
}

void APIENTRY glGetFramebufferAttachmentParameteriv(GLenum target, GLenum attachment, GLenum pname, GLint* params)
{
    printf("glGetFramebufferAttachmentParameteriv(" "%s, %s, %s, %p)\n", E2S(target), E2S(attachment), E2S(pname), params);
    glad_glGetFramebufferAttachmentParameteriv(target, attachment, pname, params);
}

void APIENTRY glGenerateMipmap(GLenum target)
{
    printf("glGenerateMipmap(" "%s)\n", E2S(target));
    glad_glGenerateMipmap(target);
}

void APIENTRY glBlitFramebuffer(GLint srcX0, GLint srcY0, GLint srcX1, GLint srcY1, GLint dstX0, GLint dstY0, GLint dstX1, GLint dstY1, GLbitfield mask, GLenum filter)
{
    printf("glBlitFramebuffer(" "%i, %i, %i, %i, %i, %i, %i, %i, %u, %s)\n", srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, (unsigned int)(mask), E2S(filter));
    glad_glBlitFramebuffer(srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, mask, filter);
}

void APIENTRY glRenderbufferStorageMultisample(GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height)
{
    printf("glRenderbufferStorageMultisample(" "%s, %i, %s, %i, %i)\n", E2S(target), samples, E2S(internalformat), width, height);
    glad_glRenderbufferStorageMultisample(target, samples, internalformat, width, height);
}

void APIENTRY glFramebufferTextureLayer(GLenum target, GLenum attachment, GLuint texture, GLint level, GLint layer)
{
    printf("glFramebufferTextureLayer(" "%s, %s, %u, %i, %i)\n", E2S(target), E2S(attachment), texture, level, layer);
    glad_glFramebufferTextureLayer(target, attachment, texture, level, layer);
}

void* APIENTRY glMapBufferRange(GLenum target, GLintptr offset, GLsizeiptr length, GLbitfield access)
{
    printf("glMapBufferRange(" "%s, %" PRId32", %" PRId32", %u)\n", E2S(target), offset, length, (unsigned int)(access));
    void* const r = glad_glMapBufferRange(target, offset, length, access);
    return r;
}

void APIENTRY glFlushMappedBufferRange(GLenum target, GLintptr offset, GLsizeiptr length)
{
    printf("glFlushMappedBufferRange(" "%s, %" PRId32", %" PRId32")\n", E2S(target), offset, length);
    glad_glFlushMappedBufferRange(target, offset, length);
}

void APIENTRY glBindVertexArray(GLuint array)
{
    printf("glBindVertexArray(" "%u)\n", array);
    glad_glBindVertexArray(array);
}

void APIENTRY glDeleteVertexArrays(GLsizei n, const GLuint* arrays)
{
    printf("glDeleteVertexArrays(" "%i, %p)\n", n, arrays);
    glad_glDeleteVertexArrays(n, arrays);
}

void APIENTRY glGenVertexArrays(GLsizei n, GLuint* arrays)
{
    printf("glGenVertexArrays(" "%i, %p)\n", n, arrays);
    glad_glGenVertexArrays(n, arrays);
}

GLboolean APIENTRY glIsVertexArray(GLuint array)
{
    printf("glIsVertexArray(" "%u)\n", array);
    GLboolean const r = glad_glIsVertexArray(array);
    return r;
}

void APIENTRY glDrawArraysInstanced(GLenum mode, GLint first, GLsizei count, GLsizei instancecount)
{
    printf("glDrawArraysInstanced(" "%s, %i, %i, %i)\n", E2S(mode), first, count, instancecount);
    glad_glDrawArraysInstanced(mode, first, count, instancecount);
}

void APIENTRY glDrawElementsInstanced(GLenum mode, GLsizei count, GLenum type, const void* indices, GLsizei instancecount)
{
    printf("glDrawElementsInstanced(" "%s, %i, %s, %p, %i)\n", E2S(mode), count, E2S(type), indices, instancecount);
    glad_glDrawElementsInstanced(mode, count, type, indices, instancecount);
}

void APIENTRY glTexBuffer(GLenum target, GLenum internalformat, GLuint buffer)
{
    printf("glTexBuffer(" "%s, %s, %u)\n", E2S(target), E2S(internalformat), buffer);
    glad_glTexBuffer(target, internalformat, buffer);
}

void APIENTRY glPrimitiveRestartIndex(GLuint index)
{
    printf("glPrimitiveRestartIndex(" "%u)\n", index);
    glad_glPrimitiveRestartIndex(index);
}

void APIENTRY glCopyBufferSubData(GLenum readTarget, GLenum writeTarget, GLintptr readOffset, GLintptr writeOffset, GLsizeiptr size)
{
    printf("glCopyBufferSubData(" "%s, %s, %" PRId32", %" PRId32", %" PRId32")\n", E2S(readTarget), E2S(writeTarget), readOffset, writeOffset, size);
    glad_glCopyBufferSubData(readTarget, writeTarget, readOffset, writeOffset, size);
}

void APIENTRY glGetUniformIndices(GLuint program, GLsizei uniformCount, const GLchar* const* uniformNames, GLuint* uniformIndices)
{
    printf("glGetUniformIndices(" "%u, %i, %p, %p)\n", program, uniformCount, uniformNames, uniformIndices);
    glad_glGetUniformIndices(program, uniformCount, uniformNames, uniformIndices);
}

void APIENTRY glGetActiveUniformsiv(GLuint program, GLsizei uniformCount, const GLuint* uniformIndices, GLenum pname, GLint* params)
{
    printf("glGetActiveUniformsiv(" "%u, %i, %p, %s, %p)\n", program, uniformCount, uniformIndices, E2S(pname), params);
    glad_glGetActiveUniformsiv(program, uniformCount, uniformIndices, pname, params);
}

void APIENTRY glGetActiveUniformName(GLuint program, GLuint uniformIndex, GLsizei bufSize, GLsizei* length, GLchar* uniformName)
{
    printf("glGetActiveUniformName(" "%u, %u, %i, %p, %p)\n", program, uniformIndex, bufSize, length, uniformName);
    glad_glGetActiveUniformName(program, uniformIndex, bufSize, length, uniformName);
}

GLuint APIENTRY glGetUniformBlockIndex(GLuint program, const GLchar* uniformBlockName)
{
    printf("glGetUniformBlockIndex(" "%u, %p)\n", program, uniformBlockName);
    GLuint const r = glad_glGetUniformBlockIndex(program, uniformBlockName);
    return r;
}

void APIENTRY glGetActiveUniformBlockiv(GLuint program, GLuint uniformBlockIndex, GLenum pname, GLint* params)
{
    printf("glGetActiveUniformBlockiv(" "%u, %u, %s, %p)\n", program, uniformBlockIndex, E2S(pname), params);
    glad_glGetActiveUniformBlockiv(program, uniformBlockIndex, pname, params);
}

void APIENTRY glGetActiveUniformBlockName(GLuint program, GLuint uniformBlockIndex, GLsizei bufSize, GLsizei* length, GLchar* uniformBlockName)
{
    printf("glGetActiveUniformBlockName(" "%u, %u, %i, %p, %p)\n", program, uniformBlockIndex, bufSize, length, uniformBlockName);
    glad_glGetActiveUniformBlockName(program, uniformBlockIndex, bufSize, length, uniformBlockName);
}

void APIENTRY glUniformBlockBinding(GLuint program, GLuint uniformBlockIndex, GLuint uniformBlockBinding)
{
    printf("glUniformBlockBinding(" "%u, %u, %u)\n", program, uniformBlockIndex, uniformBlockBinding);
    glad_glUniformBlockBinding(program, uniformBlockIndex, uniformBlockBinding);
}

void APIENTRY glDrawElementsBaseVertex(GLenum mode, GLsizei count, GLenum type, const void* indices, GLint basevertex)
{
    printf("glDrawElementsBaseVertex(" "%s, %i, %s, %p, %i)\n", E2S(mode), count, E2S(type), indices, basevertex);
    glad_glDrawElementsBaseVertex(mode, count, type, indices, basevertex);
}

void APIENTRY glDrawRangeElementsBaseVertex(GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum type, const void* indices, GLint basevertex)
{
    printf("glDrawRangeElementsBaseVertex(" "%s, %u, %u, %i, %s, %p, %i)\n", E2S(mode), start, end, count, E2S(type), indices, basevertex);
    glad_glDrawRangeElementsBaseVertex(mode, start, end, count, type, indices, basevertex);
}

void APIENTRY glDrawElementsInstancedBaseVertex(GLenum mode, GLsizei count, GLenum type, const void* indices, GLsizei instancecount, GLint basevertex)
{
    printf("glDrawElementsInstancedBaseVertex(" "%s, %i, %s, %p, %i, %i)\n", E2S(mode), count, E2S(type), indices, instancecount, basevertex);
    glad_glDrawElementsInstancedBaseVertex(mode, count, type, indices, instancecount, basevertex);
}

void APIENTRY glMultiDrawElementsBaseVertex(GLenum mode, const GLsizei* count, GLenum type, const void* const* indices, GLsizei drawcount, const GLint* basevertex)
{
    printf("glMultiDrawElementsBaseVertex(" "%s, %p, %s, %p, %i, %p)\n", E2S(mode), count, E2S(type), indices, drawcount, basevertex);
    glad_glMultiDrawElementsBaseVertex(mode, count, type, indices, drawcount, basevertex);
}

void APIENTRY glProvokingVertex(GLenum mode)
{
    printf("glProvokingVertex(" "%s)\n", E2S(mode));
    glad_glProvokingVertex(mode);
}

GLsync APIENTRY glFenceSync(GLenum condition, GLbitfield flags)
{
    printf("glFenceSync(" "%s, %u)\n", E2S(condition), (unsigned int)(flags));
    GLsync const r = glad_glFenceSync(condition, flags);
    return r;
}

GLboolean APIENTRY glIsSync(GLsync sync)
{
    printf("glIsSync(" "%x)\n", sync);
    GLboolean const r = glad_glIsSync(sync);
    return r;
}

void APIENTRY glDeleteSync(GLsync sync)
{
    printf("glDeleteSync(" "%x)\n", sync);
    glad_glDeleteSync(sync);
}

GLenum APIENTRY glClientWaitSync(GLsync sync, GLbitfield flags, GLuint64 timeout)
{
    printf("glClientWaitSync(" "%x, %u, %zu)\n", sync, (unsigned int)(flags), timeout);
    GLenum const r = glad_glClientWaitSync(sync, flags, timeout);
    return r;
}

void APIENTRY glWaitSync(GLsync sync, GLbitfield flags, GLuint64 timeout)
{
    printf("glWaitSync(" "%x, %u, %zu)\n", sync, (unsigned int)(flags), timeout);
    glad_glWaitSync(sync, flags, timeout);
}

void APIENTRY glGetInteger64v(GLenum pname, GLint64* data)
{
    printf("glGetInteger64v(" "%s, %p)\n", E2S(pname), data);
    glad_glGetInteger64v(pname, data);
}

void APIENTRY glGetSynciv(GLsync sync, GLenum pname, GLsizei count, GLsizei* length, GLint* values)
{
    printf("glGetSynciv(" "%x, %s, %i, %p, %p)\n", sync, E2S(pname), count, length, values);
    glad_glGetSynciv(sync, pname, count, length, values);
}

void APIENTRY glGetInteger64i_v(GLenum target, GLuint index, GLint64* data)
{
    printf("glGetInteger64i_v(" "%s, %u, %p)\n", E2S(target), index, data);
    glad_glGetInteger64i_v(target, index, data);
}

void APIENTRY glGetBufferParameteri64v(GLenum target, GLenum pname, GLint64* params)
{
    printf("glGetBufferParameteri64v(" "%s, %s, %p)\n", E2S(target), E2S(pname), params);
    glad_glGetBufferParameteri64v(target, pname, params);
}

void APIENTRY glFramebufferTexture(GLenum target, GLenum attachment, GLuint texture, GLint level)
{
    printf("glFramebufferTexture(" "%s, %s, %u, %i)\n", E2S(target), E2S(attachment), texture, level);
    glad_glFramebufferTexture(target, attachment, texture, level);
}

void APIENTRY glTexImage2DMultisample(GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLboolean fixedsamplelocations)
{
    printf("glTexImage2DMultisample(" "%s, %i, %s, %i, %i, %u)\n", E2S(target), samples, E2S(internalformat), width, height, (unsigned int)(fixedsamplelocations));
    glad_glTexImage2DMultisample(target, samples, internalformat, width, height, fixedsamplelocations);
}

void APIENTRY glTexImage3DMultisample(GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLboolean fixedsamplelocations)
{
    printf("glTexImage3DMultisample(" "%s, %i, %s, %i, %i, %i, %u)\n", E2S(target), samples, E2S(internalformat), width, height, depth, (unsigned int)(fixedsamplelocations));
    glad_glTexImage3DMultisample(target, samples, internalformat, width, height, depth, fixedsamplelocations);
}

void APIENTRY glGetMultisamplefv(GLenum pname, GLuint index, GLfloat* val)
{
    printf("glGetMultisamplefv(" "%s, %u, %p)\n", E2S(pname), index, val);
    glad_glGetMultisamplefv(pname, index, val);
}

void APIENTRY glSampleMaski(GLuint maskNumber, GLbitfield mask)
{
    printf("glSampleMaski(" "%u, %u)\n", maskNumber, (unsigned int)(mask));
    glad_glSampleMaski(maskNumber, mask);
}

void APIENTRY glBindFragDataLocationIndexed(GLuint program, GLuint colorNumber, GLuint index, const GLchar* name)
{
    printf("glBindFragDataLocationIndexed(" "%u, %u, %u, %p)\n", program, colorNumber, index, name);
    glad_glBindFragDataLocationIndexed(program, colorNumber, index, name);
}

GLint APIENTRY glGetFragDataIndex(GLuint program, const GLchar* name)
{
    printf("glGetFragDataIndex(" "%u, %p)\n", program, name);
    GLint const r = glad_glGetFragDataIndex(program, name);
    return r;
}

void APIENTRY glGenSamplers(GLsizei count, GLuint* samplers)
{
    printf("glGenSamplers(" "%i, %p)\n", count, samplers);
    glad_glGenSamplers(count, samplers);
}

void APIENTRY glDeleteSamplers(GLsizei count, const GLuint* samplers)
{
    printf("glDeleteSamplers(" "%i, %p)\n", count, samplers);
    glad_glDeleteSamplers(count, samplers);
}

GLboolean APIENTRY glIsSampler(GLuint sampler)
{
    printf("glIsSampler(" "%u)\n", sampler);
    GLboolean const r = glad_glIsSampler(sampler);
    return r;
}

void APIENTRY glBindSampler(GLuint unit, GLuint sampler)
{
    printf("glBindSampler(" "%u, %u)\n", unit, sampler);
    glad_glBindSampler(unit, sampler);
}

void APIENTRY glSamplerParameteri(GLuint sampler, GLenum pname, GLint param)
{
    printf("glSamplerParameteri(" "%u, %s, %i)\n", sampler, E2S(pname), param);
    glad_glSamplerParameteri(sampler, pname, param);
}

void APIENTRY glSamplerParameteriv(GLuint sampler, GLenum pname, const GLint* param)
{
    printf("glSamplerParameteriv(" "%u, %s, %p)\n", sampler, E2S(pname), param);
    glad_glSamplerParameteriv(sampler, pname, param);
}

void APIENTRY glSamplerParameterf(GLuint sampler, GLenum pname, GLfloat param)
{
    printf("glSamplerParameterf(" "%u, %s, %f)\n", sampler, E2S(pname), param);
    glad_glSamplerParameterf(sampler, pname, param);
}

void APIENTRY glSamplerParameterfv(GLuint sampler, GLenum pname, const GLfloat* param)
{
    printf("glSamplerParameterfv(" "%u, %s, %p)\n", sampler, E2S(pname), param);
    glad_glSamplerParameterfv(sampler, pname, param);
}

void APIENTRY glSamplerParameterIiv(GLuint sampler, GLenum pname, const GLint* param)
{
    printf("glSamplerParameterIiv(" "%u, %s, %p)\n", sampler, E2S(pname), param);
    glad_glSamplerParameterIiv(sampler, pname, param);
}

void APIENTRY glSamplerParameterIuiv(GLuint sampler, GLenum pname, const GLuint* param)
{
    printf("glSamplerParameterIuiv(" "%u, %s, %p)\n", sampler, E2S(pname), param);
    glad_glSamplerParameterIuiv(sampler, pname, param);
}

void APIENTRY glGetSamplerParameteriv(GLuint sampler, GLenum pname, GLint* params)
{
    printf("glGetSamplerParameteriv(" "%u, %s, %p)\n", sampler, E2S(pname), params);
    glad_glGetSamplerParameteriv(sampler, pname, params);
}

void APIENTRY glGetSamplerParameterIiv(GLuint sampler, GLenum pname, GLint* params)
{
    printf("glGetSamplerParameterIiv(" "%u, %s, %p)\n", sampler, E2S(pname), params);
    glad_glGetSamplerParameterIiv(sampler, pname, params);
}

void APIENTRY glGetSamplerParameterfv(GLuint sampler, GLenum pname, GLfloat* params)
{
    printf("glGetSamplerParameterfv(" "%u, %s, %p)\n", sampler, E2S(pname), params);
    glad_glGetSamplerParameterfv(sampler, pname, params);
}

void APIENTRY glGetSamplerParameterIuiv(GLuint sampler, GLenum pname, GLuint* params)
{
    printf("glGetSamplerParameterIuiv(" "%u, %s, %p)\n", sampler, E2S(pname), params);
    glad_glGetSamplerParameterIuiv(sampler, pname, params);
}

void APIENTRY glQueryCounter(GLuint id, GLenum target)
{
    printf("glQueryCounter(" "%u, %s)\n", id, E2S(target));
    glad_glQueryCounter(id, target);
}

void APIENTRY glGetQueryObjecti64v(GLuint id, GLenum pname, GLint64* params)
{
    printf("glGetQueryObjecti64v(" "%u, %s, %p)\n", id, E2S(pname), params);
    glad_glGetQueryObjecti64v(id, pname, params);
}

void APIENTRY glGetQueryObjectui64v(GLuint id, GLenum pname, GLuint64* params)
{
    printf("glGetQueryObjectui64v(" "%u, %s, %p)\n", id, E2S(pname), params);
    glad_glGetQueryObjectui64v(id, pname, params);
}

void APIENTRY glVertexAttribDivisor(GLuint index, GLuint divisor)
{
    printf("glVertexAttribDivisor(" "%u, %u)\n", index, divisor);
    glad_glVertexAttribDivisor(index, divisor);
}

void APIENTRY glVertexAttribP1ui(GLuint index, GLenum type, GLboolean normalized, GLuint value)
{
    printf("glVertexAttribP1ui(" "%u, %s, %u, %u)\n", index, E2S(type), (unsigned int)(normalized), value);
    glad_glVertexAttribP1ui(index, type, normalized, value);
}

void APIENTRY glVertexAttribP1uiv(GLuint index, GLenum type, GLboolean normalized, const GLuint* value)
{
    printf("glVertexAttribP1uiv(" "%u, %s, %u, %p)\n", index, E2S(type), (unsigned int)(normalized), value);
    glad_glVertexAttribP1uiv(index, type, normalized, value);
}

void APIENTRY glVertexAttribP2ui(GLuint index, GLenum type, GLboolean normalized, GLuint value)
{
    printf("glVertexAttribP2ui(" "%u, %s, %u, %u)\n", index, E2S(type), (unsigned int)(normalized), value);
    glad_glVertexAttribP2ui(index, type, normalized, value);
}

void APIENTRY glVertexAttribP2uiv(GLuint index, GLenum type, GLboolean normalized, const GLuint* value)
{
    printf("glVertexAttribP2uiv(" "%u, %s, %u, %p)\n", index, E2S(type), (unsigned int)(normalized), value);
    glad_glVertexAttribP2uiv(index, type, normalized, value);
}

void APIENTRY glVertexAttribP3ui(GLuint index, GLenum type, GLboolean normalized, GLuint value)
{
    printf("glVertexAttribP3ui(" "%u, %s, %u, %u)\n", index, E2S(type), (unsigned int)(normalized), value);
    glad_glVertexAttribP3ui(index, type, normalized, value);
}

void APIENTRY glVertexAttribP3uiv(GLuint index, GLenum type, GLboolean normalized, const GLuint* value)
{
    printf("glVertexAttribP3uiv(" "%u, %s, %u, %p)\n", index, E2S(type), (unsigned int)(normalized), value);
    glad_glVertexAttribP3uiv(index, type, normalized, value);
}

void APIENTRY glVertexAttribP4ui(GLuint index, GLenum type, GLboolean normalized, GLuint value)
{
    printf("glVertexAttribP4ui(" "%u, %s, %u, %u)\n", index, E2S(type), (unsigned int)(normalized), value);
    glad_glVertexAttribP4ui(index, type, normalized, value);
}

void APIENTRY glVertexAttribP4uiv(GLuint index, GLenum type, GLboolean normalized, const GLuint* value)
{
    printf("glVertexAttribP4uiv(" "%u, %s, %u, %p)\n", index, E2S(type), (unsigned int)(normalized), value);
    glad_glVertexAttribP4uiv(index, type, normalized, value);
}

void APIENTRY glMinSampleShading(GLfloat value)
{
    printf("glMinSampleShading(" "%f)\n", value);
    glad_glMinSampleShading(value);
}

void APIENTRY glBlendEquationi(GLuint buf, GLenum mode)
{
    printf("glBlendEquationi(" "%u, %s)\n", buf, E2S(mode));
    glad_glBlendEquationi(buf, mode);
}

void APIENTRY glBlendEquationSeparatei(GLuint buf, GLenum modeRGB, GLenum modeAlpha)
{
    printf("glBlendEquationSeparatei(" "%u, %s, %s)\n", buf, E2S(modeRGB), E2S(modeAlpha));
    glad_glBlendEquationSeparatei(buf, modeRGB, modeAlpha);
}

void APIENTRY glBlendFunci(GLuint buf, GLenum src, GLenum dst)
{
    printf("glBlendFunci(" "%u, %s, %s)\n", buf, E2S(src), E2S(dst));
    glad_glBlendFunci(buf, src, dst);
}

void APIENTRY glBlendFuncSeparatei(GLuint buf, GLenum srcRGB, GLenum dstRGB, GLenum srcAlpha, GLenum dstAlpha)
{
    printf("glBlendFuncSeparatei(" "%u, %s, %s, %s, %s)\n", buf, E2S(srcRGB), E2S(dstRGB), E2S(srcAlpha), E2S(dstAlpha));
    glad_glBlendFuncSeparatei(buf, srcRGB, dstRGB, srcAlpha, dstAlpha);
}

void APIENTRY glDrawArraysIndirect(GLenum mode, const void* indirect)
{
    printf("glDrawArraysIndirect(" "%s, %p)\n", E2S(mode), indirect);
    glad_glDrawArraysIndirect(mode, indirect);
}

void APIENTRY glDrawElementsIndirect(GLenum mode, GLenum type, const void* indirect)
{
    printf("glDrawElementsIndirect(" "%s, %s, %p)\n", E2S(mode), E2S(type), indirect);
    glad_glDrawElementsIndirect(mode, type, indirect);
}

void APIENTRY glUniform1d(GLint location, GLdouble x)
{
    printf("glUniform1d(" "%i, %f)\n", location, x);
    glad_glUniform1d(location, x);
}

void APIENTRY glUniform2d(GLint location, GLdouble x, GLdouble y)
{
    printf("glUniform2d(" "%i, %f, %f)\n", location, x, y);
    glad_glUniform2d(location, x, y);
}

void APIENTRY glUniform3d(GLint location, GLdouble x, GLdouble y, GLdouble z)
{
    printf("glUniform3d(" "%i, %f, %f, %f)\n", location, x, y, z);
    glad_glUniform3d(location, x, y, z);
}

void APIENTRY glUniform4d(GLint location, GLdouble x, GLdouble y, GLdouble z, GLdouble w)
{
    printf("glUniform4d(" "%i, %f, %f, %f, %f)\n", location, x, y, z, w);
    glad_glUniform4d(location, x, y, z, w);
}

void APIENTRY glUniform1dv(GLint location, GLsizei count, const GLdouble* value)
{
    printf("glUniform1dv(" "%i, %i, %p)\n", location, count, value);
    glad_glUniform1dv(location, count, value);
}

void APIENTRY glUniform2dv(GLint location, GLsizei count, const GLdouble* value)
{
    printf("glUniform2dv(" "%i, %i, %p)\n", location, count, value);
    glad_glUniform2dv(location, count, value);
}

void APIENTRY glUniform3dv(GLint location, GLsizei count, const GLdouble* value)
{
    printf("glUniform3dv(" "%i, %i, %p)\n", location, count, value);
    glad_glUniform3dv(location, count, value);
}

void APIENTRY glUniform4dv(GLint location, GLsizei count, const GLdouble* value)
{
    printf("glUniform4dv(" "%i, %i, %p)\n", location, count, value);
    glad_glUniform4dv(location, count, value);
}

void APIENTRY glUniformMatrix2dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    printf("glUniformMatrix2dv(" "%i, %i, %u, %p)\n", location, count, (unsigned int)(transpose), value);
    glad_glUniformMatrix2dv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix3dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    printf("glUniformMatrix3dv(" "%i, %i, %u, %p)\n", location, count, (unsigned int)(transpose), value);
    glad_glUniformMatrix3dv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix4dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    printf("glUniformMatrix4dv(" "%i, %i, %u, %p)\n", location, count, (unsigned int)(transpose), value);
    glad_glUniformMatrix4dv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix2x3dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    printf("glUniformMatrix2x3dv(" "%i, %i, %u, %p)\n", location, count, (unsigned int)(transpose), value);
    glad_glUniformMatrix2x3dv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix2x4dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    printf("glUniformMatrix2x4dv(" "%i, %i, %u, %p)\n", location, count, (unsigned int)(transpose), value);
    glad_glUniformMatrix2x4dv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix3x2dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    printf("glUniformMatrix3x2dv(" "%i, %i, %u, %p)\n", location, count, (unsigned int)(transpose), value);
    glad_glUniformMatrix3x2dv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix3x4dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    printf("glUniformMatrix3x4dv(" "%i, %i, %u, %p)\n", location, count, (unsigned int)(transpose), value);
    glad_glUniformMatrix3x4dv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix4x2dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    printf("glUniformMatrix4x2dv(" "%i, %i, %u, %p)\n", location, count, (unsigned int)(transpose), value);
    glad_glUniformMatrix4x2dv(location, count, transpose, value);
}

void APIENTRY glUniformMatrix4x3dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    printf("glUniformMatrix4x3dv(" "%i, %i, %u, %p)\n", location, count, (unsigned int)(transpose), value);
    glad_glUniformMatrix4x3dv(location, count, transpose, value);
}

void APIENTRY glGetUniformdv(GLuint program, GLint location, GLdouble* params)
{
    printf("glGetUniformdv(" "%u, %i, %p)\n", program, location, params);
    glad_glGetUniformdv(program, location, params);
}

GLint APIENTRY glGetSubroutineUniformLocation(GLuint program, GLenum shadertype, const GLchar* name)
{
    printf("glGetSubroutineUniformLocation(" "%u, %s, %p)\n", program, E2S(shadertype), name);
    GLint const r = glad_glGetSubroutineUniformLocation(program, shadertype, name);
    return r;
}

GLuint APIENTRY glGetSubroutineIndex(GLuint program, GLenum shadertype, const GLchar* name)
{
    printf("glGetSubroutineIndex(" "%u, %s, %p)\n", program, E2S(shadertype), name);
    GLuint const r = glad_glGetSubroutineIndex(program, shadertype, name);
    return r;
}

void APIENTRY glGetActiveSubroutineUniformiv(GLuint program, GLenum shadertype, GLuint index, GLenum pname, GLint* values)
{
    printf("glGetActiveSubroutineUniformiv(" "%u, %s, %u, %s, %p)\n", program, E2S(shadertype), index, E2S(pname), values);
    glad_glGetActiveSubroutineUniformiv(program, shadertype, index, pname, values);
}

void APIENTRY glGetActiveSubroutineUniformName(GLuint program, GLenum shadertype, GLuint index, GLsizei bufSize, GLsizei* length, GLchar* name)
{
    printf("glGetActiveSubroutineUniformName(" "%u, %s, %u, %i, %p, %p)\n", program, E2S(shadertype), index, bufSize, length, name);
    glad_glGetActiveSubroutineUniformName(program, shadertype, index, bufSize, length, name);
}

void APIENTRY glGetActiveSubroutineName(GLuint program, GLenum shadertype, GLuint index, GLsizei bufSize, GLsizei* length, GLchar* name)
{
    printf("glGetActiveSubroutineName(" "%u, %s, %u, %i, %p, %p)\n", program, E2S(shadertype), index, bufSize, length, name);
    glad_glGetActiveSubroutineName(program, shadertype, index, bufSize, length, name);
}

void APIENTRY glUniformSubroutinesuiv(GLenum shadertype, GLsizei count, const GLuint* indices)
{
    printf("glUniformSubroutinesuiv(" "%s, %i, %p)\n", E2S(shadertype), count, indices);
    glad_glUniformSubroutinesuiv(shadertype, count, indices);
}

void APIENTRY glGetUniformSubroutineuiv(GLenum shadertype, GLint location, GLuint* params)
{
    printf("glGetUniformSubroutineuiv(" "%s, %i, %p)\n", E2S(shadertype), location, params);
    glad_glGetUniformSubroutineuiv(shadertype, location, params);
}

void APIENTRY glGetProgramStageiv(GLuint program, GLenum shadertype, GLenum pname, GLint* values)
{
    printf("glGetProgramStageiv(" "%u, %s, %s, %p)\n", program, E2S(shadertype), E2S(pname), values);
    glad_glGetProgramStageiv(program, shadertype, pname, values);
}

void APIENTRY glPatchParameteri(GLenum pname, GLint value)
{
    printf("glPatchParameteri(" "%s, %i)\n", E2S(pname), value);
    glad_glPatchParameteri(pname, value);
}

void APIENTRY glPatchParameterfv(GLenum pname, const GLfloat* values)
{
    printf("glPatchParameterfv(" "%s, %p)\n", E2S(pname), values);
    glad_glPatchParameterfv(pname, values);
}

void APIENTRY glBindTransformFeedback(GLenum target, GLuint id)
{
    printf("glBindTransformFeedback(" "%s, %u)\n", E2S(target), id);
    glad_glBindTransformFeedback(target, id);
}

void APIENTRY glDeleteTransformFeedbacks(GLsizei n, const GLuint* ids)
{
    printf("glDeleteTransformFeedbacks(" "%i, %p)\n", n, ids);
    glad_glDeleteTransformFeedbacks(n, ids);
}

void APIENTRY glGenTransformFeedbacks(GLsizei n, GLuint* ids)
{
    printf("glGenTransformFeedbacks(" "%i, %p)\n", n, ids);
    glad_glGenTransformFeedbacks(n, ids);
}

GLboolean APIENTRY glIsTransformFeedback(GLuint id)
{
    printf("glIsTransformFeedback(" "%u)\n", id);
    GLboolean const r = glad_glIsTransformFeedback(id);
    return r;
}

void APIENTRY glPauseTransformFeedback()
{
    printf("glPauseTransformFeedback()\n");
    glad_glPauseTransformFeedback();
}

void APIENTRY glResumeTransformFeedback()
{
    printf("glResumeTransformFeedback()\n");
    glad_glResumeTransformFeedback();
}

void APIENTRY glDrawTransformFeedback(GLenum mode, GLuint id)
{
    printf("glDrawTransformFeedback(" "%s, %u)\n", E2S(mode), id);
    glad_glDrawTransformFeedback(mode, id);
}

void APIENTRY glDrawTransformFeedbackStream(GLenum mode, GLuint id, GLuint stream)
{
    printf("glDrawTransformFeedbackStream(" "%s, %u, %u)\n", E2S(mode), id, stream);
    glad_glDrawTransformFeedbackStream(mode, id, stream);
}

void APIENTRY glBeginQueryIndexed(GLenum target, GLuint index, GLuint id)
{
    printf("glBeginQueryIndexed(" "%s, %u, %u)\n", E2S(target), index, id);
    glad_glBeginQueryIndexed(target, index, id);
}

void APIENTRY glEndQueryIndexed(GLenum target, GLuint index)
{
    printf("glEndQueryIndexed(" "%s, %u)\n", E2S(target), index);
    glad_glEndQueryIndexed(target, index);
}

void APIENTRY glGetQueryIndexediv(GLenum target, GLuint index, GLenum pname, GLint* params)
{
    printf("glGetQueryIndexediv(" "%s, %u, %s, %p)\n", E2S(target), index, E2S(pname), params);
    glad_glGetQueryIndexediv(target, index, pname, params);
}

void APIENTRY glReleaseShaderCompiler()
{
    printf("glReleaseShaderCompiler()\n");
    glad_glReleaseShaderCompiler();
}

void APIENTRY glShaderBinary(GLsizei count, const GLuint* shaders, GLenum binaryformat, const void* binary, GLsizei length)
{
    printf("glShaderBinary(" "%i, %p, %s, %p, %i)\n", count, shaders, E2S(binaryformat), binary, length);
    glad_glShaderBinary(count, shaders, binaryformat, binary, length);
}

void APIENTRY glGetShaderPrecisionFormat(GLenum shadertype, GLenum precisiontype, GLint* range, GLint* precision)
{
    printf("glGetShaderPrecisionFormat(" "%s, %s, %p, %p)\n", E2S(shadertype), E2S(precisiontype), range, precision);
    glad_glGetShaderPrecisionFormat(shadertype, precisiontype, range, precision);
}

void APIENTRY glDepthRangef(GLfloat n, GLfloat f)
{
    printf("glDepthRangef(" "%f, %f)\n", n, f);
    glad_glDepthRangef(n, f);
}

void APIENTRY glClearDepthf(GLfloat d)
{
    printf("glClearDepthf(" "%f)\n", d);
    glad_glClearDepthf(d);
}

void APIENTRY glGetProgramBinary(GLuint program, GLsizei bufSize, GLsizei* length, GLenum* binaryFormat, void* binary)
{
    printf("glGetProgramBinary(" "%u, %i, %p, %p, %p)\n", program, bufSize, length, binaryFormat, binary);
    glad_glGetProgramBinary(program, bufSize, length, binaryFormat, binary);
}

void APIENTRY glProgramBinary(GLuint program, GLenum binaryFormat, const void* binary, GLsizei length)
{
    printf("glProgramBinary(" "%u, %s, %p, %i)\n", program, E2S(binaryFormat), binary, length);
    glad_glProgramBinary(program, binaryFormat, binary, length);
}

void APIENTRY glProgramParameteri(GLuint program, GLenum pname, GLint value)
{
    printf("glProgramParameteri(" "%u, %s, %i)\n", program, E2S(pname), value);
    glad_glProgramParameteri(program, pname, value);
}

void APIENTRY glUseProgramStages(GLuint pipeline, GLbitfield stages, GLuint program)
{
    printf("glUseProgramStages(" "%u, %u, %u)\n", pipeline, (unsigned int)(stages), program);
    glad_glUseProgramStages(pipeline, stages, program);
}

void APIENTRY glActiveShaderProgram(GLuint pipeline, GLuint program)
{
    printf("glActiveShaderProgram(" "%u, %u)\n", pipeline, program);
    glad_glActiveShaderProgram(pipeline, program);
}

GLuint APIENTRY glCreateShaderProgramv(GLenum type, GLsizei count, const GLchar* const* strings)
{
    printf("glCreateShaderProgramv(" "%s, %i, %p)\n", E2S(type), count, strings);
    GLuint const r = glad_glCreateShaderProgramv(type, count, strings);
    return r;
}

void APIENTRY glBindProgramPipeline(GLuint pipeline)
{
    printf("glBindProgramPipeline(" "%u)\n", pipeline);
    glad_glBindProgramPipeline(pipeline);
}

void APIENTRY glDeleteProgramPipelines(GLsizei n, const GLuint* pipelines)
{
    printf("glDeleteProgramPipelines(" "%i, %p)\n", n, pipelines);
    glad_glDeleteProgramPipelines(n, pipelines);
}

void APIENTRY glGenProgramPipelines(GLsizei n, GLuint* pipelines)
{
    printf("glGenProgramPipelines(" "%i, %p)\n", n, pipelines);
    glad_glGenProgramPipelines(n, pipelines);
}

GLboolean APIENTRY glIsProgramPipeline(GLuint pipeline)
{
    printf("glIsProgramPipeline(" "%u)\n", pipeline);
    GLboolean const r = glad_glIsProgramPipeline(pipeline);
    return r;
}

void APIENTRY glGetProgramPipelineiv(GLuint pipeline, GLenum pname, GLint* params)
{
    printf("glGetProgramPipelineiv(" "%u, %s, %p)\n", pipeline, E2S(pname), params);
    glad_glGetProgramPipelineiv(pipeline, pname, params);
}

void APIENTRY glProgramUniform1i(GLuint program, GLint location, GLint v0)
{
    printf("glProgramUniform1i(" "%u, %i, %i)\n", program, location, v0);
    glad_glProgramUniform1i(program, location, v0);
}

void APIENTRY glProgramUniform1iv(GLuint program, GLint location, GLsizei count, const GLint* value)
{
    printf("glProgramUniform1iv(" "%u, %i, %i, %p)\n", program, location, count, value);
    glad_glProgramUniform1iv(program, location, count, value);
}

void APIENTRY glProgramUniform1f(GLuint program, GLint location, GLfloat v0)
{
    printf("glProgramUniform1f(" "%u, %i, %f)\n", program, location, v0);
    glad_glProgramUniform1f(program, location, v0);
}

void APIENTRY glProgramUniform1fv(GLuint program, GLint location, GLsizei count, const GLfloat* value)
{
    printf("glProgramUniform1fv(" "%u, %i, %i, %p)\n", program, location, count, value);
    glad_glProgramUniform1fv(program, location, count, value);
}

void APIENTRY glProgramUniform1d(GLuint program, GLint location, GLdouble v0)
{
    printf("glProgramUniform1d(" "%u, %i, %f)\n", program, location, v0);
    glad_glProgramUniform1d(program, location, v0);
}

void APIENTRY glProgramUniform1dv(GLuint program, GLint location, GLsizei count, const GLdouble* value)
{
    printf("glProgramUniform1dv(" "%u, %i, %i, %p)\n", program, location, count, value);
    glad_glProgramUniform1dv(program, location, count, value);
}

void APIENTRY glProgramUniform1ui(GLuint program, GLint location, GLuint v0)
{
    printf("glProgramUniform1ui(" "%u, %i, %u)\n", program, location, v0);
    glad_glProgramUniform1ui(program, location, v0);
}

void APIENTRY glProgramUniform1uiv(GLuint program, GLint location, GLsizei count, const GLuint* value)
{
    printf("glProgramUniform1uiv(" "%u, %i, %i, %p)\n", program, location, count, value);
    glad_glProgramUniform1uiv(program, location, count, value);
}

void APIENTRY glProgramUniform2i(GLuint program, GLint location, GLint v0, GLint v1)
{
    printf("glProgramUniform2i(" "%u, %i, %i, %i)\n", program, location, v0, v1);
    glad_glProgramUniform2i(program, location, v0, v1);
}

void APIENTRY glProgramUniform2iv(GLuint program, GLint location, GLsizei count, const GLint* value)
{
    printf("glProgramUniform2iv(" "%u, %i, %i, %p)\n", program, location, count, value);
    glad_glProgramUniform2iv(program, location, count, value);
}

void APIENTRY glProgramUniform2f(GLuint program, GLint location, GLfloat v0, GLfloat v1)
{
    printf("glProgramUniform2f(" "%u, %i, %f, %f)\n", program, location, v0, v1);
    glad_glProgramUniform2f(program, location, v0, v1);
}

void APIENTRY glProgramUniform2fv(GLuint program, GLint location, GLsizei count, const GLfloat* value)
{
    printf("glProgramUniform2fv(" "%u, %i, %i, %p)\n", program, location, count, value);
    glad_glProgramUniform2fv(program, location, count, value);
}

void APIENTRY glProgramUniform2d(GLuint program, GLint location, GLdouble v0, GLdouble v1)
{
    printf("glProgramUniform2d(" "%u, %i, %f, %f)\n", program, location, v0, v1);
    glad_glProgramUniform2d(program, location, v0, v1);
}

void APIENTRY glProgramUniform2dv(GLuint program, GLint location, GLsizei count, const GLdouble* value)
{
    printf("glProgramUniform2dv(" "%u, %i, %i, %p)\n", program, location, count, value);
    glad_glProgramUniform2dv(program, location, count, value);
}

void APIENTRY glProgramUniform2ui(GLuint program, GLint location, GLuint v0, GLuint v1)
{
    printf("glProgramUniform2ui(" "%u, %i, %u, %u)\n", program, location, v0, v1);
    glad_glProgramUniform2ui(program, location, v0, v1);
}

void APIENTRY glProgramUniform2uiv(GLuint program, GLint location, GLsizei count, const GLuint* value)
{
    printf("glProgramUniform2uiv(" "%u, %i, %i, %p)\n", program, location, count, value);
    glad_glProgramUniform2uiv(program, location, count, value);
}

void APIENTRY glProgramUniform3i(GLuint program, GLint location, GLint v0, GLint v1, GLint v2)
{
    printf("glProgramUniform3i(" "%u, %i, %i, %i, %i)\n", program, location, v0, v1, v2);
    glad_glProgramUniform3i(program, location, v0, v1, v2);
}

void APIENTRY glProgramUniform3iv(GLuint program, GLint location, GLsizei count, const GLint* value)
{
    printf("glProgramUniform3iv(" "%u, %i, %i, %p)\n", program, location, count, value);
    glad_glProgramUniform3iv(program, location, count, value);
}

void APIENTRY glProgramUniform3f(GLuint program, GLint location, GLfloat v0, GLfloat v1, GLfloat v2)
{
    printf("glProgramUniform3f(" "%u, %i, %f, %f, %f)\n", program, location, v0, v1, v2);
    glad_glProgramUniform3f(program, location, v0, v1, v2);
}

void APIENTRY glProgramUniform3fv(GLuint program, GLint location, GLsizei count, const GLfloat* value)
{
    printf("glProgramUniform3fv(" "%u, %i, %i, %p)\n", program, location, count, value);
    glad_glProgramUniform3fv(program, location, count, value);
}

void APIENTRY glProgramUniform3d(GLuint program, GLint location, GLdouble v0, GLdouble v1, GLdouble v2)
{
    printf("glProgramUniform3d(" "%u, %i, %f, %f, %f)\n", program, location, v0, v1, v2);
    glad_glProgramUniform3d(program, location, v0, v1, v2);
}

void APIENTRY glProgramUniform3dv(GLuint program, GLint location, GLsizei count, const GLdouble* value)
{
    printf("glProgramUniform3dv(" "%u, %i, %i, %p)\n", program, location, count, value);
    glad_glProgramUniform3dv(program, location, count, value);
}

void APIENTRY glProgramUniform3ui(GLuint program, GLint location, GLuint v0, GLuint v1, GLuint v2)
{
    printf("glProgramUniform3ui(" "%u, %i, %u, %u, %u)\n", program, location, v0, v1, v2);
    glad_glProgramUniform3ui(program, location, v0, v1, v2);
}

void APIENTRY glProgramUniform3uiv(GLuint program, GLint location, GLsizei count, const GLuint* value)
{
    printf("glProgramUniform3uiv(" "%u, %i, %i, %p)\n", program, location, count, value);
    glad_glProgramUniform3uiv(program, location, count, value);
}

void APIENTRY glProgramUniform4i(GLuint program, GLint location, GLint v0, GLint v1, GLint v2, GLint v3)
{
    printf("glProgramUniform4i(" "%u, %i, %i, %i, %i, %i)\n", program, location, v0, v1, v2, v3);
    glad_glProgramUniform4i(program, location, v0, v1, v2, v3);
}

void APIENTRY glProgramUniform4iv(GLuint program, GLint location, GLsizei count, const GLint* value)
{
    printf("glProgramUniform4iv(" "%u, %i, %i, %p)\n", program, location, count, value);
    glad_glProgramUniform4iv(program, location, count, value);
}

void APIENTRY glProgramUniform4f(GLuint program, GLint location, GLfloat v0, GLfloat v1, GLfloat v2, GLfloat v3)
{
    printf("glProgramUniform4f(" "%u, %i, %f, %f, %f, %f)\n", program, location, v0, v1, v2, v3);
    glad_glProgramUniform4f(program, location, v0, v1, v2, v3);
}

void APIENTRY glProgramUniform4fv(GLuint program, GLint location, GLsizei count, const GLfloat* value)
{
    printf("glProgramUniform4fv(" "%u, %i, %i, %p)\n", program, location, count, value);
    glad_glProgramUniform4fv(program, location, count, value);
}

void APIENTRY glProgramUniform4d(GLuint program, GLint location, GLdouble v0, GLdouble v1, GLdouble v2, GLdouble v3)
{
    printf("glProgramUniform4d(" "%u, %i, %f, %f, %f, %f)\n", program, location, v0, v1, v2, v3);
    glad_glProgramUniform4d(program, location, v0, v1, v2, v3);
}

void APIENTRY glProgramUniform4dv(GLuint program, GLint location, GLsizei count, const GLdouble* value)
{
    printf("glProgramUniform4dv(" "%u, %i, %i, %p)\n", program, location, count, value);
    glad_glProgramUniform4dv(program, location, count, value);
}

void APIENTRY glProgramUniform4ui(GLuint program, GLint location, GLuint v0, GLuint v1, GLuint v2, GLuint v3)
{
    printf("glProgramUniform4ui(" "%u, %i, %u, %u, %u, %u)\n", program, location, v0, v1, v2, v3);
    glad_glProgramUniform4ui(program, location, v0, v1, v2, v3);
}

void APIENTRY glProgramUniform4uiv(GLuint program, GLint location, GLsizei count, const GLuint* value)
{
    printf("glProgramUniform4uiv(" "%u, %i, %i, %p)\n", program, location, count, value);
    glad_glProgramUniform4uiv(program, location, count, value);
}

void APIENTRY glProgramUniformMatrix2fv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    printf("glProgramUniformMatrix2fv(" "%u, %i, %i, %u, %p)\n", program, location, count, (unsigned int)(transpose), value);
    glad_glProgramUniformMatrix2fv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix3fv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    printf("glProgramUniformMatrix3fv(" "%u, %i, %i, %u, %p)\n", program, location, count, (unsigned int)(transpose), value);
    glad_glProgramUniformMatrix3fv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix4fv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    printf("glProgramUniformMatrix4fv(" "%u, %i, %i, %u, %p)\n", program, location, count, (unsigned int)(transpose), value);
    glad_glProgramUniformMatrix4fv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix2dv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    printf("glProgramUniformMatrix2dv(" "%u, %i, %i, %u, %p)\n", program, location, count, (unsigned int)(transpose), value);
    glad_glProgramUniformMatrix2dv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix3dv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    printf("glProgramUniformMatrix3dv(" "%u, %i, %i, %u, %p)\n", program, location, count, (unsigned int)(transpose), value);
    glad_glProgramUniformMatrix3dv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix4dv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    printf("glProgramUniformMatrix4dv(" "%u, %i, %i, %u, %p)\n", program, location, count, (unsigned int)(transpose), value);
    glad_glProgramUniformMatrix4dv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix2x3fv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    printf("glProgramUniformMatrix2x3fv(" "%u, %i, %i, %u, %p)\n", program, location, count, (unsigned int)(transpose), value);
    glad_glProgramUniformMatrix2x3fv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix3x2fv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    printf("glProgramUniformMatrix3x2fv(" "%u, %i, %i, %u, %p)\n", program, location, count, (unsigned int)(transpose), value);
    glad_glProgramUniformMatrix3x2fv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix2x4fv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    printf("glProgramUniformMatrix2x4fv(" "%u, %i, %i, %u, %p)\n", program, location, count, (unsigned int)(transpose), value);
    glad_glProgramUniformMatrix2x4fv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix4x2fv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    printf("glProgramUniformMatrix4x2fv(" "%u, %i, %i, %u, %p)\n", program, location, count, (unsigned int)(transpose), value);
    glad_glProgramUniformMatrix4x2fv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix3x4fv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    printf("glProgramUniformMatrix3x4fv(" "%u, %i, %i, %u, %p)\n", program, location, count, (unsigned int)(transpose), value);
    glad_glProgramUniformMatrix3x4fv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix4x3fv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat* value)
{
    printf("glProgramUniformMatrix4x3fv(" "%u, %i, %i, %u, %p)\n", program, location, count, (unsigned int)(transpose), value);
    glad_glProgramUniformMatrix4x3fv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix2x3dv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    printf("glProgramUniformMatrix2x3dv(" "%u, %i, %i, %u, %p)\n", program, location, count, (unsigned int)(transpose), value);
    glad_glProgramUniformMatrix2x3dv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix3x2dv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    printf("glProgramUniformMatrix3x2dv(" "%u, %i, %i, %u, %p)\n", program, location, count, (unsigned int)(transpose), value);
    glad_glProgramUniformMatrix3x2dv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix2x4dv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    printf("glProgramUniformMatrix2x4dv(" "%u, %i, %i, %u, %p)\n", program, location, count, (unsigned int)(transpose), value);
    glad_glProgramUniformMatrix2x4dv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix4x2dv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    printf("glProgramUniformMatrix4x2dv(" "%u, %i, %i, %u, %p)\n", program, location, count, (unsigned int)(transpose), value);
    glad_glProgramUniformMatrix4x2dv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix3x4dv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    printf("glProgramUniformMatrix3x4dv(" "%u, %i, %i, %u, %p)\n", program, location, count, (unsigned int)(transpose), value);
    glad_glProgramUniformMatrix3x4dv(program, location, count, transpose, value);
}

void APIENTRY glProgramUniformMatrix4x3dv(GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble* value)
{
    printf("glProgramUniformMatrix4x3dv(" "%u, %i, %i, %u, %p)\n", program, location, count, (unsigned int)(transpose), value);
    glad_glProgramUniformMatrix4x3dv(program, location, count, transpose, value);
}

void APIENTRY glValidateProgramPipeline(GLuint pipeline)
{
    printf("glValidateProgramPipeline(" "%u)\n", pipeline);
    glad_glValidateProgramPipeline(pipeline);
}

void APIENTRY glGetProgramPipelineInfoLog(GLuint pipeline, GLsizei bufSize, GLsizei* length, GLchar* infoLog)
{
    printf("glGetProgramPipelineInfoLog(" "%u, %i, %p, %p)\n", pipeline, bufSize, length, infoLog);
    glad_glGetProgramPipelineInfoLog(pipeline, bufSize, length, infoLog);
}

void APIENTRY glVertexAttribL1d(GLuint index, GLdouble x)
{
    printf("glVertexAttribL1d(" "%u, %f)\n", index, x);
    glad_glVertexAttribL1d(index, x);
}

void APIENTRY glVertexAttribL2d(GLuint index, GLdouble x, GLdouble y)
{
    printf("glVertexAttribL2d(" "%u, %f, %f)\n", index, x, y);
    glad_glVertexAttribL2d(index, x, y);
}

void APIENTRY glVertexAttribL3d(GLuint index, GLdouble x, GLdouble y, GLdouble z)
{
    printf("glVertexAttribL3d(" "%u, %f, %f, %f)\n", index, x, y, z);
    glad_glVertexAttribL3d(index, x, y, z);
}

void APIENTRY glVertexAttribL4d(GLuint index, GLdouble x, GLdouble y, GLdouble z, GLdouble w)
{
    printf("glVertexAttribL4d(" "%u, %f, %f, %f, %f)\n", index, x, y, z, w);
    glad_glVertexAttribL4d(index, x, y, z, w);
}

void APIENTRY glVertexAttribL1dv(GLuint index, const GLdouble* v)
{
    printf("glVertexAttribL1dv(" "%u, %p)\n", index, v);
    glad_glVertexAttribL1dv(index, v);
}

void APIENTRY glVertexAttribL2dv(GLuint index, const GLdouble* v)
{
    printf("glVertexAttribL2dv(" "%u, %p)\n", index, v);
    glad_glVertexAttribL2dv(index, v);
}

void APIENTRY glVertexAttribL3dv(GLuint index, const GLdouble* v)
{
    printf("glVertexAttribL3dv(" "%u, %p)\n", index, v);
    glad_glVertexAttribL3dv(index, v);
}

void APIENTRY glVertexAttribL4dv(GLuint index, const GLdouble* v)
{
    printf("glVertexAttribL4dv(" "%u, %p)\n", index, v);
    glad_glVertexAttribL4dv(index, v);
}

void APIENTRY glVertexAttribLPointer(GLuint index, GLint size, GLenum type, GLsizei stride, const void* pointer)
{
    printf("glVertexAttribLPointer(" "%u, %i, %s, %i, %p)\n", index, size, E2S(type), stride, pointer);
    glad_glVertexAttribLPointer(index, size, type, stride, pointer);
}

void APIENTRY glGetVertexAttribLdv(GLuint index, GLenum pname, GLdouble* params)
{
    printf("glGetVertexAttribLdv(" "%u, %s, %p)\n", index, E2S(pname), params);
    glad_glGetVertexAttribLdv(index, pname, params);
}

void APIENTRY glViewportArrayv(GLuint first, GLsizei count, const GLfloat* v)
{
    printf("glViewportArrayv(" "%u, %i, %p)\n", first, count, v);
    glad_glViewportArrayv(first, count, v);
}

void APIENTRY glViewportIndexedf(GLuint index, GLfloat x, GLfloat y, GLfloat w, GLfloat h)
{
    printf("glViewportIndexedf(" "%u, %f, %f, %f, %f)\n", index, x, y, w, h);
    glad_glViewportIndexedf(index, x, y, w, h);
}

void APIENTRY glViewportIndexedfv(GLuint index, const GLfloat* v)
{
    printf("glViewportIndexedfv(" "%u, %p)\n", index, v);
    glad_glViewportIndexedfv(index, v);
}

void APIENTRY glScissorArrayv(GLuint first, GLsizei count, const GLint* v)
{
    printf("glScissorArrayv(" "%u, %i, %p)\n", first, count, v);
    glad_glScissorArrayv(first, count, v);
}

void APIENTRY glScissorIndexed(GLuint index, GLint left, GLint bottom, GLsizei width, GLsizei height)
{
    printf("glScissorIndexed(" "%u, %i, %i, %i, %i)\n", index, left, bottom, width, height);
    glad_glScissorIndexed(index, left, bottom, width, height);
}

void APIENTRY glScissorIndexedv(GLuint index, const GLint* v)
{
    printf("glScissorIndexedv(" "%u, %p)\n", index, v);
    glad_glScissorIndexedv(index, v);
}

void APIENTRY glDepthRangeArrayv(GLuint first, GLsizei count, const GLdouble* v)
{
    printf("glDepthRangeArrayv(" "%u, %i, %p)\n", first, count, v);
    glad_glDepthRangeArrayv(first, count, v);
}

void APIENTRY glDepthRangeIndexed(GLuint index, GLdouble n, GLdouble f)
{
    printf("glDepthRangeIndexed(" "%u, %f, %f)\n", index, n, f);
    glad_glDepthRangeIndexed(index, n, f);
}

void APIENTRY glGetFloati_v(GLenum target, GLuint index, GLfloat* data)
{
    printf("glGetFloati_v(" "%s, %u, %p)\n", E2S(target), index, data);
    glad_glGetFloati_v(target, index, data);
}

void APIENTRY glGetDoublei_v(GLenum target, GLuint index, GLdouble* data)
{
    printf("glGetDoublei_v(" "%s, %u, %p)\n", E2S(target), index, data);
    glad_glGetDoublei_v(target, index, data);
}

void APIENTRY glDrawArraysInstancedBaseInstance(GLenum mode, GLint first, GLsizei count, GLsizei instancecount, GLuint baseinstance)
{
    printf("glDrawArraysInstancedBaseInstance(" "%s, %i, %i, %i, %u)\n", E2S(mode), first, count, instancecount, baseinstance);
    glad_glDrawArraysInstancedBaseInstance(mode, first, count, instancecount, baseinstance);
}

void APIENTRY glDrawElementsInstancedBaseInstance(GLenum mode, GLsizei count, GLenum type, const void* indices, GLsizei instancecount, GLuint baseinstance)
{
    printf("glDrawElementsInstancedBaseInstance(" "%s, %i, %s, %p, %i, %u)\n", E2S(mode), count, E2S(type), indices, instancecount, baseinstance);
    glad_glDrawElementsInstancedBaseInstance(mode, count, type, indices, instancecount, baseinstance);
}

void APIENTRY glDrawElementsInstancedBaseVertexBaseInstance(GLenum mode, GLsizei count, GLenum type, const void* indices, GLsizei instancecount, GLint basevertex, GLuint baseinstance)
{
    printf("glDrawElementsInstancedBaseVertexBaseInstance(" "%s, %i, %s, %p, %i, %i, %u)\n", E2S(mode), count, E2S(type), indices, instancecount, basevertex, baseinstance);
    glad_glDrawElementsInstancedBaseVertexBaseInstance(mode, count, type, indices, instancecount, basevertex, baseinstance);
}

void APIENTRY glGetInternalformativ(GLenum target, GLenum internalformat, GLenum pname, GLsizei count, GLint* params)
{
    printf("glGetInternalformativ(" "%s, %s, %s, %i, %p)\n", E2S(target), E2S(internalformat), E2S(pname), count, params);
    glad_glGetInternalformativ(target, internalformat, pname, count, params);
}

void APIENTRY glGetActiveAtomicCounterBufferiv(GLuint program, GLuint bufferIndex, GLenum pname, GLint* params)
{
    printf("glGetActiveAtomicCounterBufferiv(" "%u, %u, %s, %p)\n", program, bufferIndex, E2S(pname), params);
    glad_glGetActiveAtomicCounterBufferiv(program, bufferIndex, pname, params);
}

void APIENTRY glBindImageTexture(GLuint unit, GLuint texture, GLint level, GLboolean layered, GLint layer, GLenum access, GLenum format)
{
    printf("glBindImageTexture(" "%u, %u, %i, %u, %i, %s, %s)\n", unit, texture, level, (unsigned int)(layered), layer, E2S(access), E2S(format));
    glad_glBindImageTexture(unit, texture, level, layered, layer, access, format);
}

void APIENTRY glMemoryBarrier(GLbitfield barriers)
{
    printf("glMemoryBarrier(" "%u)\n", (unsigned int)(barriers));
    glad_glMemoryBarrier(barriers);
}

void APIENTRY glTexStorage1D(GLenum target, GLsizei levels, GLenum internalformat, GLsizei width)
{
    printf("glTexStorage1D(" "%s, %i, %s, %i)\n", E2S(target), levels, E2S(internalformat), width);
    glad_glTexStorage1D(target, levels, internalformat, width);
}

void APIENTRY glTexStorage2D(GLenum target, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height)
{
    printf("glTexStorage2D(" "%s, %i, %s, %i, %i)\n", E2S(target), levels, E2S(internalformat), width, height);
    glad_glTexStorage2D(target, levels, internalformat, width, height);
}

void APIENTRY glTexStorage3D(GLenum target, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth)
{
    printf("glTexStorage3D(" "%s, %i, %s, %i, %i, %i)\n", E2S(target), levels, E2S(internalformat), width, height, depth);
    glad_glTexStorage3D(target, levels, internalformat, width, height, depth);
}

void APIENTRY glDrawTransformFeedbackInstanced(GLenum mode, GLuint id, GLsizei instancecount)
{
    printf("glDrawTransformFeedbackInstanced(" "%s, %u, %i)\n", E2S(mode), id, instancecount);
    glad_glDrawTransformFeedbackInstanced(mode, id, instancecount);
}

void APIENTRY glDrawTransformFeedbackStreamInstanced(GLenum mode, GLuint id, GLuint stream, GLsizei instancecount)
{
    printf("glDrawTransformFeedbackStreamInstanced(" "%s, %u, %u, %i)\n", E2S(mode), id, stream, instancecount);
    glad_glDrawTransformFeedbackStreamInstanced(mode, id, stream, instancecount);
}

void APIENTRY glClearBufferData(GLenum target, GLenum internalformat, GLenum format, GLenum type, const void* data)
{
    printf("glClearBufferData(" "%s, %s, %s, %s, %p)\n", E2S(target), E2S(internalformat), E2S(format), E2S(type), data);
    glad_glClearBufferData(target, internalformat, format, type, data);
}

void APIENTRY glClearBufferSubData(GLenum target, GLenum internalformat, GLintptr offset, GLsizeiptr size, GLenum format, GLenum type, const void* data)
{
    printf("glClearBufferSubData(" "%s, %s, %" PRId32", %" PRId32", %s, %s, %p)\n", E2S(target), E2S(internalformat), offset, size, E2S(format), E2S(type), data);
    glad_glClearBufferSubData(target, internalformat, offset, size, format, type, data);
}

void APIENTRY glDispatchCompute(GLuint num_groups_x, GLuint num_groups_y, GLuint num_groups_z)
{
    printf("glDispatchCompute(" "%u, %u, %u)\n", num_groups_x, num_groups_y, num_groups_z);
    glad_glDispatchCompute(num_groups_x, num_groups_y, num_groups_z);
}

void APIENTRY glDispatchComputeIndirect(GLintptr indirect)
{
    printf("glDispatchComputeIndirect(" "%" PRId32")\n", indirect);
    glad_glDispatchComputeIndirect(indirect);
}

void APIENTRY glCopyImageSubData(GLuint srcName, GLenum srcTarget, GLint srcLevel, GLint srcX, GLint srcY, GLint srcZ, GLuint dstName, GLenum dstTarget, GLint dstLevel, GLint dstX, GLint dstY, GLint dstZ, GLsizei srcWidth, GLsizei srcHeight, GLsizei srcDepth)
{
    printf("glCopyImageSubData(" "%u, %s, %i, %i, %i, %i, %u, %s, %i, %i, %i, %i, %i, %i, %i)\n", srcName, E2S(srcTarget), srcLevel, srcX, srcY, srcZ, dstName, E2S(dstTarget), dstLevel, dstX, dstY, dstZ, srcWidth, srcHeight, srcDepth);
    glad_glCopyImageSubData(srcName, srcTarget, srcLevel, srcX, srcY, srcZ, dstName, dstTarget, dstLevel, dstX, dstY, dstZ, srcWidth, srcHeight, srcDepth);
}

void APIENTRY glFramebufferParameteri(GLenum target, GLenum pname, GLint param)
{
    printf("glFramebufferParameteri(" "%s, %s, %i)\n", E2S(target), E2S(pname), param);
    glad_glFramebufferParameteri(target, pname, param);
}

void APIENTRY glGetFramebufferParameteriv(GLenum target, GLenum pname, GLint* params)
{
    printf("glGetFramebufferParameteriv(" "%s, %s, %p)\n", E2S(target), E2S(pname), params);
    glad_glGetFramebufferParameteriv(target, pname, params);
}

void APIENTRY glGetInternalformati64v(GLenum target, GLenum internalformat, GLenum pname, GLsizei count, GLint64* params)
{
    printf("glGetInternalformati64v(" "%s, %s, %s, %i, %p)\n", E2S(target), E2S(internalformat), E2S(pname), count, params);
    glad_glGetInternalformati64v(target, internalformat, pname, count, params);
}

void APIENTRY glInvalidateTexSubImage(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth)
{
    printf("glInvalidateTexSubImage(" "%u, %i, %i, %i, %i, %i, %i, %i)\n", texture, level, xoffset, yoffset, zoffset, width, height, depth);
    glad_glInvalidateTexSubImage(texture, level, xoffset, yoffset, zoffset, width, height, depth);
}

void APIENTRY glInvalidateTexImage(GLuint texture, GLint level)
{
    printf("glInvalidateTexImage(" "%u, %i)\n", texture, level);
    glad_glInvalidateTexImage(texture, level);
}

void APIENTRY glInvalidateBufferSubData(GLuint buffer, GLintptr offset, GLsizeiptr length)
{
    printf("glInvalidateBufferSubData(" "%u, %" PRId32", %" PRId32")\n", buffer, offset, length);
    glad_glInvalidateBufferSubData(buffer, offset, length);
}

void APIENTRY glInvalidateBufferData(GLuint buffer)
{
    printf("glInvalidateBufferData(" "%u)\n", buffer);
    glad_glInvalidateBufferData(buffer);
}

void APIENTRY glInvalidateFramebuffer(GLenum target, GLsizei numAttachments, const GLenum* attachments)
{
    printf("glInvalidateFramebuffer(" "%s, %i, %p)\n", E2S(target), numAttachments, attachments);
    glad_glInvalidateFramebuffer(target, numAttachments, attachments);
}

void APIENTRY glInvalidateSubFramebuffer(GLenum target, GLsizei numAttachments, const GLenum* attachments, GLint x, GLint y, GLsizei width, GLsizei height)
{
    printf("glInvalidateSubFramebuffer(" "%s, %i, %p, %i, %i, %i, %i)\n", E2S(target), numAttachments, attachments, x, y, width, height);
    glad_glInvalidateSubFramebuffer(target, numAttachments, attachments, x, y, width, height);
}

void APIENTRY glMultiDrawArraysIndirect(GLenum mode, const void* indirect, GLsizei drawcount, GLsizei stride)
{
    printf("glMultiDrawArraysIndirect(" "%s, %p, %i, %i)\n", E2S(mode), indirect, drawcount, stride);
    glad_glMultiDrawArraysIndirect(mode, indirect, drawcount, stride);
}

void APIENTRY glMultiDrawElementsIndirect(GLenum mode, GLenum type, const void* indirect, GLsizei drawcount, GLsizei stride)
{
    printf("glMultiDrawElementsIndirect(" "%s, %s, %p, %i, %i)\n", E2S(mode), E2S(type), indirect, drawcount, stride);
    glad_glMultiDrawElementsIndirect(mode, type, indirect, drawcount, stride);
}

void APIENTRY glGetProgramInterfaceiv(GLuint program, GLenum programInterface, GLenum pname, GLint* params)
{
    printf("glGetProgramInterfaceiv(" "%u, %s, %s, %p)\n", program, E2S(programInterface), E2S(pname), params);
    glad_glGetProgramInterfaceiv(program, programInterface, pname, params);
}

GLuint APIENTRY glGetProgramResourceIndex(GLuint program, GLenum programInterface, const GLchar* name)
{
    printf("glGetProgramResourceIndex(" "%u, %s, %p)\n", program, E2S(programInterface), name);
    GLuint const r = glad_glGetProgramResourceIndex(program, programInterface, name);
    return r;
}

void APIENTRY glGetProgramResourceName(GLuint program, GLenum programInterface, GLuint index, GLsizei bufSize, GLsizei* length, GLchar* name)
{
    printf("glGetProgramResourceName(" "%u, %s, %u, %i, %p, %p)\n", program, E2S(programInterface), index, bufSize, length, name);
    glad_glGetProgramResourceName(program, programInterface, index, bufSize, length, name);
}

void APIENTRY glGetProgramResourceiv(GLuint program, GLenum programInterface, GLuint index, GLsizei propCount, const GLenum* props, GLsizei count, GLsizei* length, GLint* params)
{
    printf("glGetProgramResourceiv(" "%u, %s, %u, %i, %p, %i, %p, %p)\n", program, E2S(programInterface), index, propCount, props, count, length, params);
    glad_glGetProgramResourceiv(program, programInterface, index, propCount, props, count, length, params);
}

GLint APIENTRY glGetProgramResourceLocation(GLuint program, GLenum programInterface, const GLchar* name)
{
    printf("glGetProgramResourceLocation(" "%u, %s, %p)\n", program, E2S(programInterface), name);
    GLint const r = glad_glGetProgramResourceLocation(program, programInterface, name);
    return r;
}

GLint APIENTRY glGetProgramResourceLocationIndex(GLuint program, GLenum programInterface, const GLchar* name)
{
    printf("glGetProgramResourceLocationIndex(" "%u, %s, %p)\n", program, E2S(programInterface), name);
    GLint const r = glad_glGetProgramResourceLocationIndex(program, programInterface, name);
    return r;
}

void APIENTRY glShaderStorageBlockBinding(GLuint program, GLuint storageBlockIndex, GLuint storageBlockBinding)
{
    printf("glShaderStorageBlockBinding(" "%u, %u, %u)\n", program, storageBlockIndex, storageBlockBinding);
    glad_glShaderStorageBlockBinding(program, storageBlockIndex, storageBlockBinding);
}

void APIENTRY glTexBufferRange(GLenum target, GLenum internalformat, GLuint buffer, GLintptr offset, GLsizeiptr size)
{
    printf("glTexBufferRange(" "%s, %s, %u, %" PRId32", %" PRId32")\n", E2S(target), E2S(internalformat), buffer, offset, size);
    glad_glTexBufferRange(target, internalformat, buffer, offset, size);
}

void APIENTRY glTexStorage2DMultisample(GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLboolean fixedsamplelocations)
{
    printf("glTexStorage2DMultisample(" "%s, %i, %s, %i, %i, %u)\n", E2S(target), samples, E2S(internalformat), width, height, (unsigned int)(fixedsamplelocations));
    glad_glTexStorage2DMultisample(target, samples, internalformat, width, height, fixedsamplelocations);
}

void APIENTRY glTexStorage3DMultisample(GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLboolean fixedsamplelocations)
{
    printf("glTexStorage3DMultisample(" "%s, %i, %s, %i, %i, %i, %u)\n", E2S(target), samples, E2S(internalformat), width, height, depth, (unsigned int)(fixedsamplelocations));
    glad_glTexStorage3DMultisample(target, samples, internalformat, width, height, depth, fixedsamplelocations);
}

void APIENTRY glTextureView(GLuint texture, GLenum target, GLuint origtexture, GLenum internalformat, GLuint minlevel, GLuint numlevels, GLuint minlayer, GLuint numlayers)
{
    printf("glTextureView(" "%u, %s, %u, %s, %u, %u, %u, %u)\n", texture, E2S(target), origtexture, E2S(internalformat), minlevel, numlevels, minlayer, numlayers);
    glad_glTextureView(texture, target, origtexture, internalformat, minlevel, numlevels, minlayer, numlayers);
}

void APIENTRY glBindVertexBuffer(GLuint bindingindex, GLuint buffer, GLintptr offset, GLsizei stride)
{
    printf("glBindVertexBuffer(" "%u, %u, %" PRId32", %i)\n", bindingindex, buffer, offset, stride);
    glad_glBindVertexBuffer(bindingindex, buffer, offset, stride);
}

void APIENTRY glVertexAttribFormat(GLuint attribindex, GLint size, GLenum type, GLboolean normalized, GLuint relativeoffset)
{
    printf("glVertexAttribFormat(" "%u, %i, %s, %u, %u)\n", attribindex, size, E2S(type), (unsigned int)(normalized), relativeoffset);
    glad_glVertexAttribFormat(attribindex, size, type, normalized, relativeoffset);
}

void APIENTRY glVertexAttribIFormat(GLuint attribindex, GLint size, GLenum type, GLuint relativeoffset)
{
    printf("glVertexAttribIFormat(" "%u, %i, %s, %u)\n", attribindex, size, E2S(type), relativeoffset);
    glad_glVertexAttribIFormat(attribindex, size, type, relativeoffset);
}

void APIENTRY glVertexAttribLFormat(GLuint attribindex, GLint size, GLenum type, GLuint relativeoffset)
{
    printf("glVertexAttribLFormat(" "%u, %i, %s, %u)\n", attribindex, size, E2S(type), relativeoffset);
    glad_glVertexAttribLFormat(attribindex, size, type, relativeoffset);
}

void APIENTRY glVertexAttribBinding(GLuint attribindex, GLuint bindingindex)
{
    printf("glVertexAttribBinding(" "%u, %u)\n", attribindex, bindingindex);
    glad_glVertexAttribBinding(attribindex, bindingindex);
}

void APIENTRY glVertexBindingDivisor(GLuint bindingindex, GLuint divisor)
{
    printf("glVertexBindingDivisor(" "%u, %u)\n", bindingindex, divisor);
    glad_glVertexBindingDivisor(bindingindex, divisor);
}

void APIENTRY glDebugMessageControl(GLenum source, GLenum type, GLenum severity, GLsizei count, const GLuint* ids, GLboolean enabled)
{
    printf("glDebugMessageControl(" "%s, %s, %s, %i, %p, %u)\n", E2S(source), E2S(type), E2S(severity), count, ids, (unsigned int)(enabled));
    glad_glDebugMessageControl(source, type, severity, count, ids, enabled);
}

void APIENTRY glDebugMessageInsert(GLenum source, GLenum type, GLuint id, GLenum severity, GLsizei length, const GLchar* buf)
{
    printf("glDebugMessageInsert(" "%s, %s, %u, %s, %i, %p)\n", E2S(source), E2S(type), id, E2S(severity), length, buf);
    glad_glDebugMessageInsert(source, type, id, severity, length, buf);
}

void APIENTRY glDebugMessageCallback(GLDEBUGPROC callback, const void* userParam)
{
    printf("glDebugMessageCallback(" "%p, %p)\n", callback, userParam);
    glad_glDebugMessageCallback(callback, userParam);
}

GLuint APIENTRY glGetDebugMessageLog(GLuint count, GLsizei bufSize, GLenum* sources, GLenum* types, GLuint* ids, GLenum* severities, GLsizei* lengths, GLchar* messageLog)
{
    printf("glGetDebugMessageLog(" "%u, %i, %p, %p, %p, %p, %p, %p)\n", count, bufSize, sources, types, ids, severities, lengths, messageLog);
    GLuint const r = glad_glGetDebugMessageLog(count, bufSize, sources, types, ids, severities, lengths, messageLog);
    return r;
}

void APIENTRY glPushDebugGroup(GLenum source, GLuint id, GLsizei length, const GLchar* message)
{
    printf("glPushDebugGroup(" "%s, %u, %i, %p)\n", E2S(source), id, length, message);
    glad_glPushDebugGroup(source, id, length, message);
}

void APIENTRY glPopDebugGroup()
{
    printf("glPopDebugGroup()\n");
    glad_glPopDebugGroup();
}

void APIENTRY glObjectLabel(GLenum identifier, GLuint name, GLsizei length, const GLchar* label)
{
    printf("glObjectLabel(" "%s, %u, %i, %p)\n", E2S(identifier), name, length, label);
    glad_glObjectLabel(identifier, name, length, label);
}

void APIENTRY glGetObjectLabel(GLenum identifier, GLuint name, GLsizei bufSize, GLsizei* length, GLchar* label)
{
    printf("glGetObjectLabel(" "%s, %u, %i, %p, %p)\n", E2S(identifier), name, bufSize, length, label);
    glad_glGetObjectLabel(identifier, name, bufSize, length, label);
}

void APIENTRY glObjectPtrLabel(const void* ptr, GLsizei length, const GLchar* label)
{
    printf("glObjectPtrLabel(" "%p, %i, %p)\n", ptr, length, label);
    glad_glObjectPtrLabel(ptr, length, label);
}

void APIENTRY glGetObjectPtrLabel(const void* ptr, GLsizei bufSize, GLsizei* length, GLchar* label)
{
    printf("glGetObjectPtrLabel(" "%p, %i, %p, %p)\n", ptr, bufSize, length, label);
    glad_glGetObjectPtrLabel(ptr, bufSize, length, label);
}

void APIENTRY glBufferStorage(GLenum target, GLsizeiptr size, const void* data, GLbitfield flags)
{
    printf("glBufferStorage(" "%s, %" PRId32", %p, %u)\n", E2S(target), size, data, (unsigned int)(flags));
    glad_glBufferStorage(target, size, data, flags);
}

void APIENTRY glClearTexImage(GLuint texture, GLint level, GLenum format, GLenum type, const void* data)
{
    printf("glClearTexImage(" "%u, %i, %s, %s, %p)\n", texture, level, E2S(format), E2S(type), data);
    glad_glClearTexImage(texture, level, format, type, data);
}

void APIENTRY glClearTexSubImage(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const void* data)
{
    printf("glClearTexSubImage(" "%u, %i, %i, %i, %i, %i, %i, %i, %s, %s, %p)\n", texture, level, xoffset, yoffset, zoffset, width, height, depth, E2S(format), E2S(type), data);
    glad_glClearTexSubImage(texture, level, xoffset, yoffset, zoffset, width, height, depth, format, type, data);
}

void APIENTRY glBindBuffersBase(GLenum target, GLuint first, GLsizei count, const GLuint* buffers)
{
    printf("glBindBuffersBase(" "%s, %u, %i, %p)\n", E2S(target), first, count, buffers);
    glad_glBindBuffersBase(target, first, count, buffers);
}

void APIENTRY glBindBuffersRange(GLenum target, GLuint first, GLsizei count, const GLuint* buffers, const GLintptr* offsets, const GLsizeiptr* sizes)
{
    printf("glBindBuffersRange(" "%s, %u, %i, %p, %p, %p)\n", E2S(target), first, count, buffers, offsets, sizes);
    glad_glBindBuffersRange(target, first, count, buffers, offsets, sizes);
}

void APIENTRY glBindTextures(GLuint first, GLsizei count, const GLuint* textures)
{
    printf("glBindTextures(" "%u, %i, %p)\n", first, count, textures);
    glad_glBindTextures(first, count, textures);
}

void APIENTRY glBindSamplers(GLuint first, GLsizei count, const GLuint* samplers)
{
    printf("glBindSamplers(" "%u, %i, %p)\n", first, count, samplers);
    glad_glBindSamplers(first, count, samplers);
}

void APIENTRY glBindImageTextures(GLuint first, GLsizei count, const GLuint* textures)
{
    printf("glBindImageTextures(" "%u, %i, %p)\n", first, count, textures);
    glad_glBindImageTextures(first, count, textures);
}

void APIENTRY glBindVertexBuffers(GLuint first, GLsizei count, const GLuint* buffers, const GLintptr* offsets, const GLsizei* strides)
{
    printf("glBindVertexBuffers(" "%u, %i, %p, %p, %p)\n", first, count, buffers, offsets, strides);
    glad_glBindVertexBuffers(first, count, buffers, offsets, strides);
}

void APIENTRY glClipControl(GLenum origin, GLenum depth)
{
    printf("glClipControl(" "%s, %s)\n", E2S(origin), E2S(depth));
    glad_glClipControl(origin, depth);
}

void APIENTRY glCreateTransformFeedbacks(GLsizei n, GLuint* ids)
{
    printf("glCreateTransformFeedbacks(" "%i, %p)\n", n, ids);
    glad_glCreateTransformFeedbacks(n, ids);
}

void APIENTRY glTransformFeedbackBufferBase(GLuint xfb, GLuint index, GLuint buffer)
{
    printf("glTransformFeedbackBufferBase(" "%u, %u, %u)\n", xfb, index, buffer);
    glad_glTransformFeedbackBufferBase(xfb, index, buffer);
}

void APIENTRY glTransformFeedbackBufferRange(GLuint xfb, GLuint index, GLuint buffer, GLintptr offset, GLsizeiptr size)
{
    printf("glTransformFeedbackBufferRange(" "%u, %u, %u, %" PRId32", %" PRId32")\n", xfb, index, buffer, offset, size);
    glad_glTransformFeedbackBufferRange(xfb, index, buffer, offset, size);
}

void APIENTRY glGetTransformFeedbackiv(GLuint xfb, GLenum pname, GLint* param)
{
    printf("glGetTransformFeedbackiv(" "%u, %s, %p)\n", xfb, E2S(pname), param);
    glad_glGetTransformFeedbackiv(xfb, pname, param);
}

void APIENTRY glGetTransformFeedbacki_v(GLuint xfb, GLenum pname, GLuint index, GLint* param)
{
    printf("glGetTransformFeedbacki_v(" "%u, %s, %u, %p)\n", xfb, E2S(pname), index, param);
    glad_glGetTransformFeedbacki_v(xfb, pname, index, param);
}

void APIENTRY glGetTransformFeedbacki64_v(GLuint xfb, GLenum pname, GLuint index, GLint64* param)
{
    printf("glGetTransformFeedbacki64_v(" "%u, %s, %u, %p)\n", xfb, E2S(pname), index, param);
    glad_glGetTransformFeedbacki64_v(xfb, pname, index, param);
}

void APIENTRY glCreateBuffers(GLsizei n, GLuint* buffers)
{
    printf("glCreateBuffers(" "%i, %p)\n", n, buffers);
    glad_glCreateBuffers(n, buffers);
}

void APIENTRY glNamedBufferStorage(GLuint buffer, GLsizeiptr size, const void* data, GLbitfield flags)
{
    printf("glNamedBufferStorage(" "%u, %" PRId32", %p, %u)\n", buffer, size, data, (unsigned int)(flags));
    glad_glNamedBufferStorage(buffer, size, data, flags);
}

void APIENTRY glNamedBufferData(GLuint buffer, GLsizeiptr size, const void* data, GLenum usage)
{
    printf("glNamedBufferData(" "%u, %" PRId32", %p, %s)\n", buffer, size, data, E2S(usage));
    glad_glNamedBufferData(buffer, size, data, usage);
}

void APIENTRY glNamedBufferSubData(GLuint buffer, GLintptr offset, GLsizeiptr size, const void* data)
{
    printf("glNamedBufferSubData(" "%u, %" PRId32", %" PRId32", %p)\n", buffer, offset, size, data);
    glad_glNamedBufferSubData(buffer, offset, size, data);
}

void APIENTRY glCopyNamedBufferSubData(GLuint readBuffer, GLuint writeBuffer, GLintptr readOffset, GLintptr writeOffset, GLsizeiptr size)
{
    printf("glCopyNamedBufferSubData(" "%u, %u, %" PRId32", %" PRId32", %" PRId32")\n", readBuffer, writeBuffer, readOffset, writeOffset, size);
    glad_glCopyNamedBufferSubData(readBuffer, writeBuffer, readOffset, writeOffset, size);
}

void APIENTRY glClearNamedBufferData(GLuint buffer, GLenum internalformat, GLenum format, GLenum type, const void* data)
{
    printf("glClearNamedBufferData(" "%u, %s, %s, %s, %p)\n", buffer, E2S(internalformat), E2S(format), E2S(type), data);
    glad_glClearNamedBufferData(buffer, internalformat, format, type, data);
}

void APIENTRY glClearNamedBufferSubData(GLuint buffer, GLenum internalformat, GLintptr offset, GLsizeiptr size, GLenum format, GLenum type, const void* data)
{
    printf("glClearNamedBufferSubData(" "%u, %s, %" PRId32", %" PRId32", %s, %s, %p)\n", buffer, E2S(internalformat), offset, size, E2S(format), E2S(type), data);
    glad_glClearNamedBufferSubData(buffer, internalformat, offset, size, format, type, data);
}

void* APIENTRY glMapNamedBuffer(GLuint buffer, GLenum access)
{
    printf("glMapNamedBuffer(" "%u, %s)\n", buffer, E2S(access));
    void* const r = glad_glMapNamedBuffer(buffer, access);
    return r;
}

void* APIENTRY glMapNamedBufferRange(GLuint buffer, GLintptr offset, GLsizeiptr length, GLbitfield access)
{
    printf("glMapNamedBufferRange(" "%u, %" PRId32", %" PRId32", %u)\n", buffer, offset, length, (unsigned int)(access));
    void* const r = glad_glMapNamedBufferRange(buffer, offset, length, access);
    return r;
}

GLboolean APIENTRY glUnmapNamedBuffer(GLuint buffer)
{
    printf("glUnmapNamedBuffer(" "%u)\n", buffer);
    GLboolean const r = glad_glUnmapNamedBuffer(buffer);
    return r;
}

void APIENTRY glFlushMappedNamedBufferRange(GLuint buffer, GLintptr offset, GLsizeiptr length)
{
    printf("glFlushMappedNamedBufferRange(" "%u, %" PRId32", %" PRId32")\n", buffer, offset, length);
    glad_glFlushMappedNamedBufferRange(buffer, offset, length);
}

void APIENTRY glGetNamedBufferParameteriv(GLuint buffer, GLenum pname, GLint* params)
{
    printf("glGetNamedBufferParameteriv(" "%u, %s, %p)\n", buffer, E2S(pname), params);
    glad_glGetNamedBufferParameteriv(buffer, pname, params);
}

void APIENTRY glGetNamedBufferParameteri64v(GLuint buffer, GLenum pname, GLint64* params)
{
    printf("glGetNamedBufferParameteri64v(" "%u, %s, %p)\n", buffer, E2S(pname), params);
    glad_glGetNamedBufferParameteri64v(buffer, pname, params);
}

void APIENTRY glGetNamedBufferPointerv(GLuint buffer, GLenum pname, void** params)
{
    printf("glGetNamedBufferPointerv(" "%u, %s, %p)\n", buffer, E2S(pname), params);
    glad_glGetNamedBufferPointerv(buffer, pname, params);
}

void APIENTRY glGetNamedBufferSubData(GLuint buffer, GLintptr offset, GLsizeiptr size, void* data)
{
    printf("glGetNamedBufferSubData(" "%u, %" PRId32", %" PRId32", %p)\n", buffer, offset, size, data);
    glad_glGetNamedBufferSubData(buffer, offset, size, data);
}

void APIENTRY glCreateFramebuffers(GLsizei n, GLuint* framebuffers)
{
    printf("glCreateFramebuffers(" "%i, %p)\n", n, framebuffers);
    glad_glCreateFramebuffers(n, framebuffers);
}

void APIENTRY glNamedFramebufferRenderbuffer(GLuint framebuffer, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer)
{
    printf("glNamedFramebufferRenderbuffer(" "%u, %s, %s, %u)\n", framebuffer, E2S(attachment), E2S(renderbuffertarget), renderbuffer);
    glad_glNamedFramebufferRenderbuffer(framebuffer, attachment, renderbuffertarget, renderbuffer);
}

void APIENTRY glNamedFramebufferParameteri(GLuint framebuffer, GLenum pname, GLint param)
{
    printf("glNamedFramebufferParameteri(" "%u, %s, %i)\n", framebuffer, E2S(pname), param);
    glad_glNamedFramebufferParameteri(framebuffer, pname, param);
}

void APIENTRY glNamedFramebufferTexture(GLuint framebuffer, GLenum attachment, GLuint texture, GLint level)
{
    printf("glNamedFramebufferTexture(" "%u, %s, %u, %i)\n", framebuffer, E2S(attachment), texture, level);
    glad_glNamedFramebufferTexture(framebuffer, attachment, texture, level);
}

void APIENTRY glNamedFramebufferTextureLayer(GLuint framebuffer, GLenum attachment, GLuint texture, GLint level, GLint layer)
{
    printf("glNamedFramebufferTextureLayer(" "%u, %s, %u, %i, %i)\n", framebuffer, E2S(attachment), texture, level, layer);
    glad_glNamedFramebufferTextureLayer(framebuffer, attachment, texture, level, layer);
}

void APIENTRY glNamedFramebufferDrawBuffer(GLuint framebuffer, GLenum buf)
{
    printf("glNamedFramebufferDrawBuffer(" "%u, %s)\n", framebuffer, E2S(buf));
    glad_glNamedFramebufferDrawBuffer(framebuffer, buf);
}

void APIENTRY glNamedFramebufferDrawBuffers(GLuint framebuffer, GLsizei n, const GLenum* bufs)
{
    printf("glNamedFramebufferDrawBuffers(" "%u, %i, %p)\n", framebuffer, n, bufs);
    glad_glNamedFramebufferDrawBuffers(framebuffer, n, bufs);
}

void APIENTRY glNamedFramebufferReadBuffer(GLuint framebuffer, GLenum src)
{
    printf("glNamedFramebufferReadBuffer(" "%u, %s)\n", framebuffer, E2S(src));
    glad_glNamedFramebufferReadBuffer(framebuffer, src);
}

void APIENTRY glInvalidateNamedFramebufferData(GLuint framebuffer, GLsizei numAttachments, const GLenum* attachments)
{
    printf("glInvalidateNamedFramebufferData(" "%u, %i, %p)\n", framebuffer, numAttachments, attachments);
    glad_glInvalidateNamedFramebufferData(framebuffer, numAttachments, attachments);
}

void APIENTRY glInvalidateNamedFramebufferSubData(GLuint framebuffer, GLsizei numAttachments, const GLenum* attachments, GLint x, GLint y, GLsizei width, GLsizei height)
{
    printf("glInvalidateNamedFramebufferSubData(" "%u, %i, %p, %i, %i, %i, %i)\n", framebuffer, numAttachments, attachments, x, y, width, height);
    glad_glInvalidateNamedFramebufferSubData(framebuffer, numAttachments, attachments, x, y, width, height);
}

void APIENTRY glClearNamedFramebufferiv(GLuint framebuffer, GLenum buffer, GLint drawbuffer, const GLint* value)
{
    printf("glClearNamedFramebufferiv(" "%u, %s, %i, %p)\n", framebuffer, E2S(buffer), drawbuffer, value);
    glad_glClearNamedFramebufferiv(framebuffer, buffer, drawbuffer, value);
}

void APIENTRY glClearNamedFramebufferuiv(GLuint framebuffer, GLenum buffer, GLint drawbuffer, const GLuint* value)
{
    printf("glClearNamedFramebufferuiv(" "%u, %s, %i, %p)\n", framebuffer, E2S(buffer), drawbuffer, value);
    glad_glClearNamedFramebufferuiv(framebuffer, buffer, drawbuffer, value);
}

void APIENTRY glClearNamedFramebufferfv(GLuint framebuffer, GLenum buffer, GLint drawbuffer, const GLfloat* value)
{
    printf("glClearNamedFramebufferfv(" "%u, %s, %i, %p)\n", framebuffer, E2S(buffer), drawbuffer, value);
    glad_glClearNamedFramebufferfv(framebuffer, buffer, drawbuffer, value);
}

void APIENTRY glClearNamedFramebufferfi(GLuint framebuffer, GLenum buffer, GLint drawbuffer, GLfloat depth, GLint stencil)
{
    printf("glClearNamedFramebufferfi(" "%u, %s, %i, %f, %i)\n", framebuffer, E2S(buffer), drawbuffer, depth, stencil);
    glad_glClearNamedFramebufferfi(framebuffer, buffer, drawbuffer, depth, stencil);
}

void APIENTRY glBlitNamedFramebuffer(GLuint readFramebuffer, GLuint drawFramebuffer, GLint srcX0, GLint srcY0, GLint srcX1, GLint srcY1, GLint dstX0, GLint dstY0, GLint dstX1, GLint dstY1, GLbitfield mask, GLenum filter)
{
    printf("glBlitNamedFramebuffer(" "%u, %u, %i, %i, %i, %i, %i, %i, %i, %i, %u, %s)\n", readFramebuffer, drawFramebuffer, srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, (unsigned int)(mask), E2S(filter));
    glad_glBlitNamedFramebuffer(readFramebuffer, drawFramebuffer, srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, mask, filter);
}

GLenum APIENTRY glCheckNamedFramebufferStatus(GLuint framebuffer, GLenum target)
{
    printf("glCheckNamedFramebufferStatus(" "%u, %s)\n", framebuffer, E2S(target));
    GLenum const r = glad_glCheckNamedFramebufferStatus(framebuffer, target);
    return r;
}

void APIENTRY glGetNamedFramebufferParameteriv(GLuint framebuffer, GLenum pname, GLint* param)
{
    printf("glGetNamedFramebufferParameteriv(" "%u, %s, %p)\n", framebuffer, E2S(pname), param);
    glad_glGetNamedFramebufferParameteriv(framebuffer, pname, param);
}

void APIENTRY glGetNamedFramebufferAttachmentParameteriv(GLuint framebuffer, GLenum attachment, GLenum pname, GLint* params)
{
    printf("glGetNamedFramebufferAttachmentParameteriv(" "%u, %s, %s, %p)\n", framebuffer, E2S(attachment), E2S(pname), params);
    glad_glGetNamedFramebufferAttachmentParameteriv(framebuffer, attachment, pname, params);
}

void APIENTRY glCreateRenderbuffers(GLsizei n, GLuint* renderbuffers)
{
    printf("glCreateRenderbuffers(" "%i, %p)\n", n, renderbuffers);
    glad_glCreateRenderbuffers(n, renderbuffers);
}

void APIENTRY glNamedRenderbufferStorage(GLuint renderbuffer, GLenum internalformat, GLsizei width, GLsizei height)
{
    printf("glNamedRenderbufferStorage(" "%u, %s, %i, %i)\n", renderbuffer, E2S(internalformat), width, height);
    glad_glNamedRenderbufferStorage(renderbuffer, internalformat, width, height);
}

void APIENTRY glNamedRenderbufferStorageMultisample(GLuint renderbuffer, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height)
{
    printf("glNamedRenderbufferStorageMultisample(" "%u, %i, %s, %i, %i)\n", renderbuffer, samples, E2S(internalformat), width, height);
    glad_glNamedRenderbufferStorageMultisample(renderbuffer, samples, internalformat, width, height);
}

void APIENTRY glGetNamedRenderbufferParameteriv(GLuint renderbuffer, GLenum pname, GLint* params)
{
    printf("glGetNamedRenderbufferParameteriv(" "%u, %s, %p)\n", renderbuffer, E2S(pname), params);
    glad_glGetNamedRenderbufferParameteriv(renderbuffer, pname, params);
}

void APIENTRY glCreateTextures(GLenum target, GLsizei n, GLuint* textures)
{
    printf("glCreateTextures(" "%s, %i, %p)\n", E2S(target), n, textures);
    glad_glCreateTextures(target, n, textures);
}

void APIENTRY glTextureBuffer(GLuint texture, GLenum internalformat, GLuint buffer)
{
    printf("glTextureBuffer(" "%u, %s, %u)\n", texture, E2S(internalformat), buffer);
    glad_glTextureBuffer(texture, internalformat, buffer);
}

void APIENTRY glTextureBufferRange(GLuint texture, GLenum internalformat, GLuint buffer, GLintptr offset, GLsizeiptr size)
{
    printf("glTextureBufferRange(" "%u, %s, %u, %" PRId32", %" PRId32")\n", texture, E2S(internalformat), buffer, offset, size);
    glad_glTextureBufferRange(texture, internalformat, buffer, offset, size);
}

void APIENTRY glTextureStorage1D(GLuint texture, GLsizei levels, GLenum internalformat, GLsizei width)
{
    printf("glTextureStorage1D(" "%u, %i, %s, %i)\n", texture, levels, E2S(internalformat), width);
    glad_glTextureStorage1D(texture, levels, internalformat, width);
}

void APIENTRY glTextureStorage2D(GLuint texture, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height)
{
    printf("glTextureStorage2D(" "%u, %i, %s, %i, %i)\n", texture, levels, E2S(internalformat), width, height);
    glad_glTextureStorage2D(texture, levels, internalformat, width, height);
}

void APIENTRY glTextureStorage3D(GLuint texture, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth)
{
    printf("glTextureStorage3D(" "%u, %i, %s, %i, %i, %i)\n", texture, levels, E2S(internalformat), width, height, depth);
    glad_glTextureStorage3D(texture, levels, internalformat, width, height, depth);
}

void APIENTRY glTextureStorage2DMultisample(GLuint texture, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLboolean fixedsamplelocations)
{
    printf("glTextureStorage2DMultisample(" "%u, %i, %s, %i, %i, %u)\n", texture, samples, E2S(internalformat), width, height, (unsigned int)(fixedsamplelocations));
    glad_glTextureStorage2DMultisample(texture, samples, internalformat, width, height, fixedsamplelocations);
}

void APIENTRY glTextureStorage3DMultisample(GLuint texture, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLboolean fixedsamplelocations)
{
    printf("glTextureStorage3DMultisample(" "%u, %i, %s, %i, %i, %i, %u)\n", texture, samples, E2S(internalformat), width, height, depth, (unsigned int)(fixedsamplelocations));
    glad_glTextureStorage3DMultisample(texture, samples, internalformat, width, height, depth, fixedsamplelocations);
}

void APIENTRY glTextureSubImage1D(GLuint texture, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum type, const void* pixels)
{
    printf("glTextureSubImage1D(" "%u, %i, %i, %i, %s, %s, %p)\n", texture, level, xoffset, width, E2S(format), E2S(type), pixels);
    glad_glTextureSubImage1D(texture, level, xoffset, width, format, type, pixels);
}

void APIENTRY glTextureSubImage2D(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const void* pixels)
{
    printf("glTextureSubImage2D(" "%u, %i, %i, %i, %i, %i, %s, %s, %p)\n", texture, level, xoffset, yoffset, width, height, E2S(format), E2S(type), pixels);
    glad_glTextureSubImage2D(texture, level, xoffset, yoffset, width, height, format, type, pixels);
}

void APIENTRY glTextureSubImage3D(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const void* pixels)
{
    printf("glTextureSubImage3D(" "%u, %i, %i, %i, %i, %i, %i, %i, %s, %s, %p)\n", texture, level, xoffset, yoffset, zoffset, width, height, depth, E2S(format), E2S(type), pixels);
    glad_glTextureSubImage3D(texture, level, xoffset, yoffset, zoffset, width, height, depth, format, type, pixels);
}

void APIENTRY glCompressedTextureSubImage1D(GLuint texture, GLint level, GLint xoffset, GLsizei width, GLenum format, GLsizei imageSize, const void* data)
{
    printf("glCompressedTextureSubImage1D(" "%u, %i, %i, %i, %s, %i, %p)\n", texture, level, xoffset, width, E2S(format), imageSize, data);
    glad_glCompressedTextureSubImage1D(texture, level, xoffset, width, format, imageSize, data);
}

void APIENTRY glCompressedTextureSubImage2D(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, const void* data)
{
    printf("glCompressedTextureSubImage2D(" "%u, %i, %i, %i, %i, %i, %s, %i, %p)\n", texture, level, xoffset, yoffset, width, height, E2S(format), imageSize, data);
    glad_glCompressedTextureSubImage2D(texture, level, xoffset, yoffset, width, height, format, imageSize, data);
}

void APIENTRY glCompressedTextureSubImage3D(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLsizei imageSize, const void* data)
{
    printf("glCompressedTextureSubImage3D(" "%u, %i, %i, %i, %i, %i, %i, %i, %s, %i, %p)\n", texture, level, xoffset, yoffset, zoffset, width, height, depth, E2S(format), imageSize, data);
    glad_glCompressedTextureSubImage3D(texture, level, xoffset, yoffset, zoffset, width, height, depth, format, imageSize, data);
}

void APIENTRY glCopyTextureSubImage1D(GLuint texture, GLint level, GLint xoffset, GLint x, GLint y, GLsizei width)
{
    printf("glCopyTextureSubImage1D(" "%u, %i, %i, %i, %i, %i)\n", texture, level, xoffset, x, y, width);
    glad_glCopyTextureSubImage1D(texture, level, xoffset, x, y, width);
}

void APIENTRY glCopyTextureSubImage2D(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height)
{
    printf("glCopyTextureSubImage2D(" "%u, %i, %i, %i, %i, %i, %i, %i)\n", texture, level, xoffset, yoffset, x, y, width, height);
    glad_glCopyTextureSubImage2D(texture, level, xoffset, yoffset, x, y, width, height);
}

void APIENTRY glCopyTextureSubImage3D(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLint x, GLint y, GLsizei width, GLsizei height)
{
    printf("glCopyTextureSubImage3D(" "%u, %i, %i, %i, %i, %i, %i, %i, %i)\n", texture, level, xoffset, yoffset, zoffset, x, y, width, height);
    glad_glCopyTextureSubImage3D(texture, level, xoffset, yoffset, zoffset, x, y, width, height);
}

void APIENTRY glTextureParameterf(GLuint texture, GLenum pname, GLfloat param)
{
    printf("glTextureParameterf(" "%u, %s, %f)\n", texture, E2S(pname), param);
    glad_glTextureParameterf(texture, pname, param);
}

void APIENTRY glTextureParameterfv(GLuint texture, GLenum pname, const GLfloat* param)
{
    printf("glTextureParameterfv(" "%u, %s, %p)\n", texture, E2S(pname), param);
    glad_glTextureParameterfv(texture, pname, param);
}

void APIENTRY glTextureParameteri(GLuint texture, GLenum pname, GLint param)
{
    printf("glTextureParameteri(" "%u, %s, %i)\n", texture, E2S(pname), param);
    glad_glTextureParameteri(texture, pname, param);
}

void APIENTRY glTextureParameterIiv(GLuint texture, GLenum pname, const GLint* params)
{
    printf("glTextureParameterIiv(" "%u, %s, %p)\n", texture, E2S(pname), params);
    glad_glTextureParameterIiv(texture, pname, params);
}

void APIENTRY glTextureParameterIuiv(GLuint texture, GLenum pname, const GLuint* params)
{
    printf("glTextureParameterIuiv(" "%u, %s, %p)\n", texture, E2S(pname), params);
    glad_glTextureParameterIuiv(texture, pname, params);
}

void APIENTRY glTextureParameteriv(GLuint texture, GLenum pname, const GLint* param)
{
    printf("glTextureParameteriv(" "%u, %s, %p)\n", texture, E2S(pname), param);
    glad_glTextureParameteriv(texture, pname, param);
}

void APIENTRY glGenerateTextureMipmap(GLuint texture)
{
    printf("glGenerateTextureMipmap(" "%u)\n", texture);
    glad_glGenerateTextureMipmap(texture);
}

void APIENTRY glBindTextureUnit(GLuint unit, GLuint texture)
{
    printf("glBindTextureUnit(" "%u, %u)\n", unit, texture);
    glad_glBindTextureUnit(unit, texture);
}

void APIENTRY glGetTextureImage(GLuint texture, GLint level, GLenum format, GLenum type, GLsizei bufSize, void* pixels)
{
    printf("glGetTextureImage(" "%u, %i, %s, %s, %i, %p)\n", texture, level, E2S(format), E2S(type), bufSize, pixels);
    glad_glGetTextureImage(texture, level, format, type, bufSize, pixels);
}

void APIENTRY glGetCompressedTextureImage(GLuint texture, GLint level, GLsizei bufSize, void* pixels)
{
    printf("glGetCompressedTextureImage(" "%u, %i, %i, %p)\n", texture, level, bufSize, pixels);
    glad_glGetCompressedTextureImage(texture, level, bufSize, pixels);
}

void APIENTRY glGetTextureLevelParameterfv(GLuint texture, GLint level, GLenum pname, GLfloat* params)
{
    printf("glGetTextureLevelParameterfv(" "%u, %i, %s, %p)\n", texture, level, E2S(pname), params);
    glad_glGetTextureLevelParameterfv(texture, level, pname, params);
}

void APIENTRY glGetTextureLevelParameteriv(GLuint texture, GLint level, GLenum pname, GLint* params)
{
    printf("glGetTextureLevelParameteriv(" "%u, %i, %s, %p)\n", texture, level, E2S(pname), params);
    glad_glGetTextureLevelParameteriv(texture, level, pname, params);
}

void APIENTRY glGetTextureParameterfv(GLuint texture, GLenum pname, GLfloat* params)
{
    printf("glGetTextureParameterfv(" "%u, %s, %p)\n", texture, E2S(pname), params);
    glad_glGetTextureParameterfv(texture, pname, params);
}

void APIENTRY glGetTextureParameterIiv(GLuint texture, GLenum pname, GLint* params)
{
    printf("glGetTextureParameterIiv(" "%u, %s, %p)\n", texture, E2S(pname), params);
    glad_glGetTextureParameterIiv(texture, pname, params);
}

void APIENTRY glGetTextureParameterIuiv(GLuint texture, GLenum pname, GLuint* params)
{
    printf("glGetTextureParameterIuiv(" "%u, %s, %p)\n", texture, E2S(pname), params);
    glad_glGetTextureParameterIuiv(texture, pname, params);
}

void APIENTRY glGetTextureParameteriv(GLuint texture, GLenum pname, GLint* params)
{
    printf("glGetTextureParameteriv(" "%u, %s, %p)\n", texture, E2S(pname), params);
    glad_glGetTextureParameteriv(texture, pname, params);
}

void APIENTRY glCreateVertexArrays(GLsizei n, GLuint* arrays)
{
    printf("glCreateVertexArrays(" "%i, %p)\n", n, arrays);
    glad_glCreateVertexArrays(n, arrays);
}

void APIENTRY glDisableVertexArrayAttrib(GLuint vaobj, GLuint index)
{
    printf("glDisableVertexArrayAttrib(" "%u, %u)\n", vaobj, index);
    glad_glDisableVertexArrayAttrib(vaobj, index);
}

void APIENTRY glEnableVertexArrayAttrib(GLuint vaobj, GLuint index)
{
    printf("glEnableVertexArrayAttrib(" "%u, %u)\n", vaobj, index);
    glad_glEnableVertexArrayAttrib(vaobj, index);
}

void APIENTRY glVertexArrayElementBuffer(GLuint vaobj, GLuint buffer)
{
    printf("glVertexArrayElementBuffer(" "%u, %u)\n", vaobj, buffer);
    glad_glVertexArrayElementBuffer(vaobj, buffer);
}

void APIENTRY glVertexArrayVertexBuffer(GLuint vaobj, GLuint bindingindex, GLuint buffer, GLintptr offset, GLsizei stride)
{
    printf("glVertexArrayVertexBuffer(" "%u, %u, %u, %" PRId32", %i)\n", vaobj, bindingindex, buffer, offset, stride);
    glad_glVertexArrayVertexBuffer(vaobj, bindingindex, buffer, offset, stride);
}

void APIENTRY glVertexArrayVertexBuffers(GLuint vaobj, GLuint first, GLsizei count, const GLuint* buffers, const GLintptr* offsets, const GLsizei* strides)
{
    printf("glVertexArrayVertexBuffers(" "%u, %u, %i, %p, %p, %p)\n", vaobj, first, count, buffers, offsets, strides);
    glad_glVertexArrayVertexBuffers(vaobj, first, count, buffers, offsets, strides);
}

void APIENTRY glVertexArrayAttribBinding(GLuint vaobj, GLuint attribindex, GLuint bindingindex)
{
    printf("glVertexArrayAttribBinding(" "%u, %u, %u)\n", vaobj, attribindex, bindingindex);
    glad_glVertexArrayAttribBinding(vaobj, attribindex, bindingindex);
}

void APIENTRY glVertexArrayAttribFormat(GLuint vaobj, GLuint attribindex, GLint size, GLenum type, GLboolean normalized, GLuint relativeoffset)
{
    printf("glVertexArrayAttribFormat(" "%u, %u, %i, %s, %u, %u)\n", vaobj, attribindex, size, E2S(type), (unsigned int)(normalized), relativeoffset);
    glad_glVertexArrayAttribFormat(vaobj, attribindex, size, type, normalized, relativeoffset);
}

void APIENTRY glVertexArrayAttribIFormat(GLuint vaobj, GLuint attribindex, GLint size, GLenum type, GLuint relativeoffset)
{
    printf("glVertexArrayAttribIFormat(" "%u, %u, %i, %s, %u)\n", vaobj, attribindex, size, E2S(type), relativeoffset);
    glad_glVertexArrayAttribIFormat(vaobj, attribindex, size, type, relativeoffset);
}

void APIENTRY glVertexArrayAttribLFormat(GLuint vaobj, GLuint attribindex, GLint size, GLenum type, GLuint relativeoffset)
{
    printf("glVertexArrayAttribLFormat(" "%u, %u, %i, %s, %u)\n", vaobj, attribindex, size, E2S(type), relativeoffset);
    glad_glVertexArrayAttribLFormat(vaobj, attribindex, size, type, relativeoffset);
}

void APIENTRY glVertexArrayBindingDivisor(GLuint vaobj, GLuint bindingindex, GLuint divisor)
{
    printf("glVertexArrayBindingDivisor(" "%u, %u, %u)\n", vaobj, bindingindex, divisor);
    glad_glVertexArrayBindingDivisor(vaobj, bindingindex, divisor);
}

void APIENTRY glGetVertexArrayiv(GLuint vaobj, GLenum pname, GLint* param)
{
    printf("glGetVertexArrayiv(" "%u, %s, %p)\n", vaobj, E2S(pname), param);
    glad_glGetVertexArrayiv(vaobj, pname, param);
}

void APIENTRY glGetVertexArrayIndexediv(GLuint vaobj, GLuint index, GLenum pname, GLint* param)
{
    printf("glGetVertexArrayIndexediv(" "%u, %u, %s, %p)\n", vaobj, index, E2S(pname), param);
    glad_glGetVertexArrayIndexediv(vaobj, index, pname, param);
}

void APIENTRY glGetVertexArrayIndexed64iv(GLuint vaobj, GLuint index, GLenum pname, GLint64* param)
{
    printf("glGetVertexArrayIndexed64iv(" "%u, %u, %s, %p)\n", vaobj, index, E2S(pname), param);
    glad_glGetVertexArrayIndexed64iv(vaobj, index, pname, param);
}

void APIENTRY glCreateSamplers(GLsizei n, GLuint* samplers)
{
    printf("glCreateSamplers(" "%i, %p)\n", n, samplers);
    glad_glCreateSamplers(n, samplers);
}

void APIENTRY glCreateProgramPipelines(GLsizei n, GLuint* pipelines)
{
    printf("glCreateProgramPipelines(" "%i, %p)\n", n, pipelines);
    glad_glCreateProgramPipelines(n, pipelines);
}

void APIENTRY glCreateQueries(GLenum target, GLsizei n, GLuint* ids)
{
    printf("glCreateQueries(" "%s, %i, %p)\n", E2S(target), n, ids);
    glad_glCreateQueries(target, n, ids);
}

void APIENTRY glGetQueryBufferObjecti64v(GLuint id, GLuint buffer, GLenum pname, GLintptr offset)
{
    printf("glGetQueryBufferObjecti64v(" "%u, %u, %s, %" PRId32")\n", id, buffer, E2S(pname), offset);
    glad_glGetQueryBufferObjecti64v(id, buffer, pname, offset);
}

void APIENTRY glGetQueryBufferObjectiv(GLuint id, GLuint buffer, GLenum pname, GLintptr offset)
{
    printf("glGetQueryBufferObjectiv(" "%u, %u, %s, %" PRId32")\n", id, buffer, E2S(pname), offset);
    glad_glGetQueryBufferObjectiv(id, buffer, pname, offset);
}

void APIENTRY glGetQueryBufferObjectui64v(GLuint id, GLuint buffer, GLenum pname, GLintptr offset)
{
    printf("glGetQueryBufferObjectui64v(" "%u, %u, %s, %" PRId32")\n", id, buffer, E2S(pname), offset);
    glad_glGetQueryBufferObjectui64v(id, buffer, pname, offset);
}

void APIENTRY glGetQueryBufferObjectuiv(GLuint id, GLuint buffer, GLenum pname, GLintptr offset)
{
    printf("glGetQueryBufferObjectuiv(" "%u, %u, %s, %" PRId32")\n", id, buffer, E2S(pname), offset);
    glad_glGetQueryBufferObjectuiv(id, buffer, pname, offset);
}

void APIENTRY glMemoryBarrierByRegion(GLbitfield barriers)
{
    printf("glMemoryBarrierByRegion(" "%u)\n", (unsigned int)(barriers));
    glad_glMemoryBarrierByRegion(barriers);
}

void APIENTRY glGetTextureSubImage(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, GLsizei bufSize, void* pixels)
{
    printf("glGetTextureSubImage(" "%u, %i, %i, %i, %i, %i, %i, %i, %s, %s, %i, %p)\n", texture, level, xoffset, yoffset, zoffset, width, height, depth, E2S(format), E2S(type), bufSize, pixels);
    glad_glGetTextureSubImage(texture, level, xoffset, yoffset, zoffset, width, height, depth, format, type, bufSize, pixels);
}

void APIENTRY glGetCompressedTextureSubImage(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLsizei bufSize, void* pixels)
{
    printf("glGetCompressedTextureSubImage(" "%u, %i, %i, %i, %i, %i, %i, %i, %i, %p)\n", texture, level, xoffset, yoffset, zoffset, width, height, depth, bufSize, pixels);
    glad_glGetCompressedTextureSubImage(texture, level, xoffset, yoffset, zoffset, width, height, depth, bufSize, pixels);
}

GLenum APIENTRY glGetGraphicsResetStatus()
{
    printf("glGetGraphicsResetStatus()\n");
    GLenum const r = glad_glGetGraphicsResetStatus();
    return r;
}

void APIENTRY glGetnCompressedTexImage(GLenum target, GLint lod, GLsizei bufSize, void* pixels)
{
    printf("glGetnCompressedTexImage(" "%s, %i, %i, %p)\n", E2S(target), lod, bufSize, pixels);
    glad_glGetnCompressedTexImage(target, lod, bufSize, pixels);
}

void APIENTRY glGetnTexImage(GLenum target, GLint level, GLenum format, GLenum type, GLsizei bufSize, void* pixels)
{
    printf("glGetnTexImage(" "%s, %i, %s, %s, %i, %p)\n", E2S(target), level, E2S(format), E2S(type), bufSize, pixels);
    glad_glGetnTexImage(target, level, format, type, bufSize, pixels);
}

void APIENTRY glGetnUniformdv(GLuint program, GLint location, GLsizei bufSize, GLdouble* params)
{
    printf("glGetnUniformdv(" "%u, %i, %i, %p)\n", program, location, bufSize, params);
    glad_glGetnUniformdv(program, location, bufSize, params);
}

void APIENTRY glGetnUniformfv(GLuint program, GLint location, GLsizei bufSize, GLfloat* params)
{
    printf("glGetnUniformfv(" "%u, %i, %i, %p)\n", program, location, bufSize, params);
    glad_glGetnUniformfv(program, location, bufSize, params);
}

void APIENTRY glGetnUniformiv(GLuint program, GLint location, GLsizei bufSize, GLint* params)
{
    printf("glGetnUniformiv(" "%u, %i, %i, %p)\n", program, location, bufSize, params);
    glad_glGetnUniformiv(program, location, bufSize, params);
}

void APIENTRY glGetnUniformuiv(GLuint program, GLint location, GLsizei bufSize, GLuint* params)
{
    printf("glGetnUniformuiv(" "%u, %i, %i, %p)\n", program, location, bufSize, params);
    glad_glGetnUniformuiv(program, location, bufSize, params);
}

void APIENTRY glReadnPixels(GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLsizei bufSize, void* data)
{
    printf("glReadnPixels(" "%i, %i, %i, %i, %s, %s, %i, %p)\n", x, y, width, height, E2S(format), E2S(type), bufSize, data);
    glad_glReadnPixels(x, y, width, height, format, type, bufSize, data);
}

void APIENTRY glTextureBarrier()
{
    printf("glTextureBarrier()\n");
    glad_glTextureBarrier();
}

void APIENTRY glSpecializeShader(GLuint shader, const GLchar* pEntryPoint, GLuint numSpecializationConstants, const GLuint* pConstantIndex, const GLuint* pConstantValue)
{
    printf("glSpecializeShader(" "%u, %p, %u, %p, %p)\n", shader, pEntryPoint, numSpecializationConstants, pConstantIndex, pConstantValue);
    glad_glSpecializeShader(shader, pEntryPoint, numSpecializationConstants, pConstantIndex, pConstantValue);
}

void APIENTRY glMultiDrawArraysIndirectCount(GLenum mode, const void* indirect, GLintptr drawcount, GLsizei maxdrawcount, GLsizei stride)
{
    printf("glMultiDrawArraysIndirectCount(" "%s, %p, %" PRId32", %i, %i)\n", E2S(mode), indirect, drawcount, maxdrawcount, stride);
    glad_glMultiDrawArraysIndirectCount(mode, indirect, drawcount, maxdrawcount, stride);
}

void APIENTRY glMultiDrawElementsIndirectCount(GLenum mode, GLenum type, const void* indirect, GLintptr drawcount, GLsizei maxdrawcount, GLsizei stride)
{
    printf("glMultiDrawElementsIndirectCount(" "%s, %s, %p, %" PRId32", %i, %i)\n", E2S(mode), E2S(type), indirect, drawcount, maxdrawcount, stride);
    glad_glMultiDrawElementsIndirectCount(mode, type, indirect, drawcount, maxdrawcount, stride);
}

void APIENTRY glPolygonOffsetClamp(GLfloat factor, GLfloat units, GLfloat clamp)
{
    printf("glPolygonOffsetClamp(" "%f, %f, %f)\n", factor, units, clamp);
    glad_glPolygonOffsetClamp(factor, units, clamp);
}

GLuint64 APIENTRY glGetTextureHandleARB(GLuint texture)
{
    printf("glGetTextureHandleARB(" "%u)\n", texture);
    GLuint64 const r = glad_glGetTextureHandleARB(texture);
    return r;
}

GLuint64 APIENTRY glGetTextureSamplerHandleARB(GLuint texture, GLuint sampler)
{
    printf("glGetTextureSamplerHandleARB(" "%u, %u)\n", texture, sampler);
    GLuint64 const r = glad_glGetTextureSamplerHandleARB(texture, sampler);
    return r;
}

void APIENTRY glMakeTextureHandleResidentARB(GLuint64 handle)
{
    printf("glMakeTextureHandleResidentARB(" "%zu)\n", handle);
    glad_glMakeTextureHandleResidentARB(handle);
}

void APIENTRY glMakeTextureHandleNonResidentARB(GLuint64 handle)
{
    printf("glMakeTextureHandleNonResidentARB(" "%zu)\n", handle);
    glad_glMakeTextureHandleNonResidentARB(handle);
}

GLuint64 APIENTRY glGetImageHandleARB(GLuint texture, GLint level, GLboolean layered, GLint layer, GLenum format)
{
    printf("glGetImageHandleARB(" "%u, %i, %u, %i, %s)\n", texture, level, (unsigned int)(layered), layer, E2S(format));
    GLuint64 const r = glad_glGetImageHandleARB(texture, level, layered, layer, format);
    return r;
}

void APIENTRY glMakeImageHandleResidentARB(GLuint64 handle, GLenum access)
{
    printf("glMakeImageHandleResidentARB(" "%zu, %s)\n", handle, E2S(access));
    glad_glMakeImageHandleResidentARB(handle, access);
}

void APIENTRY glMakeImageHandleNonResidentARB(GLuint64 handle)
{
    printf("glMakeImageHandleNonResidentARB(" "%zu)\n", handle);
    glad_glMakeImageHandleNonResidentARB(handle);
}

void APIENTRY glUniformHandleui64ARB(GLint location, GLuint64 value)
{
    printf("glUniformHandleui64ARB(" "%i, %zu)\n", location, value);
    glad_glUniformHandleui64ARB(location, value);
}

void APIENTRY glUniformHandleui64vARB(GLint location, GLsizei count, const GLuint64* value)
{
    printf("glUniformHandleui64vARB(" "%i, %i, %p)\n", location, count, value);
    glad_glUniformHandleui64vARB(location, count, value);
}

void APIENTRY glProgramUniformHandleui64ARB(GLuint program, GLint location, GLuint64 value)
{
    printf("glProgramUniformHandleui64ARB(" "%u, %i, %zu)\n", program, location, value);
    glad_glProgramUniformHandleui64ARB(program, location, value);
}

void APIENTRY glProgramUniformHandleui64vARB(GLuint program, GLint location, GLsizei count, const GLuint64* values)
{
    printf("glProgramUniformHandleui64vARB(" "%u, %i, %i, %p)\n", program, location, count, values);
    glad_glProgramUniformHandleui64vARB(program, location, count, values);
}

GLboolean APIENTRY glIsTextureHandleResidentARB(GLuint64 handle)
{
    printf("glIsTextureHandleResidentARB(" "%zu)\n", handle);
    GLboolean const r = glad_glIsTextureHandleResidentARB(handle);
    return r;
}

GLboolean APIENTRY glIsImageHandleResidentARB(GLuint64 handle)
{
    printf("glIsImageHandleResidentARB(" "%zu)\n", handle);
    GLboolean const r = glad_glIsImageHandleResidentARB(handle);
    return r;
}

void APIENTRY glVertexAttribL1ui64ARB(GLuint index, GLuint64EXT x)
{
    printf("glVertexAttribL1ui64ARB(" "%u, %p)\n", index, x);
    glad_glVertexAttribL1ui64ARB(index, x);
}

void APIENTRY glVertexAttribL1ui64vARB(GLuint index, const GLuint64EXT* v)
{
    printf("glVertexAttribL1ui64vARB(" "%u, %p)\n", index, v);
    glad_glVertexAttribL1ui64vARB(index, v);
}

void APIENTRY glGetVertexAttribLui64vARB(GLuint index, GLenum pname, GLuint64EXT* params)
{
    printf("glGetVertexAttribLui64vARB(" "%u, %s, %p)\n", index, E2S(pname), params);
    glad_glGetVertexAttribLui64vARB(index, pname, params);
}