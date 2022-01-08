#include "SceneGraph.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Util/Utils.h"

#include <algorithm>
#include <numeric>
#include <stack>

namespace Zelo::Renderer::OpenGL {
int addNode(SceneGraph &scene, int parent, int level) {
    int node = (int) scene.hierarchy_.size();
    {
        // TODO(PERF): resize aux arrays (local/global etc.)
        scene.localTransform_.emplace_back(1.0f);
        scene.globalTransform_.emplace_back(1.0f);
    }
    scene.hierarchy_.push_back({parent, -1});
    if (parent > -1) {
        // find first item (sibling)
        int s = scene.hierarchy_[parent].firstChild_;
        if (s == -1) {
            scene.hierarchy_[parent].firstChild_ = node;
            scene.hierarchy_[node].lastSibling_ = node;
        } else {
            int dest = scene.hierarchy_[s].lastSibling_;
            if (dest <= -1) {
                // no cached lastSibling, iterate nextSibling indices
                for (dest = s; scene.hierarchy_[dest].nextSibling_ != -1; dest = scene.hierarchy_[dest].nextSibling_);
            }
            scene.hierarchy_[dest].nextSibling_ = node;
            scene.hierarchy_[s].lastSibling_ = node;
        }
    }
    scene.hierarchy_[node].level_ = level;
    scene.hierarchy_[node].nextSibling_ = -1;
    scene.hierarchy_[node].firstChild_ = -1;
    return node;
}

void markAsChanged(SceneGraph &scene, int root) {
    std::stack<int> stack;
    stack.emplace(root);
    while (!stack.empty()) {
        int node = stack.top();

        int level = scene.hierarchy_[node].level_;
        scene.changedAtThisFrame_[level].push_back(node);

        stack.pop();
        for (auto s: getNodeChildren(scene, node)) {
            stack.emplace(s);
        }
    }
}

int findNodeByName(const SceneGraph &scene, const std::string &name) {
    // Extremely simple linear search without any hierarchy reference
    // To support DFS/BFS searches separate traversal routines are needed

    for (size_t i = 0; i < scene.localTransform_.size(); i++)
        if (scene.nameForNode_.count(i)) {
            int strID = scene.nameForNode_.at(i);
            if (strID > -1)
                if (scene.names_[strID] == name)
                    return (int) i;
        }

    return -1;
}

int getNodeLevel(const SceneGraph &scene, int n) {
    int level = -1;
    for (int p = 0; p != -1; p = scene.hierarchy_[p].parent_, level++);
    return level;
}

bool mat4IsIdentity(const glm::mat4 &m);

void fprintfMat4(FILE *f, const glm::mat4 &m);

// CPU version of global transform update []
void recalculateGlobalTransforms(SceneGraph &scene) {
    if (!scene.changedAtThisFrame_[0].empty()) {
        int c = scene.changedAtThisFrame_[0][0];
        scene.globalTransform_[c] = scene.localTransform_[c];
        scene.changedAtThisFrame_[0].clear();
    }

    for (int i = 1; i < MAX_NODE_LEVEL && (!scene.changedAtThisFrame_[i].empty()); i++) {
        for (const int &c: scene.changedAtThisFrame_[i]) {
            int p = scene.hierarchy_[c].parent_;
            scene.globalTransform_[c] = scene.globalTransform_[p] * scene.localTransform_[c];
        }
        scene.changedAtThisFrame_[i].clear();
    }
}

bool mat4IsIdentity(const glm::mat4 &m) {
    return (m[0][0] == 1 && m[0][1] == 0 && m[0][2] == 0 && m[0][3] == 0 &&
            m[1][0] == 0 && m[1][1] == 1 && m[1][2] == 0 && m[1][3] == 0 &&
            m[2][0] == 0 && m[2][1] == 0 && m[2][2] == 1 && m[2][3] == 0 &&
            m[3][0] == 0 && m[3][1] == 0 && m[3][2] == 0 && m[3][3] == 1);
}

void fprintfMat4(FILE *f, const glm::mat4 &m) {
    if (mat4IsIdentity(m)) {
        fprintf(f, "Identity\n");
    } else {
        fprintf(f, "\n");
        for (int i = 0; i < 4; i++) {
            for (int j = 0; j < 4; j++)
                fprintf(f, "%f ;", m[i][j]);
            fprintf(f, "\n");
        }
    }
}

void dumpTransforms(const char *fileName, const SceneGraph &scene) {
    FILE *f = fopen(fileName, "a+");
    for (size_t i = 0; i < scene.localTransform_.size(); i++) {
        fprintf(f, "Node[%d].localTransform: ", (int) i);
        fprintfMat4(f, scene.localTransform_[i]);
        fprintf(f, "Node[%d].globalTransform: ", (int) i);
        fprintfMat4(f, scene.globalTransform_[i]);
        fprintf(f, "Node[%d].globalDet = %f; localDet = %f\n", (int) i, glm::determinant(scene.globalTransform_[i]),
                glm::determinant(scene.localTransform_[i]));
    }
    fclose(f);
}

void printChangedNodes(const SceneGraph &scene) {
    for (int i = 0; i < MAX_NODE_LEVEL && (!scene.changedAtThisFrame_[i].empty()); i++) {
        printf("Changed at level(%d):\n", i);

        for (const int &c: scene.changedAtThisFrame_[i]) {
            int p = scene.hierarchy_[c].parent_;
            //scene.globalTransform_[c] = scene.globalTransform_[p] * scene.localTransform_[c];
            printf(" Node %d. Parent = %d; LocalTransform: ", c, p);
            fprintfMat4(stdout, scene.localTransform_[i]);
            if (p > -1) {
                printf(" ParentGlobalTransform: ");
                fprintfMat4(stdout, scene.globalTransform_[p]);
            }
        }
    }
}

// Shift all hierarchy components in the nodes
void shiftNodes(SceneGraph &scene, int startOffset, int nodeCount, int shiftAmount) {
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
void mergeMaps(ItemMap &m, const ItemMap &otherMap, int indexOffset, int itemOffset) {
    for (const auto &i: otherMap)
        m[i.first + indexOffset] = i.second + itemOffset;
}

void dumpSceneToDot(const char *fileName, const SceneGraph &scene, int *visited) {
    FILE *f = fopen(fileName, "w");
    fprintf(f, "digraph G\n{\n");
    for (size_t i = 0; i < scene.globalTransform_.size(); i++) {
        std::string name = "";
        std::string extra = "";
        if (scene.nameForNode_.count(i)) {
            int strID = scene.nameForNode_.at(i);
            name = scene.names_[strID];
        }
        if (visited) {
            if (visited[i])
                extra = ", color = red";
        }
        fprintf(f, "n%d [label=\"%s\" %s]\n", (int) i, name.c_str(), extra.c_str());
    }
    for (size_t i = 0; i < scene.hierarchy_.size(); i++) {
        int p = scene.hierarchy_[i].parent_;
        if (p > -1)
            fprintf(f, "\t n%d -> n%d\n", p, (int) i);
    }
    fprintf(f, "}\n");
    fclose(f);
}

/** A rather long algorithm (and the auxiliary routines) to delete a number of scene nodes from the hierarchy */
/* */

// Add an index to a sorted index array
static void addUniqueIdx(std::vector<uint32_t> &v, uint32_t index) {
    if (!std::binary_search(v.begin(), v.end(), index))
        v.push_back(index);
}

// Recurse down from a node and collect all nodes which are already marked for deletion
static void collectNodesToDelete(const SceneGraph &scene, int node, std::vector<uint32_t> &nodes) {
    for(auto n : getNodeChildren(scene, node)){
        addUniqueIdx(nodes, n);
        collectNodesToDelete(scene, n, nodes);
    }
}

int findLastNonDeletedItem(const SceneGraph &scene, const std::vector<int> &newIndices, int node) {
    // we have to be more subtle:
    //   if the (newIndices[firstChild_] == -1), we should follow the link and extract the last non-removed item
    //   ..
    if (node == -1)
        return -1;

    return (newIndices[node] == -1) ?
           findLastNonDeletedItem(scene, newIndices, scene.hierarchy_[node].nextSibling_) :
           newIndices[node];
}

void shiftMapIndices(std::unordered_map<uint32_t, uint32_t> &items, const std::vector<int> &newIndices) {
    std::unordered_map<uint32_t, uint32_t> newItems;
    for (const auto &m: items) {
        int newIndex = newIndices[m.first];
        if (newIndex != -1)
            newItems[newIndex] = m.second;
    }
    items = newItems;
}

// Approximately an O ( N * Log(N) * Log(M)) algorithm (N = scene.size, M = nodesToDelete.size) to delete a collection of nodes from scene graph
void deleteSceneNodes(SceneGraph &scene, const std::vector<uint32_t> &nodesToDelete) {
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
    auto nodeMover = [&scene, &newIndices](Hierarchy &h) {
        return Hierarchy{
                (h.parent_ != -1) ? newIndices[h.parent_] : -1,
                findLastNonDeletedItem(scene, newIndices, h.firstChild_),
                findLastNonDeletedItem(scene, newIndices, h.nextSibling_),
                findLastNonDeletedItem(scene, newIndices, h.lastSibling_)
        };
    };
    std::transform(scene.hierarchy_.begin(), scene.hierarchy_.end(), scene.hierarchy_.begin(), nodeMover);

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

std::vector<SceneNode> getNodeChildren(const SceneGraph &scene, SceneNode node) {
    std::vector<SceneNode> children;
    for (SceneNode s = scene.hierarchy_[node].firstChild_; s != -1; s = scene.hierarchy_[s].nextSibling_) {
        children.emplace_back(s);
    }
    return children;
}
}