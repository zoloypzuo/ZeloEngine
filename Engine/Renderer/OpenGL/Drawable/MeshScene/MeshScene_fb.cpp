// SceneImporter.cpp
// created on 2022/1/7
// author @zoloypzuo

#include "SceneData_generated.h"

#include <flatbuffers/util.h>

#include "Renderer/OpenGL/Drawable/MeshScene/Material/Material.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Scene/SceneGraph.h"
#include "Renderer/OpenGL/Drawable/MeshScene/VtxData/MeshData.h"

namespace Zelo::Renderer::OpenGL {
void loadScene(const char *fileName, SceneGraph &scene) {

}

void saveScene(const char *fileName, const SceneGraph &scene) {

}

void saveMaterials(const char *fileName, const std::vector<MaterialDescription> &materials,
                   const std::vector<std::string> &files) {

}

void loadMaterials(const char *fileName, std::vector<MaterialDescription> &materials, std::vector<std::string> &files) {

}

MeshFileHeader loadMeshData(const char *meshFile, MeshData &out) {
    return {};
}

void saveMeshData(const char *fileName, const MeshData &m) {

}
}
