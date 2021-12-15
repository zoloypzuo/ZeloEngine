#pragma once

#include "GRCookbook/Scene.h"
#include "GRCookbook/Material.h"
#include "GRCookbook/VtxData/MeshData.h"
#include "Resource/GLBuffer.h"
#include "GLTexture.h"
#include "VtxData/MeshFileHeader.h"
#include "VtxData/DrawData.h"

class GLSceneData
{
public:
	GLSceneData(
		const char* meshFile,
		const char* sceneFile,
		const char* materialFile);

	std::vector<GLTexture> allMaterialTextures_;

	MeshFileHeader header_;
	MeshData meshData_;

	Scene scene_;
	std::vector<MaterialDescription> materials_;
	std::vector<DrawData> shapes_;

	void loadScene(const char* sceneFile);
};
