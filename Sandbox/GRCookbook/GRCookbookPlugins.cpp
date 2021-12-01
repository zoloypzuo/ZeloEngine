// GRCookbookPlugins.cpp
// created on 2021/11/30
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GRCookbookPlugins.h"

#include "Core/Input/Input.h"
#include "Core/Scene/SceneManager.h"
#include "Core/Resource/ResourceManager.h"


// assimp
#include <assimp/scene.h>
#include <assimp/postprocess.h>
#include <assimp/cimport.h>

using namespace glm;

#define RES_PREFIX "deps/src/glTF-Sample-Models/2.0/DamagedHelmet/glTF/"

struct PerFrameData {
    mat4 view;
    mat4 proj;
    vec4 cameraPos;
};

static std::string ZELO_PATH(const std::string &fileName) {
    auto *resourcem = Zelo::Core::Resource::ResourceManager::getSingletonPtr();
    return resourcem->resolvePath(fileName).string();
}

const std::string &Ch5MeshRendererPlugin::getName() const {
    static std::string s = "Ch5MeshRendererPlugin";
    return s;
}

void Ch5MeshRendererPlugin::install() {

}

void Ch5MeshRendererPlugin::uninstall() {

}

const GLsizeiptr kUniformBufferSize = sizeof(PerFrameData);

void Ch5MeshRendererPlugin::initialize() {
    Zelo::Core::Scene::SceneManager::getSingletonPtr()->clear();
    Zelo::Core::RHI::RenderSystem::getSingletonPtr()->resetRenderPipeline();

    // load avatar
    Zelo::Core::LuaScript::LuaScriptManager::getSingletonPtr()->luaCall("LoadAvatar");

    // shader
    m_meshShader = std::make_unique<GLSLShaderProgram>("mesh_inst.glsl");
    m_meshShader->link();

    // UBO
    perFrameDataBuffer = std::make_unique<GLBuffer>(kUniformBufferSize, nullptr, GL_DYNAMIC_STORAGE_BIT);
    glBindBufferRange(GL_UNIFORM_BUFFER, 0, perFrameDataBuffer->getHandle(), 0, kUniformBufferSize);

    // mesh
    auto *resourcem = Zelo::Core::Resource::ResourceManager::getSingletonPtr();
    auto meshPath = resourcem->resolvePath("data/meshes/test.meshes");
    MeshData meshData;
    header = loadMeshData(meshPath.string().c_str(), meshData);

    mesh = std::make_unique<GLMesh1>(header, meshData.meshes_.data(), meshData.indexData_.data(),
                                     meshData.vertexData_.data());

    // bind entity
    auto *scenem = Zelo::Core::Scene::SceneManager::getSingletonPtr();
    entity = scenem->CreateEntity();

    // init render
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_DEPTH_TEST);
}

void Ch5MeshRendererPlugin::update() {
    Plugin::update();
}

void Ch5MeshRendererPlugin::render() {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    const mat4 m = entity->getWorldMatrix();
    modelMatrices = std::make_unique<GLBuffer>(sizeof(mat4), value_ptr(m), GL_DYNAMIC_STORAGE_BIT);
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 2, modelMatrices->getHandle());

    auto *camera = Zelo::Core::Scene::SceneManager::getSingletonPtr()->getActiveCamera();
    if (!camera) { return; }
    const mat4 p = camera->getProjectionMatrix();
    const mat4 view = camera->getViewMatrix();
    const vec3 viewPos = camera->getOwner()->getPosition();

    const PerFrameData perFrameData = {view, p, glm::vec4(viewPos, 1.0f)};
    glNamedBufferSubData(perFrameDataBuffer->getHandle(), 0, kUniformBufferSize, &perFrameData);

    glEnable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
    m_meshShader->bind();
    mesh->draw(header);
}

const std::string &Ch6PBRPlugin::getName() const {
    static std::string s = "Ch6PBRPlugin";
    return s;
}

void Ch6PBRPlugin::install() {

}

void Ch6PBRPlugin::uninstall() {

}

void Ch6PBRPlugin::initialize() {

    Zelo::Core::Scene::SceneManager::getSingletonPtr()->clear();
    Zelo::Core::RHI::RenderSystem::getSingletonPtr()->resetRenderPipeline();

    // load avatar
    Zelo::Core::LuaScript::LuaScriptManager::getSingletonPtr()->luaCall("LoadAvatar");

    // shader
    m_meshShader = std::make_unique<GLSLShaderProgram>("pbr.glsl");
    m_meshShader->link();

    // UBO
    perFrameDataBuffer = std::make_unique<GLBuffer>(kUniformBufferSize, nullptr, GL_DYNAMIC_STORAGE_BIT);
    glBindBufferRange(GL_UNIFORM_BUFFER, 0, perFrameDataBuffer->getHandle(), 0, kUniformBufferSize);

    // mesh
    loadMesh(ZELO_PATH(RES_PREFIX "DamagedHelmet.gltf"));

    // tex
    loadTex();

    // bind entity
    auto *scenem = Zelo::Core::Scene::SceneManager::getSingletonPtr();
    entity = scenem->CreateEntity();

    // set transform
    entity->getTransform().setScale(vec3(3.0f));
    entity->getTransform().setRotation(vec3(1.0f, 0.0f, 0.0f), glm::radians(90.0f));

    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_DEPTH_TEST);
}


