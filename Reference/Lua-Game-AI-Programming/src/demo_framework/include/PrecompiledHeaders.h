/**
* Copyright (c) 2013 David Young dayoung@goliathdesigns.com
*
* This software is provided 'as-is', without any express or implied
* warranty. In no event will the authors be held liable for any damages
* arising from the use of this software.
*
* Permission is granted to anyone to use this software for any purpose,
* including commercial applications, and to alter it and redistribute it
* freely, subject to the following restrictions:
*
*  1. The origin of this software must not be misrepresented; you must not
*  claim that you wrote the original software. If you use this software
*  in a product, an acknowledgment in the product documentation would be
*  appreciated but is not required.
*
*  2. Altered source versions must be plainly marked as such, and must not be
*  misrepresented as being the original software.
*
*  3. This notice may not be removed or altered from any source
*  distribution.
*/

#ifndef DEMO_FRAMEWORK_PRECOMPILED_HEADERS_H
#define DEMO_FRAMEWORK_PRECOMPILED_HEADERS_H

// STL C Headers
#include <assert.h>
#include <string.h>

// STL C++ Headers
#include <algorithm>

// C Library Headers
extern "C"
{
#include "lua/include/lauxlib.h"
#include "lua/include/lstate.h"
#include "lua/include/lua.h"
#include "lua/include/lualib.h"
};

// C++ Library Headers
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
#include "zzip/include/zzip/plugin.h"

#endif  // DEMO_FRAMEWORK_PRECOMPILED_HEADERS_H
