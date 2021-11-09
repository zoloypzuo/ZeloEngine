// Mesh.h
// created on 2021/8/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

namespace Zelo::Core::RHI {
class Mesh {
public:
    virtual void render() const = 0;
};
}
