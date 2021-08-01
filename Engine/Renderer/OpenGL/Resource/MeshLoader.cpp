// MeshLoader.cpp
// created on 2021/3/31
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Core/Resource/Resource.h"
#include "MeshLoader.h"
#include "Renderer/OpenGL/Drawable/MeshRenderer.h"
#include "Renderer/OpenGL/Resource/GLTexture.h"
#include "Renderer/OpenGL/Resource/GLMesh.h"
#include "MeshManager.h"

#include <assimp/Importer.hpp>
#include <assimp/postprocess.h>

CustomIOStream::CustomIOStream(const char *pFile, const char *pMode) {
    (void) pMode;
    m_iostream = new Zelo::IOStream(std::string(pFile));
}

CustomIOStream::~CustomIOStream() {
    delete m_iostream;
}

size_t CustomIOStream::Read(void *pvBuffer, size_t pSize, size_t pCount) {
    return m_iostream->read(pvBuffer, pSize, pCount);
}

size_t CustomIOStream::Write(const void *pvBuffer, size_t pSize, size_t pCount) {
    return m_iostream->write(pvBuffer, pSize, pCount);
}

aiReturn CustomIOStream::Seek(size_t pOffset, aiOrigin pOrigin) {
    switch (pOrigin) {
        case aiOrigin_SET:
            return m_iostream->seek(pOffset, Zelo::Origin_SET) ? AI_SUCCESS : AI_FAILURE;
        case aiOrigin_CUR:
            return m_iostream->seek(pOffset, Zelo::Origin_CUR) ? AI_SUCCESS : AI_FAILURE;
        case aiOrigin_END:
            return m_iostream->seek(pOffset, Zelo::Origin_END) ? AI_SUCCESS : AI_FAILURE;
        case _AI_ORIGIN_ENFORCE_ENUM_SIZE:
            break;
    }
    ZELO_ASSERT(false, "unreachable");
}

size_t CustomIOStream::Tell() const {
    return m_iostream->tell();
}

size_t CustomIOStream::FileSize() const {
    return m_iostream->fileSize();
}

void CustomIOStream::Flush() {
    m_iostream->flush();
}

CustomIOSystem::CustomIOSystem() = default;

CustomIOSystem::~CustomIOSystem() = default;

bool CustomIOSystem::ComparePaths(const char *one, const char *second) const {
    return strcmp(one, second) == 0;
}

bool CustomIOSystem::Exists(const char *pFile) const {
    (void) pFile;
    return true;
}

char CustomIOSystem::getOsSeparator() const {
    return '/';
}

Assimp::IOStream *CustomIOSystem::Open(const char *pFile, const char *pMode) {
    return new CustomIOStream(pFile, pMode);
}

void CustomIOSystem::Close(Assimp::IOStream *pFile) {
    delete pFile;
}

MeshLoader::MeshLoader(const std::string &file) {
    m_fileName = file;
    auto *mesh_m = MeshManager::getSingletonPtr();
    if (!mesh_m->sceneMeshRendererDataCache[m_fileName].empty()) {
        m_entity = std::make_shared<Entity>();
        for (const auto &meshRenderData : mesh_m->sceneMeshRendererDataCache[m_fileName]) {
            m_entity->Entity::addComponent<MeshRenderer>(meshRenderData.mesh, meshRenderData.material);
        }
    } else {
        Assimp::Importer importer;
        importer.SetIOHandler(new CustomIOSystem());

        spdlog::info("Loading mesh: {}", file.c_str());

        const aiScene *scene = importer.ReadFile(file,
                                                 aiProcess_Triangulate |
                                                 aiProcess_GenSmoothNormals |
                                                 aiProcess_FlipUVs |
                                                 aiProcess_CalcTangentSpace);

        if (!scene) {
            spdlog::error("Failed to load mesh: {}", file.c_str());
        } else {
            loadScene(scene);
        }
    }
}

MeshLoader::~MeshLoader() = default;

std::shared_ptr<Entity> MeshLoader::getEntity() const {
    return m_entity;
}

