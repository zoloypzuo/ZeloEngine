// SceneImporter.cpp.cc
// created on 2021/12/27
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"

#include <algorithm>
#include <execution>
#include <fstream>
#include <filesystem>

#include <assimp/cimport.h>
#include <assimp/material.h>
#include <assimp/pbrmaterial.h>
#include <assimp/postprocess.h>
#include <assimp/scene.h>

#include <rapidjson/rapidjson.h>
#include <rapidjson/istreamwrapper.h>
#include <rapidjson/ostreamwrapper.h>
#include <rapidjson/document.h>
#include <rapidjson/prettywriter.h>

#include "Renderer/OpenGL/Drawable/MeshScene/VtxData/MeshData.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Material/Material.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Scene/SceneGraph.h"

#include "Core/Resource/ResourceManager.h"
#include "Engine.h"

#include "SceneMergeUtil.h"  // mergeXXX

#include "Foundation/ZeloStb.h"

#include <meshoptimizer.h>

#include <spdlog/sinks/basic_file_sink.h>

#include <crossguid/guid.hpp>

namespace fs = std::filesystem;

using namespace Zelo::Renderer::OpenGL;
using namespace Zelo::Core::Resource;

const uint32_t k_numElementsToStore = 3 + 3 + 2; // pos(vec3) + normal(vec3) + uv(vec2)

struct SceneConfig {
    std::string inputScene;
    std::string outputMesh;
    std::string outputScene;
    std::string outputMaterials;
    float scale;
    bool calculateLODs;
};

struct MergeConfig {
    std::string outputMesh;
    std::string outputScene;
    std::string outputMaterials;
    std::vector<std::string> materialNames;
};

struct SceneConverterConfig {
    std::string name;
    std::string outputPrefix;
    std::string cacheFileName;
    MergeConfig mergeConfig;
    std::vector<SceneConfig> scenes;
};

const SceneConverterConfig *g_config;

auto OUTPUT_PREFIX = [](const std::string &path) {
    return (ResourceManager::getSingletonPtr()->resolvePath(g_config->outputPrefix) / path).string();
};

SceneConverterConfig readConfigFile(const char *cfgFileName) {
    std::ifstream ifs(cfgFileName);
    ZELO_ASSERT(ifs.is_open(), "Failed to load configuration file.");

    rapidjson::IStreamWrapper isw(ifs);
    rapidjson::Document root;
    const rapidjson::ParseResult parseResult = root.ParseStream(isw);
    ZELO_ASSERT(!parseResult.IsError());

    SceneConverterConfig config;
    g_config = &config;

    config.name = root["name"].GetString();
    config.outputPrefix = root["output_prefix"].GetString();
    config.cacheFileName = OUTPUT_PREFIX(config.name + ".fileidcache.json");

    auto mergeDoc = root["merge_config"].GetObject();
    auto &mergeConfig = config.mergeConfig;
    mergeConfig.outputMesh = OUTPUT_PREFIX(mergeDoc["output_mesh"].GetString());
    mergeConfig.outputScene = OUTPUT_PREFIX(mergeDoc["output_scene"].GetString());
    mergeConfig.outputMaterials = OUTPUT_PREFIX(mergeDoc["output_materials"].GetString());
    auto materialNamesDoc = mergeDoc["material_names"].GetArray();
    for (rapidjson::SizeType i = 0; i < materialNamesDoc.Size(); i++) {
        mergeConfig.materialNames.emplace_back(materialNamesDoc[i].GetString());
    }

    auto scenesDoc = root["scenes"].GetArray();
    std::vector<SceneConfig> &configList = config.scenes;

    for (rapidjson::SizeType i = 0; i < scenesDoc.Size(); i++) {
        configList.emplace_back(SceneConfig{
                scenesDoc[i]["input_scene"].GetString(),
                OUTPUT_PREFIX(scenesDoc[i]["output_mesh"].GetString()),
                OUTPUT_PREFIX(scenesDoc[i]["output_scene"].GetString()),
                OUTPUT_PREFIX(scenesDoc[i]["output_materials"].GetString()),
                (float) scenesDoc[i]["scale"].GetDouble(),
                scenesDoc[i]["calculate_LODs"].GetBool()
        });
    }

    return config;
}

