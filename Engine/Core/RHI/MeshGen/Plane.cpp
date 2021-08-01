// Plane.cpp
// created on 2021/8/1
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Plane.h"
#include "Core/RHI/Buffer/Vertex.h"

Vertex vertices[] = {
        Vertex(glm::vec3(-0.5, 0, 0.5), glm::vec2(0, 0), glm::vec3(0, 1, 0), glm::vec3(1, 0, 0)),
        Vertex(glm::vec3(0.5, 0, 0.5), glm::vec2(1, 0), glm::vec3(0, 1, 0), glm::vec3(1, 0, 0)),
        Vertex(glm::vec3(0.5, 0, -0.5), glm::vec2(1, 1), glm::vec3(0, 1, 0), glm::vec3(1, 0, 0)),
        Vertex(glm::vec3(-0.5, 0, -0.5), glm::vec2(0, 1), glm::vec3(0, 1, 0), glm::vec3(1, 0, 0))
};

unsigned int indices[] = {
        0, 1, 2,
        0, 2, 3
};

Plane::Plane() = default;

std::shared_ptr<GLMesh> Plane::getMesh() {
    return std::make_shared<GLMesh>("BUILTIN_plane", vertices, 4, indices, 6);
}