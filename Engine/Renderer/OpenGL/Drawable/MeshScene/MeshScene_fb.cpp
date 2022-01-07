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
std::vector<U> map(const std::vector<T> &inVec, Fn functor) {
    std::vector<U> ret;
    ret.reserve(inVec.size());
    std::transform(inVec.begin(), inVec.end(), ret.begin(), functor);
    return ret;
}

template<typename TKey, typename TValue, typename U, typename Fn>
std::vector<U> map(const std::unordered_map<TKey, TValue> &inVec, Fn functor) {
    std::vector<U> ret;
    ret.reserve(inVec.size());
    std::transform(inVec.begin(), inVec.end(), ret.begin(), functor);
    return ret;
}

fb::Matrix4x4 toFbMat4(glm::mat4 inMat) {
    float data[16]{};
    std::memcpy(glm::value_ptr(inMat), data, sizeof(data));
    return fb::Matrix4x4(data);
}

glm::mat4 fromFbMat4(const fb::Matrix4x4 &from) {
    return glm::make_mat4(from.data()->data());
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

fb::MaterialDescription ToFbMaterialDescription(const MaterialDescription &D) {
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

fb::SceneComponentItem toFbSceneComponentItem(const std::pair<uint32_t, uint32_t> &kv) {
    return {kv.first, kv.second};
}

void loadScene(const char *fileName, SceneGraph &scene) {
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

    auto fbLocalTransforms = map<glm::mat4, fb::Matrix4x4>(scene.localTransform_, toFbMat4);
    auto fbGlobalTransforms = map<glm::mat4, fb::Matrix4x4>(scene.globalTransform_, toFbMat4);
    auto fbHierarchy = map<Hierarchy, fb::Offset<fb::Hierarchy>>(scene.hierarchy_, toFbHierarchy);
    auto fbMeshes = map<uint32_t, uint32_t, fb::SceneComponentItem>(scene.meshes_, toFbSceneComponentItem);
    auto fbMatForNode = map<uint32_t, uint32_t, fb::SceneComponentItem>(scene.materialForNode_, toFbSceneComponentItem);
    auto fbNameForNode = map<uint32_t, uint32_t, fb::SceneComponentItem>(scene.nameForNode_, toFbSceneComponentItem);
    auto fbNames = map<std::string, fb::Offset<fb::String>>(scene.names_, toFbString);
    auto fbMaterialNames = map<std::string, fb::Offset<fb::String>>(scene.materialNames_, toFbString);
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
    auto *material = fb::GetRoot<fb::Material>(&buf);
}

void saveMaterials(const char *fileName, const std::vector<MaterialDescription> &materials,
                   const std::vector<std::string> &files) {
    fb::FlatBufferBuilder builder;

    auto toFbString = [&builder](const std::string &s) -> fb::Offset<fb::String> { return builder.CreateString(s); };

    auto fbMaterials = map<MaterialDescription, fb::MaterialDescription>(materials, ToFbMaterialDescription);
    auto fbFiles = map<std::string, fb::Offset<fb::String>>(files, toFbString);
    auto material = fb::CreateMaterialDirect(
            builder,
            &fbMaterials,
            &fbFiles
    );
    builder.Finish(material);

    ZELO_ASSERT(fb::SaveFile(fileName, (const char *) builder.GetBufferPointer(), builder.GetSize(), true));
}


MeshFileHeader loadMeshData(const char *meshFile, MeshData &out) {
    return {};
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

    auto fbMeshes = map<Mesh, fb::Offset<fb::Mesh>>(m.meshes_, toFbMesh);
    auto fbBBs = map<BoundingBox, fb::BoundingBox>(m.boxes_, toFbBoundingBox);
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
