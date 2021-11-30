// GRCookbookPlugins.cpp
// created on 2021/11/30
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GRCookbookPlugins.h"

#include "Core/Input/Input.h"
#include "Core/OS/Time.h"
#include "Core/Window/Window.h"
#include "Core/Scene/SceneManager.h"
#include "Core/RHI/RenderSystem.h"
#include "Core/LuaScript/LuaScriptManager.h"
#include "Core/Resource/ResourceManager.h"

#include "shared/UtilsMath.h"


using namespace glm;

struct PerFrameData {
    mat4 view;
    mat4 proj;
    vec4 cameraPos;
};

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

    Zelo::Core::LuaScript::LuaScriptManager::getSingletonPtr()->luaCall("LoadAvatar");

    m_meshShader = std::make_unique<GLSLShaderProgram>("mesh_inst.glsl");
    m_meshShader->link();

    // UBO
    perFrameDataBuffer = std::make_unique<GLBuffer1>(kUniformBufferSize, nullptr, GL_DYNAMIC_STORAGE_BIT);
    glBindBufferRange(GL_UNIFORM_BUFFER, 0, perFrameDataBuffer->getHandle(), 0, kUniformBufferSize);

    // init render
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_DEPTH_TEST);

    // mesh
    auto *resourcem = Zelo::Core::Resource::ResourceManager::getSingletonPtr();
    auto meshPath = resourcem->resolvePath("data/meshes/test.meshes");
    MeshData meshData;
    header = loadMeshData(meshPath.string().c_str(), meshData);

    mesh = std::make_unique<GLMesh1>(header, meshData.meshes_.data(), meshData.indexData_.data(),
                                     meshData.vertexData_.data());

    // model matrices
    auto *scenem = Zelo::Core::Scene::SceneManager::getSingletonPtr();
    entity = scenem->CreateEntity();
}

void Ch5MeshRendererPlugin::update() {
    Plugin::update();
}

void Ch5MeshRendererPlugin::render() {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    const mat4 m = entity->getWorldMatrix();
    modelMatrices = std::make_unique<GLBuffer1>(sizeof(mat4), value_ptr(m), GL_DYNAMIC_STORAGE_BIT);
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
