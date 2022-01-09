// IDrawable.h
// created on 2022/1/10
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

namespace Zelo::Core::RHI {
class IDrawable {
public:
    virtual ~IDrawable() = default;

    virtual void render() const = 0;
};
}
