// IDrawable.h
// created on 2021/8/16
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

class IDrawable {
public:
    virtual void draw() = 0;

    virtual ~IDrawable() = default;
};