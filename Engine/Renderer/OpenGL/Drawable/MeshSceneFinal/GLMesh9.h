// GLMesh99.h
// created on 2021/12/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Buffer/GLIndirectCommandBufferDSA.h"
#include "Renderer/OpenGL/Drawable/MeshScene/VtxData/MeshData.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Material/Material.h"
#include "Renderer/OpenGL/Drawable/MeshSceneFinal/GLSceneDataLazy.h"

#include "GLBuffer.h"

#include <functional>

namespace Zelo::Renderer::OpenGL {

class GLMesh9 final {
public:
    explicit GLMesh9(const GLSceneDataLazy &data);

    void updateMaterialsBuffer(const GLSceneDataLazy &data);

    void draw(const GLIndirectCommandBufferDSA &buffer) const;

    ~GLMesh9();

    GLMesh9(const GLMesh9 &) = delete;

    GLMesh9(GLMesh9 &&) noexcept = default;

//private:
    GLuint vao_;
    uint32_t numIndices_;

    GLBuffer bufferIndices_;
    GLBuffer bufferVertices_;
    GLBuffer bufferMaterials_;
    GLBuffer bufferModelMatrices_;

    GLIndirectCommandBufferDSA bufferIndirect_;
};
}

