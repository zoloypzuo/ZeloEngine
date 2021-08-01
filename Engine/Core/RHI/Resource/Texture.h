// Texture.h
// created on 2021/6/3
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

namespace Zelo::Core::RHI {
class Texture {
public:
    virtual void bind(uint32_t slot) const = 0;
};

class Texture3D {
public:
    virtual void bind(uint32_t slot) const = 0;
};
}
