// ImGuiManager.cpp
// created on 2021/5/28
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "ImGuiManager.h"

ImGuiManager::ImGuiManager() {

}

ImGuiManager::~ImGuiManager() {

}

void ImGuiManager::initialize() {

}

void ImGuiManager::finalize() {

}

void ImGuiManager::update() {

}

template<> ImGuiManager *Singleton<ImGuiManager>::msSingleton = nullptr;

ImGuiManager *ImGuiManager::getSingletonPtr() {
    return msSingleton;
}
