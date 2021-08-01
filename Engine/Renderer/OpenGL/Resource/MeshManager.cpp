//
// Created by zuoyiping01 on 2021/4/1.
//

#include "MeshManager.h"

template<> MeshManager *Singleton<MeshManager>::msSingleton = nullptr;

MeshManager *MeshManager::getSingletonPtr() {
    return msSingleton;
}
