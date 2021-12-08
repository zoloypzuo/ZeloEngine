// Framebuffer.h
// created on 2021/6/3
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Core/Interface/IView.h"

namespace Zelo::Core::RHI {
class Framebuffer : public Core::Interface::IView {
    virtual void bind() = 0;

    virtual void unbind() = 0;

    virtual void resize(uint32_t width, uint32_t height) = 0;
};
}