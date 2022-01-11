#include "ZeloPreCompiledHeader.h"
#include "GLTexture.h"

#include "Renderer/OpenGL/Drawable/MeshScene/Texture/Bitmap.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Util/UtilsCubemap.h"

#include <stb_image.h>
#include <gli/gli.hpp>

namespace {
int getNumMipMapLevels2D(int w, int h) {
    int levels = 1;
    while ((w | h) >> levels)
        levels += 1;
    return levels;
}

/// Draw a checkerboard on a pre-allocated square RGB image.
uint8_t *genDefaultCheckerboardImage(int *width, int *height) {
    const int w = 128;
    const int h = 128;

    auto *imgData = (uint8_t *) malloc(w * h * 3); // stbi_load() uses malloc(), so this is safe

    ZELO_ASSERT(imgData && w > 0 && h > 0);
    ZELO_ASSERT(w == h);

    if (!imgData || w <= 0 || h <= 0) return nullptr;

    for (int i = 0; i < w * h; i++) {
        const int row = i / w;
        const int col = i % w;
        imgData[i * 3 + 0] = imgData[i * 3 + 1] = imgData[i * 3 + 2] = 0xFF * ((row + col) % 2);
    }

    if (width) *width = w;
    if (height) *height = h;

    return imgData;
}

/// Filename can be KTX or DDS files
/// https://github.com/g-truc/gli/blob/master/manual.md#22-creating-an-opengl-texture-object-from-file-
GLuint createTextureKtx(char const *Filename) {
    gli::texture Texture = gli::load(Filename);
    if (Texture.empty())
        return 0;

    gli::gl GL(gli::gl::PROFILE_KTX);
    gli::gl::format const Format = GL.translate(Texture.format(), Texture.swizzles());
    GLenum Target = GL.translate(Texture.target());

    GLuint TextureName = 0;
    glGenTextures(1, &TextureName);
    glBindTexture(Target, TextureName);
    glTexParameteri(Target, GL_TEXTURE_BASE_LEVEL, 0);
    glTexParameteri(Target, GL_TEXTURE_MAX_LEVEL, static_cast<GLint>(Texture.levels() - 1));
    glTexParameteri(Target, GL_TEXTURE_SWIZZLE_R, Format.Swizzles[0]);
    glTexParameteri(Target, GL_TEXTURE_SWIZZLE_G, Format.Swizzles[1]);
    glTexParameteri(Target, GL_TEXTURE_SWIZZLE_B, Format.Swizzles[2]);
    glTexParameteri(Target, GL_TEXTURE_SWIZZLE_A, Format.Swizzles[3]);

    glm::tvec3<GLsizei> const Extent(Texture.extent());
    auto const FaceTotal = static_cast<GLsizei>(Texture.layers() * Texture.faces());

    switch (Texture.target()) {
        case gli::TARGET_1D:
            glTexStorage1D(
                    Target, static_cast<GLint>(Texture.levels()), Format.Internal, Extent.x);
            break;
        case gli::TARGET_1D_ARRAY:
        case gli::TARGET_2D:
        case gli::TARGET_CUBE:
            glTexStorage2D(
                    Target, static_cast<GLint>(Texture.levels()), Format.Internal,
                    Extent.x, Texture.target() == gli::TARGET_2D ? Extent.y : FaceTotal);
            break;
        case gli::TARGET_2D_ARRAY:
        case gli::TARGET_3D:
        case gli::TARGET_CUBE_ARRAY:
            glTexStorage3D(
                    Target, static_cast<GLint>(Texture.levels()), Format.Internal,
                    Extent.x, Extent.y,
                    Texture.target() == gli::TARGET_3D ? Extent.z : FaceTotal);
            break;
        default:
            ZELO_ASSERT(0);
            break;
    }

    for (std::size_t Layer = 0; Layer < Texture.layers(); ++Layer)
        for (std::size_t Face = 0; Face < Texture.faces(); ++Face)
            for (std::size_t Level = 0; Level < Texture.levels(); ++Level) {
                auto const LayerGL = static_cast<GLsizei>(Layer);
                glm::tvec3<GLsizei> extent(Texture.extent(Level));
                Target = gli::is_target_cube(Texture.target())
                         ? static_cast<GLenum>(GL_TEXTURE_CUBE_MAP_POSITIVE_X + Face)
                         : Target;

                switch (Texture.target()) {
                    case gli::TARGET_1D:
                        if (gli::is_compressed(Texture.format()))
                            glCompressedTexSubImage1D(
                                    Target, static_cast<GLint>(Level), 0, extent.x,
                                    Format.Internal, static_cast<GLsizei>(Texture.size(Level)),
                                    Texture.data(Layer, Face, Level));
                        else
                            glTexSubImage1D(
                                    Target, static_cast<GLint>(Level), 0, extent.x,
                                    Format.External, Format.Type,
                                    Texture.data(Layer, Face, Level));
                        break;
                    case gli::TARGET_1D_ARRAY:
                    case gli::TARGET_2D:
                    case gli::TARGET_CUBE:
                        if (gli::is_compressed(Texture.format()))
                            glCompressedTexSubImage2D(
                                    Target, static_cast<GLint>(Level),
                                    0, 0,
                                    extent.x,
                                    Texture.target() == gli::TARGET_1D_ARRAY ? LayerGL : extent.y,
                                    Format.Internal, static_cast<GLsizei>(Texture.size(Level)),
                                    Texture.data(Layer, Face, Level));
                        else
                            glTexSubImage2D(
                                    Target, static_cast<GLint>(Level),
                                    0, 0,
                                    extent.x,
                                    Texture.target() == gli::TARGET_1D_ARRAY ? LayerGL : extent.y,
                                    Format.External, Format.Type,
                                    Texture.data(Layer, Face, Level));
                        break;
                    case gli::TARGET_2D_ARRAY:
                    case gli::TARGET_3D:
                    case gli::TARGET_CUBE_ARRAY:
                        if (gli::is_compressed(Texture.format()))
                            glCompressedTexSubImage3D(
                                    Target, static_cast<GLint>(Level),
                                    0, 0, 0,
                                    extent.x, extent.y,
                                    Texture.target() == gli::TARGET_3D ? extent.z : LayerGL,
                                    Format.Internal, static_cast<GLsizei>(Texture.size(Level)),
                                    Texture.data(Layer, Face, Level));
                        else
                            glTexSubImage3D(
                                    Target, static_cast<GLint>(Level),
                                    0, 0, 0,
                                    extent.x, extent.y,
                                    Texture.target() == gli::TARGET_3D ? extent.z : LayerGL,
                                    Format.External, Format.Type,
                                    Texture.data(Layer, Face, Level));
                        break;
                    default:
                        ZELO_ASSERT(false);
                        break;
                }
            }
    return TextureName;
}

GLuint createTextureStb(GLenum type, const char *fileName) {
    GLuint handle_{};
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glCreateTextures(type, 1, &handle_);
    glTextureParameteri(handle_, GL_TEXTURE_MAX_LEVEL, 0);
    glTextureParameteri(handle_, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTextureParameteri(handle_, GL_TEXTURE_MAG_FILTER, GL_LINEAR);

    switch (type) {
        case GL_TEXTURE_2D: {
            int w = 0;
            int h = 0;
            int numMipmaps; // NOLINT(cppcoreguidelines-init-variables)
            {
                uint8_t *img = stbi_load(fileName, &w, &h, nullptr, STBI_rgb_alpha);

                // Note(Anton): replaced ZELO_ASSERT(img) with a fallback image to prevent crashes with missing files or bad (eg very long) paths.
                if (!img) {
                    fprintf(stderr, "WARNING: could not load image `%s`, using a fallback.\n", fileName);
                    img = genDefaultCheckerboardImage(&w, &h);
                    ZELO_ASSERT(img, "FATAL ERROR: out of memory allocating image for fallback texture");
                }

                numMipmaps = getNumMipMapLevels2D(w, h);
                glTextureStorage2D(handle_, numMipmaps, GL_RGBA8, w, h);
                glTextureSubImage2D(handle_, 0, 0, 0, w, h, GL_RGBA, GL_UNSIGNED_BYTE, img);
                stbi_image_free((void *) img);
            }
            glGenerateTextureMipmap(handle_);
            glTextureParameteri(handle_, GL_TEXTURE_MAX_LEVEL, numMipmaps - 1);
            glTextureParameteri(handle_, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            glTextureParameteri(handle_, GL_TEXTURE_MAX_ANISOTROPY, 16);
            break;
        }
        case GL_TEXTURE_CUBE_MAP: {
            int w, h, comp; // NOLINT(cppcoreguidelines-init-variables)
            const float *img = stbi_loadf(fileName, &w, &h, &comp, 3);
            ZELO_ASSERT(img, fileName);
            Bitmap in(w, h, comp, eBitmapFormat_Float, img);
            const bool isEquirectangular = w == 2 * h;
            Bitmap out = isEquirectangular ? convertEquirectangularMapToVerticalCross(in) : in;
            stbi_image_free((void *) img);
            Bitmap cubemap = convertVerticalCrossToCubeMapFaces(out);

            const int numMipmaps = getNumMipMapLevels2D(cubemap.w_, cubemap.h_);

            glTextureParameteri(handle_, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTextureParameteri(handle_, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            glTextureParameteri(handle_, GL_TEXTURE_WRAP_R, GL_CLAMP_TO_EDGE);
            glTextureParameteri(handle_, GL_TEXTURE_BASE_LEVEL, 0);
            glTextureParameteri(handle_, GL_TEXTURE_MAX_LEVEL, numMipmaps - 1);
            glTextureParameteri(handle_, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
            glTextureParameteri(handle_, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glEnable(GL_TEXTURE_CUBE_MAP_SEAMLESS);
            glTextureStorage2D(handle_, numMipmaps, GL_RGB32F, cubemap.w_, cubemap.h_);
            const uint8_t *data = cubemap.data_.data();

            for (GLint i = 0; i != 6; ++i) {
                glTextureSubImage3D(handle_, 0, 0, 0, i, cubemap.w_, cubemap.h_, 1, GL_RGB, GL_FLOAT, data);
                data += cubemap.w_ * cubemap.h_ * cubemap.comp_ * Bitmap::getBytesPerComponent(cubemap.fmt_);
            }

            glGenerateTextureMipmap(handle_);
            break;
        }
        default:
            ZELO_ASSERT(false);
    }
    return handle_;
}
}

GLTexture::GLTexture(GLenum type, int width, int height, GLenum internalFormat)
        : type_(type) {
    glCreateTextures(type, 1, &handle_);
    glTextureParameteri(handle_, GL_TEXTURE_MAX_LEVEL, 0);
    glTextureParameteri(handle_, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTextureParameteri(handle_, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTextureStorage2D(handle_, getNumMipMapLevels2D(width, height), internalFormat, width, height);
}

GLTexture::GLTexture(GLenum type, const char *fileName)
        : type_(type) {
    const char *ext = strrchr(fileName, '.');
    const bool isKTX = ext && !strcmp(ext, ".ktx");

    if (isKTX) {  // load by ktx
        handle_ = createTextureKtx(fileName);
    } else {     // load by stb
        handle_ = createTextureStb(type, fileName);
    }

    handleBindless_ = glGetTextureHandleARB(handle_);
    glMakeTextureHandleResidentARB(handleBindless_);
}

GLTexture::GLTexture(int w, int h, const void *img)
        : type_(GL_TEXTURE_2D) {
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glCreateTextures(type_, 1, &handle_);
    int numMipmaps = getNumMipMapLevels2D(w, h);
    glTextureStorage2D(handle_, numMipmaps, GL_RGBA8, w, h);
    glTextureSubImage2D(handle_, 0, 0, 0, w, h, GL_RGBA, GL_UNSIGNED_BYTE, img);
    glGenerateTextureMipmap(handle_);
    glTextureParameteri(handle_, GL_TEXTURE_MAX_LEVEL, numMipmaps - 1);
    glTextureParameteri(handle_, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
    glTextureParameteri(handle_, GL_TEXTURE_MAX_ANISOTROPY, 16);
    handleBindless_ = glGetTextureHandleARB(handle_);
    glMakeTextureHandleResidentARB(handleBindless_);
}

GLTexture::GLTexture(GLTexture &&other) noexcept:
        type_(other.type_), handle_(other.handle_), handleBindless_(other.handleBindless_) {
    other.type_ = 0;
    other.handle_ = 0;
    other.handleBindless_ = 0;
}

GLTexture::~GLTexture() {
    if (handleBindless_)
        glMakeTextureHandleNonResidentARB(handleBindless_);
    glDeleteTextures(1, &handle_);
}
