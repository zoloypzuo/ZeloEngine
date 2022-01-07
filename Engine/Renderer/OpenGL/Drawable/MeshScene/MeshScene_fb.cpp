// SceneImporter.cpp
// created on 2022/1/7
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "SceneData_generated.h"

#include <flatbuffers/util.h>

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

fb::Matrix4x4 GlmToFbMat4(glm::mat4 inMat) {
    float data[16]{};
    std::memcpy(glm::value_ptr(inMat), data, sizeof(data));
    return fb::Matrix4x4(data);
}

glm::mat4 FbToGlmMat4(const fb::Matrix4x4 &from) {
    return glm::make_mat4(from.data()->data());
}

fb::Vector3 GlmToFbVec3(glm::vec3 inVec) {
    return fb::Vector3(inVec.x, inVec.y, inVec.z);
}

glm::vec3 FbToGlmVec3(fb::Vector3 inVec) {
    return glm::vec3(inVec.x(), inVec.y(), inVec.z());
}

fb::Vector4 GpuToFbVec4(gpuvec4 inVec) {
    return fb::Vector4(inVec.x, inVec.y, inVec.z, inVec.w);
}

fb::MaterialDescription ToFbMaterialDescription(const MaterialDescription &D) {
    return {
            GpuToFbVec4(D.emissiveColor_),
            GpuToFbVec4(D.albedoColor_),
            GpuToFbVec4(D.roughness_),
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

void loadScene(const char *fileName, SceneGraph &scene) {
}

void saveScene(const char *fileName, const SceneGraph &scene) {
    fb::FlatBufferBuilder builder;
    fb::SceneGraphBuilder sceneGraphBuilder(builder);

    sceneGraphBuilder.add_localTransform_(builder.CreateVectorOfStructs(
            map<glm::mat4, fb::Matrix4x4>(scene.localTransform_, GlmToFbMat4)));
//    sceneGraphBuilder.add_globalTransform_(builder.CreateVector())
//    sceneGraphBuilder.add_hierarchy_()

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

    auto fbMaterials = map<MaterialDescription, fb::MaterialDescription>(materials, ToFbMaterialDescription);
    auto functor = [&builder](const std::string &s) -> fb::Offset<fb::String> { return builder.CreateString(s); };
    auto fbFiles = map<std::string, fb::Offset<fb::String>>(files, functor);
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

void saveMeshData(const char *fileName, const MeshData &m) {
    fb::FlatBufferBuilder builder;



    ZELO_ASSERT(fb::SaveFile(fileName, (const char *) builder.GetBufferPointer(), builder.GetSize(), true));
}
}
