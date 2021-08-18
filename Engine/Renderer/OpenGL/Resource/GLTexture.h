// GLTexture.h
// created on 2021/3/31
// author @zoloypzuo

#ifndef ZELOENGINE_GLTEXTURE_H
#define ZELOENGINE_GLTEXTURE_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "Core/RHI/Resource/Texture.h"
#include "Core/Resource/Resource.h"

class TextureData {
public:
    TextureData(const unsigned char *data, int width, int height, bool filter_nearest);

    virtual ~TextureData();

    void bind(unsigned int unit) const;

    uint32_t getHandle() const;

private:
    GLuint m_textureId{};

private:
    void createTexture(const unsigned char *data, int width, int height, bool filter_nearest);
};

class GLTexture : public Zelo::Core::RHI::Texture {
public:
    explicit GLTexture(std::string texFilename);

    explicit GLTexture(const Zelo::Resource &file);

    GLTexture(const char *buffer, uint32_t size, bool filter_nearest, const std::string &name);

    ~GLTexture();

    void bind(uint32_t slot) const override;

    uint32_t getHandle() const;

private:
    std::shared_ptr<TextureData> m_textureData;
};

class GLTexture3D : public Zelo::Core::RHI::Texture3D {
public:
    explicit GLTexture3D(const std::string &name);

    void bind(uint32_t slot) const override;

protected:
    GLuint m_handle{};
};

#endif //ZELOENGINE_GLTEXTURE_H