using FileIDMap = std::map<std::string, std::string>;

FileIDMap g_fileIDCache;

FileIDMap readFileIDCache(std::string_view fileName) {
    if (!fs::exists(fileName)) {
        return {};
    }
    std::ifstream ifs(fileName);
    ZELO_ASSERT(ifs.is_open(), "Failed to load cache file.");

    rapidjson::IStreamWrapper isw(ifs);
    rapidjson::Document root;
    const rapidjson::ParseResult parseResult = root.ParseStream(isw);
    ZELO_ASSERT(!parseResult.IsError());

    auto obj = root.GetObject();
    FileIDMap fileIdMap;
    for (const auto &kv: obj) {
        fileIdMap[kv.name.GetString()] = kv.value.GetString();
    }
    return fileIdMap;
}

void writeFileIDCache(const FileIDMap &fileIdMap, std::string_view fileName) {
    std::ofstream ofs(fileName);
    rapidjson::OStreamWrapper osw(ofs);
    rapidjson::PrettyWriter<rapidjson::OStreamWrapper> writer(osw);

    writer.StartObject();
    for (const auto &kv: fileIdMap) {
        writer.Key(kv.first.c_str());
        writer.String(kv.second.c_str());
    }
    writer.EndObject();
    writer.Flush();
}

class FileIDCacheJanitor {
public:
    FileIDCacheJanitor() {
        g_fileIDCache = readFileIDCache(g_config->cacheFileName);
    }

    ~FileIDCacheJanitor() {
        writeFileIDCache(g_fileIDCache, g_config->cacheFileName);
    }
};

std::string getOrCreateFileID(const std::string &fileName) {
    if (g_fileIDCache.find(fileName) != g_fileIDCache.end()) {
        return g_fileIDCache.at(fileName);
    }
    const auto &newID = xg::newGuid().str();
    g_fileIDCache[fileName] = newID;
    return newID;
}

