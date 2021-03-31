// Texture.cpp
// created on 2021/3/31
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Texture.h"

#define STB_IMAGE_IMPLEMENTATION

#include "stb_image.h"

TextureData::TextureData(int width, int height, const unsigned char *data, GLenum textureTarget, GLfloat filter) {
    createTexture(width, height, data, textureTarget, filter);
}

TextureData::~TextureData() {
    glDeleteTextures(1, &m_textureId);
}

void
TextureData::createTexture(int width, int height, const unsigned char *data, GLenum textureTarget, GLfloat filter) {
    m_textureTarget = textureTarget;

    glGenTextures(1, &m_textureId);
    glBindTexture(textureTarget, m_textureId);
    glTexParameterf(textureTarget, GL_TEXTURE_MIN_FILTER, filter);
    glTexParameterf(textureTarget, GL_TEXTURE_MAG_FILTER, filter);
    // TODO: RE-ENABLE THIS!!
    // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_BORDER);
    // glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_BORDER);
    glTexImage2D(textureTarget, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
}

void TextureData::bind(unsigned int unit) const {
    glActiveTexture(GL_TEXTURE0 + unit);
    glBindTexture(m_textureTarget, m_textureId);
}

std::map<std::string, std::weak_ptr<TextureData>> m_textureCache;

Texture::Texture(const Asset &file, GLenum textureTarget, GLfloat filter) {
    auto it = m_textureCache.find(file.getIOStream()->getFileName());

    if (it == m_textureCache.end() || !(m_textureData = it->second.lock())) {
        int x, y, bytesPerPixel;
        unsigned char *data = stbi_load_from_memory(reinterpret_cast<const unsigned char *>(file.read()),
                                                    file.getIOStream()->fileSize(), &x, &y, &bytesPerPixel, 4);

        if (data == NULL) {
            spdlog::error("Unable to load texture: {}", file.getIOStream()->getFileName().c_str());
        } else {
            m_textureData = std::make_shared<TextureData>(x, y, data, textureTarget, filter);
            m_textureCache[file.getIOStream()->getFileName()] = m_textureData;
            stbi_image_free(data);
        }
    }
}

Texture::~Texture() {
}

void Texture::bind(unsigned int unit) const {
    m_textureData->bind(unit);
}
