#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

namespace Zelo::Renderer::OpenGL {
class SkyBox {
private:
    unsigned int vaoHandle{};

public:
    SkyBox();

    void render() const;
};
}
