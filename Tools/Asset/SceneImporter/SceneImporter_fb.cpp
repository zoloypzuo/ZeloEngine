// SceneImporter.cpp
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
#include <rapidjson/document.h>

#include "Renderer/OpenGL/Drawable/MeshScene/VtxData/MeshData.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Material/Material.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Scene/SceneGraph.h"

#include "Core/Resource/ResourceManager.h"
#include "Engine.h"

#define STB_IMAGE_IMPLEMENTATION

#include <stb_image.h>

#define STB_IMAGE_WRITE_IMPLEMENTATION

#include <stb_image_write.h>

#define STB_IMAGE_RESIZE_IMPLEMENTATION

#include "stb_image_resize.h"

#include <meshoptimizer.h>

#include "SceneData_generated.h"

#include <flatbuffers/util.h>

namespace fs = std::filesystem;
namespace fb = flatbuffers;

using namespace Zelo::Renderer::OpenGL;
using namespace Zelo::Core::Resource;

uint32_t g_indexOffset = 0;
uint32_t g_vertexOffset = 0;

const uint32_t g_numElementsToStore = 3 + 3 + 2; // pos(vec3) + normal(vec3) + uv(vec2)

struct SceneConfig {
    std::string fileName;
    std::string outputMesh;
    std::string outputScene;
    std::string outputMaterials;
    float scale;
    bool calculateLODs;
    bool mergeInstances;
};

std::vector<SceneConfig> readConfigFile(const char *cfgFileName) {
    std::ifstream ifs(cfgFileName);
    if (!ifs.is_open()) {
        printf("Failed to load configuration file.\n");
        exit(EXIT_FAILURE);
    }

    rapidjson::IStreamWrapper isw(ifs);
    rapidjson::Document document;
    const rapidjson::ParseResult parseResult = document.ParseStream(isw);
    assert(!parseResult.IsError());
    assert(document.IsArray());

    std::vector<SceneConfig> configList;


    for (rapidjson::SizeType i = 0; i < document.Size(); i++) {
        configList.emplace_back(SceneConfig{
                .fileName = document[i]["input_scene"].GetString(),
                .outputMesh = document[i]["output_mesh"].GetString(),
                .outputScene = document[i]["output_scene"].GetString(),
                .outputMaterials = document[i]["output_materials"].GetString(),
                .scale = (float) document[i]["scale"].GetDouble(),
                .calculateLODs = document[i]["calculate_LODs"].GetBool(),
                .mergeInstances = document[i]["merge_instances"].GetBool()
        });
    }

    return configList;
}

void convertAIMesh(fb::MeshDataT &g_MeshData, const aiMesh *m, const SceneConfig &cfg) {
    const bool hasTexCoords = m->HasTextureCoords(0);
    const auto streamElementSize = static_cast<uint32_t>(g_numElementsToStore * sizeof(float));

    auto mesh = std::make_unique<fb::MeshT>();
    auto &result = *mesh.get();
    result.streamCount = 1;
    result.indexOffset = g_indexOffset;
    result.vertexOffset = g_vertexOffset;
    result.vertexCount = m->mNumVertices;
    result.streamOffset.emplace_back(g_vertexOffset * streamElementSize);
    result.streamElementSize.emplace_back(streamElementSize);

    // Original data for LOD calculation
    std::vector<float> srcVertices;
    std::vector<uint32_t> srcIndices;

    std::vector<std::vector<uint32_t>> outLods;

    auto &vertices = g_MeshData.vertexData_;

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

    if (cfg.calculateLODs)
//        processLods(srcIndices, srcVertices, outLods); TODO
        ;
    else
        outLods.push_back(srcIndices);

    printf("\nCalculated LOD count: %u\n", (unsigned) outLods.size());

    uint32_t numIndices = 0;

    for (size_t l = 0; l < outLods.size(); l++) {
        for (unsigned int i : outLods[l])
            g_MeshData.indexData_.push_back(i);

        result.lodOffset.emplace_back(numIndices);
        numIndices += (int) outLods[l].size();
    }

    result.lodOffset.emplace_back(numIndices);
    result.lodCount = (uint32_t) outLods.size();

    g_indexOffset += numIndices;
    g_vertexOffset += m->mNumVertices;

    g_MeshData.meshes_.emplace_back(std::move(mesh));
}

inline uint32_t getLODIndicesCount(fb::MeshT &m, uint32_t lod) { return m.lodOffset[lod + 1] - m.lodOffset[lod]; }

void recalculateBoundingBoxes(fb::MeshDataT &m) {
    m.boxes_.clear();

    for (const auto &mesh : m.meshes_) {
        const auto numIndices = getLODIndicesCount(*mesh, 0);

        glm::vec3 vmin(std::numeric_limits<float>::max());
        glm::vec3 vmax(std::numeric_limits<float>::lowest());

        for (auto i = 0; i != numIndices; i++) {
            auto vtxOffset = m.indexData_[mesh->indexOffset + i] + mesh->vertexOffset;
            const float *vf = &m.vertexData_[vtxOffset * kMaxStreams];
            vmin = glm::min(vmin, vec3(vf[0], vf[1], vf[2]));
            vmax = glm::max(vmax, vec3(vf[0], vf[1], vf[2]));
        }

        m.boxes_.emplace_back(
                fb::Vector3(vmin.x, vmin.y, vmin.z),
                fb::Vector3(vmax.x, vmax.y, vmax.z)
        );
    }
}

