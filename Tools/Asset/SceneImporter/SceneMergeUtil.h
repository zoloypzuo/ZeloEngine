// SceneMergeUtil.h
// created on 2021/12/26
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Renderer/OpenGL/Drawable/MeshScene/VtxData/MeshData.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Material/Material.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Scene/SceneGraph.h"

namespace Zelo::Renderer::OpenGL {
/**
	There are different use cases for scene merging.
	The simplest one is the direct "gluing" of multiple scenes into one [all the material lists and mesh lists are merged and indices in all scene nodes are shifted appropriately]
	The second one is creating a "grid" of objects (or scenes) with the same material and mesh sets.
	For the second use case we need two flags: 'mergeMeshes' and 'mergeMaterials' to avoid shifting mesh indices
*/
void mergeScenes(SceneGraph &outScene,
                 const std::vector<SceneGraph *> &scenes,
                 const std::vector<glm::mat4> &rootTransforms,
                 const std::vector<uint32_t> &meshCounts,
                 bool mergeMeshes = true, bool mergeMaterials = true);

void mergeScene(SceneGraph& scene, MeshData& meshData, const std::string& materialName);

// Combine a list of meshes to a single mesh container
void mergeMeshData(MeshData &m, std::vector<MeshData *> md);

// Merge material lists from multiple scenes (follows the logic of merging in mergeScenes)
void mergeMaterialLists(
        // Input:
        const std::vector<std::vector<MaterialDescription> *> &oldMaterials, // all materials
        const std::vector<std::vector<std::string> *> &oldTextures,          // all textures from all material lists
        // Output:
        std::vector<MaterialDescription> &allMaterials,
        std::vector<std::string> &newTextures                                // all textures (merged from oldTextures, only unique items)
);
}
