// Plugin.h
// created on 2021/4/10
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"

class Plugin {
public:
    Plugin() = default;;

    virtual ~Plugin() = default;;

    virtual const std::string &getName() const = 0;

    virtual void install() = 0;

    virtual void uninstall() = 0;

    // engine hooks
    virtual void initialize() {};

    virtual void finalize() { uninstall(); };

    virtual void update() {};

    virtual void render() {};
};
