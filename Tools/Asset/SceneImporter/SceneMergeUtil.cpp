// SceneMergeUtil.cpp.cc
// created on 2021/12/26
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "SceneMergeUtil.h"

namespace Zelo::Renderer::OpenGL {
// Shift all hierarchy components in the nodes
static void shiftNodes(SceneGraph &scene, int startOffset, int nodeCount, int shiftAmount) {
    auto shiftNode = [shiftAmount](Hierarchy &node) {
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
        shiftNode(scene.hierarchy_[i + startOffset]);
}

using ItemMap = std::unordered_map<uint32_t, uint32_t>;

// Add the items from otherMap shifting indices and values along the way
static void mergeMaps(ItemMap &m, const ItemMap &otherMap, int indexOffset, int itemOffset) {
    for (const auto &i: otherMap)
        m[i.first + indexOffset] = i.second + itemOffset;
}

void mergeScenes(SceneGraph &outScene,
                 const std::vector<SceneGraph *> &scenes,
                 const std::vector<glm::mat4> &rootTransforms,
                 const std::vector<uint32_t> &meshCounts, bool mergeMeshes, bool mergeMaterials) {
    // Create new root node
    outScene.hierarchy_ = {{-1, 1, -1, -1, 0}};

    outScene.nameForNode_[0] = 0;
    outScene.names_ = {"NewRoot"};

    outScene.localTransform_.emplace_back(1.f);
    outScene.globalTransform_.emplace_back(1.f);

    if (scenes.empty()) return;

    int offs = 1;
    int meshOffs = 0;
    int nameOffs = (int) outScene.names_.size();
    int materialOfs = 0;
    auto meshCount = meshCounts.begin();

    if (!mergeMaterials) {
        outScene.materialNames_ = scenes[0]->materialNames_;
    }

    // FIXME: too much logic (for all the components in a scene, though mesh data and materials go separately - there are dedicated data lists)
    for (const SceneGraph *s: scenes) {
        mergeVectors(outScene.localTransform_, s->localTransform_);
        mergeVectors(outScene.globalTransform_, s->globalTransform_);

        mergeVectors(outScene.hierarchy_, s->hierarchy_);

        mergeVectors(outScene.names_, s->names_);
        if (mergeMaterials){
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
    for (const SceneGraph *s: scenes) {
        int nodeCount = (int) s->hierarchy_.size();
        bool isLast = (idx == scenes.size() - 1);
        // calculate new next sibling for the old scene roots
        int next = isLast ? -1 : offs + nodeCount;
        outScene.hierarchy_[offs].nextSibling_ = next;
        // attach to new root
        outScene.hierarchy_[offs].parent_ = 0;

        // transform old root nodes, if the transforms are given
        if (!rootTransforms.empty())
            outScene.localTransform_[offs] = rootTransforms[idx] * outScene.localTransform_[offs];

        offs += nodeCount;
        idx++;
    }

    // now shift levels of all nodes below the root
    for (auto i = outScene.hierarchy_.begin() + 1; i != outScene.hierarchy_.end(); i++){
        i->level_++;
    }
}

// Combine a list of meshes to a single mesh container
MeshFileHeader mergeMeshData(MeshData &m, const std::vector<MeshData *> md) {
    uint32_t totalVertexDataSize = 0;
    uint32_t totalIndexDataSize  = 0;

    uint32_t offs = 0;
    for (const MeshData* i: md)
    {
        mergeVectors(m.indexData_, i->indexData_);
        mergeVectors(m.vertexData_, i->vertexData_);
        mergeVectors(m.meshes_, i->meshes_);
        mergeVectors(m.boxes_, i->boxes_);

        uint32_t vtxOffset = totalVertexDataSize / 8;  /* 8 is the number of per-vertex attributes: position, normal + UV */

        for (size_t j = 0 ; j < (uint32_t)i->meshes_.size() ; j++)
            // m.vertexCount, m.lodCount and m.streamCount do not change
            // m.vertexOffset also does not change, because vertex offsets are local (i.e., baked into the indices)
            m.meshes_[offs + j].indexOffset += totalIndexDataSize;

        // shift individual indices
        for(size_t j = 0 ; j < i->indexData_.size() ; j++)
            m.indexData_[totalIndexDataSize + j] += vtxOffset;

        offs += (uint32_t)i->meshes_.size();

        totalIndexDataSize += (uint32_t)i->indexData_.size();
        totalVertexDataSize += (uint32_t)i->vertexData_.size();
    }

    return MeshFileHeader {
            .magicValue = 0x12345678,
            .meshCount = (uint32_t)offs,
            .dataBlockStartOffset = (uint32_t )(sizeof(MeshFileHeader) + offs * sizeof(Mesh)),
            .indexDataSize = static_cast<uint32_t>(totalIndexDataSize * sizeof(uint32_t)),
            .vertexDataSize = static_cast<uint32_t>(totalVertexDataSize * sizeof(float))
    };
}

void mergeMaterialLists(
        const std::vector<std::vector<MaterialDescription> *> &oldMaterials,
        const std::vector<std::vector<std::string> *> &oldTextures,
        std::vector<MaterialDescription> &allMaterials,
        std::vector<std::string> &newTextures
) {
    // map texture names to indices in newTexturesList (calculated as we fill the newTexturesList)
    std::unordered_map<std::string, int> newTextureNames;
    std::unordered_map<int, int> materialToTextureList; // direct MaterialDescription usage as a key is impossible, so we use its index in the allMaterials array

    // Create combined material list [no hashing of materials, just straightforward merging of all lists]
    int midx = 0;
    for (const std::vector<MaterialDescription> *ml: oldMaterials) {
        for (const MaterialDescription &m: *ml) {
            allMaterials.push_back(m);
            materialToTextureList[allMaterials.size() - 1] = midx;
        }

        midx++;
    }

    // Create one combined texture list
    for (const std::vector<std::string> *tl: oldTextures)
        for (const std::string &file: *tl) {
            newTextureNames[file] = addUnique(newTextures, file); // addUnique() is in SceneConverter/MaterialConv.inl
        }

    // Lambda to replace textureID by a new "version" (from global list)
    auto replaceTexture = [&materialToTextureList, &oldTextures, &newTextureNames](int m, uint64_t *textureID) {
        if (*textureID < INVALID_TEXTURE) {
            auto listIdx = materialToTextureList[m];
            auto texList = oldTextures[listIdx];
            const std::string &texFile = (*texList)[*textureID];
            *textureID = (uint64_t) (newTextureNames[texFile]);
        }
    };

    for (size_t i = 0; i < allMaterials.size(); i++) {
        auto &m = allMaterials[i];
        replaceTexture(i, &m.ambientOcclusionMap_);
        replaceTexture(i, &m.emissiveMap_);
        replaceTexture(i, &m.albedoMap_);
        replaceTexture(i, &m.metallicRoughnessMap_);
        replaceTexture(i, &m.normalMap_);
    }
}

static uint32_t shiftMeshIndices(MeshData& meshData, const std::vector<uint32_t>& meshesToMerge)
{
    auto minVtxOffset = std::numeric_limits<uint32_t>::max();
    for (auto i: meshesToMerge)
        minVtxOffset = std::min(meshData.meshes_[i].vertexOffset, minVtxOffset);

    auto mergeCount = 0u; // calculated by summing index counts in meshesToMerge

    // now shift all the indices in individual index blocks [use minVtxOffset]
    for (auto i: meshesToMerge)
    {
        auto& m = meshData.meshes_[i];
        // for how much should we shift the indices in mesh [m]
        const uint32_t delta = m.vertexOffset - minVtxOffset;

        const auto idxCount = m.getLODIndicesCount(0);
        for (auto ii = 0u ; ii < idxCount ; ii++)
            meshData.indexData_[m.indexOffset + ii] += delta;

        m.vertexOffset = minVtxOffset;

        // sum all the deleted meshes' indices
        mergeCount += idxCount;
    }

    return meshData.indexData_.size() - mergeCount;
}

// All the meshesToMerge now have the same vertexOffset and individual index values are shifted by appropriate amount
// Here we move all the indices to appropriate places in the new index array
static void mergeIndexArray(MeshData& md, const std::vector<uint32_t>& meshesToMerge, std::map<uint32_t, uint32_t>& oldToNew)
{
    std::vector<uint32_t> newIndices(md.indexData_.size());
    // Two offsets in the new indices array (one begins at the start, the second one after all the copied indices)
    uint32_t copyOffset = 0,
            mergeOffset = shiftMeshIndices(md, meshesToMerge);

    const auto mergedMeshIndex = md.meshes_.size() - meshesToMerge.size();
    auto newIndex = 0u;
    for (auto midx = 0u ; midx < md.meshes_.size() ; midx++)
    {
        const bool shouldMerge = std::binary_search( meshesToMerge.begin(), meshesToMerge.end(), midx);

        oldToNew[midx] = shouldMerge ? mergedMeshIndex : newIndex;
        newIndex += shouldMerge ? 0 : 1;

        auto& mesh = md.meshes_[midx];
        auto idxCount = mesh.getLODIndicesCount(0);
        // move all indices to the new array at mergeOffset
        const auto start = md.indexData_.begin() + mesh.indexOffset;
        mesh.indexOffset = copyOffset;
        const auto offsetPtr = shouldMerge ? &mergeOffset : &copyOffset;
        std::copy(start, start + idxCount, newIndices.begin() + *offsetPtr);
        *offsetPtr += idxCount;
    }

    md.indexData_ = newIndices;

    // all the merged indices are now in lastMesh
    Mesh lastMesh = md.meshes_[meshesToMerge[0]];
    lastMesh.indexOffset = copyOffset;
    lastMesh.lodOffset[0] = copyOffset;
    lastMesh.lodOffset[1] = mergeOffset;
    lastMesh.lodCount = 1;
    md.meshes_.push_back(lastMesh);
}

void mergeScene(SceneGraph &scene, MeshData &meshData, const std::string &materialName) {
    // Find material index
    int oldMaterial = (int)std::distance(std::begin(scene.materialNames_), std::find(std::begin(scene.materialNames_), std::end(scene.materialNames_), materialName));

    std::vector<uint32_t> toDelete;

    for (auto i = 0u ; i < scene.hierarchy_.size() ; i++)
        if (scene.meshes_.contains(i) && scene.materialForNode_.contains(i) && (scene.materialForNode_.at(i) == oldMaterial))
            toDelete.push_back(i);

    std::vector<uint32_t> meshesToMerge(toDelete.size());

    // Convert toDelete indices to mesh indices
    std::transform(toDelete.begin(), toDelete.end(), meshesToMerge.begin(), [&scene](uint32_t i) { return scene.meshes_.at(i); });

    // TODO: if merged mesh transforms are non-zero, then we should pre-transform individual mesh vertices in meshData using local transform

    // old-to-new mesh indices
    std::map<uint32_t, uint32_t> oldToNew;

    // now move all the meshesToMerge to the end of array
    mergeIndexArray(meshData, meshesToMerge, oldToNew);

    // cutoff all but one of the merged meshes (insert the last saved mesh from meshesToMerge - they are all the same)
    eraseSelected(meshData.meshes_, meshesToMerge);

    for (auto& n: scene.meshes_)
        n.second = oldToNew[n.second];

    // reattach the node with merged meshes [identity transforms are assumed]
    int newNode = addNode(scene, 0, 1);
    scene.meshes_[newNode] = meshData.meshes_.size() - 1;
    scene.materialForNode_[newNode] = (uint32_t)oldMaterial;

    deleteSceneNodes(scene, toDelete);
}
}