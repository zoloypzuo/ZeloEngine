// Material.h
// created on 2021/3/30
// author @zoloypzuo
#ifndef ZELOENGINE_MATERIAL_H
#define ZELOENGINE_MATERIAL_H

#include "ZeloPrerequisites.h"

namespace Zelo::Core::RHI {
class Material {
public:
    virtual ~Material();

    virtual void bind() const = 0;

    virtual bool isBlendable() const = 0;
};
}

#endif //ZELOENGINE_MATERIAL_H