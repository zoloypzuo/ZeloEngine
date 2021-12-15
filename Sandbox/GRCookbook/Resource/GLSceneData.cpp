#include "GLSceneData.h"
#include "Core/Resource/ResourceManager.h"
#include "VtxData/DrawData.h"

static uint64_t getTextureHandleBindless(uint64_t idx, const std::vector<GLTexture> &textures) {
    if (idx == INVALID_TEXTURE) return 0;

    return textures[idx].getHandleBindless();
}

static std::string ZELO_PATH(const std::string &fileName) {
    auto *resourcem = Zelo::Core::Resource::ResourceManager::getSingletonPtr();
    return resourcem->resolvePath(fileName).string();
}

GLSceneData::GLSceneData(
        const char *meshFile,
        const char *sceneFile,
        const char *materialFile) {
    header_ = loadMeshData(meshFile, meshData_);
    loadScene(sceneFile);

    std::vector<std::string> textureFiles;
    loadMaterials(materialFile, materials_, textureFiles);

    for (const auto &f: textureFiles) {
        allMaterialTextures_.emplace_back(GL_TEXTURE_2D, ZELO_PATH(f).c_str());
    }

    for (auto &mtl: materials_) {
        mtl.ambientOcclusionMap_ = getTextureHandleBindless(mtl.ambientOcclusionMap_, allMaterialTextures_);
        mtl.emissiveMap_ = getTextureHandleBindless(mtl.emissiveMap_, allMaterialTextures_);
        mtl.albedoMap_ = getTextureHandleBindless(mtl.albedoMap_, allMaterialTextures_);
        mtl.metallicRoughnessMap_ = getTextureHandleBindless(mtl.metallicRoughnessMap_, allMaterialTextures_);
        mtl.normalMap_ = getTextureHandleBindless(mtl.normalMap_, allMaterialTextures_);
    }
}

void GLSceneData::loadScene(const char *sceneFile) {
    ::loadScene(sceneFile, scene_);

    // prepare draw data buffer
    for (const auto &c: scene_.meshes_) {
        auto material = scene_.materialForNode_.find(c.first);
        if (material != scene_.materialForNode_.end()) {
            shapes_.push_back(
                    DrawData{
                            c.second,
                            material->second,
                            0,
                            meshData_.meshes_[c.second].indexOffset,
                            meshData_.meshes_[c.second].vertexOffset,
                            c.first
                    });
        }
    }

    // force recalculation of all global transformations
    markAsChanged(scene_, 0);
    recalculateGlobalTransforms(scene_);
}