MaterialDescription convertAIMaterialToDescription(
        const aiMaterial *M,
        std::vector<std::string> &files,
        std::vector<std::string> &opacityMaps) {
    MaterialDescription D;

    aiColor4D Color;

    if (aiGetMaterialColor(M, AI_MATKEY_COLOR_AMBIENT, &Color) == AI_SUCCESS) {
        D.emissiveColor_ = {Color.r, Color.g, Color.b, Color.a};
        if (D.emissiveColor_.w > 1.0f) D.emissiveColor_.w = 1.0f;
    }
    if (aiGetMaterialColor(M, AI_MATKEY_COLOR_DIFFUSE, &Color) == AI_SUCCESS) {
        D.albedoColor_ = {Color.r, Color.g, Color.b, Color.a};
        if (D.albedoColor_.w > 1.0f) D.albedoColor_.w = 1.0f;
    }
    if (aiGetMaterialColor(M, AI_MATKEY_COLOR_EMISSIVE, &Color) == AI_SUCCESS) {
        D.emissiveColor_.x += Color.r;
        D.emissiveColor_.y += Color.g;
        D.emissiveColor_.z += Color.b;
        D.emissiveColor_.w += Color.a;
        if (D.emissiveColor_.w > 1.0f) D.albedoColor_.w = 1.0f;
    }

    const float opaquenessThreshold = 0.05f;
    float Opacity = 1.0f;

    if (aiGetMaterialFloat(M, AI_MATKEY_OPACITY, &Opacity) == AI_SUCCESS) {
        D.transparencyFactor_ = glm::clamp(1.0f - Opacity, 0.0f, 1.0f);
        if (D.transparencyFactor_ >= 1.0f - opaquenessThreshold) D.transparencyFactor_ = 0.0f;
    }

    if (aiGetMaterialColor(M, AI_MATKEY_COLOR_TRANSPARENT, &Color) == AI_SUCCESS) {
        const float opacity = std::max(std::max(Color.r, Color.g), Color.b);
        D.transparencyFactor_ = glm::clamp(opacity, 0.0f, 1.0f);
        if (D.transparencyFactor_ >= 1.0f - opaquenessThreshold) D.transparencyFactor_ = 0.0f;
        D.alphaTest_ = 0.5f;
    }

    float tmp = 1.0f;
    if (aiGetMaterialFloat(M, AI_MATKEY_GLTF_PBRMETALLICROUGHNESS_METALLIC_FACTOR, &tmp) == AI_SUCCESS)
        D.metallicFactor_ = tmp;

    if (aiGetMaterialFloat(M, AI_MATKEY_GLTF_PBRMETALLICROUGHNESS_ROUGHNESS_FACTOR, &tmp) == AI_SUCCESS)
        D.roughness_ = {tmp, tmp, tmp, tmp};

    aiString Path;
    aiTextureMapping Mapping{};
    unsigned int UVIndex = 0;
    float Blend = 1.0f;
    aiTextureOp TextureOp = aiTextureOp_Add;
    aiTextureMapMode TextureMapMode[2] = {aiTextureMapMode_Wrap, aiTextureMapMode_Wrap};
    unsigned int TextureFlags = 0;

    if (aiGetMaterialTexture(M, aiTextureType_EMISSIVE, 0, &Path, &Mapping, &UVIndex, &Blend, &TextureOp,
                             TextureMapMode, &TextureFlags) == AI_SUCCESS) {
        D.emissiveMap_ = addUnique(files, Path.C_Str());
    }

    if (aiGetMaterialTexture(M, aiTextureType_DIFFUSE, 0, &Path, &Mapping, &UVIndex, &Blend, &TextureOp, TextureMapMode,
                             &TextureFlags) == AI_SUCCESS) {
        D.albedoMap_ = addUnique(files, Path.C_Str());
        const std::string albedoMap = std::string(Path.C_Str());
        if (absl::StrContains(albedoMap, "grey_30"))
            D.flags_ |= sMaterialFlags_Transparent;
    }

    // first try tangent space normal map
    if (aiGetMaterialTexture(M, aiTextureType_NORMALS, 0, &Path, &Mapping, &UVIndex, &Blend, &TextureOp, TextureMapMode,
                             &TextureFlags) == AI_SUCCESS) {
        D.normalMap_ = addUnique(files, Path.C_Str());
    }
    // then height map
    if (D.normalMap_ == INVALID_TEXTURE)
        if (aiGetMaterialTexture(M, aiTextureType_HEIGHT, 0, &Path, &Mapping, &UVIndex, &Blend, &TextureOp,
                                 TextureMapMode, &TextureFlags) == AI_SUCCESS)
            D.normalMap_ = addUnique(files, Path.C_Str());

    if (aiGetMaterialTexture(M, aiTextureType_OPACITY, 0, &Path, &Mapping, &UVIndex, &Blend, &TextureOp, TextureMapMode,
                             &TextureFlags) == AI_SUCCESS) {
        D.opacityMap_ = addUnique(opacityMaps, Path.C_Str());
        D.alphaTest_ = 0.5f;
    }

    // patch materials
    aiString Name;
    std::string materialName;
    if (aiGetMaterialString(M, AI_MATKEY_NAME, &Name) == AI_SUCCESS) {
        materialName = Name.C_Str();
    }
    // apply heuristics
    if ((absl::StrContains(materialName, "Glass")) ||
        (absl::StrContains(materialName, "Vespa_Headlight"))) {
        D.alphaTest_ = 0.75f;
        D.transparencyFactor_ = 0.1f;
        D.flags_ |= sMaterialFlags_Transparent;
    } else if (absl::StrContains(materialName, "Bottle")) {
        D.alphaTest_ = 0.54f;
        D.transparencyFactor_ = 0.4f;
        D.flags_ |= sMaterialFlags_Transparent;
    } else if (absl::StrContains(materialName, "Metal")) {
        D.metallicFactor_ = 1.0f;
        D.roughness_ = gpuvec4(0.1f, 0.1f, 0.0f, 0.0f);
    }

    return D;
}

