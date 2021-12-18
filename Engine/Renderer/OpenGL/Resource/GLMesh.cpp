// GLMesh.cpp
// created on 2021/3/30
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "GLMesh.h"

#include "Core/Parser/MeshLoader.h"
#include "Renderer/OpenGL/Buffer/GLBuffer.h"

using namespace Zelo::Core::RHI;
using namespace Zelo::Renderer::OpenGL;

const static BufferLayout s_BufferLayout(
        {
                BufferElement(EBufferDataType::Float3, "position"),
                BufferElement(EBufferDataType::Float2, "texCoord"),
                BufferElement(EBufferDataType::Float3, "normal"),
                BufferElement(EBufferDataType::Float3, "tangent")
        });

GLMesh::GLMesh(Vertex vertices[], size_t vertSize, uint32_t indices[],
               size_t indexSize) {

    auto vertexBuffer = std::make_shared<GLVertexBuffer>((float *) vertices, vertSize * sizeof(Vertex));
    vertexBuffer->setLayout(s_BufferLayout);
    auto indexBuffer = std::make_shared<GLIndexBuffer>(indices, indexSize);

    m_vao.addVertexBuffer(vertexBuffer);
    m_vao.setIndexBuffer(indexBuffer);
}

GLMesh::GLMesh(Zelo::Core::Interface::IMeshData &iMeshGen) :
        GLMesh(&iMeshGen.getVertices()[0],
               iMeshGen.getVertices().size(),
               &iMeshGen.getIndices()[0],
               iMeshGen.getIndices().size()) {
}

GLMesh::~GLMesh() = default;

void GLMesh::render()  {
    m_vao.bind();
    glDrawElements(GL_TRIANGLES, m_vao.getIndexBuffer()->getCount(), GL_UNSIGNED_INT, nullptr);
    m_vao.unbind();
}

