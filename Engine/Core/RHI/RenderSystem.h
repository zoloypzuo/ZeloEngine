// RenderSystem.h
// created on 2021/8/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "ZeloSingleton.h"
#include "Core/RHI/RenderSystem.h"
#include "Core/RHI/RenderCommand.h"
#include "Core/RHI/RenderPipeline.h"
#include "Core/RHI/Object/ACamera.h"
#include "Core/RHI/Resource/MeshManager.h"
#include "Core/Interface/IView.h"

namespace Zelo::Core::RHI {
class RenderSystem :
        public Singleton<RenderSystem>,
        public IRuntimeModule,
        public RenderCommand {

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

    void setRenderPipeline(std::unique_ptr<Core::RHI::RenderPipeline> renderPipeline);

    void resetRenderPipeline();

    virtual void pushView(Core::Interface::IView *view) = 0;

    virtual void popView() = 0;

private:
    FrameInfo m_frameInfo;

protected:
    std::unique_ptr<Core::RHI::RenderPipeline> m_renderPipeline{};

    std::unique_ptr<Core::RHI::MeshManager> m_meshManager;

    uint8_t m_state{};
};
}


