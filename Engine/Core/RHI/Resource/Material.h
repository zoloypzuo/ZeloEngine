// Material.h
// created on 2021/3/30
// author @zoloypzuo
#ifndef ZELOENGINE_MATERIAL_H
#define ZELOENGINE_MATERIAL_H

#include "ZeloPrerequisites.h"
#include "Core/RHI/Resource/Shader.h"

namespace Zelo::Core::RHI {
class Material {
public:
    virtual ~Material() = default;

    virtual void bind() const = 0;

    virtual bool isBlendable() const = 0;

    virtual bool hasShader() const = 0;

    virtual void setShader(Shader *shader) = 0;
};
}

#endif //ZELOENGINE_MATERIAL_H