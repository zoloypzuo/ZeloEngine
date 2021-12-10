// TemplatePlugin.cpp
// created on 2021/11/30
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "TemplatePlugins.h"

const std::string &TemplatePlugin::getName() const {
    static std::string s = "TemplatePlugin";
    return s;
}

void TemplatePlugin::install() {

}

void TemplatePlugin::uninstall() {

}

void TemplatePlugin::initialize() {
    Zelo::Plugin::initialize();
}

void TemplatePlugin::update() {
    Zelo::Plugin::update();
}

void TemplatePlugin::render() {
    Zelo::Plugin::render();
}
