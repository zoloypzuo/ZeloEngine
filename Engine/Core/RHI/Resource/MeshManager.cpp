// MeshManager.cpp
// created on 2021/8/1
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "MeshManager.h"

using namespace Zelo::Core::RHI;

template<> MeshManager *Singleton<MeshManager>::msSingleton = nullptr;

MeshManager *MeshManager::getSingletonPtr() {
    return msSingleton;
}
