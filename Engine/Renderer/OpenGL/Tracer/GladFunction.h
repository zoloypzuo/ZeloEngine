GLAPI void APIENTRY glCullFace (GLenum mode);

GLAPI void APIENTRY glFrontFace (GLenum mode);

GLAPI void APIENTRY glHint (GLenum target, GLenum mode);

GLAPI void APIENTRY glLineWidth (GLfloat width);

GLAPI void APIENTRY glPointSize (GLfloat size);

GLAPI void APIENTRY glPolygonMode (GLenum face, GLenum mode);

GLAPI void APIENTRY glScissor (GLint x, GLint y, GLsizei width, GLsizei height);

GLAPI void APIENTRY glTexParameterf (GLenum target, GLenum pname, GLfloat param);

GLAPI void APIENTRY glTexParameterfv (GLenum target, GLenum pname, const GLfloat *params);

GLAPI void APIENTRY glTexParameteri (GLenum target, GLenum pname, GLint param);

GLAPI void APIENTRY glTexParameteriv (GLenum target, GLenum pname, const GLint *params);

GLAPI void APIENTRY glTexImage1D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLint border, GLenum format, GLenum type, const void *pixels);

GLAPI void APIENTRY glTexImage2D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const void *pixels);

GLAPI void APIENTRY glDrawBuffer (GLenum buf);

GLAPI void APIENTRY glClear (GLbitfield mask);

GLAPI void APIENTRY glClearColor (GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha);

GLAPI void APIENTRY glClearStencil (GLint s);

GLAPI void APIENTRY glClearDepth (GLdouble depth);

GLAPI void APIENTRY glStencilMask (GLuint mask);

GLAPI void APIENTRY glColorMask (GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha);

GLAPI void APIENTRY glDepthMask (GLboolean flag);

GLAPI void APIENTRY glDisable (GLenum cap);

GLAPI void APIENTRY glEnable (GLenum cap);

GLAPI void APIENTRY glFinish (void);

GLAPI void APIENTRY glFlush (void);

GLAPI void APIENTRY glBlendFunc (GLenum sfactor, GLenum dfactor);

GLAPI void APIENTRY glLogicOp (GLenum opcode);

GLAPI void APIENTRY glStencilFunc (GLenum func, GLint ref, GLuint mask);

GLAPI void APIENTRY glStencilOp (GLenum fail, GLenum zfail, GLenum zpass);

GLAPI void APIENTRY glDepthFunc (GLenum func);

GLAPI void APIENTRY glPixelStoref (GLenum pname, GLfloat param);

GLAPI void APIENTRY glPixelStorei (GLenum pname, GLint param);

GLAPI void APIENTRY glReadBuffer (GLenum src);

GLAPI void APIENTRY glReadPixels (GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, void *pixels);

GLAPI void APIENTRY glGetBooleanv (GLenum pname, GLboolean *data);

GLAPI void APIENTRY glGetDoublev (GLenum pname, GLdouble *data);

GLAPI GLenum APIENTRY glGetError (void);

GLAPI void APIENTRY glGetFloatv (GLenum pname, GLfloat *data);

GLAPI void APIENTRY glGetIntegerv (GLenum pname, GLint *data);

GLAPI const GLubyte *APIENTRY glGetString (GLenum name);

GLAPI void APIENTRY glGetTexImage (GLenum target, GLint level, GLenum format, GLenum type, void *pixels);

GLAPI void APIENTRY glGetTexParameterfv (GLenum target, GLenum pname, GLfloat *params);

GLAPI void APIENTRY glGetTexParameteriv (GLenum target, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetTexLevelParameterfv (GLenum target, GLint level, GLenum pname, GLfloat *params);

GLAPI void APIENTRY glGetTexLevelParameteriv (GLenum target, GLint level, GLenum pname, GLint *params);

GLAPI GLboolean APIENTRY glIsEnabled (GLenum cap);

GLAPI void APIENTRY glDepthRange (GLdouble n, GLdouble f);

GLAPI void APIENTRY glViewport (GLint x, GLint y, GLsizei width, GLsizei height);

GLAPI void APIENTRY glDrawArrays (GLenum mode, GLint first, GLsizei count);

GLAPI void APIENTRY glDrawElements (GLenum mode, GLsizei count, GLenum type, const void *indices);

GLAPI void APIENTRY glGetPointerv (GLenum pname, void **params);

GLAPI void APIENTRY glPolygonOffset (GLfloat factor, GLfloat units);

GLAPI void APIENTRY glCopyTexImage1D (GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLint border);

GLAPI void APIENTRY glCopyTexImage2D (GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border);

GLAPI void APIENTRY glCopyTexSubImage1D (GLenum target, GLint level, GLint xoffset, GLint x, GLint y, GLsizei width);

GLAPI void APIENTRY glCopyTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height);

GLAPI void APIENTRY glTexSubImage1D (GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum type, const void *pixels);

GLAPI void APIENTRY glTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const void *pixels);

GLAPI void APIENTRY glBindTexture (GLenum target, GLuint texture);

GLAPI void APIENTRY glDeleteTextures (GLsizei n, const GLuint *textures);

GLAPI void APIENTRY glGenTextures (GLsizei n, GLuint *textures);

GLAPI GLboolean APIENTRY glIsTexture (GLuint texture);

GLAPI void APIENTRY glDrawRangeElements (GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum type, const void *indices);

GLAPI void APIENTRY glTexImage3D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum type, const void *pixels);

GLAPI void APIENTRY glTexSubImage3D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const void *pixels);

GLAPI void APIENTRY glCopyTexSubImage3D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLint x, GLint y, GLsizei width, GLsizei height);

GLAPI void APIENTRY glActiveTexture (GLenum texture);

GLAPI void APIENTRY glSampleCoverage (GLfloat value, GLboolean invert);

GLAPI void APIENTRY glCompressedTexImage3D (GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLsizei imageSize, const void *data);

GLAPI void APIENTRY glCompressedTexImage2D (GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, const void *data);

GLAPI void APIENTRY glCompressedTexImage1D (GLenum target, GLint level, GLenum internalformat, GLsizei width, GLint border, GLsizei imageSize, const void *data);

GLAPI void APIENTRY glCompressedTexSubImage3D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLsizei imageSize, const void *data);

GLAPI void APIENTRY glCompressedTexSubImage2D (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, const void *data);

GLAPI void APIENTRY glCompressedTexSubImage1D (GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLsizei imageSize, const void *data);

GLAPI void APIENTRY glGetCompressedTexImage (GLenum target, GLint level, void *img);

GLAPI void APIENTRY glBlendFuncSeparate (GLenum sfactorRGB, GLenum dfactorRGB, GLenum sfactorAlpha, GLenum dfactorAlpha);

GLAPI void APIENTRY glMultiDrawArrays (GLenum mode, const GLint *first, const GLsizei *count, GLsizei drawcount);

GLAPI void APIENTRY glMultiDrawElements (GLenum mode, const GLsizei *count, GLenum type, const void *const*indices, GLsizei drawcount);

GLAPI void APIENTRY glPointParameterf (GLenum pname, GLfloat param);

GLAPI void APIENTRY glPointParameterfv (GLenum pname, const GLfloat *params);

GLAPI void APIENTRY glPointParameteri (GLenum pname, GLint param);

GLAPI void APIENTRY glPointParameteriv (GLenum pname, const GLint *params);

GLAPI void APIENTRY glBlendColor (GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha);

GLAPI void APIENTRY glBlendEquation (GLenum mode);

GLAPI void APIENTRY glGenQueries (GLsizei n, GLuint *ids);

GLAPI void APIENTRY glDeleteQueries (GLsizei n, const GLuint *ids);

GLAPI GLboolean APIENTRY glIsQuery (GLuint id);

GLAPI void APIENTRY glBeginQuery (GLenum target, GLuint id);

GLAPI void APIENTRY glEndQuery (GLenum target);

