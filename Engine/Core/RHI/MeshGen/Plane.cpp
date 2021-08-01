// Plane.cpp
// created on 2021/8/1
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "Plane.h"

using namespace Zelo::Core::RHI;

std::vector<Vertex> vertices = {
        Vertex(glm::vec3(-0.5, 0, 0.5), glm::vec2(0, 0), glm::vec3(0, 1, 0), glm::vec3(1, 0, 0)),
        Vertex(glm::vec3(0.5, 0, 0.5), glm::vec2(1, 0), glm::vec3(0, 1, 0), glm::vec3(1, 0, 0)),
        Vertex(glm::vec3(0.5, 0, -0.5), glm::vec2(1, 1), glm::vec3(0, 1, 0), glm::vec3(1, 0, 0)),
        Vertex(glm::vec3(-0.5, 0, -0.5), glm::vec2(0, 1), glm::vec3(0, 1, 0), glm::vec3(1, 0, 0))
};

std::vector<uint32_t> indices = {
        0, 1, 2,
        0, 2, 3
};

Plane::Plane() = default;

const std::string &Plane::getId() {
    static const std::string meshId = "BUILTIN_plane";
    return meshId;
}

std::vector<Vertex> Plane::getVertices() {
    return vertices;
}

std::vector<uint32_t> Plane::getIndices() {
    return indices;
}

