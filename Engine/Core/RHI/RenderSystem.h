// RenderSystem.h
// created on 2021/8/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"

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

private:
    FrameInfo m_frameInfo;
};
}