void processLods(
        std::vector<uint32_t> &indices,
        std::vector<float> &vertices,
        std::vector<std::vector<uint32_t>> &outLods) {
    size_t verticesCountIn = vertices.size() / 2;
    size_t targetIndicesCount = indices.size();

    uint8_t LOD = 1;

    spdlog::debug("   LOD0: {} indices", int(indices.size()));

    outLods.push_back(indices);

    while (targetIndicesCount > 1024 && LOD < 8) {
        targetIndicesCount = indices.size() / 2;

        size_t numOptIndices = meshopt_simplify(
                indices.data(),
                indices.data(), (uint32_t) indices.size(),
                vertices.data(), verticesCountIn,
                sizeof(float) * 3,
                targetIndicesCount, 0.02f);

        // cannot simplify further
        if (static_cast<size_t>(1.1f * numOptIndices) > indices.size()) {
            if (LOD > 1) {
                // try harder
                numOptIndices = meshopt_simplifySloppy(
                        indices.data(),
                        indices.data(), indices.size(),
                        vertices.data(), verticesCountIn,
                        sizeof(float) * 3,
                        targetIndicesCount, 0.02f, nullptr);
                if (numOptIndices == indices.size()) break;
            } else
                break;
        }

        indices.resize(numOptIndices);

        meshopt_optimizeVertexCache(indices.data(), indices.data(), indices.size(), verticesCountIn);

//		spdlog::debug("   LOD{}: {} indices {}", int(LOD), int(numOptIndices), sloppy ? "[sloppy]" : "");

        LOD++;

        outLods.push_back(indices);
    }
}

Mesh convertAIMesh(MeshData &meshData, const aiMesh *m, const SceneConfig &cfg,
                   std::reference_wrapper<uint32_t> indexOffset,
                   std::reference_wrapper<uint32_t> vertexOffset) {
    const bool hasTexCoords = m->HasTextureCoords(0);
    const auto streamElementSize = static_cast<uint32_t>(k_numElementsToStore * sizeof(float));

    Mesh result = {
            .streamCount = 1,
            .indexOffset = indexOffset,
            .vertexOffset = vertexOffset,
            .vertexCount = m->mNumVertices,
            .streamOffset = {vertexOffset * streamElementSize},
            .streamElementSize = {streamElementSize}
    };

    // Original data for LOD calculation
    std::vector<float> srcVertices;
    std::vector<uint32_t> srcIndices;

    std::vector<std::vector<uint32_t>> outLods;

    auto &vertices = meshData.vertexData_;

    for (size_t i = 0; i != m->mNumVertices; i++) {
        const aiVector3D v = m->mVertices[i];
        const aiVector3D n = m->mNormals[i];
        const aiVector3D t = hasTexCoords ? m->mTextureCoords[0][i] : aiVector3D();

        if (cfg.calculateLODs) {
            srcVertices.push_back(v.x);
            srcVertices.push_back(v.y);
            srcVertices.push_back(v.z);
        }

        vertices.push_back(v.x * cfg.scale);
        vertices.push_back(v.y * cfg.scale);
        vertices.push_back(v.z * cfg.scale);

        vertices.push_back(t.x);
        vertices.push_back(1.0f - t.y);

        vertices.push_back(n.x);
        vertices.push_back(n.y);
        vertices.push_back(n.z);
    }

    for (size_t i = 0; i != m->mNumFaces; i++) {
        if (m->mFaces[i].mNumIndices != 3)
            continue;
        for (unsigned j = 0; j != m->mFaces[i].mNumIndices; j++)
            srcIndices.push_back(m->mFaces[i].mIndices[j]);
    }

    if (!cfg.calculateLODs)
        outLods.push_back(srcIndices);
    else
        processLods(srcIndices, srcVertices, outLods);

//    spdlog::debug("Calculated LOD count: {}", (unsigned) outLods.size());

    uint32_t numIndices = 0;

    for (size_t l = 0; l < outLods.size(); l++) {
        for (unsigned int i : outLods[l])
            meshData.indexData_.push_back(i);

        result.lodOffset[l] = numIndices;
        numIndices += (int) outLods[l].size();
    }

    result.lodOffset[outLods.size()] = numIndices;
    result.lodCount = (uint32_t) outLods.size();

    indexOffset += numIndices;
    vertexOffset += m->mNumVertices;

    return result;
}

