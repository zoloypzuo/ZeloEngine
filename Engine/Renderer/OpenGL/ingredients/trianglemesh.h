#pragma once

#include <vector>

#include "cookbookogl.h"

class TriangleMesh {

protected:

    GLuint nVerts;     // Number of vertices
    GLuint vao;        // The Vertex Array Object

    // Vertex buffers
    std::vector<GLuint> buffers;

    virtual void initBuffers(
            std::vector<GLuint> *indices,
            std::vector<GLfloat> *points,
            std::vector<GLfloat> *normals,
            std::vector<GLfloat> *texCoords,
            std::vector<GLfloat> *tangents
    );

    virtual void deleteBuffers();

public:
    virtual ~TriangleMesh();

    virtual void render() const = 0;

    GLuint getVao() const { return vao; }
};
