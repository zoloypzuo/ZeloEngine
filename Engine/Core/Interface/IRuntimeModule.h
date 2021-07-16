// IRuntimeModule.h
// created on 2021/7/16
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

class IRuntimeModule {
public:
    virtual ~IRuntimeModule() = default;

    virtual void initialize() = 0;

    virtual void finalize() = 0;

    virtual void update() = 0;
};