#define DEBUG_LOG_INDENTED(indent, fmt, ...) do{ spdlog::debug(fmt, std::string(indent, '\t'), __VA_ARGS__); } while(0)

void printMat4(const aiMatrix4x4 &m) {
    if (!m.IsIdentity()) {
        for (int i = 0; i < 4; i++)
            for (int j = 0; j < 4; j++)
                spdlog::debug("{} ;", m[i][j]);
    } else {
        spdlog::debug(" Identity");
    }
}

glm::mat4 toMat4(const aiMatrix4x4 &from) {
    glm::mat4 to;
    to[0][0] = (float) from.a1;
    to[0][1] = (float) from.b1;
    to[0][2] = (float) from.c1;
    to[0][3] = (float) from.d1;
    to[1][0] = (float) from.a2;
    to[1][1] = (float) from.b2;
    to[1][2] = (float) from.c2;
    to[1][3] = (float) from.d2;
    to[2][0] = (float) from.a3;
    to[2][1] = (float) from.b3;
    to[2][2] = (float) from.c3;
    to[2][3] = (float) from.d3;
    to[3][0] = (float) from.a4;
    to[3][1] = (float) from.b4;
    to[3][2] = (float) from.c4;
    to[3][3] = (float) from.d4;
    return to;
}

void traverse(const aiScene *sourceScene, SceneGraph &scene, aiNode *N, int parent, int ofs) {
    int newNode = addNode(scene, parent, ofs);

    if (N->mName.C_Str()) {
        DEBUG_LOG_INDENTED(ofs, "{}Node[{}].name = {}", newNode, N->mName.C_Str());

        auto stringID = (uint32_t) scene.names_.size();
        scene.names_.emplace_back(N->mName.C_Str());
        scene.nameForNode_[newNode] = stringID;
    }

    for (size_t i = 0; i < N->mNumMeshes; i++) {
        int newSubNode = addNode(scene, newNode, ofs + 1);

        auto stringID = (uint32_t) scene.names_.size();
        scene.names_.push_back(std::string(N->mName.C_Str()) + "_Mesh_" + std::to_string(i));
        scene.nameForNode_[newSubNode] = stringID;

        int mesh = (int) N->mMeshes[i];
        scene.meshes_[newSubNode] = mesh;
        scene.materialForNode_[newSubNode] = sourceScene->mMeshes[mesh]->mMaterialIndex;

        DEBUG_LOG_INDENTED(ofs, "{}Node[{}].SubNode[{}].mesh     = {}", newNode, newSubNode, (int) mesh);
        DEBUG_LOG_INDENTED(ofs, "{}Node[{}].SubNode[{}].material = {}", newNode, newSubNode,
                           sourceScene->mMeshes[mesh]->mMaterialIndex);

        scene.globalTransform_[newSubNode] = glm::mat4(1.0f);
        scene.localTransform_[newSubNode] = glm::mat4(1.0f);
    }

    scene.globalTransform_[newNode] = glm::mat4(1.0f);
    scene.localTransform_[newNode] = toMat4(N->mTransformation);

    if (N->mParent != nullptr) {
        DEBUG_LOG_INDENTED(ofs, "{}\tNode[{}].parent         = {}", newNode, N->mParent->mName.C_Str());
        DEBUG_LOG_INDENTED(ofs, "{}\tNode[{}].localTransform = ", newNode);
        printMat4(N->mTransformation);
        spdlog::debug("");
    }

    for (unsigned int n = 0; n < N->mNumChildren; n++)
        traverse(sourceScene, scene, N->mChildren[n], newNode, ofs + 1);
}

