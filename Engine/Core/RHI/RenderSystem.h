// RenderSystem.h
// created on 2021/8/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"
#include "Core/RHI/RenderCommand.h"
#include "Core/RHI/Object/Camera.h"
#include "ZeloGLPrerequisites.h"
#include "Core/RHI/RenderSystem.h"
#include "Renderer/OpenGL/Pipeline/Renderer.h"
#include "Renderer/OpenGL/Resource/GLSLShaderProgram.h"
#include "Core/RHI/Resource/MeshManager.h"

namespace Zelo::Core::RHI {
class RenderSystem :
        public Singleton<RenderSystem>,
        IRuntimeModule,
        RenderCommand {

public:
    struct FrameInfo {
        uint64_t batchCount = 0;
        uint64_t instanceCount = 0;
        uint64_t polyCount = 0;
    };

    struct RenderState {

    };

public:
    ~RenderSystem() override;

    void initialize() override;

    void update() override;

    void finalize() override;

    static RenderSystem *getSingletonPtr();

    static RenderSystem &getSingleton();

public:
    const FrameInfo &GetFrameInfo() const;

    void ClearFrameInfo();

public:


private:
    FrameInfo m_frameInfo;

protected:

};
}


