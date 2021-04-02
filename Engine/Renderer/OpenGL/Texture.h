// Texture.h
// created on 2021/3/31
// author @zoloypzuo

#ifndef ZELOENGINE_TEXTURE_H
#define ZELOENGINE_TEXTURE_H

#include "ZeloPrerequisites.h"

#if defined(GLES2)
#include <GLES2/gl2.h>
#elif defined(GLES3)
#include <GLES3/gl3.h>
#else

#include <GL/glew.h>

#endif

class TextureData {
public:
    TextureData(int width, int height, const unsigned char *data, GLenum textureTarget, GLfloat filter);

    virtual ~TextureData();

    void createTexture(int width, int height, const unsigned char *data, GLenum textureTarget, GLfloat filter);

    void bind(unsigned int unit) const;

private:
    GLenum m_textureTarget;
    GLuint m_textureId;
};

#if defined(GLES2)
#include <GLES2/gl2.h>
#elif defined(GLES3)
#include <GLES3/gl3.h>
#else

#include <GL/glew.h>

#endif

#include "Asset.h"

class Texture {
public:
    Texture(const Asset &file, GLenum textureTarget = GL_TEXTURE_2D, GLfloat filter = GL_LINEAR);

    ~Texture();

    void bind(unsigned int unit = 0) const;

private:
    std::shared_ptr<TextureData> m_textureData;
};

#endif //ZELOENGINE_TEXTURE_H