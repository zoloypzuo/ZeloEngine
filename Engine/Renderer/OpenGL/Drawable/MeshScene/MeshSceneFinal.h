// MeshSceneFinalFinal.h
// created on 2021/12/18
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

#include "Core/RHI/Resource/Mesh.h"

namespace Zelo::Renderer::OpenGL {
class MeshSceneFinal : public Core::RHI::Mesh {
public:
    MeshSceneFinal(const std::string &meshFile,
                   const std::string &sceneFile,
                   const std::string &materialFile,
                   const std::string &dummyTextureFile);

    void render() override;

    ~MeshSceneFinal();

    ZELO_SCRIPT_API bool GetEnableGPUCulling() const;

    ZELO_SCRIPT_API bool GetFreezeCullingView() const;

    ZELO_SCRIPT_API bool GetDrawOpaque() const;

    ZELO_SCRIPT_API bool GetDrawTransparent() const;

    ZELO_SCRIPT_API bool GetDrawGrid() const;

    ZELO_SCRIPT_API bool GetEnableSSAO() const;

    ZELO_SCRIPT_API bool GetEnableBlur() const;

    ZELO_SCRIPT_API bool GetEnableHDR() const;

    ZELO_SCRIPT_API bool GetEnableShadows() const;

    ZELO_SCRIPT_API float GetLightTheta() const;

    ZELO_SCRIPT_API float GetLightPhi() const;

    ZELO_SCRIPT_API void SetEnableGPUCulling(bool w_);

    ZELO_SCRIPT_API void SetFreezeCullingView(bool w_);

    ZELO_SCRIPT_API void SetDrawOpaque(bool w_);

    ZELO_SCRIPT_API void SetDrawTransparent(bool w_);

    ZELO_SCRIPT_API void SetDrawGrid(bool w_);

    ZELO_SCRIPT_API void SetEnableSSAO(bool w_);

    ZELO_SCRIPT_API void SetEnableBlur(bool w_);

    ZELO_SCRIPT_API void SetEnableHDR(bool w_);

    ZELO_SCRIPT_API void SetEnableShadows(bool w_);

    ZELO_SCRIPT_API void SetLightTheta(float w_);

    ZELO_SCRIPT_API void SetLightPhi(float w_);

private:
    struct Impl;
    std::shared_ptr<Impl> pimpl{};
};
}
