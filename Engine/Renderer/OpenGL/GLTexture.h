// GLTexture.h
// created on 2021/3/31
// author @zoloypzuo

#ifndef ZELOENGINE_GLTEXTURE_H
#define ZELOENGINE_GLTEXTURE_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "Core/RHI/Texture.h"
#include "Core/Resource/Resource.h"

class TextureData {
public:
    TextureData(int width, int height, const unsigned char *data);

    virtual ~TextureData();

    void bind(unsigned int unit) const;

private:
    GLuint m_textureId{};

private:
    void createTexture(int width, int height, const unsigned char *data);
};

class GLTexture : public Texture {
public:
    explicit GLTexture(const Zelo::Resource &file);

    ~GLTexture();

    void bind(uint32_t slot) const override;

private:
    std::shared_ptr<TextureData> m_textureData;
};

class GLTexture3D : public Texture3D {
public:
    explicit GLTexture3D(const std::string &name);

    void bind(uint32_t slot) const override;

protected:
    GLuint m_handle{};
};

#endif //ZELOENGINE_GLTEXTURE_H