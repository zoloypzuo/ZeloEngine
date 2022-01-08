// SceneImporter.cpp
// created on 2022/1/7
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "SceneData_generated.h"

#include <flatbuffers//util.h>

#include "Renderer/OpenGL/Drawable/MeshScene/Material/Material.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Scene/SceneGraph.h"
#include "Renderer/OpenGL/Drawable/MeshScene/VtxData/MeshData.h"

namespace fb = flatbuffers;

using namespace Zelo::Renderer::OpenGL;

namespace Zelo::Renderer::OpenGL {
template<typename T, typename U, typename Fn>
std::vector<U> Map(const std::vector<T> &inVec, Fn functor) {
    std::vector<U> ret;
    ret.resize(inVec.size());
    std::transform(inVec.begin(), inVec.end(), ret.begin(), functor);
    return ret;
}

template<typename T, typename U, typename Fn>
void Map(const fb::Vector<T> &inVec, std::vector<U> &outVec, Fn functor) {
    outVec.resize(inVec.size());
    std::transform(inVec.begin(), inVec.end(), outVec.begin(), functor);
}

template<typename TKey, typename TValue, typename U, typename Fn>
std::vector<U> Map(const std::unordered_map<TKey, TValue> &inMap, Fn functor) {
    std::vector<U> ret;
    ret.resize(inMap.size());
    std::map<TKey, TValue> sortedMap(inMap.begin(), inMap.end());
    std::transform(sortedMap.begin(), sortedMap.end(), ret.begin(), functor);
    return ret;
}

template<typename TKey, typename TValue, typename U, typename Fn>
void Map(const fb::Vector<U> &inVec, std::unordered_map<TKey, TValue> &outMap, Fn functor) {
    std::transform(inVec.begin(), inVec.end(), std::inserter(outMap, outMap.begin()), functor);
}

fb::Matrix4x4 toFbMat4(glm::mat4 inMat) {
    float data[16]{};
    std::memcpy(data, glm::value_ptr(inMat), sizeof(data));
    return fb::Matrix4x4(data);
}

glm::mat4 fromFbMat4(const fb::Matrix4x4 *from) {
    return glm::make_mat4(from->data()->data());
}

fb::Vector3 toFbVec3(glm::vec3 inVec) {
    return fb::Vector3(inVec.x, inVec.y, inVec.z);
}

glm::vec3 fromFbVec3(fb::Vector3 inVec) {
    return glm::vec3(inVec.x(), inVec.y(), inVec.z());
}

fb::Vector4 toFbVec4(gpuvec4 inVec) {
    return fb::Vector4(inVec.x, inVec.y, inVec.z, inVec.w);
}

gpuvec4 fromFbVec4(fb::Vector4 inVec) {
    return gpuvec4(inVec.x(), inVec.y(), inVec.z(), inVec.w());
}

std::string fromFbString(const fb::String *from) {
    return from->str();
}

fb::SceneComponentItem toFbSceneComponentItem(const std::pair<uint32_t, uint32_t> &kv) {
    return {kv.first, kv.second};
}

std::pair<uint32_t, uint32_t> fromFbSceneComponentItem(const fb::SceneComponentItem *pC) {
    return std::make_pair(pC->key(), pC->value());
}

fb::MaterialDescription toFbMaterialDescription(const MaterialDescription &D) {
    return {
            toFbVec4(D.emissiveColor_),
            toFbVec4(D.albedoColor_),
            toFbVec4(D.roughness_),
            D.transparencyFactor_,
            D.alphaTest_,
            D.metallicFactor_,
            D.flags_,
            D.ambientOcclusionMap_,
            D.emissiveMap_,
            D.albedoMap_,
            D.metallicRoughnessMap_,
            D.normalMap_,
            D.opacityMap_
    };
}

MaterialDescription fromFbMaterialDescription(const fb::MaterialDescription *pD) {
    const auto &D = *pD;
    return {
            fromFbVec4(D.emissiveColor_()),
            fromFbVec4(D.albedoColor_()),
            fromFbVec4(D.roughness_()),
            D.transparencyFactor_(),
            D.alphaTest_(),
            D.metallicFactor_(),
            D.flags_(),
            D.ambientOcclusionMap_(),
            D.emissiveMap_(),
            D.albedoMap_(),
            D.metallicRoughnessMap_(),
            D.normalMap_(),
            D.opacityMap_()
    };
}

void loadScene(const char *fileName, SceneGraph &scene) {
    std::string buf;
    fb::LoadFile(fileName, true, &buf);
    const auto &sceneGraph = *fb::GetRoot<fb::SceneGraph>(buf.c_str());

    auto fromFbHierarchy = [](const fb::Hierarchy *pH) -> Hierarchy {
        const auto &h = *pH;
        return Hierarchy{
                h.parent_(),
                h.firstChild_(),
                h.nextSibling_(),
                h.lastSibling_(),
                h.level_()
        };
    };

    Map(*sceneGraph.localTransform_(), scene.localTransform_, fromFbMat4);
    Map(*sceneGraph.globalTransform_(), scene.globalTransform_, fromFbMat4);
    Map(*sceneGraph.hierarchy_(), scene.hierarchy_, fromFbHierarchy);
    Map(*sceneGraph.meshes_(), scene.meshes_, fromFbSceneComponentItem);
    Map(*sceneGraph.materialForNode_(), scene.materialForNode_, fromFbSceneComponentItem);
    Map(*sceneGraph.nameForNode_(), scene.nameForNode_, fromFbSceneComponentItem);
    Map(*sceneGraph.names_(), scene.names_, fromFbString);
    Map(*sceneGraph.materialNames_(), scene.materialNames_, fromFbString);
}

void saveScene(const char *fileName, const SceneGraph &scene) {
    fb::FlatBufferBuilder builder;
    fb::SceneGraphBuilder sceneGraphBuilder(builder);

    auto toFbHierarchy = [&builder](const Hierarchy &h) -> fb::Offset<fb::Hierarchy> {
        return fb::CreateHierarchy(
                builder,
                h.parent_,
                h.firstChild_,
                h.nextSibling_,
                h.lastSibling_,
                h.level_
        );
    };

    auto toFbString = [&builder](const std::string &s) -> fb::Offset<fb::String> { return builder.CreateString(s); };

    auto fbLocalTransforms = Map<glm::mat4, fb::Matrix4x4>(scene.localTransform_, toFbMat4);
    auto fbGlobalTransforms = Map<glm::mat4, fb::Matrix4x4>(scene.globalTransform_, toFbMat4);
    auto fbHierarchy = Map<Hierarchy, fb::Offset<fb::Hierarchy>>(scene.hierarchy_, toFbHierarchy);
    auto fbMeshes = Map<uint32_t, uint32_t, fb::SceneComponentItem>(scene.meshes_, toFbSceneComponentItem);
    auto fbMatForNode = Map<uint32_t, uint32_t, fb::SceneComponentItem>(scene.materialForNode_, toFbSceneComponentItem);
    auto fbNameForNode = Map<uint32_t, uint32_t, fb::SceneComponentItem>(scene.nameForNode_, toFbSceneComponentItem);
    auto fbNames = Map<std::string, fb::Offset<fb::String>>(scene.names_, toFbString);
    auto fbMaterialNames = Map<std::string, fb::Offset<fb::String>>(scene.materialNames_, toFbString);
    auto sceneGraph = fb::CreateSceneGraphDirect(
            builder,
            &fbLocalTransforms,
            &fbGlobalTransforms,
            &fbHierarchy,
            &fbMeshes,
            &fbMatForNode,
            &fbNameForNode,
            &fbNames,
            &fbMaterialNames
    );
    builder.Finish(sceneGraph);

    ZELO_ASSERT(fb::SaveFile(fileName, (const char *) builder.GetBufferPointer(), builder.GetSize(), true));
}

void loadMaterials(const char *fileName, std::vector<MaterialDescription> &materials, std::vector<std::string> &files) {
    std::string buf;
    fb::LoadFile(fileName, true, &buf);
    const auto *material = fb::GetRoot<fb::Material>(buf.c_str());

    Map(*material->materials(), materials, fromFbMaterialDescription);
    Map(*material->files(), files, fromFbString);
}

void saveMaterials(const char *fileName, const std::vector<MaterialDescription> &materials,
                   const std::vector<std::string> &files) {
    fb::FlatBufferBuilder builder;

    auto toFbString = [&builder](const std::string &s) -> fb::Offset<fb::String> { return builder.CreateString(s); };

    auto fbMaterials = Map<MaterialDescription, fb::MaterialDescription>(materials, toFbMaterialDescription);
    auto fbFiles = Map<std::string, fb::Offset<fb::String>>(files, toFbString);
    auto material = fb::CreateMaterialDirect(
            builder,
            &fbMaterials,
            &fbFiles
    );
    builder.Finish(material);

    ZELO_ASSERT(fb::SaveFile(fileName, (const char *) builder.GetBufferPointer(), builder.GetSize(), true));
}

template<class InIt, class TOut>
void Copy(const InIt &src, std::vector<TOut> &dest) {
    dest.resize(src.size());
    std::copy(std::begin(src), std::end(src), std::begin(dest));
}

template<class InIt, class TOut>
void Copy(const InIt &src, TOut *dest) {
    std::copy(std::begin(src), std::end(src), dest);
}

BoundingBox fromFbBoundingBox(const flatbuffers::BoundingBox *pbb) {
    const auto &bb = *pbb;
    return {
            fromFbVec3(bb.min_()),
            fromFbVec3(bb.max_())
    };
}

MeshFileHeader loadMeshData(const char *fileName, MeshData &out) {
    std::string buf;
    fb::LoadFile(fileName, true, &buf);
    const auto &meshData = *fb::GetRoot<fb::MeshData>(buf.c_str());

    auto fromFbMesh = [](const fb::Mesh *pMesh) -> Mesh {
        const auto &mesh = *pMesh;

        Mesh ret;
        ret.lodCount = mesh.lodCount();
        ret.streamCount = mesh.streamCount();
        ret.indexOffset = mesh.indexOffset();
        ret.vertexOffset = mesh.vertexOffset();
        ret.vertexCount = mesh.vertexCount();
        Copy(*mesh.lodOffset(), ret.lodOffset);
        Copy(*mesh.streamOffset(), ret.streamOffset);
        Copy(*mesh.streamElementSize(), ret.streamElementSize);
        return ret;
    };

    out.indexData_.resize(meshData.indexData_()->size());
    Copy(*meshData.indexData_(), out.indexData_);
    Copy(*meshData.vertexData_(), out.vertexData_);
    Map(*meshData.meshes_(), out.meshes_, fromFbMesh);
    Map(*meshData.boxes_(), out.boxes_, fromFbBoundingBox);

    auto &m = out;
    return {
            0x12345678,
            (uint32_t) m.meshes_.size(),
            (uint32_t) (sizeof(MeshFileHeader) + m.meshes_.size() * sizeof(Mesh)),
            (uint32_t) (m.indexData_.size() * sizeof(uint32_t)),
            (uint32_t) (m.vertexData_.size() * sizeof(float))
    };
}

flatbuffers::BoundingBox toFbBoundingBox(const BoundingBox &bb) {
    return {
            toFbVec3(bb.min_),
            toFbVec3(bb.max_)
    };
}

void saveMeshData(const char *fileName, const MeshData &m) {
    fb::FlatBufferBuilder builder;

    auto toFbMesh = [&builder](const Mesh &mesh) -> fb::Offset<fb::Mesh> {
        return fb::CreateMesh(
                builder,
                mesh.lodCount,
                mesh.streamCount,
                mesh.indexOffset,
                mesh.vertexOffset,
                mesh.vertexCount,
                builder.CreateVector(mesh.lodOffset, kMaxLODs),
                builder.CreateVector(mesh.streamOffset, kMaxStreams),
                builder.CreateVector(mesh.streamElementSize, kMaxStreams)
        );
    };

    auto fbMeshes = Map<Mesh, fb::Offset<fb::Mesh>>(m.meshes_, toFbMesh);
    auto fbBBs = Map<BoundingBox, fb::BoundingBox>(m.boxes_, toFbBoundingBox);
    auto meshData = fb::CreateMeshDataDirect(
            builder,
            &m.indexData_,
            &m.vertexData_,
            &fbMeshes,
            &fbBBs
    );
    builder.Finish(meshData);

    ZELO_ASSERT(fb::SaveFile(fileName, (const char *) builder.GetBufferPointer(), builder.GetSize(), true));
}
}