void dumpMaterial(const std::vector<std::string> &files, const MaterialDescription &d) {
    printf("files: %d\n", (int) files.size());
    printf("maps: %u/%u/%u/%u/%u\n", (uint32_t) d.albedoMap_, (uint32_t) d.ambientOcclusionMap_,
           (uint32_t) d.emissiveMap_, (uint32_t) d.opacityMap_, (uint32_t) d.metallicRoughnessMap_);
    printf(" albedo:    %s\n", (d.albedoMap_ < 0xFFFF) ? files[d.albedoMap_].c_str() : "");
    printf(" occlusion: %s\n", (d.ambientOcclusionMap_ < 0xFFFF) ? files[d.ambientOcclusionMap_].c_str() : "");
    printf(" emission:  %s\n", (d.emissiveMap_ < 0xFFFF) ? files[d.emissiveMap_].c_str() : "");
    printf(" opacity:   %s\n", (d.opacityMap_ < 0xFFFF) ? files[d.opacityMap_].c_str() : "");
    printf(" MeR:       %s\n", (d.metallicRoughnessMap_ < 0xFFFF) ? files[d.metallicRoughnessMap_].c_str() : "");
    printf(" Normal:    %s\n", (d.normalMap_ < 0xFFFF) ? files[d.normalMap_].c_str() : "");
}

