// CraftPlugin.h
// created on 2021/11/23
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloGLPrerequisites.h"
#include "Foundation/ZeloPlugin.h"

struct Attrib {
    GLuint program;
    GLuint position;
    GLuint normal;
    GLuint uv;
    GLuint matrix;
    GLuint sampler;
    GLuint camera;
    GLuint timer;
    GLuint extra1;
    GLuint extra2;
    GLuint extra3;
    GLuint extra4;
};

class CraftPlugin : public Plugin {
public:
    const std::string &getName() const override;;

    void install() override;

    void uninstall() override;

    void initialize() override;

    void update() override;

    void render() override;

private:
    Attrib block_attrib{};
    Attrib line_attrib{};
    Attrib text_attrib{};
    Attrib sky_attrib{};

    GLuint sky_buffer{};
};