void dumpMaterial(const std::vector<std::string> &files, const MaterialDescription &d) {
    spdlog::debug("files: {}", (int) files.size());
    spdlog::debug("maps: {}/{}/{}/{}/{}", (uint32_t) d.albedoMap_, (uint32_t) d.ambientOcclusionMap_,
                  (uint32_t) d.emissiveMap_, (uint32_t) d.opacityMap_, (uint32_t) d.metallicRoughnessMap_);
    spdlog::debug(" albedo:    {}", (d.albedoMap_ < 0xFFFF) ? files[d.albedoMap_].c_str() : "");
    spdlog::debug(" occlusion: {}", (d.ambientOcclusionMap_ < 0xFFFF) ? files[d.ambientOcclusionMap_].c_str() : "");
    spdlog::debug(" emission:  {}", (d.emissiveMap_ < 0xFFFF) ? files[d.emissiveMap_].c_str() : "");
    spdlog::debug(" opacity:   {}", (d.opacityMap_ < 0xFFFF) ? files[d.opacityMap_].c_str() : "");
    spdlog::debug(" MeR:       {}", (d.metallicRoughnessMap_ < 0xFFFF) ? files[d.metallicRoughnessMap_].c_str() : "");
    spdlog::debug(" Normal:    {}", (d.normalMap_ < 0xFFFF) ? files[d.normalMap_].c_str() : "");
}

std::string replaceAll(const std::string &str, const std::string &oldSubStr, const std::string &newSubStr) {
    std::string result = str;

    for (size_t p = result.find(oldSubStr); p != std::string::npos; p = result.find(oldSubStr))
        result.replace(p, oldSubStr.length(), newSubStr);

    return result;
}

std::string convertTexture(
        const std::string &file,
        const std::string &basePath,
        std::unordered_map<std::string, uint32_t> &opacityMapIndices,
        const std::vector<std::string> &opacityMaps) {
    const int maxNewWidth = 512;
    const int maxNewHeight = 512;

    auto _fileName = getOrCreateFileID(file);
    auto newFileName = std::string("textures/") + _fileName + std::string(".png");

    // load this image
    const auto srcFile = replaceAll(basePath + file, "\\", "/");
    int texWidth, texHeight, texChannels; // NOLINT(cppcoreguidelines-init-variables)
    stbi_uc *pixels = stbi_load(
            ZELO_PATH(srcFile, "").c_str(), &texWidth, &texHeight, &texChannels, STBI_rgb_alpha);
    uint8_t *src = pixels;
    texChannels = STBI_rgb_alpha;

    std::vector<uint8_t> tmpImage(maxNewWidth * maxNewHeight * 4);

    if (!src) {
        spdlog::debug("Failed to load [{}] texture, use dummy instead", srcFile.c_str());
        texWidth = maxNewWidth;
        texHeight = maxNewHeight;
        texChannels = STBI_rgb_alpha;
        src = tmpImage.data();
    } else {
        spdlog::debug("Loaded [{}] {}x{} texture with {} channels", srcFile.c_str(), texWidth, texHeight, texChannels);
    }

    if (opacityMapIndices.contains(file)) {
        const auto opacityMapFile = replaceAll(basePath + opacityMaps[opacityMapIndices[file]], "\\", "/");
        int opacityWidth, opacityHeight; // NOLINT(cppcoreguidelines-init-variables)
        stbi_uc *opacityPixels = stbi_load(
                ZELO_PATH(opacityMapFile, "").c_str(), &opacityWidth, &opacityHeight, nullptr, 1);

        if (!opacityPixels) {
            spdlog::debug("Failed to load opacity mask [{}]", opacityMapFile.c_str());
        }

        ZELO_ASSERT(opacityPixels);
        ZELO_ASSERT(texWidth == opacityWidth);
        ZELO_ASSERT(texHeight == opacityHeight);

        // store the opacity mask in the alpha component of this image
        if (opacityPixels)
            for (int y = 0; y != opacityHeight; y++)
                for (int x = 0; x != opacityWidth; x++)
                    src[(y * opacityWidth + x) * texChannels + 3] = opacityPixels[y * opacityWidth + x];

        stbi_image_free(opacityPixels);
    }

    const uint32_t imgSize = texWidth * texHeight * texChannels;
    std::vector<uint8_t> mipData(imgSize);
    uint8_t *dst = mipData.data();

    const int newW = std::min(texWidth, maxNewWidth);
    const int newH = std::min(texHeight, maxNewHeight);

    stbir_resize_uint8(src, texWidth, texHeight, 0, dst, newW, newH, 0, texChannels);

    const auto &newFilePath = OUTPUT_PREFIX(newFileName);
    stbi_write_png(newFilePath.c_str(), newW, newH, texChannels, dst, 0);
    spdlog::debug("Write texture to => [{}]", newFilePath);

    if (pixels)
        stbi_image_free(pixels);

    return newFileName;
}