void convertAIMaterialToDescription(
        std::vector<fb::MaterialDescription> materials,
        const aiMaterial *M,
        std::vector<std::string> &files, std::vector<std::string> &opacityMaps) {
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
    aiTextureMapping Mapping;
    unsigned int UVIndex = 0;
    float Blend = 1.0f;
    aiTextureOp TextureOp = aiTextureOp_Add;
    aiTextureMapMode TextureMapMode[2] = {aiTextureMapMode_Wrap, aiTextureMapMode_Wrap};
    unsigned int TextureFlags = 0;

    if (aiGetMaterialTexture(M, aiTextureType_EMISSIVE, 0,
                             &Path, &Mapping, &UVIndex, &Blend, &TextureOp,
                             TextureMapMode, &TextureFlags) == AI_SUCCESS) {
        D.emissiveMap_ = addUnique(files, Path.C_Str());
    }

    if (aiGetMaterialTexture(M, aiTextureType_DIFFUSE, 0,
                             &Path, &Mapping, &UVIndex, &Blend, &TextureOp, TextureMapMode,
                             &TextureFlags) == AI_SUCCESS) {
        D.albedoMap_ = addUnique(files, Path.C_Str());
        const std::string albedoMap = std::string(Path.C_Str());
        if (albedoMap.find("grey_30") != std::string::npos)
            D.flags_ |= sMaterialFlags_Transparent;
    }

    // first try tangent space normal map
    if (aiGetMaterialTexture(M, aiTextureType_NORMALS, 0,
                             &Path, &Mapping, &UVIndex, &Blend, &TextureOp, TextureMapMode,
                             &TextureFlags) == AI_SUCCESS) {
        D.normalMap_ = addUnique(files, Path.C_Str());
    }
    // then height map
    if (D.normalMap_ == 0xFFFFFFFF)
        if (aiGetMaterialTexture(M, aiTextureType_HEIGHT, 0,
                                 &Path, &Mapping, &UVIndex, &Blend, &TextureOp,
                                 TextureMapMode, &TextureFlags) == AI_SUCCESS)
            D.normalMap_ = addUnique(files, Path.C_Str());

    if (aiGetMaterialTexture(M, aiTextureType_OPACITY, 0,
                             &Path, &Mapping, &UVIndex, &Blend, &TextureOp, TextureMapMode,
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
    if ((materialName.find("Glass") != std::string::npos) ||
        (materialName.find("Vespa_Headlight") != std::string::npos)) {
        D.alphaTest_ = 0.75f;
        D.transparencyFactor_ = 0.1f;
        D.flags_ |= sMaterialFlags_Transparent;
    } else if (materialName.find("Bottle") != std::string::npos) {
        D.alphaTest_ = 0.54f;
        D.transparencyFactor_ = 0.4f;
        D.flags_ |= sMaterialFlags_Transparent;
    } else if (materialName.find("Metal") != std::string::npos) {
        D.metallicFactor_ = 1.0f;
        D.roughness_ = gpuvec4(0.1f, 0.1f, 0.0f, 0.0f);
    }

    materials.emplace_back(
            fb::Vector4(D.emissiveColor_.x, D.emissiveColor_.y, D.emissiveColor_.z, D.emissiveColor_.w),
            fb::Vector4(D.albedoColor_.x, D.albedoColor_.y, D.albedoColor_.z, D.albedoColor_.w),
            fb::Vector4(D.roughness_.x, D.roughness_.y, D.roughness_.z, D.roughness_.w),
            D.transparencyFactor_,
            D.alphaTest_,
            D.metallicFactor_,
            D.flags_,
            D.ambientOcclusionMap_,
            D.emissiveMap_,
            D.albedoMap_,
            D.metallicRoughnessMap_,
            D.normalMap_,
            D.opacityMap_);

    dumpMaterial(files, D);
}

void makePrefix(int ofs) { for (int i = 0; i < ofs; i++) printf("\t"); }

fb::Matrix4x4 GlmToFbMat4(glm::mat4 inMat) {
    float data[16]{};
    std::memcpy(glm::value_ptr(inMat), data, sizeof(data));
    return fb::Matrix4x4(data);
}

fb::Matrix4x4 GlmToFbMat4() {
    return GlmToFbMat4(glm::mat4(1.0f));
}

fb::Matrix4x4 GlmToFbMat4(const aiMatrix4x4 &from) {
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
    return GlmToFbMat4(to);
}

glm::mat4 FbToGlmMat4(const fb::Matrix4x4 &from) {
    return glm::make_mat4(from.data()->data());
}

void printMat4(const aiMatrix4x4 &m) {
    if (!m.IsIdentity()) {
        for (int i = 0; i < 4; i++)
            for (int j = 0; j < 4; j++)
                printf("%f ;", m[i][j]);
    } else {
        printf(" Identity");
    }
}

int addNode(fb::SceneGraphT &scene, int parent, int level) {
    int node = (int) scene.hierarchy_.size();
    {
        // TODO(PERF): resize aux arrays (local/global etc.)
        scene.localTransform_.emplace_back(GlmToFbMat4());
        scene.globalTransform_.emplace_back(GlmToFbMat4());
    }
    auto hierarchy = std::make_unique<fb::HierarchyT>();
    hierarchy->parent_ = parent;
    hierarchy->firstChild_ = -1;
    scene.hierarchy_.emplace_back(std::move(hierarchy));
    if (parent > -1) {
        // find first item (sibling)
        int s = scene.hierarchy_[parent]->firstChild_;
        if (s == -1) {
            scene.hierarchy_[parent]->firstChild_ = node;
            scene.hierarchy_[node]->lastSibling_ = node;
        } else {
            int dest = scene.hierarchy_[s]->lastSibling_;
            if (dest <= -1) {
                // no cached lastSibling, iterate nextSibling indices
                for (dest = s; scene.hierarchy_[dest]->nextSibling_ != -1; dest = scene.hierarchy_[dest]->nextSibling_);
            }
            scene.hierarchy_[dest]->nextSibling_ = node;
            scene.hierarchy_[s]->lastSibling_ = node;
        }
    }
    scene.hierarchy_[node]->level_ = level;
    scene.hierarchy_[node]->nextSibling_ = -1;
    scene.hierarchy_[node]->firstChild_ = -1;
    return node;
}

void traverse(const aiScene *sourceScene, fb::SceneGraphT &scene, aiNode *N, int parent, int ofs) {
    int newNode = addNode(scene, parent, ofs);

    if (N->mName.C_Str()) {
        makePrefix(ofs);
        printf("Node[%d].name = %s\n", newNode, N->mName.C_Str());

        auto stringID = (uint32_t) scene.names_.size();
        scene.names_.emplace_back(N->mName.C_Str());
        scene.nameForNode_.emplace_back(newNode, stringID);
    }

    for (size_t i = 0; i < N->mNumMeshes; i++) {
        int newSubNode = addNode(scene, newNode, ofs + 1);

        auto stringID = (uint32_t) scene.names_.size();
        scene.names_.push_back(std::string(N->mName.C_Str()) + "_Mesh_" + std::to_string(i));
        scene.nameForNode_.emplace_back(newSubNode, stringID);

        int mesh = (int) N->mMeshes[i];
        scene.meshes_.emplace_back(newSubNode, mesh);
        scene.materialForNode_.emplace_back(newSubNode, sourceScene->mMeshes[mesh]->mMaterialIndex);

        makePrefix(ofs);
        printf("Node[%d].SubNode[%d].mesh     = %d\n", newNode, newSubNode, (int) mesh);
        makePrefix(ofs);
        printf("Node[%d].SubNode[%d].material = %d\n", newNode, newSubNode, sourceScene->mMeshes[mesh]->mMaterialIndex);

        scene.globalTransform_[newSubNode] = GlmToFbMat4();
        scene.localTransform_[newSubNode] = GlmToFbMat4();
    }

    scene.globalTransform_[newNode] = GlmToFbMat4();
    scene.localTransform_[newNode] = GlmToFbMat4(N->mTransformation);

    if (N->mParent != nullptr) {
        makePrefix(ofs);
        printf("\tNode[%d].parent         = %s\n", newNode, N->mParent->mName.C_Str());
        makePrefix(ofs);
        printf("\tNode[%d].localTransform = ", newNode);
        printMat4(N->mTransformation);
        printf("\n");
    }

    for (unsigned int n = 0; n < N->mNumChildren; n++)
        traverse(sourceScene, scene, N->mChildren[n], newNode, ofs + 1);
}

void processScene(const SceneConfig &cfg) {
    // extract base model path
    const std::size_t pathSeparator = cfg.fileName.find_last_of("/\\");
    const std::string basePath = (pathSeparator != std::string::npos) ? cfg.fileName.substr(0, pathSeparator + 1)
                                                                      : std::string();

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

    printf("Loading scene from '%s'...\n", cfg.fileName.c_str());

    const aiScene *scene = aiImportFile(cfg.fileName.c_str(), flags);

    fb::SceneDataT sceneDataT{
            .meshData = std::make_unique<fb::MeshDataT>(),
            .sceneGraph = std::make_unique<fb::SceneGraphT>(),
            .material = std::make_unique<fb::MaterialT>()
    };

    {
        fb::MeshDataT &g_MeshData = *sceneDataT.meshData;

        // clear mesh data from previous scene
        g_MeshData.meshes_.clear();
        g_MeshData.boxes_.clear();
        g_MeshData.indexData_.clear();
        g_MeshData.vertexData_.clear();

        g_indexOffset = 0;
        g_vertexOffset = 0;

        if (!scene || !scene->HasMeshes()) {
            printf("Unable to load '%s'\n", cfg.fileName.c_str());
            exit(EXIT_FAILURE);
        }

        // 1. Mesh conversion as in Chapter 5
        g_MeshData.meshes_.reserve(scene->mNumMeshes);
        g_MeshData.boxes_.reserve(scene->mNumMeshes);

        for (unsigned int i = 0; i != scene->mNumMeshes; i++) {
            printf("\nConverting meshes %u/%u...", i + 1, scene->mNumMeshes);
            convertAIMesh(g_MeshData, scene->mMeshes[i], cfg);
        }

        printf("\nConverting meshes ...");
        recalculateBoundingBoxes(g_MeshData);
    }

    auto &ourScene = *sceneDataT.sceneGraph;

    // 2. Material conversion
    {
        fb::MaterialT &materialT = *sceneDataT.material;
        auto &materials = materialT.materials;
        auto &materialNames = ourScene.materialNames_;

        auto &files = materialT.files;
        std::vector<std::string> opacityMaps;

        for (unsigned int m = 0; m < scene->mNumMaterials; m++) {
            aiMaterial *mm = scene->mMaterials[m];

            printf("Material [%s] %u\n", mm->GetName().C_Str(), m);
            materialNames.emplace_back(mm->GetName().C_Str());

            convertAIMaterialToDescription(materials, mm, files, opacityMaps);
        }

        // 3. Texture processing, rescaling and packing
//        convertAndDownscaleAllTextures(materials, basePath, files, opacityMaps); TODO
    }

    // 4. Scene hierarchy conversion
    traverse(scene, ourScene, scene->mRootNode, -1, 0);

    flatbuffers::FlatBufferBuilder fbb;
    fbb.Finish(fb::SceneData::Pack(fbb, &sceneDataT));
    flatbuffers::SaveFile((cfg.outputScene + ".fbin").c_str(),
                          reinterpret_cast<char *>(fbb.GetBufferPointer()),
                          fbb.GetSize(), true);
}

uint32_t meshCount(const fb::MeshDataT *m) { return (uint32_t) m->meshes_.size(); }

// Shift all hierarchy components in the nodes
static void shiftNodes(fb::SceneGraphT &scene, int startOffset, int nodeCount, int shiftAmount) {
    auto shiftNode = [shiftAmount](fb::HierarchyT &node) {
        if (node.parent_ > -1)
            node.parent_ += shiftAmount;
        if (node.firstChild_ > -1)
            node.firstChild_ += shiftAmount;
        if (node.nextSibling_ > -1)
            node.nextSibling_ += shiftAmount;
        if (node.lastSibling_ > -1)
            node.lastSibling_ += shiftAmount;
        // node->level_ does not have to be shifted
    };

    // If there are too many nodes, we can use std::execution::par with std::transform
//	std::transform(scene.hierarchy_.begin() + startOffset, scene.hierarchy_.begin() + nodeCount, scene.hierarchy_.begin() + startOffset, shiftNode);

//	for (auto i = scene.hierarchy_.begin() + startOffset ; i != scene.hierarchy_.begin() + nodeCount ; i++)
//		shiftNode(*i);

    for (int i = 0; i < nodeCount; i++)
        shiftNode(*scene.hierarchy_[i + startOffset]);
}


template<typename T>
void mergeVectors(std::vector<std::unique_ptr<T>> &v1, std::vector<std::unique_ptr<T>> &v2) {
    std::move(v2.begin(), v2.end(), std::back_inserter(v1));
}

using ItemMap = std::vector<flatbuffers::SceneComponentItem>;

// Add the items from otherMap shifting indices and values along the way
static void mergeMaps(ItemMap &m, const ItemMap &otherMap, int indexOffset, int itemOffset) {
    for (const auto &i: otherMap)
        m.emplace_back(i.key() + indexOffset, i.value() + itemOffset);
}

void mergeScenes(fb::SceneGraphT &outScene,
                 std::vector<fb::SceneGraphT *> &scenes,
                 const std::vector<glm::mat4> &rootTransforms,
                 const std::vector<uint32_t> &meshCounts,
                 bool mergeMeshes = true, bool mergeMaterials = true) {
    // Create new root node
    auto hierarchy = std::make_unique<fb::HierarchyT>();
    hierarchy->parent_ = -1;
    hierarchy->firstChild_ = 1;
    hierarchy->nextSibling_ = -1;
    hierarchy->lastSibling_ = -1;
    hierarchy->level_ = 0;
    outScene.hierarchy_.emplace_back(std::move(hierarchy));

    outScene.nameForNode_.emplace_back(0, 0);
    outScene.names_ = {"NewRoot"};

    outScene.localTransform_.emplace_back(GlmToFbMat4());
    outScene.globalTransform_.emplace_back(GlmToFbMat4());

    if (scenes.empty()) return;

    int offs = 1;
    int meshOffs = 0;
    int nameOffs = (int) outScene.names_.size();
    int materialOfs = 0;
    auto meshCount = meshCounts.begin();

    if (!mergeMaterials) {
//        outScene.materialNames_ = scenes[0]->materialNames_; TODO
    }

    // FIXME: too much logic (for all the components in a scene, though mesh data and materials go separately - there are dedicated data lists)
    for (auto *s: scenes) {
        mergeVectors(outScene.localTransform_, s->localTransform_);
        mergeVectors(outScene.globalTransform_, s->globalTransform_);

        mergeVectors(outScene.hierarchy_, s->hierarchy_);

        mergeVectors(outScene.names_, s->names_);
        if (mergeMaterials) {
            mergeVectors(outScene.materialNames_, s->materialNames_);
        }

        int nodeCount = (int) s->hierarchy_.size();

        shiftNodes(outScene, offs, nodeCount, offs);

        mergeMaps(outScene.meshes_, s->meshes_, offs, mergeMeshes ? meshOffs : 0);
        mergeMaps(outScene.materialForNode_, s->materialForNode_, offs, mergeMaterials ? materialOfs : 0);
        mergeMaps(outScene.nameForNode_, s->nameForNode_, offs, nameOffs);

        offs += nodeCount;

        materialOfs += (int) s->materialNames_.size();
        nameOffs += (int) s->names_.size();

        if (mergeMeshes) {
            meshOffs += *meshCount;
            meshCount++;
        }
    }

    // fixing 'nextSibling' fields in the old roots (zero-index in all the scenes)
    offs = 1;
    int idx = 0;
    for (const auto *s: scenes) {
        int nodeCount = (int) s->hierarchy_.size();
        bool isLast = (idx == scenes.size() - 1);
        // calculate new next sibling for the old scene roots
        int next = isLast ? -1 : offs + nodeCount;
        outScene.hierarchy_[offs]->nextSibling_ = next;
        // attach to new root
        outScene.hierarchy_[offs]->parent_ = 0;

        // transform old root nodes, if the transforms are given
        if (!rootTransforms.empty())
            outScene.localTransform_[offs] = GlmToFbMat4(
                    rootTransforms[idx] *
                    FbToGlmMat4(outScene.localTransform_[offs]));

        offs += nodeCount;
        idx++;
    }

    // now shift levels of all nodes below the root
    for (auto iter = outScene.hierarchy_.begin() + 1; iter != outScene.hierarchy_.end(); iter++) {
        auto &hierarchyT = *iter;
        hierarchyT->level_++;
    }
}

// Combine a list of meshes to a single mesh container
void mergeMeshData(fb::MeshDataT &m, std::vector<fb::MeshDataT *> md) {
    uint32_t totalVertexDataSize = 0;
    uint32_t totalIndexDataSize = 0;

    uint32_t offs = 0;
    for (auto *i: md) {
        mergeVectors(m.indexData_, i->indexData_);
        mergeVectors(m.vertexData_, i->vertexData_);
        mergeVectors(m.meshes_, i->meshes_);
        mergeVectors(m.boxes_, i->boxes_);

        uint32_t vtxOffset =
                totalVertexDataSize / 8;  /* 8 is the number of per-vertex attributes: position, normal + UV */

        for (size_t j = 0; j < (uint32_t) i->meshes_.size(); j++)
            // m.vertexCount, m.lodCount and m.streamCount do not change
            // m.vertexOffset also does not change, because vertex offsets are local (i.e., baked into the indices)
            m.meshes_[offs + j]->indexOffset += totalIndexDataSize;

        // shift individual indices
        for (size_t j = 0; j < i->indexData_.size(); j++)
            m.indexData_[totalIndexDataSize + j] += vtxOffset;

        offs += (uint32_t) i->meshes_.size();

        totalIndexDataSize += (uint32_t) i->indexData_.size();
        totalVertexDataSize += (uint32_t) i->vertexData_.size();
    }
}

void mergeMaterialLists(
        std::vector<std::vector<fb::MaterialDescription> *> &oldMaterials,
        std::vector<std::vector<std::string> *> &oldTextures,
        std::vector<fb::MaterialDescription> &allMaterials,
        std::vector<std::string> &newTextures
) {
    // map texture names to indices in newTexturesList (calculated as we fill the newTexturesList)
    std::unordered_map<std::string, int> newTextureNames;
    std::unordered_map<int, int> materialToTextureList; // direct MaterialDescription usage as a key is impossible, so we use its index in the allMaterials array

    // Create combined material list [no hashing of materials, just straightforward merging of all lists]
    int midx = 0;
    for (auto *ml: oldMaterials) {
        for (auto &m: *ml) {
            allMaterials.push_back(m);
            materialToTextureList[allMaterials.size() - 1] = midx;
        }

        midx++;
    }

    // Create one combined texture list
    for (auto *tl: oldTextures)
        for (const std::string &file: *tl) {
            newTextureNames[file] = addUnique(newTextures, file); // addUnique() is in SceneConverter/MaterialConv.inl
        }

    // Lambda to replace textureID by a new "version" (from global list)
    auto replaceTexture = [&materialToTextureList, &oldTextures, &newTextureNames](
            int m, uint64_t textureID) -> auto {
        if (textureID < INVALID_TEXTURE) {
            auto listIdx = materialToTextureList[m];
            auto *texList = oldTextures[listIdx];
            const std::string &texFile = (*texList)[textureID];
            return (uint64_t) (newTextureNames[texFile]);
        }
        return textureID;
    };

    for (size_t i = 0; i < allMaterials.size(); i++) {
        auto &m = allMaterials[i];
        m.mutate_ambientOcclusionMap_(replaceTexture(i, m.ambientOcclusionMap_()));
        m.mutate_emissiveMap_(replaceTexture(i, m.emissiveMap_()));
        m.mutate_albedoMap_(replaceTexture(i, m.albedoMap_()));
        m.mutate_metallicRoughnessMap_(replaceTexture(i, m.metallicRoughnessMap_()));
        m.mutate_normalMap_(replaceTexture(i, m.normalMap_()));
    }
}

static uint32_t shiftMeshIndices(fb::MeshDataT &meshData, const std::vector<uint32_t> &meshesToMerge) {
    auto minVtxOffset = std::numeric_limits<uint32_t>::max();
    for (auto i: meshesToMerge)
        minVtxOffset = std::min(meshData.meshes_[i]->vertexOffset, minVtxOffset);

    auto mergeCount = 0u; // calculated by summing index counts in meshesToMerge

    // now shift all the indices in individual index blocks [use minVtxOffset]
    for (auto i: meshesToMerge) {
        auto &m = meshData.meshes_[i];
        // for how much should we shift the indices in mesh [m]
        const uint32_t delta = m->vertexOffset - minVtxOffset;

        const auto idxCount = getLODIndicesCount(*m, 0);
        for (auto ii = 0u; ii < idxCount; ii++)
            meshData.indexData_[m->indexOffset + ii] += delta;

        m->vertexOffset = minVtxOffset;

        // sum all the deleted meshes' indices
        mergeCount += idxCount;
    }

    return meshData.indexData_.size() - mergeCount;
}

// All the meshesToMerge now have the same vertexOffset and individual index values are shifted by appropriate amount
// Here we move all the indices to appropriate places in the new index array
void mergeIndexArray(fb::MeshDataT &md,
                     const std::vector<uint32_t> &meshesToMerge,
                     std::map<uint32_t, uint32_t> &oldToNew) {
    std::vector<uint32_t> newIndices(md.indexData_.size());
    // Two offsets in the new indices array (one begins at the start, the second one after all the copied indices)
    uint32_t copyOffset = 0,
            mergeOffset = shiftMeshIndices(md, meshesToMerge);

    const auto mergedMeshIndex = md.meshes_.size() - meshesToMerge.size();
    auto newIndex = 0u;
    for (auto midx = 0u; midx < md.meshes_.size(); midx++) {
        const bool shouldMerge = std::binary_search(meshesToMerge.begin(), meshesToMerge.end(), midx);

        oldToNew[midx] = shouldMerge ? mergedMeshIndex : newIndex;
        newIndex += shouldMerge ? 0 : 1;

        auto &mesh = md.meshes_[midx];
        auto idxCount = getLODIndicesCount(*mesh, 0);
        // move all indices to the new array at mergeOffset
        const auto start = md.indexData_.begin() + mesh->indexOffset;
        mesh->indexOffset = copyOffset;
        auto *const offsetPtr = shouldMerge ? &mergeOffset : &copyOffset;
        std::copy(start, start + idxCount, newIndices.begin() + *offsetPtr);
        *offsetPtr += idxCount;
    }

    md.indexData_ = newIndices;

    // all the merged indices are now in lastMesh
    auto pLastMesh = std::make_unique<fb::MeshT>(*md.meshes_[meshesToMerge[0]]);  // copy
    auto &lastMesh = *pLastMesh;
    lastMesh.indexOffset = copyOffset;
    lastMesh.lodOffset[0] = copyOffset;
    lastMesh.lodOffset[1] = mergeOffset;
    lastMesh.lodCount = 1;
    md.meshes_.emplace_back(std::move(pLastMesh));
}

std::unordered_map<uint32_t, uint32_t> toStdMap(std::vector<flatbuffers::SceneComponentItem> &component) {
    std::unordered_map<uint32_t, uint32_t> to;
    for (const auto &item: component) {
        to[item.key()] = item.value();
    }
    return to;
}

// Add an index to a sorted index array
static void addUniqueIdx(std::vector<uint32_t> &v, uint32_t index) {
    if (!std::binary_search(v.begin(), v.end(), index))
        v.push_back(index);
}

std::vector<SceneNode> getNodeChildren(const fb::SceneGraphT &scene, SceneNode node) {
    std::vector<SceneNode> children;
    for (SceneNode s = scene.hierarchy_[node]->firstChild_; s != -1; s = scene.hierarchy_[s]->nextSibling_) {
        children.emplace_back(s);
    }
    return children;
}

// Recurse down from a node and collect all nodes which are already marked for deletion
static void collectNodesToDelete(const fb::SceneGraphT &scene, int node, std::vector<uint32_t> &nodes) {
    for (auto n : getNodeChildren(scene, node)) {
        addUniqueIdx(nodes, n);
        collectNodesToDelete(scene, n, nodes);
    }
}

int findLastNonDeletedItem(const fb::SceneGraphT &scene, const std::vector<int> &newIndices, int node) {
    // we have to be more subtle:
    //   if the (newIndices[firstChild_] == -1), we should follow the link and extract the last non-removed item
    //   ..
    if (node == -1)
        return -1;

    return (newIndices[node] == -1) ?
           findLastNonDeletedItem(scene, newIndices, scene.hierarchy_[node]->nextSibling_) :
           newIndices[node];
}

void shiftMapIndices(std::vector<flatbuffers::SceneComponentItem> &items, const std::vector<int> &newIndices) {
    std::vector<flatbuffers::SceneComponentItem> newItems;
    for (const auto &m: items) {
        int newIndex = newIndices[m.key()];
        if (newIndex != -1)
            newItems.emplace_back(newIndex, m.value());
    }
    items = newItems;
}

// Approximately an O ( N * Log(N) * Log(M)) algorithm (N = scene.size, M = nodesToDelete.size) to delete a collection of nodes from scene graph
void deleteSceneNodes(fb::SceneGraphT &scene, const std::vector<uint32_t> &nodesToDelete) {
    // 0) Add all the nodes down below in the hierarchy
    auto indicesToDelete = nodesToDelete;
    for (auto i: indicesToDelete)
        collectNodesToDelete(scene, i, indicesToDelete);

    // aux array with node indices to keep track of the moved ones [moved = [](node) { return (node != nodes[node]); ]
    std::vector<int> nodes(scene.hierarchy_.size());
    std::iota(nodes.begin(), nodes.end(), 0);

    // 1.a) Move all the indicesToDelete to the end of 'nodes' array (and cut them off, a variation of swap'n'pop for multiple elements)
    auto oldSize = nodes.size();
    eraseSelected(nodes, indicesToDelete);

    // 1.b) Make a newIndices[oldIndex] mapping table
    std::vector<int> newIndices(oldSize, -1);
    for (int i = 0; i < nodes.size(); i++)
        newIndices[nodes[i]] = i;

    // 2) Replace all non-null parent/firstChild/nextSibling pointers in all the nodes by new positions
    for (auto &hierarchyT: scene.hierarchy_) {
        auto &h = hierarchyT;
        hierarchyT->parent_ = (h->parent_ != -1) ? newIndices[h->parent_] : -1;
        hierarchyT->firstChild_ = findLastNonDeletedItem(scene, newIndices, h->firstChild_);
        hierarchyT->nextSibling_ = findLastNonDeletedItem(scene, newIndices, h->nextSibling_);
        hierarchyT->lastSibling_ = findLastNonDeletedItem(scene, newIndices, h->lastSibling_);
    }

    // 3) Finally throw away the hierarchy items
    eraseSelected(scene.hierarchy_, indicesToDelete);

    // 4) As in mergeScenes() routine we also have to adjust all the "components" (i.e., meshes, materials, names and transformations)

    // 4a) Transformations are stored in arrays, so we just erase the items as we did with the scene.hierarchy_
    eraseSelected(scene.localTransform_, indicesToDelete);
    eraseSelected(scene.globalTransform_, indicesToDelete);

    // 4b) All the maps should change the key values with the newIndices[] array
    shiftMapIndices(scene.meshes_, newIndices);
    shiftMapIndices(scene.materialForNode_, newIndices);
    shiftMapIndices(scene.nameForNode_, newIndices);

    // 5) scene node names list is not modified, but in principle it can be (remove all non-used items and adjust the nameForNode_ map)
    // 6) Material names list is not modified also, but if some materials fell out of use
}


void mergeScene(fb::SceneGraphT &scene, fb::MeshDataT &meshData, const std::string &materialName) {
    // Find material index
    int oldMaterial = (int) std::distance(
            std::begin(scene.materialNames_),
            std::find(std::begin(scene.materialNames_), std::end(scene.materialNames_), materialName));

    std::vector<uint32_t> toDelete;

    auto meshes = toStdMap(scene.meshes_);
    auto materialForNode = toStdMap(scene.materialForNode_);

    for (auto i = 0u; i < scene.hierarchy_.size(); i++)
        if (meshes.contains(i) && materialForNode.contains(i) &&
            (materialForNode.at(i) == oldMaterial))
            toDelete.emplace_back(i);

    std::vector<uint32_t> meshesToMerge(toDelete.size());

    // Convert toDelete indices to mesh indices
    std::transform(toDelete.begin(), toDelete.end(), meshesToMerge.begin(),
                   [&scene, &meshes](uint32_t i) { return meshes.at(i); });

    // TODO: if merged mesh transforms are non-zero, then we should pre-transform individual mesh vertices in meshData using local transform

    // old-to-new mesh indices
    std::map<uint32_t, uint32_t> oldToNew;

    // now move all the meshesToMerge to the end of array
    mergeIndexArray(meshData, meshesToMerge, oldToNew);

    // cutoff all but one of the merged meshes (insert the last saved mesh from meshesToMerge -  they are all the same)
    eraseSelected(meshData.meshes_, meshesToMerge);

    for (auto &n: scene.meshes_)
        n.mutate_value(oldToNew[n.value()]);

    // reattach the node with merged meshes [identity transforms are assumed]
    int newNode = addNode(scene, 0, 1);
    scene.meshes_.emplace_back(newNode, (uint32_t) meshData.meshes_.size() - 1);
    scene.materialForNode_.emplace_back(newNode, (uint32_t) oldMaterial);

    deleteSceneNodes(scene, toDelete);
}

/** Chapter9: Merge meshes (interior/exterior) */
void mergeBistro() {
    fb::SceneDataT sceneDataT{
            .meshData = std::make_unique<fb::MeshDataT>(),
            .sceneGraph = std::make_unique<fb::SceneGraphT>(),
            .material = std::make_unique<fb::MaterialT>()
    };

    std::string data;
    fb::SceneDataT sceneDataT1, sceneDataT2;
    fb::LoadFile("data/meshes/test.scene.fbin", true, &data);
    fb::GetSceneData(data.c_str())->UnPackTo(&sceneDataT1);

    fb::LoadFile("data/meshes/test2.scene.fbin", true, &data);
    fb::GetSceneData(data.c_str())->UnPackTo(&sceneDataT2);

    auto *scene1 = sceneDataT1.sceneGraph.get();
    auto *scene2 = sceneDataT2.sceneGraph.get();
    std::vector<fb::SceneGraphT *> scenes{scene1, scene2};

    auto *m1 = sceneDataT1.meshData.get();
    auto *m2 = sceneDataT2.meshData.get();

    std::vector<uint32_t> meshCounts{meshCount(m1), meshCount(m2)};

    fb::SceneGraphT &scene = *sceneDataT.sceneGraph;
    mergeScenes(scene, scenes, {}, meshCounts);

    fb::MeshDataT &meshData = *sceneDataT.meshData;
    std::vector<fb::MeshDataT *> meshDatas{m1, m2};

    mergeMeshData(meshData, meshDatas);

    // now the material lists:
    auto &materials1 = sceneDataT1.material->materials;
    auto &materials2 = sceneDataT2.material->materials;
    auto &textureFiles1 = sceneDataT1.material->files;
    auto &textureFiles2 = sceneDataT2.material->files;

    std::vector<fb::MaterialDescription> &allMaterials = sceneDataT.material->materials;
    std::vector<std::string> &allTextures = sceneDataT.material->files;

    std::vector<std::vector<fb::MaterialDescription> *> oldMaterials{&materials1, &materials2};
    std::vector<std::vector<std::string> *> oldTextures{&textureFiles1, &textureFiles2};
    mergeMaterialLists(
            oldMaterials, oldTextures,
            allMaterials, allTextures);

    printf("[Unmerged] scene items: %d\n", (int) scene.hierarchy_.size());
    mergeScene(scene, meshData, "Foliage_Linde_Tree_Large_Orange_Leaves");
    printf("[Merged orange leaves] scene items: %d\n", (int) scene.hierarchy_.size());
    mergeScene(scene, meshData, "Foliage_Linde_Tree_Large_Green_Leaves");
    printf("[Merged green leaves]  scene items: %d\n", (int) scene.hierarchy_.size());
    mergeScene(scene, meshData, "Foliage_Linde_Tree_Large_Trunk");
    printf("[Merged trunk]  scene items: %d\n", (int) scene.hierarchy_.size());

    recalculateBoundingBoxes(meshData);

    flatbuffers::FlatBufferBuilder fbb;
    fbb.Finish(fb::SceneData::Pack(fbb, &sceneDataT));
    flatbuffers::SaveFile("data/meshes/bistro_all.scene.fbin",
                          reinterpret_cast<char *>(fbb.GetBufferPointer()),
                          fbb.GetSize(), true);
}

int main() {
    fs::create_directory("data/meshes");
    fs::create_directory("data/out_textures");

    const auto configs = readConfigFile("data/sceneconverter.json");

    for (const auto &cfg: configs)
        processScene(cfg);

    mergeBistro();

    return 0;
}