GLAPI void APIENTRY glGetQueryiv (GLenum target, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetQueryObjectiv (GLuint id, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetQueryObjectuiv (GLuint id, GLenum pname, GLuint *params);

GLAPI void APIENTRY glBindBuffer (GLenum target, GLuint buffer);

GLAPI void APIENTRY glDeleteBuffers (GLsizei n, const GLuint *buffers);

GLAPI void APIENTRY glGenBuffers (GLsizei n, GLuint *buffers);

GLAPI GLboolean APIENTRY glIsBuffer (GLuint buffer);

GLAPI void APIENTRY glBufferData (GLenum target, GLsizeiptr size, const void *data, GLenum usage);

GLAPI void APIENTRY glBufferSubData (GLenum target, GLintptr offset, GLsizeiptr size, const void *data);

GLAPI void APIENTRY glGetBufferSubData (GLenum target, GLintptr offset, GLsizeiptr size, void *data);

GLAPI void *APIENTRY glMapBuffer (GLenum target, GLenum access);

GLAPI GLboolean APIENTRY glUnmapBuffer (GLenum target);

GLAPI void APIENTRY glGetBufferParameteriv (GLenum target, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetBufferPointerv (GLenum target, GLenum pname, void **params);

GLAPI void APIENTRY glBlendEquationSeparate (GLenum modeRGB, GLenum modeAlpha);

GLAPI void APIENTRY glDrawBuffers (GLsizei n, const GLenum *bufs);

GLAPI void APIENTRY glStencilOpSeparate (GLenum face, GLenum sfail, GLenum dpfail, GLenum dppass);

GLAPI void APIENTRY glStencilFuncSeparate (GLenum face, GLenum func, GLint ref, GLuint mask);

GLAPI void APIENTRY glStencilMaskSeparate (GLenum face, GLuint mask);

GLAPI void APIENTRY glAttachShader (GLuint program, GLuint shader);

GLAPI void APIENTRY glBindAttribLocation (GLuint program, GLuint index, const GLchar *name);

GLAPI void APIENTRY glCompileShader (GLuint shader);

GLAPI GLuint APIENTRY glCreateProgram (void);

GLAPI GLuint APIENTRY glCreateShader (GLenum type);

GLAPI void APIENTRY glDeleteProgram (GLuint program);

GLAPI void APIENTRY glDeleteShader (GLuint shader);

GLAPI void APIENTRY glDetachShader (GLuint program, GLuint shader);

GLAPI void APIENTRY glDisableVertexAttribArray (GLuint index);

GLAPI void APIENTRY glEnableVertexAttribArray (GLuint index);

GLAPI void APIENTRY glGetActiveAttrib (GLuint program, GLuint index, GLsizei bufSize, GLsizei *length, GLint *size, GLenum *type, GLchar *name);

GLAPI void APIENTRY glGetActiveUniform (GLuint program, GLuint index, GLsizei bufSize, GLsizei *length, GLint *size, GLenum *type, GLchar *name);

GLAPI void APIENTRY glGetAttachedShaders (GLuint program, GLsizei maxCount, GLsizei *count, GLuint *shaders);

GLAPI GLint APIENTRY glGetAttribLocation (GLuint program, const GLchar *name);

GLAPI void APIENTRY glGetProgramiv (GLuint program, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetProgramInfoLog (GLuint program, GLsizei bufSize, GLsizei *length, GLchar *infoLog);

GLAPI void APIENTRY glGetShaderiv (GLuint shader, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetShaderInfoLog (GLuint shader, GLsizei bufSize, GLsizei *length, GLchar *infoLog);

GLAPI void APIENTRY glGetShaderSource (GLuint shader, GLsizei bufSize, GLsizei *length, GLchar *source);

GLAPI GLint APIENTRY glGetUniformLocation (GLuint program, const GLchar *name);

GLAPI void APIENTRY glGetUniformfv (GLuint program, GLint location, GLfloat *params);

GLAPI void APIENTRY glGetUniformiv (GLuint program, GLint location, GLint *params);

GLAPI void APIENTRY glGetVertexAttribdv (GLuint index, GLenum pname, GLdouble *params);

GLAPI void APIENTRY glGetVertexAttribfv (GLuint index, GLenum pname, GLfloat *params);

GLAPI void APIENTRY glGetVertexAttribiv (GLuint index, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetVertexAttribPointerv (GLuint index, GLenum pname, void **pointer);

GLAPI GLboolean APIENTRY glIsProgram (GLuint program);

GLAPI GLboolean APIENTRY glIsShader (GLuint shader);

GLAPI void APIENTRY glLinkProgram (GLuint program);

GLAPI void APIENTRY glShaderSource (GLuint shader, GLsizei count, const GLchar *const*string, const GLint *length);

GLAPI void APIENTRY glUseProgram (GLuint program);

GLAPI void APIENTRY glUniform1f (GLint location, GLfloat v0);

GLAPI void APIENTRY glUniform2f (GLint location, GLfloat v0, GLfloat v1);

GLAPI void APIENTRY glUniform3f (GLint location, GLfloat v0, GLfloat v1, GLfloat v2);

GLAPI void APIENTRY glUniform4f (GLint location, GLfloat v0, GLfloat v1, GLfloat v2, GLfloat v3);

GLAPI void APIENTRY glUniform1i (GLint location, GLint v0);

GLAPI void APIENTRY glUniform2i (GLint location, GLint v0, GLint v1);

GLAPI void APIENTRY glUniform3i (GLint location, GLint v0, GLint v1, GLint v2);

GLAPI void APIENTRY glUniform4i (GLint location, GLint v0, GLint v1, GLint v2, GLint v3);

GLAPI void APIENTRY glUniform1fv (GLint location, GLsizei count, const GLfloat *value);

GLAPI void APIENTRY glUniform2fv (GLint location, GLsizei count, const GLfloat *value);

GLAPI void APIENTRY glUniform3fv (GLint location, GLsizei count, const GLfloat *value);

GLAPI void APIENTRY glUniform4fv (GLint location, GLsizei count, const GLfloat *value);

GLAPI void APIENTRY glUniform1iv (GLint location, GLsizei count, const GLint *value);

GLAPI void APIENTRY glUniform2iv (GLint location, GLsizei count, const GLint *value);

GLAPI void APIENTRY glUniform3iv (GLint location, GLsizei count, const GLint *value);

GLAPI void APIENTRY glUniform4iv (GLint location, GLsizei count, const GLint *value);

GLAPI void APIENTRY glUniformMatrix2fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glUniformMatrix3fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glUniformMatrix4fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glValidateProgram (GLuint program);

GLAPI void APIENTRY glVertexAttrib1d (GLuint index, GLdouble x);

GLAPI void APIENTRY glVertexAttrib1dv (GLuint index, const GLdouble *v);

GLAPI void APIENTRY glVertexAttrib1f (GLuint index, GLfloat x);

GLAPI void APIENTRY glVertexAttrib1fv (GLuint index, const GLfloat *v);

GLAPI void APIENTRY glVertexAttrib1s (GLuint index, GLshort x);

GLAPI void APIENTRY glVertexAttrib1sv (GLuint index, const GLshort *v);

GLAPI void APIENTRY glVertexAttrib2d (GLuint index, GLdouble x, GLdouble y);

GLAPI void APIENTRY glVertexAttrib2dv (GLuint index, const GLdouble *v);

GLAPI void APIENTRY glVertexAttrib2f (GLuint index, GLfloat x, GLfloat y);

GLAPI void APIENTRY glVertexAttrib2fv (GLuint index, const GLfloat *v);

GLAPI void APIENTRY glVertexAttrib2s (GLuint index, GLshort x, GLshort y);

GLAPI void APIENTRY glVertexAttrib2sv (GLuint index, const GLshort *v);

GLAPI void APIENTRY glVertexAttrib3d (GLuint index, GLdouble x, GLdouble y, GLdouble z);

GLAPI void APIENTRY glVertexAttrib3dv (GLuint index, const GLdouble *v);

GLAPI void APIENTRY glVertexAttrib3f (GLuint index, GLfloat x, GLfloat y, GLfloat z);

GLAPI void APIENTRY glVertexAttrib3fv (GLuint index, const GLfloat *v);

GLAPI void APIENTRY glVertexAttrib3s (GLuint index, GLshort x, GLshort y, GLshort z);

GLAPI void APIENTRY glVertexAttrib3sv (GLuint index, const GLshort *v);

GLAPI void APIENTRY glVertexAttrib4Nbv (GLuint index, const GLbyte *v);

GLAPI void APIENTRY glVertexAttrib4Niv (GLuint index, const GLint *v);

GLAPI void APIENTRY glVertexAttrib4Nsv (GLuint index, const GLshort *v);

GLAPI void APIENTRY glVertexAttrib4Nub (GLuint index, GLubyte x, GLubyte y, GLubyte z, GLubyte w);

GLAPI void APIENTRY glVertexAttrib4Nubv (GLuint index, const GLubyte *v);

GLAPI void APIENTRY glVertexAttrib4Nuiv (GLuint index, const GLuint *v);

GLAPI void APIENTRY glVertexAttrib4Nusv (GLuint index, const GLushort *v);

GLAPI void APIENTRY glVertexAttrib4bv (GLuint index, const GLbyte *v);

GLAPI void APIENTRY glVertexAttrib4d (GLuint index, GLdouble x, GLdouble y, GLdouble z, GLdouble w);

GLAPI void APIENTRY glVertexAttrib4dv (GLuint index, const GLdouble *v);

GLAPI void APIENTRY glVertexAttrib4f (GLuint index, GLfloat x, GLfloat y, GLfloat z, GLfloat w);

GLAPI void APIENTRY glVertexAttrib4fv (GLuint index, const GLfloat *v);

GLAPI void APIENTRY glVertexAttrib4iv (GLuint index, const GLint *v);

GLAPI void APIENTRY glVertexAttrib4s (GLuint index, GLshort x, GLshort y, GLshort z, GLshort w);

GLAPI void APIENTRY glVertexAttrib4sv (GLuint index, const GLshort *v);

GLAPI void APIENTRY glVertexAttrib4ubv (GLuint index, const GLubyte *v);

GLAPI void APIENTRY glVertexAttrib4uiv (GLuint index, const GLuint *v);

GLAPI void APIENTRY glVertexAttrib4usv (GLuint index, const GLushort *v);

GLAPI void APIENTRY glVertexAttribPointer (GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const void *pointer);

GLAPI void APIENTRY glUniformMatrix2x3fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glUniformMatrix3x2fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glUniformMatrix2x4fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glUniformMatrix4x2fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glUniformMatrix3x4fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glUniformMatrix4x3fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glColorMaski (GLuint index, GLboolean r, GLboolean g, GLboolean b, GLboolean a);

GLAPI void APIENTRY glGetBooleani_v (GLenum target, GLuint index, GLboolean *data);

GLAPI void APIENTRY glGetIntegeri_v (GLenum target, GLuint index, GLint *data);

GLAPI void APIENTRY glEnablei (GLenum target, GLuint index);

GLAPI void APIENTRY glDisablei (GLenum target, GLuint index);

GLAPI GLboolean APIENTRY glIsEnabledi (GLenum target, GLuint index);

GLAPI void APIENTRY glBeginTransformFeedback (GLenum primitiveMode);

GLAPI void APIENTRY glEndTransformFeedback (void);

GLAPI void APIENTRY glBindBufferRange (GLenum target, GLuint index, GLuint buffer, GLintptr offset, GLsizeiptr size);

GLAPI void APIENTRY glBindBufferBase (GLenum target, GLuint index, GLuint buffer);

GLAPI void APIENTRY glTransformFeedbackVaryings (GLuint program, GLsizei count, const GLchar *const*varyings, GLenum bufferMode);

GLAPI void APIENTRY glGetTransformFeedbackVarying (GLuint program, GLuint index, GLsizei bufSize, GLsizei *length, GLsizei *size, GLenum *type, GLchar *name);

GLAPI void APIENTRY glClampColor (GLenum target, GLenum clamp);

GLAPI void APIENTRY glBeginConditionalRender (GLuint id, GLenum mode);

GLAPI void APIENTRY glEndConditionalRender (void);

GLAPI void APIENTRY glVertexAttribIPointer (GLuint index, GLint size, GLenum type, GLsizei stride, const void *pointer);

GLAPI void APIENTRY glGetVertexAttribIiv (GLuint index, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetVertexAttribIuiv (GLuint index, GLenum pname, GLuint *params);

GLAPI void APIENTRY glVertexAttribI1i (GLuint index, GLint x);

GLAPI void APIENTRY glVertexAttribI2i (GLuint index, GLint x, GLint y);

GLAPI void APIENTRY glVertexAttribI3i (GLuint index, GLint x, GLint y, GLint z);

GLAPI void APIENTRY glVertexAttribI4i (GLuint index, GLint x, GLint y, GLint z, GLint w);

GLAPI void APIENTRY glVertexAttribI1ui (GLuint index, GLuint x);

GLAPI void APIENTRY glVertexAttribI2ui (GLuint index, GLuint x, GLuint y);

GLAPI void APIENTRY glVertexAttribI3ui (GLuint index, GLuint x, GLuint y, GLuint z);

GLAPI void APIENTRY glVertexAttribI4ui (GLuint index, GLuint x, GLuint y, GLuint z, GLuint w);

GLAPI void APIENTRY glVertexAttribI1iv (GLuint index, const GLint *v);

GLAPI void APIENTRY glVertexAttribI2iv (GLuint index, const GLint *v);

GLAPI void APIENTRY glVertexAttribI3iv (GLuint index, const GLint *v);

GLAPI void APIENTRY glVertexAttribI4iv (GLuint index, const GLint *v);

GLAPI void APIENTRY glVertexAttribI1uiv (GLuint index, const GLuint *v);

GLAPI void APIENTRY glVertexAttribI2uiv (GLuint index, const GLuint *v);

GLAPI void APIENTRY glVertexAttribI3uiv (GLuint index, const GLuint *v);

GLAPI void APIENTRY glVertexAttribI4uiv (GLuint index, const GLuint *v);

GLAPI void APIENTRY glVertexAttribI4bv (GLuint index, const GLbyte *v);

GLAPI void APIENTRY glVertexAttribI4sv (GLuint index, const GLshort *v);

GLAPI void APIENTRY glVertexAttribI4ubv (GLuint index, const GLubyte *v);

GLAPI void APIENTRY glVertexAttribI4usv (GLuint index, const GLushort *v);

GLAPI void APIENTRY glGetUniformuiv (GLuint program, GLint location, GLuint *params);

GLAPI void APIENTRY glBindFragDataLocation (GLuint program, GLuint color, const GLchar *name);

GLAPI GLint APIENTRY glGetFragDataLocation (GLuint program, const GLchar *name);

GLAPI void APIENTRY glUniform1ui (GLint location, GLuint v0);

GLAPI void APIENTRY glUniform2ui (GLint location, GLuint v0, GLuint v1);

GLAPI void APIENTRY glUniform3ui (GLint location, GLuint v0, GLuint v1, GLuint v2);

GLAPI void APIENTRY glUniform4ui (GLint location, GLuint v0, GLuint v1, GLuint v2, GLuint v3);

GLAPI void APIENTRY glUniform1uiv (GLint location, GLsizei count, const GLuint *value);

GLAPI void APIENTRY glUniform2uiv (GLint location, GLsizei count, const GLuint *value);

GLAPI void APIENTRY glUniform3uiv (GLint location, GLsizei count, const GLuint *value);

GLAPI void APIENTRY glUniform4uiv (GLint location, GLsizei count, const GLuint *value);

GLAPI void APIENTRY glTexParameterIiv (GLenum target, GLenum pname, const GLint *params);

GLAPI void APIENTRY glTexParameterIuiv (GLenum target, GLenum pname, const GLuint *params);

GLAPI void APIENTRY glGetTexParameterIiv (GLenum target, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetTexParameterIuiv (GLenum target, GLenum pname, GLuint *params);

GLAPI void APIENTRY glClearBufferiv (GLenum buffer, GLint drawbuffer, const GLint *value);

GLAPI void APIENTRY glClearBufferuiv (GLenum buffer, GLint drawbuffer, const GLuint *value);

GLAPI void APIENTRY glClearBufferfv (GLenum buffer, GLint drawbuffer, const GLfloat *value);

GLAPI void APIENTRY glClearBufferfi (GLenum buffer, GLint drawbuffer, GLfloat depth, GLint stencil);

GLAPI const GLubyte *APIENTRY glGetStringi (GLenum name, GLuint index);

GLAPI GLboolean APIENTRY glIsRenderbuffer (GLuint renderbuffer);

GLAPI void APIENTRY glBindRenderbuffer (GLenum target, GLuint renderbuffer);

GLAPI void APIENTRY glDeleteRenderbuffers (GLsizei n, const GLuint *renderbuffers);

GLAPI void APIENTRY glGenRenderbuffers (GLsizei n, GLuint *renderbuffers);

GLAPI void APIENTRY glRenderbufferStorage (GLenum target, GLenum internalformat, GLsizei width, GLsizei height);

GLAPI void APIENTRY glGetRenderbufferParameteriv (GLenum target, GLenum pname, GLint *params);

GLAPI GLboolean APIENTRY glIsFramebuffer (GLuint framebuffer);

GLAPI void APIENTRY glBindFramebuffer (GLenum target, GLuint framebuffer);

GLAPI void APIENTRY glDeleteFramebuffers (GLsizei n, const GLuint *framebuffers);

GLAPI void APIENTRY glGenFramebuffers (GLsizei n, GLuint *framebuffers);

GLAPI GLenum APIENTRY glCheckFramebufferStatus (GLenum target);

GLAPI void APIENTRY glFramebufferTexture1D (GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level);

GLAPI void APIENTRY glFramebufferTexture2D (GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level);

GLAPI void APIENTRY glFramebufferTexture3D (GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level, GLint zoffset);

GLAPI void APIENTRY glFramebufferRenderbuffer (GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer);

GLAPI void APIENTRY glGetFramebufferAttachmentParameteriv (GLenum target, GLenum attachment, GLenum pname, GLint *params);

GLAPI void APIENTRY glGenerateMipmap (GLenum target);

GLAPI void APIENTRY glBlitFramebuffer (GLint srcX0, GLint srcY0, GLint srcX1, GLint srcY1, GLint dstX0, GLint dstY0, GLint dstX1, GLint dstY1, GLbitfield mask, GLenum filter);

GLAPI void APIENTRY glRenderbufferStorageMultisample (GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height);

GLAPI void APIENTRY glFramebufferTextureLayer (GLenum target, GLenum attachment, GLuint texture, GLint level, GLint layer);

GLAPI void *APIENTRY glMapBufferRange (GLenum target, GLintptr offset, GLsizeiptr length, GLbitfield access);

GLAPI void APIENTRY glFlushMappedBufferRange (GLenum target, GLintptr offset, GLsizeiptr length);

GLAPI void APIENTRY glBindVertexArray (GLuint array);

GLAPI void APIENTRY glDeleteVertexArrays (GLsizei n, const GLuint *arrays);

GLAPI void APIENTRY glGenVertexArrays (GLsizei n, GLuint *arrays);

GLAPI GLboolean APIENTRY glIsVertexArray (GLuint array);

GLAPI void APIENTRY glDrawArraysInstanced (GLenum mode, GLint first, GLsizei count, GLsizei instancecount);

GLAPI void APIENTRY glDrawElementsInstanced (GLenum mode, GLsizei count, GLenum type, const void *indices, GLsizei instancecount);

GLAPI void APIENTRY glTexBuffer (GLenum target, GLenum internalformat, GLuint buffer);

GLAPI void APIENTRY glPrimitiveRestartIndex (GLuint index);

GLAPI void APIENTRY glCopyBufferSubData (GLenum readTarget, GLenum writeTarget, GLintptr readOffset, GLintptr writeOffset, GLsizeiptr size);

GLAPI void APIENTRY glGetUniformIndices (GLuint program, GLsizei uniformCount, const GLchar *const*uniformNames, GLuint *uniformIndices);

GLAPI void APIENTRY glGetActiveUniformsiv (GLuint program, GLsizei uniformCount, const GLuint *uniformIndices, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetActiveUniformName (GLuint program, GLuint uniformIndex, GLsizei bufSize, GLsizei *length, GLchar *uniformName);

GLAPI GLuint APIENTRY glGetUniformBlockIndex (GLuint program, const GLchar *uniformBlockName);

GLAPI void APIENTRY glGetActiveUniformBlockiv (GLuint program, GLuint uniformBlockIndex, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetActiveUniformBlockName (GLuint program, GLuint uniformBlockIndex, GLsizei bufSize, GLsizei *length, GLchar *uniformBlockName);

GLAPI void APIENTRY glUniformBlockBinding (GLuint program, GLuint uniformBlockIndex, GLuint uniformBlockBinding);

GLAPI void APIENTRY glDrawElementsBaseVertex (GLenum mode, GLsizei count, GLenum type, const void *indices, GLint basevertex);

GLAPI void APIENTRY glDrawRangeElementsBaseVertex (GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum type, const void *indices, GLint basevertex);

GLAPI void APIENTRY glDrawElementsInstancedBaseVertex (GLenum mode, GLsizei count, GLenum type, const void *indices, GLsizei instancecount, GLint basevertex);

GLAPI void APIENTRY glMultiDrawElementsBaseVertex (GLenum mode, const GLsizei *count, GLenum type, const void *const*indices, GLsizei drawcount, const GLint *basevertex);

GLAPI void APIENTRY glProvokingVertex (GLenum mode);

GLAPI GLsync APIENTRY glFenceSync (GLenum condition, GLbitfield flags);

GLAPI GLboolean APIENTRY glIsSync (GLsync sync);

GLAPI void APIENTRY glDeleteSync (GLsync sync);

GLAPI GLenum APIENTRY glClientWaitSync (GLsync sync, GLbitfield flags, GLuint64 timeout);

GLAPI void APIENTRY glWaitSync (GLsync sync, GLbitfield flags, GLuint64 timeout);

GLAPI void APIENTRY glGetInteger64v (GLenum pname, GLint64 *data);

GLAPI void APIENTRY glGetSynciv (GLsync sync, GLenum pname, GLsizei count, GLsizei *length, GLint *values);

GLAPI void APIENTRY glGetInteger64i_v (GLenum target, GLuint index, GLint64 *data);

GLAPI void APIENTRY glGetBufferParameteri64v (GLenum target, GLenum pname, GLint64 *params);

GLAPI void APIENTRY glFramebufferTexture (GLenum target, GLenum attachment, GLuint texture, GLint level);

GLAPI void APIENTRY glTexImage2DMultisample (GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLboolean fixedsamplelocations);

GLAPI void APIENTRY glTexImage3DMultisample (GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLboolean fixedsamplelocations);

GLAPI void APIENTRY glGetMultisamplefv (GLenum pname, GLuint index, GLfloat *val);

GLAPI void APIENTRY glSampleMaski (GLuint maskNumber, GLbitfield mask);

GLAPI void APIENTRY glBindFragDataLocationIndexed (GLuint program, GLuint colorNumber, GLuint index, const GLchar *name);

GLAPI GLint APIENTRY glGetFragDataIndex (GLuint program, const GLchar *name);

GLAPI void APIENTRY glGenSamplers (GLsizei count, GLuint *samplers);

GLAPI void APIENTRY glDeleteSamplers (GLsizei count, const GLuint *samplers);

GLAPI GLboolean APIENTRY glIsSampler (GLuint sampler);

GLAPI void APIENTRY glBindSampler (GLuint unit, GLuint sampler);

GLAPI void APIENTRY glSamplerParameteri (GLuint sampler, GLenum pname, GLint param);

GLAPI void APIENTRY glSamplerParameteriv (GLuint sampler, GLenum pname, const GLint *param);

GLAPI void APIENTRY glSamplerParameterf (GLuint sampler, GLenum pname, GLfloat param);

GLAPI void APIENTRY glSamplerParameterfv (GLuint sampler, GLenum pname, const GLfloat *param);

GLAPI void APIENTRY glSamplerParameterIiv (GLuint sampler, GLenum pname, const GLint *param);

GLAPI void APIENTRY glSamplerParameterIuiv (GLuint sampler, GLenum pname, const GLuint *param);

GLAPI void APIENTRY glGetSamplerParameteriv (GLuint sampler, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetSamplerParameterIiv (GLuint sampler, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetSamplerParameterfv (GLuint sampler, GLenum pname, GLfloat *params);

GLAPI void APIENTRY glGetSamplerParameterIuiv (GLuint sampler, GLenum pname, GLuint *params);

GLAPI void APIENTRY glQueryCounter (GLuint id, GLenum target);

GLAPI void APIENTRY glGetQueryObjecti64v (GLuint id, GLenum pname, GLint64 *params);

GLAPI void APIENTRY glGetQueryObjectui64v (GLuint id, GLenum pname, GLuint64 *params);

GLAPI void APIENTRY glVertexAttribDivisor (GLuint index, GLuint divisor);

GLAPI void APIENTRY glVertexAttribP1ui (GLuint index, GLenum type, GLboolean normalized, GLuint value);

GLAPI void APIENTRY glVertexAttribP1uiv (GLuint index, GLenum type, GLboolean normalized, const GLuint *value);

GLAPI void APIENTRY glVertexAttribP2ui (GLuint index, GLenum type, GLboolean normalized, GLuint value);

GLAPI void APIENTRY glVertexAttribP2uiv (GLuint index, GLenum type, GLboolean normalized, const GLuint *value);

GLAPI void APIENTRY glVertexAttribP3ui (GLuint index, GLenum type, GLboolean normalized, GLuint value);

GLAPI void APIENTRY glVertexAttribP3uiv (GLuint index, GLenum type, GLboolean normalized, const GLuint *value);

GLAPI void APIENTRY glVertexAttribP4ui (GLuint index, GLenum type, GLboolean normalized, GLuint value);

GLAPI void APIENTRY glVertexAttribP4uiv (GLuint index, GLenum type, GLboolean normalized, const GLuint *value);

GLAPI void APIENTRY glMinSampleShading (GLfloat value);

GLAPI void APIENTRY glBlendEquationi (GLuint buf, GLenum mode);

GLAPI void APIENTRY glBlendEquationSeparatei (GLuint buf, GLenum modeRGB, GLenum modeAlpha);

GLAPI void APIENTRY glBlendFunci (GLuint buf, GLenum src, GLenum dst);

GLAPI void APIENTRY glBlendFuncSeparatei (GLuint buf, GLenum srcRGB, GLenum dstRGB, GLenum srcAlpha, GLenum dstAlpha);

GLAPI void APIENTRY glDrawArraysIndirect (GLenum mode, const void *indirect);

GLAPI void APIENTRY glDrawElementsIndirect (GLenum mode, GLenum type, const void *indirect);

GLAPI void APIENTRY glUniform1d (GLint location, GLdouble x);

GLAPI void APIENTRY glUniform2d (GLint location, GLdouble x, GLdouble y);

GLAPI void APIENTRY glUniform3d (GLint location, GLdouble x, GLdouble y, GLdouble z);

GLAPI void APIENTRY glUniform4d (GLint location, GLdouble x, GLdouble y, GLdouble z, GLdouble w);

GLAPI void APIENTRY glUniform1dv (GLint location, GLsizei count, const GLdouble *value);

GLAPI void APIENTRY glUniform2dv (GLint location, GLsizei count, const GLdouble *value);

GLAPI void APIENTRY glUniform3dv (GLint location, GLsizei count, const GLdouble *value);

GLAPI void APIENTRY glUniform4dv (GLint location, GLsizei count, const GLdouble *value);

GLAPI void APIENTRY glUniformMatrix2dv (GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glUniformMatrix3dv (GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glUniformMatrix4dv (GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glUniformMatrix2x3dv (GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glUniformMatrix2x4dv (GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glUniformMatrix3x2dv (GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glUniformMatrix3x4dv (GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glUniformMatrix4x2dv (GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glUniformMatrix4x3dv (GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glGetUniformdv (GLuint program, GLint location, GLdouble *params);

GLAPI GLint APIENTRY glGetSubroutineUniformLocation (GLuint program, GLenum shadertype, const GLchar *name);

GLAPI GLuint APIENTRY glGetSubroutineIndex (GLuint program, GLenum shadertype, const GLchar *name);

GLAPI void APIENTRY glGetActiveSubroutineUniformiv (GLuint program, GLenum shadertype, GLuint index, GLenum pname, GLint *values);

GLAPI void APIENTRY glGetActiveSubroutineUniformName (GLuint program, GLenum shadertype, GLuint index, GLsizei bufSize, GLsizei *length, GLchar *name);

GLAPI void APIENTRY glGetActiveSubroutineName (GLuint program, GLenum shadertype, GLuint index, GLsizei bufSize, GLsizei *length, GLchar *name);

GLAPI void APIENTRY glUniformSubroutinesuiv (GLenum shadertype, GLsizei count, const GLuint *indices);

GLAPI void APIENTRY glGetUniformSubroutineuiv (GLenum shadertype, GLint location, GLuint *params);

GLAPI void APIENTRY glGetProgramStageiv (GLuint program, GLenum shadertype, GLenum pname, GLint *values);

GLAPI void APIENTRY glPatchParameteri (GLenum pname, GLint value);

GLAPI void APIENTRY glPatchParameterfv (GLenum pname, const GLfloat *values);

GLAPI void APIENTRY glBindTransformFeedback (GLenum target, GLuint id);

GLAPI void APIENTRY glDeleteTransformFeedbacks (GLsizei n, const GLuint *ids);

GLAPI void APIENTRY glGenTransformFeedbacks (GLsizei n, GLuint *ids);

GLAPI GLboolean APIENTRY glIsTransformFeedback (GLuint id);

GLAPI void APIENTRY glPauseTransformFeedback (void);

GLAPI void APIENTRY glResumeTransformFeedback (void);

GLAPI void APIENTRY glDrawTransformFeedback (GLenum mode, GLuint id);

GLAPI void APIENTRY glDrawTransformFeedbackStream (GLenum mode, GLuint id, GLuint stream);

GLAPI void APIENTRY glBeginQueryIndexed (GLenum target, GLuint index, GLuint id);

GLAPI void APIENTRY glEndQueryIndexed (GLenum target, GLuint index);

GLAPI void APIENTRY glGetQueryIndexediv (GLenum target, GLuint index, GLenum pname, GLint *params);

GLAPI void APIENTRY glReleaseShaderCompiler (void);

GLAPI void APIENTRY glShaderBinary (GLsizei count, const GLuint *shaders, GLenum binaryformat, const void *binary, GLsizei length);

GLAPI void APIENTRY glGetShaderPrecisionFormat (GLenum shadertype, GLenum precisiontype, GLint *range, GLint *precision);

GLAPI void APIENTRY glDepthRangef (GLfloat n, GLfloat f);

GLAPI void APIENTRY glClearDepthf (GLfloat d);

GLAPI void APIENTRY glGetProgramBinary (GLuint program, GLsizei bufSize, GLsizei *length, GLenum *binaryFormat, void *binary);

GLAPI void APIENTRY glProgramBinary (GLuint program, GLenum binaryFormat, const void *binary, GLsizei length);

GLAPI void APIENTRY glProgramParameteri (GLuint program, GLenum pname, GLint value);

GLAPI void APIENTRY glUseProgramStages (GLuint pipeline, GLbitfield stages, GLuint program);

GLAPI void APIENTRY glActiveShaderProgram (GLuint pipeline, GLuint program);

GLAPI GLuint APIENTRY glCreateShaderProgramv (GLenum type, GLsizei count, const GLchar *const*strings);

GLAPI void APIENTRY glBindProgramPipeline (GLuint pipeline);

GLAPI void APIENTRY glDeleteProgramPipelines (GLsizei n, const GLuint *pipelines);

GLAPI void APIENTRY glGenProgramPipelines (GLsizei n, GLuint *pipelines);

GLAPI GLboolean APIENTRY glIsProgramPipeline (GLuint pipeline);

GLAPI void APIENTRY glGetProgramPipelineiv (GLuint pipeline, GLenum pname, GLint *params);

GLAPI void APIENTRY glProgramUniform1i (GLuint program, GLint location, GLint v0);

GLAPI void APIENTRY glProgramUniform1iv (GLuint program, GLint location, GLsizei count, const GLint *value);

GLAPI void APIENTRY glProgramUniform1f (GLuint program, GLint location, GLfloat v0);

GLAPI void APIENTRY glProgramUniform1fv (GLuint program, GLint location, GLsizei count, const GLfloat *value);

GLAPI void APIENTRY glProgramUniform1d (GLuint program, GLint location, GLdouble v0);

GLAPI void APIENTRY glProgramUniform1dv (GLuint program, GLint location, GLsizei count, const GLdouble *value);

GLAPI void APIENTRY glProgramUniform1ui (GLuint program, GLint location, GLuint v0);

GLAPI void APIENTRY glProgramUniform1uiv (GLuint program, GLint location, GLsizei count, const GLuint *value);

GLAPI void APIENTRY glProgramUniform2i (GLuint program, GLint location, GLint v0, GLint v1);

GLAPI void APIENTRY glProgramUniform2iv (GLuint program, GLint location, GLsizei count, const GLint *value);

GLAPI void APIENTRY glProgramUniform2f (GLuint program, GLint location, GLfloat v0, GLfloat v1);

GLAPI void APIENTRY glProgramUniform2fv (GLuint program, GLint location, GLsizei count, const GLfloat *value);

GLAPI void APIENTRY glProgramUniform2d (GLuint program, GLint location, GLdouble v0, GLdouble v1);

GLAPI void APIENTRY glProgramUniform2dv (GLuint program, GLint location, GLsizei count, const GLdouble *value);

GLAPI void APIENTRY glProgramUniform2ui (GLuint program, GLint location, GLuint v0, GLuint v1);

GLAPI void APIENTRY glProgramUniform2uiv (GLuint program, GLint location, GLsizei count, const GLuint *value);

GLAPI void APIENTRY glProgramUniform3i (GLuint program, GLint location, GLint v0, GLint v1, GLint v2);

GLAPI void APIENTRY glProgramUniform3iv (GLuint program, GLint location, GLsizei count, const GLint *value);

GLAPI void APIENTRY glProgramUniform3f (GLuint program, GLint location, GLfloat v0, GLfloat v1, GLfloat v2);

GLAPI void APIENTRY glProgramUniform3fv (GLuint program, GLint location, GLsizei count, const GLfloat *value);

GLAPI void APIENTRY glProgramUniform3d (GLuint program, GLint location, GLdouble v0, GLdouble v1, GLdouble v2);

GLAPI void APIENTRY glProgramUniform3dv (GLuint program, GLint location, GLsizei count, const GLdouble *value);

GLAPI void APIENTRY glProgramUniform3ui (GLuint program, GLint location, GLuint v0, GLuint v1, GLuint v2);

GLAPI void APIENTRY glProgramUniform3uiv (GLuint program, GLint location, GLsizei count, const GLuint *value);

GLAPI void APIENTRY glProgramUniform4i (GLuint program, GLint location, GLint v0, GLint v1, GLint v2, GLint v3);

GLAPI void APIENTRY glProgramUniform4iv (GLuint program, GLint location, GLsizei count, const GLint *value);

GLAPI void APIENTRY glProgramUniform4f (GLuint program, GLint location, GLfloat v0, GLfloat v1, GLfloat v2, GLfloat v3);

GLAPI void APIENTRY glProgramUniform4fv (GLuint program, GLint location, GLsizei count, const GLfloat *value);

GLAPI void APIENTRY glProgramUniform4d (GLuint program, GLint location, GLdouble v0, GLdouble v1, GLdouble v2, GLdouble v3);

GLAPI void APIENTRY glProgramUniform4dv (GLuint program, GLint location, GLsizei count, const GLdouble *value);

GLAPI void APIENTRY glProgramUniform4ui (GLuint program, GLint location, GLuint v0, GLuint v1, GLuint v2, GLuint v3);

GLAPI void APIENTRY glProgramUniform4uiv (GLuint program, GLint location, GLsizei count, const GLuint *value);

GLAPI void APIENTRY glProgramUniformMatrix2fv (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glProgramUniformMatrix3fv (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glProgramUniformMatrix4fv (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glProgramUniformMatrix2dv (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glProgramUniformMatrix3dv (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glProgramUniformMatrix4dv (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glProgramUniformMatrix2x3fv (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glProgramUniformMatrix3x2fv (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glProgramUniformMatrix2x4fv (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glProgramUniformMatrix4x2fv (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glProgramUniformMatrix3x4fv (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glProgramUniformMatrix4x3fv (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glProgramUniformMatrix2x3dv (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glProgramUniformMatrix3x2dv (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glProgramUniformMatrix2x4dv (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glProgramUniformMatrix4x2dv (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glProgramUniformMatrix3x4dv (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glProgramUniformMatrix4x3dv (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glValidateProgramPipeline (GLuint pipeline);

GLAPI void APIENTRY glGetProgramPipelineInfoLog (GLuint pipeline, GLsizei bufSize, GLsizei *length, GLchar *infoLog);

GLAPI void APIENTRY glVertexAttribL1d (GLuint index, GLdouble x);

GLAPI void APIENTRY glVertexAttribL2d (GLuint index, GLdouble x, GLdouble y);

GLAPI void APIENTRY glVertexAttribL3d (GLuint index, GLdouble x, GLdouble y, GLdouble z);

GLAPI void APIENTRY glVertexAttribL4d (GLuint index, GLdouble x, GLdouble y, GLdouble z, GLdouble w);

GLAPI void APIENTRY glVertexAttribL1dv (GLuint index, const GLdouble *v);

GLAPI void APIENTRY glVertexAttribL2dv (GLuint index, const GLdouble *v);

GLAPI void APIENTRY glVertexAttribL3dv (GLuint index, const GLdouble *v);

GLAPI void APIENTRY glVertexAttribL4dv (GLuint index, const GLdouble *v);

GLAPI void APIENTRY glVertexAttribLPointer (GLuint index, GLint size, GLenum type, GLsizei stride, const void *pointer);

GLAPI void APIENTRY glGetVertexAttribLdv (GLuint index, GLenum pname, GLdouble *params);

GLAPI void APIENTRY glViewportArrayv (GLuint first, GLsizei count, const GLfloat *v);

GLAPI void APIENTRY glViewportIndexedf (GLuint index, GLfloat x, GLfloat y, GLfloat w, GLfloat h);

GLAPI void APIENTRY glViewportIndexedfv (GLuint index, const GLfloat *v);

GLAPI void APIENTRY glScissorArrayv (GLuint first, GLsizei count, const GLint *v);

GLAPI void APIENTRY glScissorIndexed (GLuint index, GLint left, GLint bottom, GLsizei width, GLsizei height);

GLAPI void APIENTRY glScissorIndexedv (GLuint index, const GLint *v);

GLAPI void APIENTRY glDepthRangeArrayv (GLuint first, GLsizei count, const GLdouble *v);

GLAPI void APIENTRY glDepthRangeIndexed (GLuint index, GLdouble n, GLdouble f);

GLAPI void APIENTRY glGetFloati_v (GLenum target, GLuint index, GLfloat *data);

GLAPI void APIENTRY glGetDoublei_v (GLenum target, GLuint index, GLdouble *data);

GLAPI void APIENTRY glDrawArraysInstancedBaseInstance (GLenum mode, GLint first, GLsizei count, GLsizei instancecount, GLuint baseinstance);

GLAPI void APIENTRY glDrawElementsInstancedBaseInstance (GLenum mode, GLsizei count, GLenum type, const void *indices, GLsizei instancecount, GLuint baseinstance);

GLAPI void APIENTRY glDrawElementsInstancedBaseVertexBaseInstance (GLenum mode, GLsizei count, GLenum type, const void *indices, GLsizei instancecount, GLint basevertex, GLuint baseinstance);

GLAPI void APIENTRY glGetInternalformativ (GLenum target, GLenum internalformat, GLenum pname, GLsizei count, GLint *params);

GLAPI void APIENTRY glGetActiveAtomicCounterBufferiv (GLuint program, GLuint bufferIndex, GLenum pname, GLint *params);

GLAPI void APIENTRY glBindImageTexture (GLuint unit, GLuint texture, GLint level, GLboolean layered, GLint layer, GLenum access, GLenum format);

GLAPI void APIENTRY glMemoryBarrier (GLbitfield barriers);

GLAPI void APIENTRY glTexStorage1D (GLenum target, GLsizei levels, GLenum internalformat, GLsizei width);

GLAPI void APIENTRY glTexStorage2D (GLenum target, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height);

GLAPI void APIENTRY glTexStorage3D (GLenum target, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth);

GLAPI void APIENTRY glDrawTransformFeedbackInstanced (GLenum mode, GLuint id, GLsizei instancecount);

GLAPI void APIENTRY glDrawTransformFeedbackStreamInstanced (GLenum mode, GLuint id, GLuint stream, GLsizei instancecount);

GLAPI void APIENTRY glClearBufferData (GLenum target, GLenum internalformat, GLenum format, GLenum type, const void *data);

GLAPI void APIENTRY glClearBufferSubData (GLenum target, GLenum internalformat, GLintptr offset, GLsizeiptr size, GLenum format, GLenum type, const void *data);

GLAPI void APIENTRY glDispatchCompute (GLuint num_groups_x, GLuint num_groups_y, GLuint num_groups_z);

GLAPI void APIENTRY glDispatchComputeIndirect (GLintptr indirect);

GLAPI void APIENTRY glCopyImageSubData (GLuint srcName, GLenum srcTarget, GLint srcLevel, GLint srcX, GLint srcY, GLint srcZ, GLuint dstName, GLenum dstTarget, GLint dstLevel, GLint dstX, GLint dstY, GLint dstZ, GLsizei srcWidth, GLsizei srcHeight, GLsizei srcDepth);

GLAPI void APIENTRY glFramebufferParameteri (GLenum target, GLenum pname, GLint param);

GLAPI void APIENTRY glGetFramebufferParameteriv (GLenum target, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetInternalformati64v (GLenum target, GLenum internalformat, GLenum pname, GLsizei count, GLint64 *params);

GLAPI void APIENTRY glInvalidateTexSubImage (GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth);

GLAPI void APIENTRY glInvalidateTexImage (GLuint texture, GLint level);

GLAPI void APIENTRY glInvalidateBufferSubData (GLuint buffer, GLintptr offset, GLsizeiptr length);

GLAPI void APIENTRY glInvalidateBufferData (GLuint buffer);

GLAPI void APIENTRY glInvalidateFramebuffer (GLenum target, GLsizei numAttachments, const GLenum *attachments);

GLAPI void APIENTRY glInvalidateSubFramebuffer (GLenum target, GLsizei numAttachments, const GLenum *attachments, GLint x, GLint y, GLsizei width, GLsizei height);

GLAPI void APIENTRY glMultiDrawArraysIndirect (GLenum mode, const void *indirect, GLsizei drawcount, GLsizei stride);

GLAPI void APIENTRY glMultiDrawElementsIndirect (GLenum mode, GLenum type, const void *indirect, GLsizei drawcount, GLsizei stride);

GLAPI void APIENTRY glGetProgramInterfaceiv (GLuint program, GLenum programInterface, GLenum pname, GLint *params);

GLAPI GLuint APIENTRY glGetProgramResourceIndex (GLuint program, GLenum programInterface, const GLchar *name);

GLAPI void APIENTRY glGetProgramResourceName (GLuint program, GLenum programInterface, GLuint index, GLsizei bufSize, GLsizei *length, GLchar *name);

GLAPI void APIENTRY glGetProgramResourceiv (GLuint program, GLenum programInterface, GLuint index, GLsizei propCount, const GLenum *props, GLsizei count, GLsizei *length, GLint *params);

GLAPI GLint APIENTRY glGetProgramResourceLocation (GLuint program, GLenum programInterface, const GLchar *name);

GLAPI GLint APIENTRY glGetProgramResourceLocationIndex (GLuint program, GLenum programInterface, const GLchar *name);

GLAPI void APIENTRY glShaderStorageBlockBinding (GLuint program, GLuint storageBlockIndex, GLuint storageBlockBinding);

GLAPI void APIENTRY glTexBufferRange (GLenum target, GLenum internalformat, GLuint buffer, GLintptr offset, GLsizeiptr size);

GLAPI void APIENTRY glTexStorage2DMultisample (GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLboolean fixedsamplelocations);

GLAPI void APIENTRY glTexStorage3DMultisample (GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLboolean fixedsamplelocations);

GLAPI void APIENTRY glTextureView (GLuint texture, GLenum target, GLuint origtexture, GLenum internalformat, GLuint minlevel, GLuint numlevels, GLuint minlayer, GLuint numlayers);

GLAPI void APIENTRY glBindVertexBuffer (GLuint bindingindex, GLuint buffer, GLintptr offset, GLsizei stride);

GLAPI void APIENTRY glVertexAttribFormat (GLuint attribindex, GLint size, GLenum type, GLboolean normalized, GLuint relativeoffset);

GLAPI void APIENTRY glVertexAttribIFormat (GLuint attribindex, GLint size, GLenum type, GLuint relativeoffset);

GLAPI void APIENTRY glVertexAttribLFormat (GLuint attribindex, GLint size, GLenum type, GLuint relativeoffset);

GLAPI void APIENTRY glVertexAttribBinding (GLuint attribindex, GLuint bindingindex);

GLAPI void APIENTRY glVertexBindingDivisor (GLuint bindingindex, GLuint divisor);

GLAPI void APIENTRY glDebugMessageControl (GLenum source, GLenum type, GLenum severity, GLsizei count, const GLuint *ids, GLboolean enabled);

GLAPI void APIENTRY glDebugMessageInsert (GLenum source, GLenum type, GLuint id, GLenum severity, GLsizei length, const GLchar *buf);

GLAPI void APIENTRY glDebugMessageCallback (GLDEBUGPROC callback, const void *userParam);

GLAPI GLuint APIENTRY glGetDebugMessageLog (GLuint count, GLsizei bufSize, GLenum *sources, GLenum *types, GLuint *ids, GLenum *severities, GLsizei *lengths, GLchar *messageLog);

GLAPI void APIENTRY glPushDebugGroup (GLenum source, GLuint id, GLsizei length, const GLchar *message);

GLAPI void APIENTRY glPopDebugGroup (void);

GLAPI void APIENTRY glObjectLabel (GLenum identifier, GLuint name, GLsizei length, const GLchar *label);

GLAPI void APIENTRY glGetObjectLabel (GLenum identifier, GLuint name, GLsizei bufSize, GLsizei *length, GLchar *label);

GLAPI void APIENTRY glObjectPtrLabel (const void *ptr, GLsizei length, const GLchar *label);

GLAPI void APIENTRY glGetObjectPtrLabel (const void *ptr, GLsizei bufSize, GLsizei *length, GLchar *label);

GLAPI void APIENTRY glBufferStorage (GLenum target, GLsizeiptr size, const void *data, GLbitfield flags);

GLAPI void APIENTRY glClearTexImage (GLuint texture, GLint level, GLenum format, GLenum type, const void *data);

GLAPI void APIENTRY glClearTexSubImage (GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const void *data);

GLAPI void APIENTRY glBindBuffersBase (GLenum target, GLuint first, GLsizei count, const GLuint *buffers);

GLAPI void APIENTRY glBindBuffersRange (GLenum target, GLuint first, GLsizei count, const GLuint *buffers, const GLintptr *offsets, const GLsizeiptr *sizes);

GLAPI void APIENTRY glBindTextures (GLuint first, GLsizei count, const GLuint *textures);

GLAPI void APIENTRY glBindSamplers (GLuint first, GLsizei count, const GLuint *samplers);

GLAPI void APIENTRY glBindImageTextures (GLuint first, GLsizei count, const GLuint *textures);

GLAPI void APIENTRY glBindVertexBuffers (GLuint first, GLsizei count, const GLuint *buffers, const GLintptr *offsets, const GLsizei *strides);

GLAPI void APIENTRY glClipControl (GLenum origin, GLenum depth);

GLAPI void APIENTRY glCreateTransformFeedbacks (GLsizei n, GLuint *ids);

GLAPI void APIENTRY glTransformFeedbackBufferBase (GLuint xfb, GLuint index, GLuint buffer);

GLAPI void APIENTRY glTransformFeedbackBufferRange (GLuint xfb, GLuint index, GLuint buffer, GLintptr offset, GLsizeiptr size);

GLAPI void APIENTRY glGetTransformFeedbackiv (GLuint xfb, GLenum pname, GLint *param);

GLAPI void APIENTRY glGetTransformFeedbacki_v (GLuint xfb, GLenum pname, GLuint index, GLint *param);

GLAPI void APIENTRY glGetTransformFeedbacki64_v (GLuint xfb, GLenum pname, GLuint index, GLint64 *param);

GLAPI void APIENTRY glCreateBuffers (GLsizei n, GLuint *buffers);

GLAPI void APIENTRY glNamedBufferStorage (GLuint buffer, GLsizeiptr size, const void *data, GLbitfield flags);

GLAPI void APIENTRY glNamedBufferData (GLuint buffer, GLsizeiptr size, const void *data, GLenum usage);

GLAPI void APIENTRY glNamedBufferSubData (GLuint buffer, GLintptr offset, GLsizeiptr size, const void *data);

GLAPI void APIENTRY glCopyNamedBufferSubData (GLuint readBuffer, GLuint writeBuffer, GLintptr readOffset, GLintptr writeOffset, GLsizeiptr size);

GLAPI void APIENTRY glClearNamedBufferData (GLuint buffer, GLenum internalformat, GLenum format, GLenum type, const void *data);

GLAPI void APIENTRY glClearNamedBufferSubData (GLuint buffer, GLenum internalformat, GLintptr offset, GLsizeiptr size, GLenum format, GLenum type, const void *data);

GLAPI void *APIENTRY glMapNamedBuffer (GLuint buffer, GLenum access);

GLAPI void *APIENTRY glMapNamedBufferRange (GLuint buffer, GLintptr offset, GLsizeiptr length, GLbitfield access);

GLAPI GLboolean APIENTRY glUnmapNamedBuffer (GLuint buffer);

GLAPI void APIENTRY glFlushMappedNamedBufferRange (GLuint buffer, GLintptr offset, GLsizeiptr length);

GLAPI void APIENTRY glGetNamedBufferParameteriv (GLuint buffer, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetNamedBufferParameteri64v (GLuint buffer, GLenum pname, GLint64 *params);

GLAPI void APIENTRY glGetNamedBufferPointerv (GLuint buffer, GLenum pname, void **params);

GLAPI void APIENTRY glGetNamedBufferSubData (GLuint buffer, GLintptr offset, GLsizeiptr size, void *data);

GLAPI void APIENTRY glCreateFramebuffers (GLsizei n, GLuint *framebuffers);

GLAPI void APIENTRY glNamedFramebufferRenderbuffer (GLuint framebuffer, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer);

GLAPI void APIENTRY glNamedFramebufferParameteri (GLuint framebuffer, GLenum pname, GLint param);

GLAPI void APIENTRY glNamedFramebufferTexture (GLuint framebuffer, GLenum attachment, GLuint texture, GLint level);

GLAPI void APIENTRY glNamedFramebufferTextureLayer (GLuint framebuffer, GLenum attachment, GLuint texture, GLint level, GLint layer);

GLAPI void APIENTRY glNamedFramebufferDrawBuffer (GLuint framebuffer, GLenum buf);

GLAPI void APIENTRY glNamedFramebufferDrawBuffers (GLuint framebuffer, GLsizei n, const GLenum *bufs);

GLAPI void APIENTRY glNamedFramebufferReadBuffer (GLuint framebuffer, GLenum src);

GLAPI void APIENTRY glInvalidateNamedFramebufferData (GLuint framebuffer, GLsizei numAttachments, const GLenum *attachments);

GLAPI void APIENTRY glInvalidateNamedFramebufferSubData (GLuint framebuffer, GLsizei numAttachments, const GLenum *attachments, GLint x, GLint y, GLsizei width, GLsizei height);

GLAPI void APIENTRY glClearNamedFramebufferiv (GLuint framebuffer, GLenum buffer, GLint drawbuffer, const GLint *value);

GLAPI void APIENTRY glClearNamedFramebufferuiv (GLuint framebuffer, GLenum buffer, GLint drawbuffer, const GLuint *value);

GLAPI void APIENTRY glClearNamedFramebufferfv (GLuint framebuffer, GLenum buffer, GLint drawbuffer, const GLfloat *value);

GLAPI void APIENTRY glClearNamedFramebufferfi (GLuint framebuffer, GLenum buffer, GLint drawbuffer, GLfloat depth, GLint stencil);

GLAPI void APIENTRY glBlitNamedFramebuffer (GLuint readFramebuffer, GLuint drawFramebuffer, GLint srcX0, GLint srcY0, GLint srcX1, GLint srcY1, GLint dstX0, GLint dstY0, GLint dstX1, GLint dstY1, GLbitfield mask, GLenum filter);

GLAPI GLenum APIENTRY glCheckNamedFramebufferStatus (GLuint framebuffer, GLenum target);

GLAPI void APIENTRY glGetNamedFramebufferParameteriv (GLuint framebuffer, GLenum pname, GLint *param);

GLAPI void APIENTRY glGetNamedFramebufferAttachmentParameteriv (GLuint framebuffer, GLenum attachment, GLenum pname, GLint *params);

GLAPI void APIENTRY glCreateRenderbuffers (GLsizei n, GLuint *renderbuffers);

GLAPI void APIENTRY glNamedRenderbufferStorage (GLuint renderbuffer, GLenum internalformat, GLsizei width, GLsizei height);

GLAPI void APIENTRY glNamedRenderbufferStorageMultisample (GLuint renderbuffer, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height);

GLAPI void APIENTRY glGetNamedRenderbufferParameteriv (GLuint renderbuffer, GLenum pname, GLint *params);

GLAPI void APIENTRY glCreateTextures (GLenum target, GLsizei n, GLuint *textures);

GLAPI void APIENTRY glTextureBuffer (GLuint texture, GLenum internalformat, GLuint buffer);

GLAPI void APIENTRY glTextureBufferRange (GLuint texture, GLenum internalformat, GLuint buffer, GLintptr offset, GLsizeiptr size);

GLAPI void APIENTRY glTextureStorage1D (GLuint texture, GLsizei levels, GLenum internalformat, GLsizei width);

GLAPI void APIENTRY glTextureStorage2D (GLuint texture, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height);

GLAPI void APIENTRY glTextureStorage3D (GLuint texture, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth);

GLAPI void APIENTRY glTextureStorage2DMultisample (GLuint texture, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLboolean fixedsamplelocations);

GLAPI void APIENTRY glTextureStorage3DMultisample (GLuint texture, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLboolean fixedsamplelocations);

GLAPI void APIENTRY glTextureSubImage1D (GLuint texture, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum type, const void *pixels);

GLAPI void APIENTRY glTextureSubImage2D (GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const void *pixels);

GLAPI void APIENTRY glTextureSubImage3D (GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const void *pixels);

GLAPI void APIENTRY glCompressedTextureSubImage1D (GLuint texture, GLint level, GLint xoffset, GLsizei width, GLenum format, GLsizei imageSize, const void *data);

GLAPI void APIENTRY glCompressedTextureSubImage2D (GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, const void *data);

GLAPI void APIENTRY glCompressedTextureSubImage3D (GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLsizei imageSize, const void *data);

GLAPI void APIENTRY glCopyTextureSubImage1D (GLuint texture, GLint level, GLint xoffset, GLint x, GLint y, GLsizei width);

GLAPI void APIENTRY glCopyTextureSubImage2D (GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height);

GLAPI void APIENTRY glCopyTextureSubImage3D (GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLint x, GLint y, GLsizei width, GLsizei height);

GLAPI void APIENTRY glTextureParameterf (GLuint texture, GLenum pname, GLfloat param);

GLAPI void APIENTRY glTextureParameterfv (GLuint texture, GLenum pname, const GLfloat *param);

GLAPI void APIENTRY glTextureParameteri (GLuint texture, GLenum pname, GLint param);

GLAPI void APIENTRY glTextureParameterIiv (GLuint texture, GLenum pname, const GLint *params);

GLAPI void APIENTRY glTextureParameterIuiv (GLuint texture, GLenum pname, const GLuint *params);

GLAPI void APIENTRY glTextureParameteriv (GLuint texture, GLenum pname, const GLint *param);

GLAPI void APIENTRY glGenerateTextureMipmap (GLuint texture);

GLAPI void APIENTRY glBindTextureUnit (GLuint unit, GLuint texture);

GLAPI void APIENTRY glGetTextureImage (GLuint texture, GLint level, GLenum format, GLenum type, GLsizei bufSize, void *pixels);

GLAPI void APIENTRY glGetCompressedTextureImage (GLuint texture, GLint level, GLsizei bufSize, void *pixels);

GLAPI void APIENTRY glGetTextureLevelParameterfv (GLuint texture, GLint level, GLenum pname, GLfloat *params);

GLAPI void APIENTRY glGetTextureLevelParameteriv (GLuint texture, GLint level, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetTextureParameterfv (GLuint texture, GLenum pname, GLfloat *params);

GLAPI void APIENTRY glGetTextureParameterIiv (GLuint texture, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetTextureParameterIuiv (GLuint texture, GLenum pname, GLuint *params);

GLAPI void APIENTRY glGetTextureParameteriv (GLuint texture, GLenum pname, GLint *params);

GLAPI void APIENTRY glCreateVertexArrays (GLsizei n, GLuint *arrays);

GLAPI void APIENTRY glDisableVertexArrayAttrib (GLuint vaobj, GLuint index);

GLAPI void APIENTRY glEnableVertexArrayAttrib (GLuint vaobj, GLuint index);

GLAPI void APIENTRY glVertexArrayElementBuffer (GLuint vaobj, GLuint buffer);

GLAPI void APIENTRY glVertexArrayVertexBuffer (GLuint vaobj, GLuint bindingindex, GLuint buffer, GLintptr offset, GLsizei stride);

GLAPI void APIENTRY glVertexArrayVertexBuffers (GLuint vaobj, GLuint first, GLsizei count, const GLuint *buffers, const GLintptr *offsets, const GLsizei *strides);

GLAPI void APIENTRY glVertexArrayAttribBinding (GLuint vaobj, GLuint attribindex, GLuint bindingindex);

GLAPI void APIENTRY glVertexArrayAttribFormat (GLuint vaobj, GLuint attribindex, GLint size, GLenum type, GLboolean normalized, GLuint relativeoffset);

GLAPI void APIENTRY glVertexArrayAttribIFormat (GLuint vaobj, GLuint attribindex, GLint size, GLenum type, GLuint relativeoffset);

GLAPI void APIENTRY glVertexArrayAttribLFormat (GLuint vaobj, GLuint attribindex, GLint size, GLenum type, GLuint relativeoffset);

GLAPI void APIENTRY glVertexArrayBindingDivisor (GLuint vaobj, GLuint bindingindex, GLuint divisor);

GLAPI void APIENTRY glGetVertexArrayiv (GLuint vaobj, GLenum pname, GLint *param);

GLAPI void APIENTRY glGetVertexArrayIndexediv (GLuint vaobj, GLuint index, GLenum pname, GLint *param);

GLAPI void APIENTRY glGetVertexArrayIndexed64iv (GLuint vaobj, GLuint index, GLenum pname, GLint64 *param);

GLAPI void APIENTRY glCreateSamplers (GLsizei n, GLuint *samplers);

GLAPI void APIENTRY glCreateProgramPipelines (GLsizei n, GLuint *pipelines);

GLAPI void APIENTRY glCreateQueries (GLenum target, GLsizei n, GLuint *ids);

GLAPI void APIENTRY glGetQueryBufferObjecti64v (GLuint id, GLuint buffer, GLenum pname, GLintptr offset);

GLAPI void APIENTRY glGetQueryBufferObjectiv (GLuint id, GLuint buffer, GLenum pname, GLintptr offset);

GLAPI void APIENTRY glGetQueryBufferObjectui64v (GLuint id, GLuint buffer, GLenum pname, GLintptr offset);

GLAPI void APIENTRY glGetQueryBufferObjectuiv (GLuint id, GLuint buffer, GLenum pname, GLintptr offset);

GLAPI void APIENTRY glMemoryBarrierByRegion (GLbitfield barriers);

GLAPI void APIENTRY glGetTextureSubImage (GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, GLsizei bufSize, void *pixels);

GLAPI void APIENTRY glGetCompressedTextureSubImage (GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLsizei bufSize, void *pixels);

GLAPI GLenum APIENTRY glGetGraphicsResetStatus (void);

GLAPI void APIENTRY glGetnCompressedTexImage (GLenum target, GLint lod, GLsizei bufSize, void *pixels);

GLAPI void APIENTRY glGetnTexImage (GLenum target, GLint level, GLenum format, GLenum type, GLsizei bufSize, void *pixels);

GLAPI void APIENTRY glGetnUniformdv (GLuint program, GLint location, GLsizei bufSize, GLdouble *params);

GLAPI void APIENTRY glGetnUniformfv (GLuint program, GLint location, GLsizei bufSize, GLfloat *params);

GLAPI void APIENTRY glGetnUniformiv (GLuint program, GLint location, GLsizei bufSize, GLint *params);

GLAPI void APIENTRY glGetnUniformuiv (GLuint program, GLint location, GLsizei bufSize, GLuint *params);

GLAPI void APIENTRY glReadnPixels (GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLsizei bufSize, void *data);

GLAPI void APIENTRY glTextureBarrier (void);

GLAPI void APIENTRY glSpecializeShader (GLuint shader, const GLchar *pEntryPoint, GLuint numSpecializationConstants, const GLuint *pConstantIndex, const GLuint *pConstantValue);

GLAPI void APIENTRY glMultiDrawArraysIndirectCount (GLenum mode, const void *indirect, GLintptr drawcount, GLsizei maxdrawcount, GLsizei stride);

GLAPI void APIENTRY glMultiDrawElementsIndirectCount (GLenum mode, GLenum type, const void *indirect, GLintptr drawcount, GLsizei maxdrawcount, GLsizei stride);

GLAPI void APIENTRY glPolygonOffsetClamp (GLfloat factor, GLfloat units, GLfloat clamp);

GLAPI void APIENTRY glPrimitiveBoundingBoxARB (GLfloat minX, GLfloat minY, GLfloat minZ, GLfloat minW, GLfloat maxX, GLfloat maxY, GLfloat maxZ, GLfloat maxW);

GLAPI GLuint64 APIENTRY glGetTextureHandleARB (GLuint texture);

GLAPI GLuint64 APIENTRY glGetTextureSamplerHandleARB (GLuint texture, GLuint sampler);

GLAPI void APIENTRY glMakeTextureHandleResidentARB (GLuint64 handle);

GLAPI void APIENTRY glMakeTextureHandleNonResidentARB (GLuint64 handle);

GLAPI GLuint64 APIENTRY glGetImageHandleARB (GLuint texture, GLint level, GLboolean layered, GLint layer, GLenum format);

GLAPI void APIENTRY glMakeImageHandleResidentARB (GLuint64 handle, GLenum access);

GLAPI void APIENTRY glMakeImageHandleNonResidentARB (GLuint64 handle);

GLAPI void APIENTRY glUniformHandleui64ARB (GLint location, GLuint64 value);

GLAPI void APIENTRY glUniformHandleui64vARB (GLint location, GLsizei count, const GLuint64 *value);

GLAPI void APIENTRY glProgramUniformHandleui64ARB (GLuint program, GLint location, GLuint64 value);

GLAPI void APIENTRY glProgramUniformHandleui64vARB (GLuint program, GLint location, GLsizei count, const GLuint64 *values);

GLAPI GLboolean APIENTRY glIsTextureHandleResidentARB (GLuint64 handle);

GLAPI GLboolean APIENTRY glIsImageHandleResidentARB (GLuint64 handle);

GLAPI void APIENTRY glVertexAttribL1ui64ARB (GLuint index, GLuint64EXT x);

GLAPI void APIENTRY glVertexAttribL1ui64vARB (GLuint index, const GLuint64EXT *v);

GLAPI void APIENTRY glGetVertexAttribLui64vARB (GLuint index, GLenum pname, GLuint64EXT *params);

GLAPI GLsync APIENTRY glCreateSyncFromCLeventARB (struct _cl_context *context, struct _cl_event *event, GLbitfield flags);

GLAPI void APIENTRY glDispatchComputeGroupSizeARB (GLuint num_groups_x, GLuint num_groups_y, GLuint num_groups_z, GLuint group_size_x, GLuint group_size_y, GLuint group_size_z);

GLAPI void APIENTRY glDebugMessageControlARB (GLenum source, GLenum type, GLenum severity, GLsizei count, const GLuint *ids, GLboolean enabled);

GLAPI void APIENTRY glDebugMessageInsertARB (GLenum source, GLenum type, GLuint id, GLenum severity, GLsizei length, const GLchar *buf);

GLAPI void APIENTRY glDebugMessageCallbackARB (GLDEBUGPROCARB callback, const void *userParam);

GLAPI GLuint APIENTRY glGetDebugMessageLogARB (GLuint count, GLsizei bufSize, GLenum *sources, GLenum *types, GLuint *ids, GLenum *severities, GLsizei *lengths, GLchar *messageLog);

GLAPI void APIENTRY glBlendEquationiARB (GLuint buf, GLenum mode);

GLAPI void APIENTRY glBlendEquationSeparateiARB (GLuint buf, GLenum modeRGB, GLenum modeAlpha);

GLAPI void APIENTRY glBlendFunciARB (GLuint buf, GLenum src, GLenum dst);

GLAPI void APIENTRY glBlendFuncSeparateiARB (GLuint buf, GLenum srcRGB, GLenum dstRGB, GLenum srcAlpha, GLenum dstAlpha);

GLAPI void APIENTRY glDrawArraysInstancedARB (GLenum mode, GLint first, GLsizei count, GLsizei primcount);

GLAPI void APIENTRY glDrawElementsInstancedARB (GLenum mode, GLsizei count, GLenum type, const void *indices, GLsizei primcount);

GLAPI void APIENTRY glProgramParameteriARB (GLuint program, GLenum pname, GLint value);

GLAPI void APIENTRY glFramebufferTextureARB (GLenum target, GLenum attachment, GLuint texture, GLint level);

GLAPI void APIENTRY glFramebufferTextureLayerARB (GLenum target, GLenum attachment, GLuint texture, GLint level, GLint layer);

GLAPI void APIENTRY glFramebufferTextureFaceARB (GLenum target, GLenum attachment, GLuint texture, GLint level, GLenum face);

GLAPI void APIENTRY glSpecializeShaderARB (GLuint shader, const GLchar *pEntryPoint, GLuint numSpecializationConstants, const GLuint *pConstantIndex, const GLuint *pConstantValue);

GLAPI void APIENTRY glUniform1i64ARB (GLint location, GLint64 x);

GLAPI void APIENTRY glUniform2i64ARB (GLint location, GLint64 x, GLint64 y);

GLAPI void APIENTRY glUniform3i64ARB (GLint location, GLint64 x, GLint64 y, GLint64 z);

GLAPI void APIENTRY glUniform4i64ARB (GLint location, GLint64 x, GLint64 y, GLint64 z, GLint64 w);

GLAPI void APIENTRY glUniform1i64vARB (GLint location, GLsizei count, const GLint64 *value);

GLAPI void APIENTRY glUniform2i64vARB (GLint location, GLsizei count, const GLint64 *value);

GLAPI void APIENTRY glUniform3i64vARB (GLint location, GLsizei count, const GLint64 *value);

GLAPI void APIENTRY glUniform4i64vARB (GLint location, GLsizei count, const GLint64 *value);

GLAPI void APIENTRY glUniform1ui64ARB (GLint location, GLuint64 x);

GLAPI void APIENTRY glUniform2ui64ARB (GLint location, GLuint64 x, GLuint64 y);

GLAPI void APIENTRY glUniform3ui64ARB (GLint location, GLuint64 x, GLuint64 y, GLuint64 z);

GLAPI void APIENTRY glUniform4ui64ARB (GLint location, GLuint64 x, GLuint64 y, GLuint64 z, GLuint64 w);

GLAPI void APIENTRY glUniform1ui64vARB (GLint location, GLsizei count, const GLuint64 *value);

GLAPI void APIENTRY glUniform2ui64vARB (GLint location, GLsizei count, const GLuint64 *value);

GLAPI void APIENTRY glUniform3ui64vARB (GLint location, GLsizei count, const GLuint64 *value);

GLAPI void APIENTRY glUniform4ui64vARB (GLint location, GLsizei count, const GLuint64 *value);

GLAPI void APIENTRY glGetUniformi64vARB (GLuint program, GLint location, GLint64 *params);

GLAPI void APIENTRY glGetUniformui64vARB (GLuint program, GLint location, GLuint64 *params);

GLAPI void APIENTRY glGetnUniformi64vARB (GLuint program, GLint location, GLsizei bufSize, GLint64 *params);

GLAPI void APIENTRY glGetnUniformui64vARB (GLuint program, GLint location, GLsizei bufSize, GLuint64 *params);

GLAPI void APIENTRY glProgramUniform1i64ARB (GLuint program, GLint location, GLint64 x);

GLAPI void APIENTRY glProgramUniform2i64ARB (GLuint program, GLint location, GLint64 x, GLint64 y);

GLAPI void APIENTRY glProgramUniform3i64ARB (GLuint program, GLint location, GLint64 x, GLint64 y, GLint64 z);

GLAPI void APIENTRY glProgramUniform4i64ARB (GLuint program, GLint location, GLint64 x, GLint64 y, GLint64 z, GLint64 w);

GLAPI void APIENTRY glProgramUniform1i64vARB (GLuint program, GLint location, GLsizei count, const GLint64 *value);

GLAPI void APIENTRY glProgramUniform2i64vARB (GLuint program, GLint location, GLsizei count, const GLint64 *value);

GLAPI void APIENTRY glProgramUniform3i64vARB (GLuint program, GLint location, GLsizei count, const GLint64 *value);

GLAPI void APIENTRY glProgramUniform4i64vARB (GLuint program, GLint location, GLsizei count, const GLint64 *value);

GLAPI void APIENTRY glProgramUniform1ui64ARB (GLuint program, GLint location, GLuint64 x);

GLAPI void APIENTRY glProgramUniform2ui64ARB (GLuint program, GLint location, GLuint64 x, GLuint64 y);

GLAPI void APIENTRY glProgramUniform3ui64ARB (GLuint program, GLint location, GLuint64 x, GLuint64 y, GLuint64 z);

GLAPI void APIENTRY glProgramUniform4ui64ARB (GLuint program, GLint location, GLuint64 x, GLuint64 y, GLuint64 z, GLuint64 w);

GLAPI void APIENTRY glProgramUniform1ui64vARB (GLuint program, GLint location, GLsizei count, const GLuint64 *value);

GLAPI void APIENTRY glProgramUniform2ui64vARB (GLuint program, GLint location, GLsizei count, const GLuint64 *value);

GLAPI void APIENTRY glProgramUniform3ui64vARB (GLuint program, GLint location, GLsizei count, const GLuint64 *value);

GLAPI void APIENTRY glProgramUniform4ui64vARB (GLuint program, GLint location, GLsizei count, const GLuint64 *value);

GLAPI void APIENTRY glMultiDrawArraysIndirectCountARB (GLenum mode, const void *indirect, GLintptr drawcount, GLsizei maxdrawcount, GLsizei stride);

GLAPI void APIENTRY glMultiDrawElementsIndirectCountARB (GLenum mode, GLenum type, const void *indirect, GLintptr drawcount, GLsizei maxdrawcount, GLsizei stride);

GLAPI void APIENTRY glVertexAttribDivisorARB (GLuint index, GLuint divisor);

GLAPI void APIENTRY glMaxShaderCompilerThreadsARB (GLuint count);

GLAPI GLenum APIENTRY glGetGraphicsResetStatusARB (void);

GLAPI void APIENTRY glGetnTexImageARB (GLenum target, GLint level, GLenum format, GLenum type, GLsizei bufSize, void *img);

GLAPI void APIENTRY glReadnPixelsARB (GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, GLsizei bufSize, void *data);

GLAPI void APIENTRY glGetnCompressedTexImageARB (GLenum target, GLint lod, GLsizei bufSize, void *img);

GLAPI void APIENTRY glGetnUniformfvARB (GLuint program, GLint location, GLsizei bufSize, GLfloat *params);

GLAPI void APIENTRY glGetnUniformivARB (GLuint program, GLint location, GLsizei bufSize, GLint *params);

GLAPI void APIENTRY glGetnUniformuivARB (GLuint program, GLint location, GLsizei bufSize, GLuint *params);

GLAPI void APIENTRY glGetnUniformdvARB (GLuint program, GLint location, GLsizei bufSize, GLdouble *params);

GLAPI void APIENTRY glFramebufferSampleLocationsfvARB (GLenum target, GLuint start, GLsizei count, const GLfloat *v);

GLAPI void APIENTRY glNamedFramebufferSampleLocationsfvARB (GLuint framebuffer, GLuint start, GLsizei count, const GLfloat *v);

GLAPI void APIENTRY glEvaluateDepthValuesARB (void);

GLAPI void APIENTRY glMinSampleShadingARB (GLfloat value);

GLAPI void APIENTRY glNamedStringARB (GLenum type, GLint namelen, const GLchar *name, GLint stringlen, const GLchar *string);

GLAPI void APIENTRY glDeleteNamedStringARB (GLint namelen, const GLchar *name);

GLAPI void APIENTRY glCompileShaderIncludeARB (GLuint shader, GLsizei count, const GLchar *const*path, const GLint *length);

GLAPI GLboolean APIENTRY glIsNamedStringARB (GLint namelen, const GLchar *name);

GLAPI void APIENTRY glGetNamedStringARB (GLint namelen, const GLchar *name, GLsizei bufSize, GLint *stringlen, GLchar *string);

GLAPI void APIENTRY glGetNamedStringivARB (GLint namelen, const GLchar *name, GLenum pname, GLint *params);

GLAPI void APIENTRY glBufferPageCommitmentARB (GLenum target, GLintptr offset, GLsizeiptr size, GLboolean commit);

GLAPI void APIENTRY glNamedBufferPageCommitmentEXT (GLuint buffer, GLintptr offset, GLsizeiptr size, GLboolean commit);

GLAPI void APIENTRY glNamedBufferPageCommitmentARB (GLuint buffer, GLintptr offset, GLsizeiptr size, GLboolean commit);

GLAPI void APIENTRY glTexPageCommitmentARB (GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLboolean commit);

GLAPI void APIENTRY glTexBufferARB (GLenum target, GLenum internalformat, GLuint buffer);

GLAPI void APIENTRY glDepthRangeArraydvNV (GLuint first, GLsizei count, const GLdouble *v);

GLAPI void APIENTRY glDepthRangeIndexeddNV (GLuint index, GLdouble n, GLdouble f);

GLAPI void APIENTRY glBlendBarrierKHR (void);

GLAPI void APIENTRY glMaxShaderCompilerThreadsKHR (GLuint count);

GLAPI void APIENTRY glRenderbufferStorageMultisampleAdvancedAMD (GLenum target, GLsizei samples, GLsizei storageSamples, GLenum internalformat, GLsizei width, GLsizei height);

GLAPI void APIENTRY glNamedRenderbufferStorageMultisampleAdvancedAMD (GLuint renderbuffer, GLsizei samples, GLsizei storageSamples, GLenum internalformat, GLsizei width, GLsizei height);

GLAPI void APIENTRY glGetPerfMonitorGroupsAMD (GLint *numGroups, GLsizei groupsSize, GLuint *groups);

GLAPI void APIENTRY glGetPerfMonitorCountersAMD (GLuint group, GLint *numCounters, GLint *maxActiveCounters, GLsizei counterSize, GLuint *counters);

GLAPI void APIENTRY glGetPerfMonitorGroupStringAMD (GLuint group, GLsizei bufSize, GLsizei *length, GLchar *groupString);

GLAPI void APIENTRY glGetPerfMonitorCounterStringAMD (GLuint group, GLuint counter, GLsizei bufSize, GLsizei *length, GLchar *counterString);

GLAPI void APIENTRY glGetPerfMonitorCounterInfoAMD (GLuint group, GLuint counter, GLenum pname, void *data);

GLAPI void APIENTRY glGenPerfMonitorsAMD (GLsizei n, GLuint *monitors);

GLAPI void APIENTRY glDeletePerfMonitorsAMD (GLsizei n, GLuint *monitors);

GLAPI void APIENTRY glSelectPerfMonitorCountersAMD (GLuint monitor, GLboolean enable, GLuint group, GLint numCounters, GLuint *counterList);

GLAPI void APIENTRY glBeginPerfMonitorAMD (GLuint monitor);

GLAPI void APIENTRY glEndPerfMonitorAMD (GLuint monitor);

GLAPI void APIENTRY glGetPerfMonitorCounterDataAMD (GLuint monitor, GLenum pname, GLsizei dataSize, GLuint *data, GLint *bytesWritten);

GLAPI void APIENTRY glEGLImageTargetTexStorageEXT (GLenum target, GLeglImageOES image, const GLint* attrib_list);

GLAPI void APIENTRY glEGLImageTargetTextureStorageEXT (GLuint texture, GLeglImageOES image, const GLint* attrib_list);

GLAPI void APIENTRY glLabelObjectEXT (GLenum type, GLuint object, GLsizei length, const GLchar *label);

GLAPI void APIENTRY glGetObjectLabelEXT (GLenum type, GLuint object, GLsizei bufSize, GLsizei *length, GLchar *label);

GLAPI void APIENTRY glInsertEventMarkerEXT (GLsizei length, const GLchar *marker);

GLAPI void APIENTRY glPushGroupMarkerEXT (GLsizei length, const GLchar *marker);

GLAPI void APIENTRY glPopGroupMarkerEXT (void);

GLAPI void APIENTRY glMatrixLoadfEXT (GLenum mode, const GLfloat *m);

GLAPI void APIENTRY glMatrixLoaddEXT (GLenum mode, const GLdouble *m);

GLAPI void APIENTRY glMatrixMultfEXT (GLenum mode, const GLfloat *m);

GLAPI void APIENTRY glMatrixMultdEXT (GLenum mode, const GLdouble *m);

GLAPI void APIENTRY glMatrixLoadIdentityEXT (GLenum mode);

GLAPI void APIENTRY glMatrixRotatefEXT (GLenum mode, GLfloat angle, GLfloat x, GLfloat y, GLfloat z);

GLAPI void APIENTRY glMatrixRotatedEXT (GLenum mode, GLdouble angle, GLdouble x, GLdouble y, GLdouble z);

GLAPI void APIENTRY glMatrixScalefEXT (GLenum mode, GLfloat x, GLfloat y, GLfloat z);

GLAPI void APIENTRY glMatrixScaledEXT (GLenum mode, GLdouble x, GLdouble y, GLdouble z);

GLAPI void APIENTRY glMatrixTranslatefEXT (GLenum mode, GLfloat x, GLfloat y, GLfloat z);

GLAPI void APIENTRY glMatrixTranslatedEXT (GLenum mode, GLdouble x, GLdouble y, GLdouble z);

GLAPI void APIENTRY glMatrixFrustumEXT (GLenum mode, GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar);

GLAPI void APIENTRY glMatrixOrthoEXT (GLenum mode, GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar);

GLAPI void APIENTRY glMatrixPopEXT (GLenum mode);

GLAPI void APIENTRY glMatrixPushEXT (GLenum mode);

GLAPI void APIENTRY glClientAttribDefaultEXT (GLbitfield mask);

GLAPI void APIENTRY glPushClientAttribDefaultEXT (GLbitfield mask);

GLAPI void APIENTRY glTextureParameterfEXT (GLuint texture, GLenum target, GLenum pname, GLfloat param);

GLAPI void APIENTRY glTextureParameterfvEXT (GLuint texture, GLenum target, GLenum pname, const GLfloat *params);

GLAPI void APIENTRY glTextureParameteriEXT (GLuint texture, GLenum target, GLenum pname, GLint param);

GLAPI void APIENTRY glTextureParameterivEXT (GLuint texture, GLenum target, GLenum pname, const GLint *params);

GLAPI void APIENTRY glTextureImage1DEXT (GLuint texture, GLenum target, GLint level, GLint internalformat, GLsizei width, GLint border, GLenum format, GLenum type, const void *pixels);

GLAPI void APIENTRY glTextureImage2DEXT (GLuint texture, GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const void *pixels);

GLAPI void APIENTRY glTextureSubImage1DEXT (GLuint texture, GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum type, const void *pixels);

GLAPI void APIENTRY glTextureSubImage2DEXT (GLuint texture, GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const void *pixels);

GLAPI void APIENTRY glCopyTextureImage1DEXT (GLuint texture, GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLint border);

GLAPI void APIENTRY glCopyTextureImage2DEXT (GLuint texture, GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border);

GLAPI void APIENTRY glCopyTextureSubImage1DEXT (GLuint texture, GLenum target, GLint level, GLint xoffset, GLint x, GLint y, GLsizei width);

GLAPI void APIENTRY glCopyTextureSubImage2DEXT (GLuint texture, GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height);

GLAPI void APIENTRY glGetTextureImageEXT (GLuint texture, GLenum target, GLint level, GLenum format, GLenum type, void *pixels);

GLAPI void APIENTRY glGetTextureParameterfvEXT (GLuint texture, GLenum target, GLenum pname, GLfloat *params);

GLAPI void APIENTRY glGetTextureParameterivEXT (GLuint texture, GLenum target, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetTextureLevelParameterfvEXT (GLuint texture, GLenum target, GLint level, GLenum pname, GLfloat *params);

GLAPI void APIENTRY glGetTextureLevelParameterivEXT (GLuint texture, GLenum target, GLint level, GLenum pname, GLint *params);

GLAPI void APIENTRY glTextureImage3DEXT (GLuint texture, GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum type, const void *pixels);

GLAPI void APIENTRY glTextureSubImage3DEXT (GLuint texture, GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const void *pixels);

GLAPI void APIENTRY glCopyTextureSubImage3DEXT (GLuint texture, GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLint x, GLint y, GLsizei width, GLsizei height);

GLAPI void APIENTRY glBindMultiTextureEXT (GLenum texunit, GLenum target, GLuint texture);

GLAPI void APIENTRY glMultiTexCoordPointerEXT (GLenum texunit, GLint size, GLenum type, GLsizei stride, const void *pointer);

GLAPI void APIENTRY glMultiTexEnvfEXT (GLenum texunit, GLenum target, GLenum pname, GLfloat param);

GLAPI void APIENTRY glMultiTexEnvfvEXT (GLenum texunit, GLenum target, GLenum pname, const GLfloat *params);

GLAPI void APIENTRY glMultiTexEnviEXT (GLenum texunit, GLenum target, GLenum pname, GLint param);

GLAPI void APIENTRY glMultiTexEnvivEXT (GLenum texunit, GLenum target, GLenum pname, const GLint *params);

GLAPI void APIENTRY glMultiTexGendEXT (GLenum texunit, GLenum coord, GLenum pname, GLdouble param);

GLAPI void APIENTRY glMultiTexGendvEXT (GLenum texunit, GLenum coord, GLenum pname, const GLdouble *params);

GLAPI void APIENTRY glMultiTexGenfEXT (GLenum texunit, GLenum coord, GLenum pname, GLfloat param);

GLAPI void APIENTRY glMultiTexGenfvEXT (GLenum texunit, GLenum coord, GLenum pname, const GLfloat *params);

GLAPI void APIENTRY glMultiTexGeniEXT (GLenum texunit, GLenum coord, GLenum pname, GLint param);

GLAPI void APIENTRY glMultiTexGenivEXT (GLenum texunit, GLenum coord, GLenum pname, const GLint *params);

GLAPI void APIENTRY glGetMultiTexEnvfvEXT (GLenum texunit, GLenum target, GLenum pname, GLfloat *params);

GLAPI void APIENTRY glGetMultiTexEnvivEXT (GLenum texunit, GLenum target, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetMultiTexGendvEXT (GLenum texunit, GLenum coord, GLenum pname, GLdouble *params);

GLAPI void APIENTRY glGetMultiTexGenfvEXT (GLenum texunit, GLenum coord, GLenum pname, GLfloat *params);

GLAPI void APIENTRY glGetMultiTexGenivEXT (GLenum texunit, GLenum coord, GLenum pname, GLint *params);

GLAPI void APIENTRY glMultiTexParameteriEXT (GLenum texunit, GLenum target, GLenum pname, GLint param);

GLAPI void APIENTRY glMultiTexParameterivEXT (GLenum texunit, GLenum target, GLenum pname, const GLint *params);

GLAPI void APIENTRY glMultiTexParameterfEXT (GLenum texunit, GLenum target, GLenum pname, GLfloat param);

GLAPI void APIENTRY glMultiTexParameterfvEXT (GLenum texunit, GLenum target, GLenum pname, const GLfloat *params);

GLAPI void APIENTRY glMultiTexImage1DEXT (GLenum texunit, GLenum target, GLint level, GLint internalformat, GLsizei width, GLint border, GLenum format, GLenum type, const void *pixels);

GLAPI void APIENTRY glMultiTexImage2DEXT (GLenum texunit, GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const void *pixels);

GLAPI void APIENTRY glMultiTexSubImage1DEXT (GLenum texunit, GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum type, const void *pixels);

GLAPI void APIENTRY glMultiTexSubImage2DEXT (GLenum texunit, GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const void *pixels);

GLAPI void APIENTRY glCopyMultiTexImage1DEXT (GLenum texunit, GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLint border);

GLAPI void APIENTRY glCopyMultiTexImage2DEXT (GLenum texunit, GLenum target, GLint level, GLenum internalformat, GLint x, GLint y, GLsizei width, GLsizei height, GLint border);

GLAPI void APIENTRY glCopyMultiTexSubImage1DEXT (GLenum texunit, GLenum target, GLint level, GLint xoffset, GLint x, GLint y, GLsizei width);

GLAPI void APIENTRY glCopyMultiTexSubImage2DEXT (GLenum texunit, GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint x, GLint y, GLsizei width, GLsizei height);

GLAPI void APIENTRY glGetMultiTexImageEXT (GLenum texunit, GLenum target, GLint level, GLenum format, GLenum type, void *pixels);

GLAPI void APIENTRY glGetMultiTexParameterfvEXT (GLenum texunit, GLenum target, GLenum pname, GLfloat *params);

GLAPI void APIENTRY glGetMultiTexParameterivEXT (GLenum texunit, GLenum target, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetMultiTexLevelParameterfvEXT (GLenum texunit, GLenum target, GLint level, GLenum pname, GLfloat *params);

GLAPI void APIENTRY glGetMultiTexLevelParameterivEXT (GLenum texunit, GLenum target, GLint level, GLenum pname, GLint *params);

GLAPI void APIENTRY glMultiTexImage3DEXT (GLenum texunit, GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum type, const void *pixels);

GLAPI void APIENTRY glMultiTexSubImage3DEXT (GLenum texunit, GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const void *pixels);

GLAPI void APIENTRY glCopyMultiTexSubImage3DEXT (GLenum texunit, GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLint x, GLint y, GLsizei width, GLsizei height);

GLAPI void APIENTRY glEnableClientStateIndexedEXT (GLenum array, GLuint index);

GLAPI void APIENTRY glDisableClientStateIndexedEXT (GLenum array, GLuint index);

GLAPI void APIENTRY glGetFloatIndexedvEXT (GLenum target, GLuint index, GLfloat *data);

GLAPI void APIENTRY glGetDoubleIndexedvEXT (GLenum target, GLuint index, GLdouble *data);

GLAPI void APIENTRY glGetPointerIndexedvEXT (GLenum target, GLuint index, void **data);

GLAPI void APIENTRY glEnableIndexedEXT (GLenum target, GLuint index);

GLAPI void APIENTRY glDisableIndexedEXT (GLenum target, GLuint index);

GLAPI GLboolean APIENTRY glIsEnabledIndexedEXT (GLenum target, GLuint index);

GLAPI void APIENTRY glGetIntegerIndexedvEXT (GLenum target, GLuint index, GLint *data);

GLAPI void APIENTRY glGetBooleanIndexedvEXT (GLenum target, GLuint index, GLboolean *data);

GLAPI void APIENTRY glCompressedTextureImage3DEXT (GLuint texture, GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLsizei imageSize, const void *bits);

GLAPI void APIENTRY glCompressedTextureImage2DEXT (GLuint texture, GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, const void *bits);

GLAPI void APIENTRY glCompressedTextureImage1DEXT (GLuint texture, GLenum target, GLint level, GLenum internalformat, GLsizei width, GLint border, GLsizei imageSize, const void *bits);

GLAPI void APIENTRY glCompressedTextureSubImage3DEXT (GLuint texture, GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLsizei imageSize, const void *bits);

GLAPI void APIENTRY glCompressedTextureSubImage2DEXT (GLuint texture, GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, const void *bits);

GLAPI void APIENTRY glCompressedTextureSubImage1DEXT (GLuint texture, GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLsizei imageSize, const void *bits);

GLAPI void APIENTRY glGetCompressedTextureImageEXT (GLuint texture, GLenum target, GLint lod, void *img);

GLAPI void APIENTRY glCompressedMultiTexImage3DEXT (GLenum texunit, GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLsizei imageSize, const void *bits);

GLAPI void APIENTRY glCompressedMultiTexImage2DEXT (GLenum texunit, GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, const void *bits);

GLAPI void APIENTRY glCompressedMultiTexImage1DEXT (GLenum texunit, GLenum target, GLint level, GLenum internalformat, GLsizei width, GLint border, GLsizei imageSize, const void *bits);

GLAPI void APIENTRY glCompressedMultiTexSubImage3DEXT (GLenum texunit, GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLsizei imageSize, const void *bits);

GLAPI void APIENTRY glCompressedMultiTexSubImage2DEXT (GLenum texunit, GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, const void *bits);

GLAPI void APIENTRY glCompressedMultiTexSubImage1DEXT (GLenum texunit, GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLsizei imageSize, const void *bits);

GLAPI void APIENTRY glGetCompressedMultiTexImageEXT (GLenum texunit, GLenum target, GLint lod, void *img);

GLAPI void APIENTRY glMatrixLoadTransposefEXT (GLenum mode, const GLfloat *m);

GLAPI void APIENTRY glMatrixLoadTransposedEXT (GLenum mode, const GLdouble *m);

GLAPI void APIENTRY glMatrixMultTransposefEXT (GLenum mode, const GLfloat *m);

GLAPI void APIENTRY glMatrixMultTransposedEXT (GLenum mode, const GLdouble *m);

GLAPI void APIENTRY glNamedBufferDataEXT (GLuint buffer, GLsizeiptr size, const void *data, GLenum usage);

GLAPI void APIENTRY glNamedBufferSubDataEXT (GLuint buffer, GLintptr offset, GLsizeiptr size, const void *data);

GLAPI void *APIENTRY glMapNamedBufferEXT (GLuint buffer, GLenum access);

GLAPI GLboolean APIENTRY glUnmapNamedBufferEXT (GLuint buffer);

GLAPI void APIENTRY glGetNamedBufferParameterivEXT (GLuint buffer, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetNamedBufferPointervEXT (GLuint buffer, GLenum pname, void **params);

GLAPI void APIENTRY glGetNamedBufferSubDataEXT (GLuint buffer, GLintptr offset, GLsizeiptr size, void *data);

GLAPI void APIENTRY glProgramUniform1fEXT (GLuint program, GLint location, GLfloat v0);

GLAPI void APIENTRY glProgramUniform2fEXT (GLuint program, GLint location, GLfloat v0, GLfloat v1);

GLAPI void APIENTRY glProgramUniform3fEXT (GLuint program, GLint location, GLfloat v0, GLfloat v1, GLfloat v2);

GLAPI void APIENTRY glProgramUniform4fEXT (GLuint program, GLint location, GLfloat v0, GLfloat v1, GLfloat v2, GLfloat v3);

GLAPI void APIENTRY glProgramUniform1iEXT (GLuint program, GLint location, GLint v0);

GLAPI void APIENTRY glProgramUniform2iEXT (GLuint program, GLint location, GLint v0, GLint v1);

GLAPI void APIENTRY glProgramUniform3iEXT (GLuint program, GLint location, GLint v0, GLint v1, GLint v2);

GLAPI void APIENTRY glProgramUniform4iEXT (GLuint program, GLint location, GLint v0, GLint v1, GLint v2, GLint v3);

GLAPI void APIENTRY glProgramUniform1fvEXT (GLuint program, GLint location, GLsizei count, const GLfloat *value);

GLAPI void APIENTRY glProgramUniform2fvEXT (GLuint program, GLint location, GLsizei count, const GLfloat *value);

GLAPI void APIENTRY glProgramUniform3fvEXT (GLuint program, GLint location, GLsizei count, const GLfloat *value);

GLAPI void APIENTRY glProgramUniform4fvEXT (GLuint program, GLint location, GLsizei count, const GLfloat *value);

GLAPI void APIENTRY glProgramUniform1ivEXT (GLuint program, GLint location, GLsizei count, const GLint *value);

GLAPI void APIENTRY glProgramUniform2ivEXT (GLuint program, GLint location, GLsizei count, const GLint *value);

GLAPI void APIENTRY glProgramUniform3ivEXT (GLuint program, GLint location, GLsizei count, const GLint *value);

GLAPI void APIENTRY glProgramUniform4ivEXT (GLuint program, GLint location, GLsizei count, const GLint *value);

GLAPI void APIENTRY glProgramUniformMatrix2fvEXT (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glProgramUniformMatrix3fvEXT (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glProgramUniformMatrix4fvEXT (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glProgramUniformMatrix2x3fvEXT (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glProgramUniformMatrix3x2fvEXT (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glProgramUniformMatrix2x4fvEXT (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glProgramUniformMatrix4x2fvEXT (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glProgramUniformMatrix3x4fvEXT (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glProgramUniformMatrix4x3fvEXT (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);

GLAPI void APIENTRY glTextureBufferEXT (GLuint texture, GLenum target, GLenum internalformat, GLuint buffer);

GLAPI void APIENTRY glMultiTexBufferEXT (GLenum texunit, GLenum target, GLenum internalformat, GLuint buffer);

GLAPI void APIENTRY glTextureParameterIivEXT (GLuint texture, GLenum target, GLenum pname, const GLint *params);

GLAPI void APIENTRY glTextureParameterIuivEXT (GLuint texture, GLenum target, GLenum pname, const GLuint *params);

GLAPI void APIENTRY glGetTextureParameterIivEXT (GLuint texture, GLenum target, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetTextureParameterIuivEXT (GLuint texture, GLenum target, GLenum pname, GLuint *params);

GLAPI void APIENTRY glMultiTexParameterIivEXT (GLenum texunit, GLenum target, GLenum pname, const GLint *params);

GLAPI void APIENTRY glMultiTexParameterIuivEXT (GLenum texunit, GLenum target, GLenum pname, const GLuint *params);

GLAPI void APIENTRY glGetMultiTexParameterIivEXT (GLenum texunit, GLenum target, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetMultiTexParameterIuivEXT (GLenum texunit, GLenum target, GLenum pname, GLuint *params);

GLAPI void APIENTRY glProgramUniform1uiEXT (GLuint program, GLint location, GLuint v0);

GLAPI void APIENTRY glProgramUniform2uiEXT (GLuint program, GLint location, GLuint v0, GLuint v1);

GLAPI void APIENTRY glProgramUniform3uiEXT (GLuint program, GLint location, GLuint v0, GLuint v1, GLuint v2);

GLAPI void APIENTRY glProgramUniform4uiEXT (GLuint program, GLint location, GLuint v0, GLuint v1, GLuint v2, GLuint v3);

GLAPI void APIENTRY glProgramUniform1uivEXT (GLuint program, GLint location, GLsizei count, const GLuint *value);

GLAPI void APIENTRY glProgramUniform2uivEXT (GLuint program, GLint location, GLsizei count, const GLuint *value);

GLAPI void APIENTRY glProgramUniform3uivEXT (GLuint program, GLint location, GLsizei count, const GLuint *value);

GLAPI void APIENTRY glProgramUniform4uivEXT (GLuint program, GLint location, GLsizei count, const GLuint *value);

GLAPI void APIENTRY glNamedProgramLocalParameters4fvEXT (GLuint program, GLenum target, GLuint index, GLsizei count, const GLfloat *params);

GLAPI void APIENTRY glNamedProgramLocalParameterI4iEXT (GLuint program, GLenum target, GLuint index, GLint x, GLint y, GLint z, GLint w);

GLAPI void APIENTRY glNamedProgramLocalParameterI4ivEXT (GLuint program, GLenum target, GLuint index, const GLint *params);

GLAPI void APIENTRY glNamedProgramLocalParametersI4ivEXT (GLuint program, GLenum target, GLuint index, GLsizei count, const GLint *params);

GLAPI void APIENTRY glNamedProgramLocalParameterI4uiEXT (GLuint program, GLenum target, GLuint index, GLuint x, GLuint y, GLuint z, GLuint w);

GLAPI void APIENTRY glNamedProgramLocalParameterI4uivEXT (GLuint program, GLenum target, GLuint index, const GLuint *params);

GLAPI void APIENTRY glNamedProgramLocalParametersI4uivEXT (GLuint program, GLenum target, GLuint index, GLsizei count, const GLuint *params);

GLAPI void APIENTRY glGetNamedProgramLocalParameterIivEXT (GLuint program, GLenum target, GLuint index, GLint *params);

GLAPI void APIENTRY glGetNamedProgramLocalParameterIuivEXT (GLuint program, GLenum target, GLuint index, GLuint *params);

GLAPI void APIENTRY glEnableClientStateiEXT (GLenum array, GLuint index);

GLAPI void APIENTRY glDisableClientStateiEXT (GLenum array, GLuint index);

GLAPI void APIENTRY glGetFloati_vEXT (GLenum pname, GLuint index, GLfloat *params);

GLAPI void APIENTRY glGetDoublei_vEXT (GLenum pname, GLuint index, GLdouble *params);

GLAPI void APIENTRY glGetPointeri_vEXT (GLenum pname, GLuint index, void **params);

GLAPI void APIENTRY glNamedProgramStringEXT (GLuint program, GLenum target, GLenum format, GLsizei len, const void *string);

GLAPI void APIENTRY glNamedProgramLocalParameter4dEXT (GLuint program, GLenum target, GLuint index, GLdouble x, GLdouble y, GLdouble z, GLdouble w);

GLAPI void APIENTRY glNamedProgramLocalParameter4dvEXT (GLuint program, GLenum target, GLuint index, const GLdouble *params);

GLAPI void APIENTRY glNamedProgramLocalParameter4fEXT (GLuint program, GLenum target, GLuint index, GLfloat x, GLfloat y, GLfloat z, GLfloat w);

GLAPI void APIENTRY glNamedProgramLocalParameter4fvEXT (GLuint program, GLenum target, GLuint index, const GLfloat *params);

GLAPI void APIENTRY glGetNamedProgramLocalParameterdvEXT (GLuint program, GLenum target, GLuint index, GLdouble *params);

GLAPI void APIENTRY glGetNamedProgramLocalParameterfvEXT (GLuint program, GLenum target, GLuint index, GLfloat *params);

GLAPI void APIENTRY glGetNamedProgramivEXT (GLuint program, GLenum target, GLenum pname, GLint *params);

GLAPI void APIENTRY glGetNamedProgramStringEXT (GLuint program, GLenum target, GLenum pname, void *string);

GLAPI void APIENTRY glNamedRenderbufferStorageEXT (GLuint renderbuffer, GLenum internalformat, GLsizei width, GLsizei height);

GLAPI void APIENTRY glGetNamedRenderbufferParameterivEXT (GLuint renderbuffer, GLenum pname, GLint *params);

GLAPI void APIENTRY glNamedRenderbufferStorageMultisampleEXT (GLuint renderbuffer, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height);

GLAPI void APIENTRY glNamedRenderbufferStorageMultisampleCoverageEXT (GLuint renderbuffer, GLsizei coverageSamples, GLsizei colorSamples, GLenum internalformat, GLsizei width, GLsizei height);

GLAPI GLenum APIENTRY glCheckNamedFramebufferStatusEXT (GLuint framebuffer, GLenum target);

GLAPI void APIENTRY glNamedFramebufferTexture1DEXT (GLuint framebuffer, GLenum attachment, GLenum textarget, GLuint texture, GLint level);

GLAPI void APIENTRY glNamedFramebufferTexture2DEXT (GLuint framebuffer, GLenum attachment, GLenum textarget, GLuint texture, GLint level);

GLAPI void APIENTRY glNamedFramebufferTexture3DEXT (GLuint framebuffer, GLenum attachment, GLenum textarget, GLuint texture, GLint level, GLint zoffset);

GLAPI void APIENTRY glNamedFramebufferRenderbufferEXT (GLuint framebuffer, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer);

GLAPI void APIENTRY glGetNamedFramebufferAttachmentParameterivEXT (GLuint framebuffer, GLenum attachment, GLenum pname, GLint *params);

GLAPI void APIENTRY glGenerateTextureMipmapEXT (GLuint texture, GLenum target);

GLAPI void APIENTRY glGenerateMultiTexMipmapEXT (GLenum texunit, GLenum target);

GLAPI void APIENTRY glFramebufferDrawBufferEXT (GLuint framebuffer, GLenum mode);

GLAPI void APIENTRY glFramebufferDrawBuffersEXT (GLuint framebuffer, GLsizei n, const GLenum *bufs);

GLAPI void APIENTRY glFramebufferReadBufferEXT (GLuint framebuffer, GLenum mode);

GLAPI void APIENTRY glGetFramebufferParameterivEXT (GLuint framebuffer, GLenum pname, GLint *params);

GLAPI void APIENTRY glNamedCopyBufferSubDataEXT (GLuint readBuffer, GLuint writeBuffer, GLintptr readOffset, GLintptr writeOffset, GLsizeiptr size);

GLAPI void APIENTRY glNamedFramebufferTextureEXT (GLuint framebuffer, GLenum attachment, GLuint texture, GLint level);

GLAPI void APIENTRY glNamedFramebufferTextureLayerEXT (GLuint framebuffer, GLenum attachment, GLuint texture, GLint level, GLint layer);

GLAPI void APIENTRY glNamedFramebufferTextureFaceEXT (GLuint framebuffer, GLenum attachment, GLuint texture, GLint level, GLenum face);

GLAPI void APIENTRY glTextureRenderbufferEXT (GLuint texture, GLenum target, GLuint renderbuffer);

GLAPI void APIENTRY glMultiTexRenderbufferEXT (GLenum texunit, GLenum target, GLuint renderbuffer);

GLAPI void APIENTRY glVertexArrayVertexOffsetEXT (GLuint vaobj, GLuint buffer, GLint size, GLenum type, GLsizei stride, GLintptr offset);

GLAPI void APIENTRY glVertexArrayColorOffsetEXT (GLuint vaobj, GLuint buffer, GLint size, GLenum type, GLsizei stride, GLintptr offset);

GLAPI void APIENTRY glVertexArrayEdgeFlagOffsetEXT (GLuint vaobj, GLuint buffer, GLsizei stride, GLintptr offset);

GLAPI void APIENTRY glVertexArrayIndexOffsetEXT (GLuint vaobj, GLuint buffer, GLenum type, GLsizei stride, GLintptr offset);

GLAPI void APIENTRY glVertexArrayNormalOffsetEXT (GLuint vaobj, GLuint buffer, GLenum type, GLsizei stride, GLintptr offset);

GLAPI void APIENTRY glVertexArrayTexCoordOffsetEXT (GLuint vaobj, GLuint buffer, GLint size, GLenum type, GLsizei stride, GLintptr offset);

GLAPI void APIENTRY glVertexArrayMultiTexCoordOffsetEXT (GLuint vaobj, GLuint buffer, GLenum texunit, GLint size, GLenum type, GLsizei stride, GLintptr offset);

GLAPI void APIENTRY glVertexArrayFogCoordOffsetEXT (GLuint vaobj, GLuint buffer, GLenum type, GLsizei stride, GLintptr offset);

GLAPI void APIENTRY glVertexArraySecondaryColorOffsetEXT (GLuint vaobj, GLuint buffer, GLint size, GLenum type, GLsizei stride, GLintptr offset);

GLAPI void APIENTRY glVertexArrayVertexAttribOffsetEXT (GLuint vaobj, GLuint buffer, GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride, GLintptr offset);

GLAPI void APIENTRY glVertexArrayVertexAttribIOffsetEXT (GLuint vaobj, GLuint buffer, GLuint index, GLint size, GLenum type, GLsizei stride, GLintptr offset);

GLAPI void APIENTRY glEnableVertexArrayEXT (GLuint vaobj, GLenum array);

GLAPI void APIENTRY glDisableVertexArrayEXT (GLuint vaobj, GLenum array);

GLAPI void APIENTRY glEnableVertexArrayAttribEXT (GLuint vaobj, GLuint index);

GLAPI void APIENTRY glDisableVertexArrayAttribEXT (GLuint vaobj, GLuint index);

GLAPI void APIENTRY glGetVertexArrayIntegervEXT (GLuint vaobj, GLenum pname, GLint *param);

GLAPI void APIENTRY glGetVertexArrayPointervEXT (GLuint vaobj, GLenum pname, void **param);

GLAPI void APIENTRY glGetVertexArrayIntegeri_vEXT (GLuint vaobj, GLuint index, GLenum pname, GLint *param);

GLAPI void APIENTRY glGetVertexArrayPointeri_vEXT (GLuint vaobj, GLuint index, GLenum pname, void **param);

GLAPI void *APIENTRY glMapNamedBufferRangeEXT (GLuint buffer, GLintptr offset, GLsizeiptr length, GLbitfield access);

GLAPI void APIENTRY glFlushMappedNamedBufferRangeEXT (GLuint buffer, GLintptr offset, GLsizeiptr length);

GLAPI void APIENTRY glNamedBufferStorageEXT (GLuint buffer, GLsizeiptr size, const void *data, GLbitfield flags);

GLAPI void APIENTRY glClearNamedBufferDataEXT (GLuint buffer, GLenum internalformat, GLenum format, GLenum type, const void *data);

GLAPI void APIENTRY glClearNamedBufferSubDataEXT (GLuint buffer, GLenum internalformat, GLsizeiptr offset, GLsizeiptr size, GLenum format, GLenum type, const void *data);

GLAPI void APIENTRY glNamedFramebufferParameteriEXT (GLuint framebuffer, GLenum pname, GLint param);

GLAPI void APIENTRY glGetNamedFramebufferParameterivEXT (GLuint framebuffer, GLenum pname, GLint *params);

GLAPI void APIENTRY glProgramUniform1dEXT (GLuint program, GLint location, GLdouble x);

GLAPI void APIENTRY glProgramUniform2dEXT (GLuint program, GLint location, GLdouble x, GLdouble y);

GLAPI void APIENTRY glProgramUniform3dEXT (GLuint program, GLint location, GLdouble x, GLdouble y, GLdouble z);

GLAPI void APIENTRY glProgramUniform4dEXT (GLuint program, GLint location, GLdouble x, GLdouble y, GLdouble z, GLdouble w);

GLAPI void APIENTRY glProgramUniform1dvEXT (GLuint program, GLint location, GLsizei count, const GLdouble *value);

GLAPI void APIENTRY glProgramUniform2dvEXT (GLuint program, GLint location, GLsizei count, const GLdouble *value);

GLAPI void APIENTRY glProgramUniform3dvEXT (GLuint program, GLint location, GLsizei count, const GLdouble *value);

GLAPI void APIENTRY glProgramUniform4dvEXT (GLuint program, GLint location, GLsizei count, const GLdouble *value);

GLAPI void APIENTRY glProgramUniformMatrix2dvEXT (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glProgramUniformMatrix3dvEXT (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glProgramUniformMatrix4dvEXT (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glProgramUniformMatrix2x3dvEXT (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glProgramUniformMatrix2x4dvEXT (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glProgramUniformMatrix3x2dvEXT (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glProgramUniformMatrix3x4dvEXT (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glProgramUniformMatrix4x2dvEXT (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glProgramUniformMatrix4x3dvEXT (GLuint program, GLint location, GLsizei count, GLboolean transpose, const GLdouble *value);

GLAPI void APIENTRY glTextureBufferRangeEXT (GLuint texture, GLenum target, GLenum internalformat, GLuint buffer, GLintptr offset, GLsizeiptr size);

GLAPI void APIENTRY glTextureStorage1DEXT (GLuint texture, GLenum target, GLsizei levels, GLenum internalformat, GLsizei width);

GLAPI void APIENTRY glTextureStorage2DEXT (GLuint texture, GLenum target, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height);

GLAPI void APIENTRY glTextureStorage3DEXT (GLuint texture, GLenum target, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth);

GLAPI void APIENTRY glTextureStorage2DMultisampleEXT (GLuint texture, GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLboolean fixedsamplelocations);

GLAPI void APIENTRY glTextureStorage3DMultisampleEXT (GLuint texture, GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLboolean fixedsamplelocations);

GLAPI void APIENTRY glVertexArrayBindVertexBufferEXT (GLuint vaobj, GLuint bindingindex, GLuint buffer, GLintptr offset, GLsizei stride);

GLAPI void APIENTRY glVertexArrayVertexAttribFormatEXT (GLuint vaobj, GLuint attribindex, GLint size, GLenum type, GLboolean normalized, GLuint relativeoffset);

GLAPI void APIENTRY glVertexArrayVertexAttribIFormatEXT (GLuint vaobj, GLuint attribindex, GLint size, GLenum type, GLuint relativeoffset);

GLAPI void APIENTRY glVertexArrayVertexAttribLFormatEXT (GLuint vaobj, GLuint attribindex, GLint size, GLenum type, GLuint relativeoffset);

GLAPI void APIENTRY glVertexArrayVertexAttribBindingEXT (GLuint vaobj, GLuint attribindex, GLuint bindingindex);

GLAPI void APIENTRY glVertexArrayVertexBindingDivisorEXT (GLuint vaobj, GLuint bindingindex, GLuint divisor);

GLAPI void APIENTRY glVertexArrayVertexAttribLOffsetEXT (GLuint vaobj, GLuint buffer, GLuint index, GLint size, GLenum type, GLsizei stride, GLintptr offset);

GLAPI void APIENTRY glTexturePageCommitmentEXT (GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLboolean commit);

GLAPI void APIENTRY glVertexArrayVertexAttribDivisorEXT (GLuint vaobj, GLuint index, GLuint divisor);

GLAPI void APIENTRY glDrawArraysInstancedEXT (GLenum mode, GLint start, GLsizei count, GLsizei primcount);

GLAPI void APIENTRY glDrawElementsInstancedEXT (GLenum mode, GLsizei count, GLenum type, const void *indices, GLsizei primcount);

GLAPI void APIENTRY glPolygonOffsetClampEXT (GLfloat factor, GLfloat units, GLfloat clamp);

GLAPI void APIENTRY glRasterSamplesEXT (GLuint samples, GLboolean fixedsamplelocations);

GLAPI void APIENTRY glUseShaderProgramEXT (GLenum type, GLuint program);

GLAPI void APIENTRY glActiveProgramEXT (GLuint program);

GLAPI GLuint APIENTRY glCreateShaderProgramEXT (GLenum type, const GLchar *string);

GLAPI void APIENTRY glFramebufferFetchBarrierEXT (void);

GLAPI void APIENTRY glWindowRectanglesEXT (GLenum mode, GLsizei count, const GLint *box);

GLAPI void APIENTRY glApplyFramebufferAttachmentCMAAINTEL (void);

GLAPI void APIENTRY glBeginPerfQueryINTEL (GLuint queryHandle);

GLAPI void APIENTRY glCreatePerfQueryINTEL (GLuint queryId, GLuint *queryHandle);

GLAPI void APIENTRY glDeletePerfQueryINTEL (GLuint queryHandle);

GLAPI void APIENTRY glEndPerfQueryINTEL (GLuint queryHandle);

GLAPI void APIENTRY glGetFirstPerfQueryIdINTEL (GLuint *queryId);

GLAPI void APIENTRY glGetNextPerfQueryIdINTEL (GLuint queryId, GLuint *nextQueryId);

GLAPI void APIENTRY glGetPerfCounterInfoINTEL (GLuint queryId, GLuint counterId, GLuint counterNameLength, GLchar *counterName, GLuint counterDescLength, GLchar *counterDesc, GLuint *counterOffset, GLuint *counterDataSize, GLuint *counterTypeEnum, GLuint *counterDataTypeEnum, GLuint64 *rawCounterMaxValue);

GLAPI void APIENTRY glGetPerfQueryDataINTEL (GLuint queryHandle, GLuint flags, GLsizei dataSize, void *data, GLuint *bytesWritten);

GLAPI void APIENTRY glGetPerfQueryIdByNameINTEL (GLchar *queryName, GLuint *queryId);

GLAPI void APIENTRY glGetPerfQueryInfoINTEL (GLuint queryId, GLuint queryNameLength, GLchar *queryName, GLuint *dataSize, GLuint *noCounters, GLuint *noInstances, GLuint *capsMask);

GLAPI void APIENTRY glFramebufferParameteriMESA (GLenum target, GLenum pname, GLint param);

GLAPI void APIENTRY glGetFramebufferParameterivMESA (GLenum target, GLenum pname, GLint *params);

GLAPI void APIENTRY glMultiDrawArraysIndirectBindlessNV (GLenum mode, const void *indirect, GLsizei drawCount, GLsizei stride, GLint vertexBufferCount);

GLAPI void APIENTRY glMultiDrawElementsIndirectBindlessNV (GLenum mode, GLenum type, const void *indirect, GLsizei drawCount, GLsizei stride, GLint vertexBufferCount);

GLAPI void APIENTRY glMultiDrawArraysIndirectBindlessCountNV (GLenum mode, const void *indirect, GLsizei drawCount, GLsizei maxDrawCount, GLsizei stride, GLint vertexBufferCount);

GLAPI void APIENTRY glMultiDrawElementsIndirectBindlessCountNV (GLenum mode, GLenum type, const void *indirect, GLsizei drawCount, GLsizei maxDrawCount, GLsizei stride, GLint vertexBufferCount);

GLAPI GLuint64 APIENTRY glGetTextureHandleNV (GLuint texture);

GLAPI GLuint64 APIENTRY glGetTextureSamplerHandleNV (GLuint texture, GLuint sampler);

GLAPI void APIENTRY glMakeTextureHandleResidentNV (GLuint64 handle);

GLAPI void APIENTRY glMakeTextureHandleNonResidentNV (GLuint64 handle);

GLAPI GLuint64 APIENTRY glGetImageHandleNV (GLuint texture, GLint level, GLboolean layered, GLint layer, GLenum format);

GLAPI void APIENTRY glMakeImageHandleResidentNV (GLuint64 handle, GLenum access);

GLAPI void APIENTRY glMakeImageHandleNonResidentNV (GLuint64 handle);

GLAPI void APIENTRY glUniformHandleui64NV (GLint location, GLuint64 value);

GLAPI void APIENTRY glUniformHandleui64vNV (GLint location, GLsizei count, const GLuint64 *value);

GLAPI void APIENTRY glProgramUniformHandleui64NV (GLuint program, GLint location, GLuint64 value);

GLAPI void APIENTRY glProgramUniformHandleui64vNV (GLuint program, GLint location, GLsizei count, const GLuint64 *values);

GLAPI GLboolean APIENTRY glIsTextureHandleResidentNV (GLuint64 handle);

GLAPI GLboolean APIENTRY glIsImageHandleResidentNV (GLuint64 handle);

GLAPI void APIENTRY glBlendParameteriNV (GLenum pname, GLint value);

GLAPI void APIENTRY glBlendBarrierNV (void);

GLAPI void APIENTRY glViewportPositionWScaleNV (GLuint index, GLfloat xcoeff, GLfloat ycoeff);

GLAPI void APIENTRY glCreateStatesNV (GLsizei n, GLuint *states);

GLAPI void APIENTRY glDeleteStatesNV (GLsizei n, const GLuint *states);

GLAPI GLboolean APIENTRY glIsStateNV (GLuint state);

GLAPI void APIENTRY glStateCaptureNV (GLuint state, GLenum mode);

GLAPI GLuint APIENTRY glGetCommandHeaderNV (GLenum tokenID, GLuint size);

GLAPI GLushort APIENTRY glGetStageIndexNV (GLenum shadertype);

GLAPI void APIENTRY glDrawCommandsNV (GLenum primitiveMode, GLuint buffer, const GLintptr *indirects, const GLsizei *sizes, GLuint count);

GLAPI void APIENTRY glDrawCommandsAddressNV (GLenum primitiveMode, const GLuint64 *indirects, const GLsizei *sizes, GLuint count);

GLAPI void APIENTRY glDrawCommandsStatesNV (GLuint buffer, const GLintptr *indirects, const GLsizei *sizes, const GLuint *states, const GLuint *fbos, GLuint count);

GLAPI void APIENTRY glDrawCommandsStatesAddressNV (const GLuint64 *indirects, const GLsizei *sizes, const GLuint *states, const GLuint *fbos, GLuint count);

GLAPI void APIENTRY glCreateCommandListsNV (GLsizei n, GLuint *lists);

GLAPI void APIENTRY glDeleteCommandListsNV (GLsizei n, const GLuint *lists);

GLAPI GLboolean APIENTRY glIsCommandListNV (GLuint list);

GLAPI void APIENTRY glListDrawCommandsStatesClientNV (GLuint list, GLuint segment, const void **indirects, const GLsizei *sizes, const GLuint *states, const GLuint *fbos, GLuint count);

GLAPI void APIENTRY glCommandListSegmentsNV (GLuint list, GLuint segments);

GLAPI void APIENTRY glCompileCommandListNV (GLuint list);

GLAPI void APIENTRY glCallCommandListNV (GLuint list);

GLAPI void APIENTRY glBeginConditionalRenderNV (GLuint id, GLenum mode);

GLAPI void APIENTRY glEndConditionalRenderNV (void);

GLAPI void APIENTRY glSubpixelPrecisionBiasNV (GLuint xbits, GLuint ybits);

GLAPI void APIENTRY glConservativeRasterParameterfNV (GLenum pname, GLfloat value);

GLAPI void APIENTRY glConservativeRasterParameteriNV (GLenum pname, GLint param);

GLAPI void APIENTRY glDepthRangedNV (GLdouble zNear, GLdouble zFar);

GLAPI void APIENTRY glClearDepthdNV (GLdouble depth);

GLAPI void APIENTRY glDepthBoundsdNV (GLdouble zmin, GLdouble zmax);

GLAPI void APIENTRY glDrawVkImageNV (GLuint64 vkImage, GLuint sampler, GLfloat x0, GLfloat y0, GLfloat x1, GLfloat y1, GLfloat z, GLfloat s0, GLfloat t0, GLfloat s1, GLfloat t1);

GLAPI GLVULKANPROCNV APIENTRY glGetVkProcAddrNV (const GLchar *name);

GLAPI void APIENTRY glWaitVkSemaphoreNV (GLuint64 vkSemaphore);

GLAPI void APIENTRY glSignalVkSemaphoreNV (GLuint64 vkSemaphore);

GLAPI void APIENTRY glSignalVkFenceNV (GLuint64 vkFence);

GLAPI void APIENTRY glFragmentCoverageColorNV (GLuint color);

GLAPI void APIENTRY glCoverageModulationTableNV (GLsizei n, const GLfloat *v);

GLAPI void APIENTRY glGetCoverageModulationTableNV (GLsizei bufSize, GLfloat *v);

GLAPI void APIENTRY glCoverageModulationNV (GLenum components);

GLAPI void APIENTRY glRenderbufferStorageMultisampleCoverageNV (GLenum target, GLsizei coverageSamples, GLsizei colorSamples, GLenum internalformat, GLsizei width, GLsizei height);

GLAPI void APIENTRY glUniform1i64NV (GLint location, GLint64EXT x);

GLAPI void APIENTRY glUniform2i64NV (GLint location, GLint64EXT x, GLint64EXT y);

GLAPI void APIENTRY glUniform3i64NV (GLint location, GLint64EXT x, GLint64EXT y, GLint64EXT z);

GLAPI void APIENTRY glUniform4i64NV (GLint location, GLint64EXT x, GLint64EXT y, GLint64EXT z, GLint64EXT w);

GLAPI void APIENTRY glUniform1i64vNV (GLint location, GLsizei count, const GLint64EXT *value);

GLAPI void APIENTRY glUniform2i64vNV (GLint location, GLsizei count, const GLint64EXT *value);

GLAPI void APIENTRY glUniform3i64vNV (GLint location, GLsizei count, const GLint64EXT *value);

GLAPI void APIENTRY glUniform4i64vNV (GLint location, GLsizei count, const GLint64EXT *value);

GLAPI void APIENTRY glUniform1ui64NV (GLint location, GLuint64EXT x);

GLAPI void APIENTRY glUniform2ui64NV (GLint location, GLuint64EXT x, GLuint64EXT y);

GLAPI void APIENTRY glUniform3ui64NV (GLint location, GLuint64EXT x, GLuint64EXT y, GLuint64EXT z);

GLAPI void APIENTRY glUniform4ui64NV (GLint location, GLuint64EXT x, GLuint64EXT y, GLuint64EXT z, GLuint64EXT w);

GLAPI void APIENTRY glUniform1ui64vNV (GLint location, GLsizei count, const GLuint64EXT *value);

GLAPI void APIENTRY glUniform2ui64vNV (GLint location, GLsizei count, const GLuint64EXT *value);

GLAPI void APIENTRY glUniform3ui64vNV (GLint location, GLsizei count, const GLuint64EXT *value);

GLAPI void APIENTRY glUniform4ui64vNV (GLint location, GLsizei count, const GLuint64EXT *value);

GLAPI void APIENTRY glGetUniformi64vNV (GLuint program, GLint location, GLint64EXT *params);

GLAPI void APIENTRY glProgramUniform1i64NV (GLuint program, GLint location, GLint64EXT x);

GLAPI void APIENTRY glProgramUniform2i64NV (GLuint program, GLint location, GLint64EXT x, GLint64EXT y);

GLAPI void APIENTRY glProgramUniform3i64NV (GLuint program, GLint location, GLint64EXT x, GLint64EXT y, GLint64EXT z);

GLAPI void APIENTRY glProgramUniform4i64NV (GLuint program, GLint location, GLint64EXT x, GLint64EXT y, GLint64EXT z, GLint64EXT w);

GLAPI void APIENTRY glProgramUniform1i64vNV (GLuint program, GLint location, GLsizei count, const GLint64EXT *value);

GLAPI void APIENTRY glProgramUniform2i64vNV (GLuint program, GLint location, GLsizei count, const GLint64EXT *value);

GLAPI void APIENTRY glProgramUniform3i64vNV (GLuint program, GLint location, GLsizei count, const GLint64EXT *value);

GLAPI void APIENTRY glProgramUniform4i64vNV (GLuint program, GLint location, GLsizei count, const GLint64EXT *value);

GLAPI void APIENTRY glProgramUniform1ui64NV (GLuint program, GLint location, GLuint64EXT x);

GLAPI void APIENTRY glProgramUniform2ui64NV (GLuint program, GLint location, GLuint64EXT x, GLuint64EXT y);

GLAPI void APIENTRY glProgramUniform3ui64NV (GLuint program, GLint location, GLuint64EXT x, GLuint64EXT y, GLuint64EXT z);

GLAPI void APIENTRY glProgramUniform4ui64NV (GLuint program, GLint location, GLuint64EXT x, GLuint64EXT y, GLuint64EXT z, GLuint64EXT w);

GLAPI void APIENTRY glProgramUniform1ui64vNV (GLuint program, GLint location, GLsizei count, const GLuint64EXT *value);

GLAPI void APIENTRY glProgramUniform2ui64vNV (GLuint program, GLint location, GLsizei count, const GLuint64EXT *value);

GLAPI void APIENTRY glProgramUniform3ui64vNV (GLuint program, GLint location, GLsizei count, const GLuint64EXT *value);

GLAPI void APIENTRY glProgramUniform4ui64vNV (GLuint program, GLint location, GLsizei count, const GLuint64EXT *value);

GLAPI void APIENTRY glGetInternalformatSampleivNV (GLenum target, GLenum internalformat, GLsizei samples, GLenum pname, GLsizei count, GLint *params);

GLAPI void APIENTRY glGetMemoryObjectDetachedResourcesuivNV (GLuint memory, GLenum pname, GLint first, GLsizei count, GLuint *params);

GLAPI void APIENTRY glResetMemoryObjectParameterNV (GLuint memory, GLenum pname);

GLAPI void APIENTRY glTexAttachMemoryNV (GLenum target, GLuint memory, GLuint64 offset);

GLAPI void APIENTRY glBufferAttachMemoryNV (GLenum target, GLuint memory, GLuint64 offset);

GLAPI void APIENTRY glTextureAttachMemoryNV (GLuint texture, GLuint memory, GLuint64 offset);

GLAPI void APIENTRY glNamedBufferAttachMemoryNV (GLuint buffer, GLuint memory, GLuint64 offset);

GLAPI void APIENTRY glDrawMeshTasksNV (GLuint first, GLuint count);

GLAPI void APIENTRY glDrawMeshTasksIndirectNV (GLintptr indirect);

GLAPI void APIENTRY glMultiDrawMeshTasksIndirectNV (GLintptr indirect, GLsizei drawcount, GLsizei stride);

GLAPI void APIENTRY glMultiDrawMeshTasksIndirectCountNV (GLintptr indirect, GLintptr drawcount, GLsizei maxdrawcount, GLsizei stride);

GLAPI GLuint APIENTRY glGenPathsNV (GLsizei range);

GLAPI void APIENTRY glDeletePathsNV (GLuint path, GLsizei range);

GLAPI GLboolean APIENTRY glIsPathNV (GLuint path);

GLAPI void APIENTRY glPathCommandsNV (GLuint path, GLsizei numCommands, const GLubyte *commands, GLsizei numCoords, GLenum coordType, const void *coords);

GLAPI void APIENTRY glPathCoordsNV (GLuint path, GLsizei numCoords, GLenum coordType, const void *coords);

GLAPI void APIENTRY glPathSubCommandsNV (GLuint path, GLsizei commandStart, GLsizei commandsToDelete, GLsizei numCommands, const GLubyte *commands, GLsizei numCoords, GLenum coordType, const void *coords);

GLAPI void APIENTRY glPathSubCoordsNV (GLuint path, GLsizei coordStart, GLsizei numCoords, GLenum coordType, const void *coords);

GLAPI void APIENTRY glPathStringNV (GLuint path, GLenum format, GLsizei length, const void *pathString);

GLAPI void APIENTRY glPathGlyphsNV (GLuint firstPathName, GLenum fontTarget, const void *fontName, GLbitfield fontStyle, GLsizei numGlyphs, GLenum type, const void *charcodes, GLenum handleMissingGlyphs, GLuint pathParameterTemplate, GLfloat emScale);

GLAPI void APIENTRY glPathGlyphRangeNV (GLuint firstPathName, GLenum fontTarget, const void *fontName, GLbitfield fontStyle, GLuint firstGlyph, GLsizei numGlyphs, GLenum handleMissingGlyphs, GLuint pathParameterTemplate, GLfloat emScale);

GLAPI void APIENTRY glWeightPathsNV (GLuint resultPath, GLsizei numPaths, const GLuint *paths, const GLfloat *weights);

GLAPI void APIENTRY glCopyPathNV (GLuint resultPath, GLuint srcPath);

GLAPI void APIENTRY glInterpolatePathsNV (GLuint resultPath, GLuint pathA, GLuint pathB, GLfloat weight);

GLAPI void APIENTRY glTransformPathNV (GLuint resultPath, GLuint srcPath, GLenum transformType, const GLfloat *transformValues);

GLAPI void APIENTRY glPathParameterivNV (GLuint path, GLenum pname, const GLint *value);

GLAPI void APIENTRY glPathParameteriNV (GLuint path, GLenum pname, GLint value);

GLAPI void APIENTRY glPathParameterfvNV (GLuint path, GLenum pname, const GLfloat *value);

GLAPI void APIENTRY glPathParameterfNV (GLuint path, GLenum pname, GLfloat value);

GLAPI void APIENTRY glPathDashArrayNV (GLuint path, GLsizei dashCount, const GLfloat *dashArray);

GLAPI void APIENTRY glPathStencilFuncNV (GLenum func, GLint ref, GLuint mask);

GLAPI void APIENTRY glPathStencilDepthOffsetNV (GLfloat factor, GLfloat units);

GLAPI void APIENTRY glStencilFillPathNV (GLuint path, GLenum fillMode, GLuint mask);

GLAPI void APIENTRY glStencilStrokePathNV (GLuint path, GLint reference, GLuint mask);

GLAPI void APIENTRY glStencilFillPathInstancedNV (GLsizei numPaths, GLenum pathNameType, const void *paths, GLuint pathBase, GLenum fillMode, GLuint mask, GLenum transformType, const GLfloat *transformValues);

GLAPI void APIENTRY glStencilStrokePathInstancedNV (GLsizei numPaths, GLenum pathNameType, const void *paths, GLuint pathBase, GLint reference, GLuint mask, GLenum transformType, const GLfloat *transformValues);

GLAPI void APIENTRY glPathCoverDepthFuncNV (GLenum func);

GLAPI void APIENTRY glCoverFillPathNV (GLuint path, GLenum coverMode);

GLAPI void APIENTRY glCoverStrokePathNV (GLuint path, GLenum coverMode);

GLAPI void APIENTRY glCoverFillPathInstancedNV (GLsizei numPaths, GLenum pathNameType, const void *paths, GLuint pathBase, GLenum coverMode, GLenum transformType, const GLfloat *transformValues);

GLAPI void APIENTRY glCoverStrokePathInstancedNV (GLsizei numPaths, GLenum pathNameType, const void *paths, GLuint pathBase, GLenum coverMode, GLenum transformType, const GLfloat *transformValues);

GLAPI void APIENTRY glGetPathParameterivNV (GLuint path, GLenum pname, GLint *value);

GLAPI void APIENTRY glGetPathParameterfvNV (GLuint path, GLenum pname, GLfloat *value);

GLAPI void APIENTRY glGetPathCommandsNV (GLuint path, GLubyte *commands);

GLAPI void APIENTRY glGetPathCoordsNV (GLuint path, GLfloat *coords);

GLAPI void APIENTRY glGetPathDashArrayNV (GLuint path, GLfloat *dashArray);

GLAPI void APIENTRY glGetPathMetricsNV (GLbitfield metricQueryMask, GLsizei numPaths, GLenum pathNameType, const void *paths, GLuint pathBase, GLsizei stride, GLfloat *metrics);

GLAPI void APIENTRY glGetPathMetricRangeNV (GLbitfield metricQueryMask, GLuint firstPathName, GLsizei numPaths, GLsizei stride, GLfloat *metrics);

GLAPI void APIENTRY glGetPathSpacingNV (GLenum pathListMode, GLsizei numPaths, GLenum pathNameType, const void *paths, GLuint pathBase, GLfloat advanceScale, GLfloat kerningScale, GLenum transformType, GLfloat *returnedSpacing);

GLAPI GLboolean APIENTRY glIsPointInFillPathNV (GLuint path, GLuint mask, GLfloat x, GLfloat y);

GLAPI GLboolean APIENTRY glIsPointInStrokePathNV (GLuint path, GLfloat x, GLfloat y);

GLAPI GLfloat APIENTRY glGetPathLengthNV (GLuint path, GLsizei startSegment, GLsizei numSegments);

GLAPI GLboolean APIENTRY glPointAlongPathNV (GLuint path, GLsizei startSegment, GLsizei numSegments, GLfloat distance, GLfloat *x, GLfloat *y, GLfloat *tangentX, GLfloat *tangentY);

GLAPI void APIENTRY glMatrixLoad3x2fNV (GLenum matrixMode, const GLfloat *m);

GLAPI void APIENTRY glMatrixLoad3x3fNV (GLenum matrixMode, const GLfloat *m);

GLAPI void APIENTRY glMatrixLoadTranspose3x3fNV (GLenum matrixMode, const GLfloat *m);

GLAPI void APIENTRY glMatrixMult3x2fNV (GLenum matrixMode, const GLfloat *m);

GLAPI void APIENTRY glMatrixMult3x3fNV (GLenum matrixMode, const GLfloat *m);

GLAPI void APIENTRY glMatrixMultTranspose3x3fNV (GLenum matrixMode, const GLfloat *m);

GLAPI void APIENTRY glStencilThenCoverFillPathNV (GLuint path, GLenum fillMode, GLuint mask, GLenum coverMode);

GLAPI void APIENTRY glStencilThenCoverStrokePathNV (GLuint path, GLint reference, GLuint mask, GLenum coverMode);

GLAPI void APIENTRY glStencilThenCoverFillPathInstancedNV (GLsizei numPaths, GLenum pathNameType, const void *paths, GLuint pathBase, GLenum fillMode, GLuint mask, GLenum coverMode, GLenum transformType, const GLfloat *transformValues);

GLAPI void APIENTRY glStencilThenCoverStrokePathInstancedNV (GLsizei numPaths, GLenum pathNameType, const void *paths, GLuint pathBase, GLint reference, GLuint mask, GLenum coverMode, GLenum transformType, const GLfloat *transformValues);

GLAPI GLenum APIENTRY glPathGlyphIndexRangeNV (GLenum fontTarget, const void *fontName, GLbitfield fontStyle, GLuint pathParameterTemplate, GLfloat emScale, GLuint baseAndCount[2]);

GLAPI GLenum APIENTRY glPathGlyphIndexArrayNV (GLuint firstPathName, GLenum fontTarget, const void *fontName, GLbitfield fontStyle, GLuint firstGlyphIndex, GLsizei numGlyphs, GLuint pathParameterTemplate, GLfloat emScale);

GLAPI GLenum APIENTRY glPathMemoryGlyphIndexArrayNV (GLuint firstPathName, GLenum fontTarget, GLsizeiptr fontSize, const void *fontData, GLsizei faceIndex, GLuint firstGlyphIndex, GLsizei numGlyphs, GLuint pathParameterTemplate, GLfloat emScale);

GLAPI void APIENTRY glProgramPathFragmentInputGenNV (GLuint program, GLint location, GLenum genMode, GLint components, const GLfloat *coeffs);

GLAPI void APIENTRY glGetProgramResourcefvNV (GLuint program, GLenum programInterface, GLuint index, GLsizei propCount, const GLenum *props, GLsizei count, GLsizei *length, GLfloat *params);

GLAPI void APIENTRY glFramebufferSampleLocationsfvNV (GLenum target, GLuint start, GLsizei count, const GLfloat *v);

GLAPI void APIENTRY glNamedFramebufferSampleLocationsfvNV (GLuint framebuffer, GLuint start, GLsizei count, const GLfloat *v);

GLAPI void APIENTRY glResolveDepthValuesNV (void);

GLAPI void APIENTRY glScissorExclusiveNV (GLint x, GLint y, GLsizei width, GLsizei height);

GLAPI void APIENTRY glScissorExclusiveArrayvNV (GLuint first, GLsizei count, const GLint *v);

GLAPI void APIENTRY glMakeBufferResidentNV (GLenum target, GLenum access);

GLAPI void APIENTRY glMakeBufferNonResidentNV (GLenum target);

GLAPI GLboolean APIENTRY glIsBufferResidentNV (GLenum target);

GLAPI void APIENTRY glMakeNamedBufferResidentNV (GLuint buffer, GLenum access);

GLAPI void APIENTRY glMakeNamedBufferNonResidentNV (GLuint buffer);

GLAPI GLboolean APIENTRY glIsNamedBufferResidentNV (GLuint buffer);

GLAPI void APIENTRY glGetBufferParameterui64vNV (GLenum target, GLenum pname, GLuint64EXT *params);

GLAPI void APIENTRY glGetNamedBufferParameterui64vNV (GLuint buffer, GLenum pname, GLuint64EXT *params);

GLAPI void APIENTRY glGetIntegerui64vNV (GLenum value, GLuint64EXT *result);

GLAPI void APIENTRY glUniformui64NV (GLint location, GLuint64EXT value);

GLAPI void APIENTRY glUniformui64vNV (GLint location, GLsizei count, const GLuint64EXT *value);

GLAPI void APIENTRY glGetUniformui64vNV (GLuint program, GLint location, GLuint64EXT *params);

GLAPI void APIENTRY glProgramUniformui64NV (GLuint program, GLint location, GLuint64EXT value);

GLAPI void APIENTRY glProgramUniformui64vNV (GLuint program, GLint location, GLsizei count, const GLuint64EXT *value);

GLAPI void APIENTRY glBindShadingRateImageNV (GLuint texture);

GLAPI void APIENTRY glGetShadingRateImagePaletteNV (GLuint viewport, GLuint entry, GLenum *rate);

GLAPI void APIENTRY glGetShadingRateSampleLocationivNV (GLenum rate, GLuint samples, GLuint index, GLint *location);

GLAPI void APIENTRY glShadingRateImageBarrierNV (GLboolean synchronize);

GLAPI void APIENTRY glShadingRateImagePaletteNV (GLuint viewport, GLuint first, GLsizei count, const GLenum *rates);

GLAPI void APIENTRY glShadingRateSampleOrderNV (GLenum order);

GLAPI void APIENTRY glShadingRateSampleOrderCustomNV (GLenum rate, GLuint samples, const GLint *locations);

GLAPI void APIENTRY glTextureBarrierNV (void);

GLAPI void APIENTRY glVertexAttribL1i64NV (GLuint index, GLint64EXT x);

GLAPI void APIENTRY glVertexAttribL2i64NV (GLuint index, GLint64EXT x, GLint64EXT y);

GLAPI void APIENTRY glVertexAttribL3i64NV (GLuint index, GLint64EXT x, GLint64EXT y, GLint64EXT z);

GLAPI void APIENTRY glVertexAttribL4i64NV (GLuint index, GLint64EXT x, GLint64EXT y, GLint64EXT z, GLint64EXT w);

GLAPI void APIENTRY glVertexAttribL1i64vNV (GLuint index, const GLint64EXT *v);

GLAPI void APIENTRY glVertexAttribL2i64vNV (GLuint index, const GLint64EXT *v);

GLAPI void APIENTRY glVertexAttribL3i64vNV (GLuint index, const GLint64EXT *v);

GLAPI void APIENTRY glVertexAttribL4i64vNV (GLuint index, const GLint64EXT *v);

GLAPI void APIENTRY glVertexAttribL1ui64NV (GLuint index, GLuint64EXT x);

GLAPI void APIENTRY glVertexAttribL2ui64NV (GLuint index, GLuint64EXT x, GLuint64EXT y);

GLAPI void APIENTRY glVertexAttribL3ui64NV (GLuint index, GLuint64EXT x, GLuint64EXT y, GLuint64EXT z);

GLAPI void APIENTRY glVertexAttribL4ui64NV (GLuint index, GLuint64EXT x, GLuint64EXT y, GLuint64EXT z, GLuint64EXT w);

GLAPI void APIENTRY glVertexAttribL1ui64vNV (GLuint index, const GLuint64EXT *v);

GLAPI void APIENTRY glVertexAttribL2ui64vNV (GLuint index, const GLuint64EXT *v);

GLAPI void APIENTRY glVertexAttribL3ui64vNV (GLuint index, const GLuint64EXT *v);

GLAPI void APIENTRY glVertexAttribL4ui64vNV (GLuint index, const GLuint64EXT *v);

GLAPI void APIENTRY glGetVertexAttribLi64vNV (GLuint index, GLenum pname, GLint64EXT *params);

GLAPI void APIENTRY glGetVertexAttribLui64vNV (GLuint index, GLenum pname, GLuint64EXT *params);

GLAPI void APIENTRY glVertexAttribLFormatNV (GLuint index, GLint size, GLenum type, GLsizei stride);

GLAPI void APIENTRY glBufferAddressRangeNV (GLenum pname, GLuint index, GLuint64EXT address, GLsizeiptr length);

GLAPI void APIENTRY glVertexFormatNV (GLint size, GLenum type, GLsizei stride);

GLAPI void APIENTRY glNormalFormatNV (GLenum type, GLsizei stride);

GLAPI void APIENTRY glColorFormatNV (GLint size, GLenum type, GLsizei stride);

GLAPI void APIENTRY glIndexFormatNV (GLenum type, GLsizei stride);

GLAPI void APIENTRY glTexCoordFormatNV (GLint size, GLenum type, GLsizei stride);

GLAPI void APIENTRY glEdgeFlagFormatNV (GLsizei stride);

GLAPI void APIENTRY glSecondaryColorFormatNV (GLint size, GLenum type, GLsizei stride);

GLAPI void APIENTRY glFogCoordFormatNV (GLenum type, GLsizei stride);

GLAPI void APIENTRY glVertexAttribFormatNV (GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride);

GLAPI void APIENTRY glVertexAttribIFormatNV (GLuint index, GLint size, GLenum type, GLsizei stride);

GLAPI void APIENTRY glGetIntegerui64i_vNV (GLenum value, GLuint index, GLuint64EXT *result);

GLAPI void APIENTRY glViewportSwizzleNV (GLuint index, GLenum swizzlex, GLenum swizzley, GLenum swizzlez, GLenum swizzlew);

GLAPI void APIENTRY glFramebufferTextureMultiviewOVR (GLenum target, GLenum attachment, GLuint texture, GLint level, GLint baseViewIndex, GLsizei numViews);