/// generate the internal filenames for each of the textures and convert the contents of each texture into a GPU-compatible format
/// \param materials
/// \param basePath
/// \param files
/// \param opacityMaps
void convertAllTextures(
        const std::vector<MaterialDescription> &materials,
        const std::string &basePath,
        std::vector<std::string> &files,
        std::vector<std::string> &opacityMaps) {
    std::unordered_map<std::string, uint32_t> opacityMapIndices(files.size());

    for (const auto &m : materials) {
        if (m.opacityMap_ != INVALID_TEXTURE && m.albedoMap_ != INVALID_TEXTURE) {
            opacityMapIndices[files[m.albedoMap_]] = (uint32_t) m.opacityMap_;
        }
    }
    auto converter = [&](const std::string &s) -> std::string {
        return convertTexture(s, basePath, opacityMapIndices, opacityMaps);
    };

    std::transform(std::execution::par, std::begin(files), std::end(files), std::begin(files), converter);
}

void processScene(const SceneConfig &cfg) {
    // We want to apply most of the optimizations and convert all the polygons into triangles.
    // Normal vectors should be generated for those meshes that do not contain
    // them. Error checking has been skipped here so that we can focus on the
    // code's flow
    const unsigned int flags = 0 |
                               aiProcess_JoinIdenticalVertices |
                               aiProcess_Triangulate |
                               aiProcess_GenSmoothNormals |
                               aiProcess_LimitBoneWeights |
                               aiProcess_SplitLargeMeshes |
                               aiProcess_ImproveCacheLocality |
                               aiProcess_RemoveRedundantMaterials |
                               aiProcess_FindDegenerates |
                               aiProcess_FindInvalidData |
                               aiProcess_GenUVCoords;

    spdlog::debug("Loading scene from '{}'...", cfg.inputScene.c_str());

    const aiScene *scene = aiImportFile(ZELO_PATH(cfg.inputScene).c_str(), flags);

    {
        MeshData meshData;

        uint32_t indexOffset = 0;
        uint32_t vertexOffset = 0;

        ZELO_ASSERT(scene && scene->HasMeshes(), cfg.inputScene.c_str());

        // 1. Mesh conversion as in Chapter 5
        meshData.meshes_.reserve(scene->mNumMeshes);
        meshData.boxes_.reserve(scene->mNumMeshes);

        spdlog::debug("Start converting meshes 0/{}...", scene->mNumMeshes);
        for (unsigned int i = 0; i != scene->mNumMeshes; i++) {
            Mesh mesh = convertAIMesh(meshData, scene->mMeshes[i], cfg,
                                      std::ref(indexOffset), std::ref(vertexOffset));
            meshData.meshes_.push_back(mesh);
        }
        spdlog::debug("End Converting meshes {}/{}...", scene->mNumMeshes, scene->mNumMeshes);

        recalculateBoundingBoxes(meshData);

        saveMeshData(cfg.outputMesh.c_str(), meshData);
    }

    SceneGraph ourScene;

    // 2. Material conversion
    {
        std::vector<MaterialDescription> materials;
        std::vector<std::string> &materialNames = ourScene.materialNames_;

        std::vector<std::string> files;
        std::vector<std::string> opacityMaps;

        // extract base model path
        auto basePath = fs::path(cfg.inputScene).remove_filename().string();

        for (unsigned int m = 0; m < scene->mNumMaterials; m++) {
            aiMaterial *mm = scene->mMaterials[m];

            spdlog::debug("Material [{}] {}", mm->GetName().C_Str(), m);
            materialNames.emplace_back(mm->GetName().C_Str());

            MaterialDescription D = convertAIMaterialToDescription(mm, files, opacityMaps);
            materials.push_back(D);
            //dumpMaterial(files, D);
        }

        // 3. Texture processing, rescaling and packing
        convertAllTextures(materials, basePath, files, opacityMaps);

        saveMaterials(cfg.outputMaterials.c_str(), materials, files);
    }

    // 4. Scene hierarchy conversion
    traverse(scene, ourScene, scene->mRootNode, -1, 0);

    saveScene(cfg.outputScene.c_str(), ourScene);
}