void MeshLoader::loadScene(const aiScene *scene) {
    m_entity = std::make_shared<Entity>();

    for (unsigned int i = 0; i < scene->mNumMeshes; i++) {
        const aiMesh *model = scene->mMeshes[i];

        std::vector<Vertex> vertices;
        std::vector<unsigned int> indices;

        const aiVector3D aiZeroVector(0.0f, 0.0f, 0.0f);
        for (unsigned int idxVertex = 0; idxVertex < model->mNumVertices; idxVertex++) {
            const aiVector3D *pPos = &(model->mVertices[idxVertex]);
            const aiVector3D *pNormal = &(model->mNormals[idxVertex]);
            const aiVector3D *pTexCoord = model->HasTextureCoords(0) ? &(model->mTextureCoords[0][idxVertex])
                                                                     : &aiZeroVector;
            const aiVector3D *pTangent = model->HasTangentsAndBitangents() ? &(model->mTangents[idxVertex])
                                                                           : &aiZeroVector;

            Vertex vert(glm::vec3(pPos->x, pPos->y, pPos->z),
                        glm::vec2(pTexCoord->x, pTexCoord->y),
                        glm::vec3(pNormal->x, pNormal->y, pNormal->z),
                        glm::vec3(pTangent->x, pTangent->y, pTangent->z));

            vertices.push_back(vert);
        }

        for (unsigned int idxFace = 0; idxFace < model->mNumFaces; idxFace++) {
            const aiFace &face = model->mFaces[idxFace];
            indices.push_back(face.mIndices[0]);
            indices.push_back(face.mIndices[1]);
            indices.push_back(face.mIndices[2]);
        }

        const aiMaterial *pMaterial = scene->mMaterials[model->mMaterialIndex];
        spdlog::info("tex num: {}", model->mMaterialIndex);

        std::shared_ptr<GLTexture> diffuseMap;
        std::shared_ptr<GLTexture> normalMap;
        std::shared_ptr<GLTexture> specularMap;

        aiString Path;

        if (pMaterial->GetTextureCount(aiTextureType_DIFFUSE) > 0
            && pMaterial->GetTexture(
                aiTextureType_DIFFUSE, 0, &Path,
                nullptr, nullptr, nullptr, nullptr, nullptr) == AI_SUCCESS) {
            diffuseMap = std::make_shared<GLTexture>(Zelo::Resource(Path.data));
        } else {
            diffuseMap = std::make_shared<GLTexture>(Zelo::Resource("default_normal.jpg"));
        }

        if (pMaterial->GetTextureCount(aiTextureType_HEIGHT) > 0
            && pMaterial->GetTexture(
                aiTextureType_HEIGHT, 0, &Path,
                nullptr, nullptr, nullptr, nullptr, nullptr) == AI_SUCCESS) {
            normalMap = std::make_shared<GLTexture>(Zelo::Resource(Path.data));
        } else {
            normalMap = std::make_shared<GLTexture>(Zelo::Resource("default_normal.jpg"));
        }

        if (pMaterial->GetTextureCount(aiTextureType_SPECULAR) > 0
            && pMaterial->GetTexture(
                aiTextureType_SPECULAR, 0, &Path,
                nullptr, nullptr, nullptr, nullptr, nullptr) == AI_SUCCESS) {
            specularMap = std::make_shared<GLTexture>(Zelo::Resource(Path.data));
        } else {
            specularMap = std::make_shared<GLTexture>(Zelo::Resource("default_specular.jpg"));
        }

        MeshRendererData meshRenderData;
        meshRenderData.mesh = std::make_shared<GLMesh>(m_fileName + std::string(model->mName.C_Str()), &vertices[0],
                                                       vertices.size(), &indices[0], indices.size());
        meshRenderData.material = std::make_shared<Material>(diffuseMap, normalMap, specularMap);

        MeshManager::getSingletonPtr()->sceneMeshRendererDataCache[m_fileName].push_back(meshRenderData);
        m_entity->Entity::addComponent<MeshRenderer>(meshRenderData.mesh, meshRenderData.material);
    }
}
