// PostEffectPlugin.h
// created on 2021/11/21
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Core/Plugin/Plugin.h"

class PostEffectPlugin : public Plugin {
public:
    const std::string &getName() const override;;

    void install() override;

    void initialise() override;

    void shutdown() override;

    void uninstall() override;
};

