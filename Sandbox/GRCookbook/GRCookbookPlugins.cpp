// GRCookbookPlugins.cpp
// created on 2021/11/30
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GRCookbookPlugins.h"

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
const GLsizeiptr kUniformBufferSize = sizeof(PerFrameData);

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
    MeshData meshData;
    header = loadMeshData(ZELO_PATH("data/meshes/test.meshes").c_str(), meshData);

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
    Zelo::Plugin::update();
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


const std::string &Ch7LargeScenePlugin::getName() const {
    static std::string s = "Ch7LargeScenePlugin";
    return s;
}

void Ch7LargeScenePlugin::install() {

}

void Ch7LargeScenePlugin::uninstall() {

}

void Ch7LargeScenePlugin::initialize() {
    Zelo::Core::Scene::SceneManager::getSingletonPtr()->clear();
    Zelo::Core::RHI::RenderSystem::getSingletonPtr()->resetRenderPipeline();

    // load avatar
    Zelo::Core::LuaScript::LuaScriptManager::getSingletonPtr()->luaCall("LoadAvatar");

    // shader
    m_meshShader = std::make_unique<GLSLShaderProgram>("mesh.glsl");
    m_meshShader->link();

    // UBO
    perFrameDataBuffer = std::make_unique<GLBuffer>(kUniformBufferSize, nullptr, GL_DYNAMIC_STORAGE_BIT);
    glBindBufferRange(GL_UNIFORM_BUFFER, 0, perFrameDataBuffer->getHandle(), 0, kUniformBufferSize);

    // mesh
    sceneData1 = std::make_unique<GLSceneData>(ZELO_PATH("data/meshes/test.meshes").c_str(),
                                               ZELO_PATH("data/meshes/test.scene").c_str(),
                                               ZELO_PATH("data/meshes/test.materials").c_str());
    sceneData2 = std::make_unique<GLSceneData>(ZELO_PATH("data/meshes/test2.meshes").c_str(),
                                               ZELO_PATH("data/meshes/test2.scene").c_str(),
                                               ZELO_PATH("data/meshes/test2.materials").c_str());

    mesh1 = std::make_unique<GLMesh2>(*sceneData1);
    mesh2 = std::make_unique<GLMesh2>(*sceneData2);

    // bind entity
    auto *scenem = Zelo::Core::Scene::SceneManager::getSingletonPtr();
    entity = scenem->CreateEntity();
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);

    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_DEPTH_TEST);
}

void Ch7LargeScenePlugin::update() {
    Zelo::Plugin::update();
}

void Ch7LargeScenePlugin::render() {
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
    mesh1->draw();
    mesh2->draw();
}
