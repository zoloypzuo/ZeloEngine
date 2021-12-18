#pragma once

#include <string>
#include <unordered_map>
#include <vector>

#include <glm/glm.hpp>
#include <glm/ext.hpp>

using glm::mat4;

// we do not define std::vector<Node*> Children - this is already present in the aiNode from assimp

constexpr const int MAX_NODE_LEVEL = 16;

struct Hierarchy {
    // parent for this node (or -1 for root)
    int parent_;
    // first child for a node (or -1)
    int firstChild_;
    // next sibling for a node (or -1)
    int nextSibling_;
    // last added node (or -1)
    int lastSibling_;
    // cached node level
    int level_;
};

/* This scene is converted into a descriptorSet(s) in MultiRenderer class 
   This structure is also used as a storage type in SceneExporter tool
 */
// struct Node (pseudocode)
// 1. name
// 2. hierarchy
// 3. mesh
// 4. material
// 5. transform local
// 6. transform global
// 7. transform dirty
struct Scene {
#pragma region runtime
    // local transformations for each node and global transforms
    // + an array of 'dirty/changed' local transforms
    std::vector<mat4> localTransform_;
    std::vector<mat4> globalTransform_;

    // list of nodes whose global transform must be recalculated
    std::vector<int> changedAtThisFrame_[MAX_NODE_LEVEL];
#pragma endregion runtime

    // Hierarchy component
    std::vector<Hierarchy> hierarchy_;

    // Mesh component: Which node corresponds to which node
    std::unordered_map<uint32_t, uint32_t> meshes_;

    // Material component: Which material belongs to which node
    std::unordered_map<uint32_t, uint32_t> materialForNode_;

    // Node name component: Which name is assigned to the node
    std::unordered_map<uint32_t, uint32_t> nameForNode_;

    // List of scene node names
    std::vector<std::string> names_;

    // Debug list of material names
    std::vector<std::string> materialNames_;
};

int addNode(Scene &scene, int parent, int level);

void markAsChanged(Scene &scene, int node);

int findNodeByName(const Scene &scene, const std::string &name);

inline std::string getNodeName(const Scene &scene, uint32_t node) {
    int strID = scene.nameForNode_.count(node) ? scene.nameForNode_.at(node) : -1;
    return (strID > -1) ? scene.names_[strID] : std::string();
}

inline void setNodeName(Scene &scene, int node, const std::string &name) {
    uint32_t stringID = (uint32_t) scene.names_.size();
    scene.names_.push_back(name);
    scene.nameForNode_[node] = stringID;
}

int getNodeLevel(const Scene &scene, int n);

void recalculateGlobalTransforms(Scene &scene);

void loadScene(const char *fileName, Scene &scene);

void saveScene(const char *fileName, const Scene &scene);

void dumpTransforms(const char *fileName, const Scene &scene);

void printChangedNodes(const Scene &scene);

void dumpSceneToDot(const char *fileName, const Scene &scene, int *visited = nullptr);

// Delete a collection of nodes from a scenegraph
void deleteSceneNodes(Scene &scene, const std::vector<uint32_t> &nodesToDelete);
