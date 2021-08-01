// MeshLoader.h
// created on 2021/3/31
// author @zoloypzuo

#ifndef ZELOENGINE_MESHLOADER_H
#define ZELOENGINE_MESHLOADER_H

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Renderer/OpenGL/Resource/GLTexture.h"
#include "Renderer/OpenGL/Resource/GLMesh.h"
#include "Renderer/OpenGL/Resource/Material.h"
#include "Core/ECS/Entity.h"

#include <assimp/scene.h>
#include <assimp/IOSystem.hpp>
#include <assimp/IOStream.hpp>

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
    Zelo::IOStream *m_iostream;
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

class MeshLoader {
public:
    explicit MeshLoader(const std::string &file);

    ~MeshLoader();

    std::shared_ptr<Entity> getEntity() const;

private:
    void loadScene(const aiScene *scene);

    std::string m_fileName;

    std::shared_ptr<Entity> m_entity;
};

#endif //ZELOENGINE_MESHLOADER_H