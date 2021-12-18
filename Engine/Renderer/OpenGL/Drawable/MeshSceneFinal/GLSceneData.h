#pragma once

#include "Renderer/OpenGL/Drawable/MeshSceneFinal/Scene/Scene.h"
#include "Renderer/OpenGL/Drawable/MeshSceneFinal/Material/Material.h"
#include "Renderer/OpenGL/Drawable/MeshSceneFinal/VtxData/MeshData.h"
#include "GLBuffer.h"
#include "Renderer/OpenGL/Drawable/MeshSceneFinal/Texture/GLTexture.h"
#include "Renderer/OpenGL/Drawable/MeshSceneFinal/VtxData/MeshFileHeader.h"
#include "Renderer/OpenGL/Drawable/MeshSceneFinal/VtxData/DrawData.h"

class GLSceneData {
public:
    GLSceneData(
            const char *meshFile,
            const char *sceneFile,
            const char *materialFile);

    std::vector<GLTexture> allMaterialTextures_;

    MeshFileHeader header_;
    MeshData meshData_;

    Scene scene_;
    std::vector<MaterialDescription> materials_;
    std::vector<DrawData> shapes_;

    void loadScene(const char *sceneFile);
};
