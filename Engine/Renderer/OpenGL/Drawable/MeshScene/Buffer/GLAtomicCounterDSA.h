// GLAtomicCounterDSA.h
// created on 2021/12/19
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"

#include "GLBufferDSA.h"  // GLBufferDSABase

namespace Zelo::Renderer::OpenGL {
class GLAtomicCounterDSA : public GLBufferDSABase {
public:
    GLAtomicCounterDSA() : GLBufferDSABase(sizeof(uint32_t), nullptr, GL_DYNAMIC_STORAGE_BIT) {}

    GLBufferType getType() const override { return GLBufferType::ATOMIC_COUNTER_BUFFER; }



    void sendZero(){

    }
};
}
