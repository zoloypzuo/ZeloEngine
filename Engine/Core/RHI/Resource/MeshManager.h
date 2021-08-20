// MeshManager.h
// created on 2021/8/1
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "ZeloSingleton.h"

namespace Zelo::Core::RHI {
class MeshManager : public Singleton<MeshManager> {
public:
    static MeshManager *getSingletonPtr();
};
}
