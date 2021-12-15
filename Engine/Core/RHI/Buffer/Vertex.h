// Vertex.h
// created on 2021/8/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

namespace Zelo::Core::RHI {
ZELO_PACKED(
struct Vertex {
    glm::vec3 position{};
    glm::vec2 texCoord{};
    glm::vec3 normal{};
    glm::vec3 tangent{};

    explicit Vertex(
            const glm::vec3 &position,
            const glm::vec2 &texCoord = glm::vec2(0, 0),
            const glm::vec3 &normal = glm::vec3(0, 0, 0),
            const glm::vec3 &tangent = glm::vec3(0, 0, 0)) {
        this->position = position;
        this->texCoord = texCoord;
        this->normal = normal;
        this->tangent = tangent;
    }
};)
}
