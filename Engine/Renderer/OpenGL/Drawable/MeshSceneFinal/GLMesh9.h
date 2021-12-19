// GLMesh99.h
// created on 2021/12/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Renderer/OpenGL/Drawable/MeshScene/VtxData/MeshData.h"
#include "Renderer/OpenGL/Drawable/MeshScene/Material/Material.h"
#include "Renderer/OpenGL/Drawable/MeshSceneFinal/GLSceneDataLazy.h"

#include "GLBuffer.h"

#include <functional>

namespace Zelo::Renderer::OpenGL {

struct DrawElementsIndirectCommand {
    GLuint count_;
    GLuint instanceCount_;
    GLuint firstIndex_;
    GLuint baseVertex_;
    GLuint baseInstance_;
};

class GLIndirectBuffer final {
public:
    explicit GLIndirectBuffer(size_t maxDrawCommands);

    GLuint getHandle() const;

    void uploadIndirectBuffer();

    void selectTo(GLIndirectBuffer &buf, const std::function<bool(const DrawElementsIndirectCommand &)> &pred);

    std::vector<DrawElementsIndirectCommand> drawCommands_;

private:
    GLBuffer bufferIndirect_;
};

class GLMesh9 final {
public:
    explicit GLMesh9(const GLSceneDataLazy &data);

    void updateMaterialsBuffer(const GLSceneDataLazy &data);

    void draw(size_t numDrawCommands, const GLIndirectBuffer *buffer = nullptr) const;

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

    GLIndirectBuffer bufferIndirect_;
};
}

