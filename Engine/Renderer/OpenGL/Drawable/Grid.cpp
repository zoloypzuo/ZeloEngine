// Grid.cpp
// created on 2021/11/29
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Grid.h"

#include "Core/Scene/SceneManager.h"

using namespace Zelo::Core::ECS;
using namespace Zelo::Core::Scene;

namespace Zelo::Renderer::OpenGL {

using glm::mat4;
using glm::vec2;
using glm::vec3;
using glm::vec4;
using glm::ivec2;

namespace {
struct PerFrameData {
    mat4 model;
    mat4 mvp;
    vec4 cameraPos;
};
const GLsizeiptr kUniformBufferSize = sizeof(PerFrameData);

GLuint perFrameDataBuffer{};

const uint32_t kBufferIndex_PerFrameUniforms = 4;
}

Grid::Grid(Entity &owner) : Component(owner) {
    glGenVertexArrays(1, &m_vao);
    m_gridShader = std::make_unique<GLSLShaderProgram>("grid.glsl");

    // perFrameDataBuffer
    glCreateBuffers(1, &perFrameDataBuffer);
    glNamedBufferStorage(perFrameDataBuffer, kUniformBufferSize, nullptr, GL_DYNAMIC_STORAGE_BIT);
    glBindBufferRange(GL_UNIFORM_BUFFER, kBufferIndex_PerFrameUniforms, perFrameDataBuffer, 0, kUniformBufferSize);
}

void Grid::render() const {
    auto *camera = SceneManager::getSingletonPtr()->getActiveCamera();

    mat4 mvp = camera->getProjectionMatrix() * camera->getViewMatrix();
    const PerFrameData perFrameData = {mat4(1.0f), mvp, vec4(0.0f)};
    glNamedBufferSubData(perFrameDataBuffer, 0, kUniformBufferSize, &perFrameData);

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glDisable(GL_CULL_FACE);
    m_gridShader->bind();
    glBindVertexArray(m_vao);
    glDrawArraysInstancedBaseInstance(GL_TRIANGLES, 0, 6, 1, 0);
    glEnable(GL_CULL_FACE);
    glDisable(GL_BLEND);
}

std::string Grid::getType() {
    return "Grid";
}
}