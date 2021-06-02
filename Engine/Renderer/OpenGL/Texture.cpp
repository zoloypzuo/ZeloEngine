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

void TextureData::createTexture(
        int width, int height,
        const unsigned char *data,
        GLenum textureTarget,
        GLfloat filter) {
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

Texture::Texture(const Zelo::Resource &file, GLenum textureTarget, GLfloat filter) {
    auto it = m_textureCache.find(file.getIOStream()->getFileName());

    if (it == m_textureCache.end() || !(m_textureData = it->second.lock())) {
        int x = 0, y = 0, bytesPerPixel = 0;
        unsigned char *data = stbi_load_from_memory(
                reinterpret_cast<const unsigned char *>(file.read()),
                static_cast<int>(file.getIOStream()->fileSize()),
                &x, &y, &bytesPerPixel,
                4);

        if (data == nullptr) {
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

unsigned char *loadPixels(const Zelo::Resource &file, int &w, int &h) {
    int bytesPerPixel = 0;
    unsigned char *data = stbi_load_from_memory(
            reinterpret_cast<const unsigned char *>(file.read()),
            static_cast<int>(file.getIOStream()->fileSize()),
            &w, &h, &bytesPerPixel,
            4);
    if (data == nullptr) {
        spdlog::error("Unable to load texture: {}", file.getIOStream()->getFileName().c_str());
        return nullptr;
    } else {
        spdlog::debug("loadPixels @{} {}x{}", file.getIOStream()->getFileName(), w, h);
        return data;
    }
}

GLuint loadCubeMap(const std::string &baseName) {
    GLuint texID{};
    glGenTextures(1, &texID);
    glBindTexture(GL_TEXTURE_CUBE_MAP, texID);

    const char *suffixes[] = {"posx", "negx", "posy", "negy", "posz", "negz"};
    GLuint targets[] = {
            GL_TEXTURE_CUBE_MAP_POSITIVE_X, GL_TEXTURE_CUBE_MAP_NEGATIVE_X,
            GL_TEXTURE_CUBE_MAP_POSITIVE_Y, GL_TEXTURE_CUBE_MAP_NEGATIVE_Y,
            GL_TEXTURE_CUBE_MAP_POSITIVE_Z, GL_TEXTURE_CUBE_MAP_NEGATIVE_Z
    };

    stbi_set_flip_vertically_on_load(true);
    GLint w = 0, h = 0;

    // Load the first one to get width/height
    std::string texName0 = baseName + "_" + suffixes[0] + ".png";
    GLubyte *data0 = loadPixels(Zelo::Resource(texName0), w, h);

    // Allocate immutable storage for the whole cube map texture
    glTexStorage2D(GL_TEXTURE_CUBE_MAP, 1, GL_RGBA8, w, h);

    glTexSubImage2D(targets[0], 0, 0, 0, w, h, GL_RGBA, GL_UNSIGNED_BYTE, data0);
    stbi_image_free(data0);

    // Load the other 5 cube-map faces
    for (int i = 1; i < 6; i++) {
        std::string texName = baseName + "_" + suffixes[i] + ".png";
        GLubyte *data = loadPixels(Zelo::Resource(texName), w, h);
        glTexSubImage2D(targets[i], 0, 0, 0, w, h, GL_RGBA, GL_UNSIGNED_BYTE, data);
        stbi_image_free(data);
    }

    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);

    return texID;
}

Texture3D::Texture3D(const std::string &name) : m_handle(loadCubeMap(name)) {
}

void Texture3D::bind(unsigned int slot) const {
    glActiveTexture(GL_TEXTURE0 + slot);
    glBindTexture(getTextureTarget(), m_handle);
}

GLenum Texture3D::getTextureTarget() const{
    return GL_TEXTURE_CUBE_MAP;
}

