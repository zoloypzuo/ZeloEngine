// UIManager.cpp
// created on 2021/8/16
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "UIManager.h"

using namespace Zelo::Core::UI;

template<> UIManager *Singleton<UIManager>::msSingleton = nullptr;

UIManager *UIManager::getSingletonPtr() {
    return msSingleton;
}

UIManager &UIManager::getSingleton() {
    assert(msSingleton);
    return *msSingleton;
}

void UIManager::initialize() {

}

void UIManager::finalize() {

}

void UIManager::update() {

}
