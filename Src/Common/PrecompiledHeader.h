// PrecompiledHeader.h
// created on 2019/10/19
// author @zoloypzuo

#ifndef ZELOENGINE_PRECOMPILEDHEADER_H
#define ZELOENGINE_PRECOMPILEDHEADER_H


#include <cassert>
#include <cstring>
#include <algorithm>

extern "C"{
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}

#pragma warning(push)
#pragma warning(disable : 4100)
#pragma warning(disable : 4127)
#include "bullet_dynamics/include/btBulletDynamicsCommon.h"
#include "bullet_collision/include/BulletCollision/CollisionShapes/btShapeHull.h"
#pragma warning(pop)

#include "detour/include/DetourNavMesh.h"
#include "detour/include/DetourNavMeshQuery.h"
#include "detour/include/DetourNavMeshBuilder.h"

#include "ogre3d/include/Ogre.h"
#include "ogre3d/include/OgreTagPoint.h"

#pragma warning(push)
#pragma warning(disable : 4512)
#include "ogre3d/include/Samples/SdkCameraMan.h"
#pragma warning(pop)

#include "ogre3d_direct3d9/include/OgreD3D9Plugin.h"
#include "ogre3d_gorilla/include/Gorilla.h"
#include "ogre3d_particlefx/include/OgreParticleFXPlugin.h"
#include "ogre3d_procedural/include/Procedural.h"

#pragma warning(push)
#pragma warning(disable : 4512)
#include "ois/include/OIS.h"
#pragma warning(pop)

#include "opensteer/include/Vec3.h"

#include "recast/include/Recast.h"

#include "zzip/include/zzip/_msvc.h"
#include "zzip/include/zzip/conf.h"
#include "zzip/include/zzip/types.h"
#include "zzip/include/zzip/zzip.h"

#endif //ZELOENGINE_PRECOMPILEDHEADER_H