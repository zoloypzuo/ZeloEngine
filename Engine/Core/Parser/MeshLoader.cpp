// MeshLoader.cpp
// created on 2021/3/31
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "MeshLoader.h"
#include "Core/Resource/Resource.h"
#include "Core/RHI/Buffer/Vertex.h"

#include "Renderer/OpenGL/Resource/GLTexture.h"
#include "Renderer/OpenGL/Resource/GLMesh.h"
#include "Renderer/OpenGL/Resource/GLMaterial.h"

#include <assimp/scene.h>
#include <assimp/IOSystem.hpp>
#include <assimp/IOStream.hpp>

#include <assimp/Importer.hpp>
#include <assimp/postprocess.h>

using namespace Zelo::Core::RHI;
using namespace Zelo::Renderer::OpenGL;

class CustomIOStream : public Assimp::IOStream {
    friend class CustomIOSystem;

protected:
    // Constructor protected for private usage by CustomIOSystem
    CustomIOStream(const char *pFile, const char *pMode);

public:
    ~CustomIOStream() override;

    size_t Read(void *pvBuffer, size_t pSize, size_t pCount) override;

    size_t Write(const void *pvBuffer, size_t pSize, size_t pCount) override;

    aiReturn Seek(size_t pOffset, aiOrigin pOrigin) override;

    size_t Tell() const override;

    size_t FileSize() const override;

    void Flush() override;

private:
    Zelo::IOStream *m_ioStream;
};

class CustomIOSystem : public Assimp::IOSystem {
public:
    CustomIOSystem();

    ~CustomIOSystem() override;

    bool ComparePaths(const char *one, const char *second) const override;

    bool Exists(const char *pFile) const override;

    char getOsSeparator() const override;

    Assimp::IOStream *Open(const char *pFile, const char *pMode) override;

    void Close(Assimp::IOStream *pFile) override;
};

CustomIOStream::CustomIOStream(const char *pFile, const char *pMode) {
    (void) pMode;
    m_ioStream = new Zelo::IOStream(std::string(pFile));
}

CustomIOStream::~CustomIOStream() {
    delete m_ioStream;
}

size_t CustomIOStream::Read(void *pvBuffer, size_t pSize, size_t pCount) {
    return m_ioStream->read(pvBuffer, pSize, pCount);
}

size_t CustomIOStream::Write(const void *pvBuffer, size_t pSize, size_t pCount) {
    return m_ioStream->write(pvBuffer, pSize, pCount);
}

aiReturn CustomIOStream::Seek(size_t pOffset, aiOrigin pOrigin) {
    switch (pOrigin) {
        case aiOrigin_SET:
            return m_ioStream->seek(pOffset, Zelo::Origin_SET) ? AI_SUCCESS : AI_FAILURE;
        case aiOrigin_CUR:
            return m_ioStream->seek(pOffset, Zelo::Origin_CUR) ? AI_SUCCESS : AI_FAILURE;
        case aiOrigin_END:
            return m_ioStream->seek(pOffset, Zelo::Origin_END) ? AI_SUCCESS : AI_FAILURE;
        case _AI_ORIGIN_ENFORCE_ENUM_SIZE:
            break;
    }
    ZELO_ASSERT(false, "unreachable");
    return aiReturn_FAILURE;
}

size_t CustomIOStream::Tell() const {
    return m_ioStream->tell();
}

size_t CustomIOStream::FileSize() const {
    return m_ioStream->fileSize();
}

void CustomIOStream::Flush() {
    m_ioStream->flush();
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

std::string getTexturePathFromMaterial(const aiMaterial *pMaterial,
                                       aiTextureType textureType,
                                       std::string defaultPath) {
    aiString Path{};
    if (pMaterial->GetTextureCount(textureType) > 0 &&
        pMaterial->GetTexture(textureType,
                              0,
                              &Path,
                              nullptr, nullptr,
                              nullptr, nullptr,
                              nullptr) == AI_SUCCESS) {
        return Path.data;
    } else {
        return defaultPath;
    }
}

Zelo::Parser::MeshLoader::MeshLoader(const std::string &file) {
    m_fileName = file;

    Assimp::Importer importer;
    importer.SetIOHandler(new CustomIOSystem());

    spdlog::info("Loading mesh: {}", file);

    auto pFlags = aiProcess_Triangulate |
                  aiProcess_GenSmoothNormals |
                  aiProcess_FlipUVs |
                  aiProcess_CalcTangentSpace;
    const auto *scene = importer.ReadFile(file, pFlags);

    if (!scene) {
        spdlog::error("Failed to load mesh: {}", file);
        return;
    }

    for (unsigned int i = 0; i < scene->mNumMeshes; i++) {
        const aiMesh *model = scene->mMeshes[i];

        std::vector<Vertex> vertices;
        std::vector<uint32_t> indices;

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

        auto diffuseMapPath = getTexturePathFromMaterial(pMaterial, aiTextureType_DIFFUSE, "default_normal.jpg");
        diffuseMap = std::make_shared<GLTexture>(Zelo::Resource(diffuseMapPath));

        auto normalMapPath = getTexturePathFromMaterial(pMaterial, aiTextureType_HEIGHT, "default_normal.jpg");
        normalMap = std::make_shared<GLTexture>(Zelo::Resource(normalMapPath));

        auto specularMapPath = getTexturePathFromMaterial(pMaterial, aiTextureType_SPECULAR, "default_specular.jpg");
        specularMap = std::make_shared<GLTexture>(Zelo::Resource(specularMapPath));

        m_meshRendererData.emplace_back(
                std::make_shared<GLMesh>(m_fileName + std::string(model->mName.C_Str()),
                                         &vertices[0],
                                         vertices.size(), &indices[0], indices.size()),
                std::make_shared<GLMaterial>(diffuseMap, normalMap, specularMap)
        );
    }
}

Zelo::Parser::MeshLoader::MeshLoader(const std::string &meshFileName, int meshIndex) {
    m_fileName = meshFileName;

    Assimp::Importer importer;
    importer.SetIOHandler(new CustomIOSystem());

    auto pFlags = aiProcess_Triangulate |
                  aiProcess_GenSmoothNormals |
                  aiProcess_FlipUVs |
                  aiProcess_CalcTangentSpace;
    const auto *scene = importer.ReadFile(meshFileName, pFlags);

    if (!scene) {
        spdlog::error("Failed to load mesh: {}", meshFileName);
        return;
    }

    ZELO_ASSERT(meshIndex < scene->mNumMeshes);

    auto i = meshIndex;
    const aiMesh *model = scene->mMeshes[i];

    m_id = m_fileName + std::string(model->mName.C_Str());

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

        m_vertex.push_back(vert);
    }

    for (unsigned int idxFace = 0; idxFace < model->mNumFaces; idxFace++) {
        const aiFace &face = model->mFaces[idxFace];
        m_indice.push_back(face.mIndices[0]);
        m_indice.push_back(face.mIndices[1]);
        m_indice.push_back(face.mIndices[2]);
    }
}


Zelo::Parser::MeshLoader::~MeshLoader() = default;

std::vector<MeshRendererData> Zelo::Parser::MeshLoader::getMeshRendererData() {
    return m_meshRendererData;
}

std::string Zelo::Parser::MeshLoader::getFileName() {
    return m_fileName;
}

const std::string &Zelo::Parser::MeshLoader::getId() {
    return m_id;
}

std::vector<Vertex> Zelo::Parser::MeshLoader::getVertices() {
    return m_vertex;
}

std::vector<uint32_t> Zelo::Parser::MeshLoader::getIndices() {
    return m_indice;
}