void Ch6PBRPlugin::loadMesh(const std::string &meshPath) {
    const aiScene *scene = aiImportFile(meshPath.c_str(), aiProcess_Triangulate);

    ZELO_ASSERT(scene && scene->HasMeshes());

    struct VertexData {
        vec3 pos;
        vec3 n;
        vec2 tc;
    };

    std::vector<VertexData> vertices;
    std::vector<uint32_t> indices;
    {
        const aiMesh *pAiMesh = scene->mMeshes[0];
        for (unsigned i = 0; i != pAiMesh->mNumVertices; i++) {
            const aiVector3D v = pAiMesh->mVertices[i];
            const aiVector3D n = pAiMesh->mNormals[i];
            const aiVector3D t = pAiMesh->mTextureCoords[0][i];
            vertices.push_back({vec3(v.x, v.y, v.z), vec3(n.x, n.y, n.z), vec2(t.x, 1.0f - t.y)});
        }
        for (unsigned i = 0; i != pAiMesh->mNumFaces; i++) {
            for (unsigned j = 0; j != 3; j++)
                indices.push_back(pAiMesh->mFaces[i].mIndices[j]);
        }
        aiReleaseImport(scene);
    }

    const size_t kSizeIndices = sizeof(uint32_t) * indices.size();
    const size_t kSizeVertices = sizeof(VertexData) * vertices.size();

    mesh = std::make_unique<GLMeshPVP>(indices.data(), (uint32_t) kSizeIndices,
                                       (float *) vertices.data(), (uint32_t) kSizeVertices);
}

void Ch6PBRPlugin::update() {
    Plugin::update();
}

void Ch6PBRPlugin::render() {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    const mat4 m = entity->getWorldMatrix();
    modelMatrices = std::make_unique<GLBuffer>(sizeof(mat4), value_ptr(m), GL_DYNAMIC_STORAGE_BIT);
    glBindBufferBase(GL_SHADER_STORAGE_BUFFER, 2, modelMatrices->getHandle());

    auto *camera = Zelo::Core::Scene::SceneManager::getSingletonPtr()->getActiveCamera();
    if (!camera) { return; }
    const mat4 p = camera->getProjectionMatrix();
    const mat4 view = camera->getViewMatrix();
    const vec3 viewPos = camera->getOwner()->getPosition();

    const PerFrameData perFrameData = {view, p, glm::vec4(viewPos, 1.0f)};
    glNamedBufferSubData(perFrameDataBuffer->getHandle(), 0, kUniformBufferSize, &perFrameData);

    glEnable(GL_DEPTH_TEST);
    glDisable(GL_BLEND);
    m_meshShader->bind();
    mesh->draw();
}

void Ch6PBRPlugin::loadTex() {
    texAO = std::make_unique<GLTexture>(GL_TEXTURE_2D, ZELO_PATH(RES_PREFIX "Default_AO.jpg").c_str());
    texEmissive = std::make_unique<GLTexture>(GL_TEXTURE_2D, ZELO_PATH(RES_PREFIX "Default_emissive.jpg").c_str());
    texAlbedo = std::make_unique<GLTexture>(GL_TEXTURE_2D, ZELO_PATH(RES_PREFIX "Default_albedo.jpg").c_str());
    texMeR = std::make_unique<GLTexture>(GL_TEXTURE_2D, ZELO_PATH(RES_PREFIX "Default_metalRoughness.jpg").c_str());
    texNormal = std::make_unique<GLTexture>(GL_TEXTURE_2D, ZELO_PATH(RES_PREFIX "Default_normal.jpg").c_str());

    const GLuint textures[] = {texAO->getHandle(),
                               texEmissive->getHandle(),
                               texAlbedo->getHandle(),
                               texMeR->getHandle(),
                               texNormal->getHandle()};
    glBindTextures(0, sizeof(textures) / sizeof(GLuint), textures);

    // cube map
    envMap = std::make_unique<GLTexture>(GL_TEXTURE_CUBE_MAP, ZELO_PATH("data/piazza_bologni_1k.hdr").c_str());
    envMapIrradiance = std::make_unique<GLTexture>(GL_TEXTURE_CUBE_MAP,
                                                   ZELO_PATH("data/piazza_bologni_1k_irradiance.hdr").c_str());
    const GLuint envMaps[] = {envMap->getHandle(), envMapIrradiance->getHandle()};
    glBindTextures(5, 2, envMaps);

    // BRDF LUT
    brdfLUT = std::make_unique<GLTexture>(GL_TEXTURE_2D, ZELO_PATH("data/brdfLUT.ktx").c_str());
    glBindTextureUnit(7, brdfLUT->getHandle());
}