#pragma once

#include <cstdint>
#include "vec4.h"

#include <string>
#include <vector>

namespace Zelo::Renderer::OpenGL {
enum MaterialFlags {
    sMaterialFlags_CastShadow = 0x1,
    sMaterialFlags_ReceiveShadow = 0x2,
    sMaterialFlags_Transparent = 0x4,
};

constexpr const uint64_t INVALID_TEXTURE = 0xFFFFFFFF;

/// Our material system is compatible with the glTF2 material format and easily extensible for
/// incorporating many existing glTF2 extensions.
struct PACKED_STRUCT MaterialDescription final {
    /// emissive color
    gpuvec4 emissiveColor_ = {0.0f, 0.0f, 0.0f, 0.0f};
    /// ambient color
    gpuvec4 albedoColor_ = {1.0f, 1.0f, 1.0f, 1.0f};
    /// surface's roughness, can be used to represent anisotropic roughness.
    /// UV anisotropic roughness (isotropic lighting models use only the first value). ZW values are ignored
    gpuvec4 roughness_ = {1.0f, 1.0f, 0.0f, 0.0f};
    /// used to render with alpha-blended materials
    float transparencyFactor_ = 1.0f;
    /// alpha test threshold, which is used for the simple punch-through transparency rendering
    float alphaTest_ = 0.0f;
    /// the metallic factor for our PBR rendering
    float metallicFactor_ = 0.0f;
    uint32_t flags_ = sMaterialFlags_CastShadow | sMaterialFlags_ReceiveShadow;
#pragma region maps
    uint64_t ambientOcclusionMap_ = INVALID_TEXTURE;
    uint64_t emissiveMap_ = INVALID_TEXTURE;
    uint64_t albedoMap_ = INVALID_TEXTURE;
    /// Occlusion (R), Roughness (G), Metallic (B) https://github.com/KhronosGroup/glTF/issues/857
    uint64_t metallicRoughnessMap_ = INVALID_TEXTURE;
    uint64_t normalMap_ = INVALID_TEXTURE;
    /// only used in SceneImporter
    uint64_t opacityMap_ = INVALID_TEXTURE;
#pragma endregion maps
};

static_assert(sizeof(MaterialDescription) % 16 == 0, "MaterialDescription should be padded to 16 bytes");

void saveMaterials(const char *fileName, const std::vector<MaterialDescription> &materials,
                   const std::vector<std::string> &files);

void loadMaterials(const char *fileName, std::vector<MaterialDescription> &materials, std::vector<std::string> &files);
}