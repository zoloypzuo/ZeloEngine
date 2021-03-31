// MeshLoader.h
// created on 2021/3/31
// author @zoloypzuo

#ifndef ZELOENGINE_MESHLOADER_H
#define ZELOENGINE_MESHLOADER_H

#include "ZeloPrerequisites.h"
#include "Texture.h"
#include "Mesh.h"
#include "Material.h"
#include "Entity.h"

#include <assimp/scene.h>
#include <assimp/IOSystem.hpp>
#include <assimp/IOStream.hpp>

class CustomIOStream : public Assimp::IOStream
{
    friend class CustomIOSystem;

protected:
    // Constructor protected for private usage by CustomIOSystem
    CustomIOStream(const char* pFile, const char* pMode);

public:
    ~CustomIOStream(void);

    size_t Read(void* pvBuffer, size_t pSize, size_t pCount);
    size_t Write(const void* pvBuffer, size_t pSize, size_t pCount);
    aiReturn Seek(size_t pOffset, aiOrigin pOrigin);
    size_t Tell(void) const;
    size_t FileSize(void) const;
    void Flush(void);

private:
    EngineIOStream *m_iostream;
};

class CustomIOSystem : public Assimp::IOSystem
{
public:
    CustomIOSystem(void);
    ~CustomIOSystem(void);

    bool ComparePaths (const char *one, const char *second) const;
    bool Exists(const char* pFile) const;
    char getOsSeparator(void) const;
    Assimp::IOStream *Open(const char* pFile, const char* pMode);
    void Close(Assimp::IOStream* pFile);
};


struct MeshRendererData {
    std::shared_ptr<Mesh> mesh;
    std::shared_ptr<Material> material;
};

class MeshLoader {
public:
    MeshLoader(const std::string file);

    ~MeshLoader();

    std::shared_ptr<Entity> getEntity() const;

private:
    void loadScene(const aiScene *scene);

    std::string m_fileName;

    std::shared_ptr<Entity> m_entity;

    static std::map<std::string, std::vector<MeshRendererData>> sceneMeshRendererDataCache;
};


#endif //ZELOENGINE_MESHLOADER_H