/** Chapter9: Merge meshes (interior/exterior) */
void mergeScene(const SceneConverterConfig &config) {
    const auto &mergeConfig = config.mergeConfig;

    SceneGraph scene1, scene2;
    std::vector<SceneGraph *> scenes = {&scene1, &scene2};

    MeshData m1, m2;
    loadMeshData(config.scenes[0].outputMesh.c_str(), m1);
    loadMeshData(config.scenes[1].outputMesh.c_str(), m2);

    std::vector<uint32_t> meshCounts = {m1.meshCount(), m2.meshCount()};

    loadScene(config.scenes[0].outputScene.c_str(), scene1);
    loadScene(config.scenes[1].outputScene.c_str(), scene2);

    SceneGraph scene;
    mergeScenes(scene, scenes, {}, meshCounts);

    MeshData meshData;
    std::vector<MeshData *> meshDatas = {&m1, &m2};

    mergeMeshData(meshData, meshDatas);

    // now the material lists:
    std::vector<MaterialDescription> materials1, materials2;
    std::vector<std::string> textureFiles1, textureFiles2;
    loadMaterials(config.scenes[0].outputMaterials.c_str(), materials1, textureFiles1);
    loadMaterials(config.scenes[1].outputMaterials.c_str(), materials2, textureFiles2);

    std::vector<MaterialDescription> allMaterials;
    std::vector<std::string> allTextures;

    mergeMaterialLists(
            {&materials1, &materials2},
            {&textureFiles1, &textureFiles2},
            allMaterials, allTextures);

    saveMaterials(mergeConfig.outputMaterials.c_str(), allMaterials, allTextures);

    spdlog::debug("[Unmerged] scene items count=[{}]", scene.hierarchy_.size());
    for (const auto &materialName: mergeConfig.materialNames) {
        mergeScene(scene, meshData, materialName);
        spdlog::debug("Merge scene by [{}], scene items count=[{}]", materialName, scene.hierarchy_.size());
    }

    recalculateBoundingBoxes(meshData);

    saveMeshData(mergeConfig.outputMesh.c_str(), meshData);
    saveScene(mergeConfig.outputScene.c_str(), scene);
}

int main() {
    // 0. bootstrap
    Zelo::Engine engine;
    engine.bootstrap();

    // logger settings
    spdlog::set_default_logger(
            spdlog::basic_logger_mt("sc", "logs/scene-importer.log", true));
    spdlog::set_level(spdlog::level::debug);
    const std::string pattern = "[%T.%e] [%n] [%^%l%$] %v";  // remove datetime in ts
    spdlog::set_pattern(pattern);

    // 1. read config
    const auto &config = readConfigFile(ZELO_PATH("bistro.json").c_str());
    // 2. read file id cache
    FileIDCacheJanitor fileIdCacheJanitor;
    // 3. process all scenes
    for (const auto &cfg: config.scenes) {
        processScene(cfg);
    }
    // 4. merge scenes
    mergeScene(config);

    return 0;
}
