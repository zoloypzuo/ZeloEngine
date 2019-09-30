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

#ifndef DEMO_FRAMEWORK_SANDBOX_UTILITIES_H
#define DEMO_FRAMEWORK_SANDBOX_UTILITIES_H

#include "ogre3d/include/OgrePrerequisites.h"
#include "ogre3d/include/OgreQuaternion.h"

struct InfluenceMapConfig;
struct lua_State;
struct LuaScriptType;
struct rcConfig;

class Agent;
class Collision;
class Event;
class InfluenceMap;
class NavigationMesh;
class Sandbox;
class Object;
class UserInterfaceComponent;

namespace Ogre
{
class Vector3;
}

#define SANDBOX_LUA_PACKAGE         "Sandbox"
#define SANDBOX_CLEANUP_FUNC        "Sandbox_Cleanup"
#define SANDBOX_HANDLE_EVENT_FUNC   "Sandbox_HandleEvent"
#define SANDBOX_INITIALIZE_FUNC     "Sandbox_Initialize"
#define SANDBOX_LUA_VM_NAME         "AI Sandbox VM"
#define SANDBOX_UPDATE_FUNC         "Sandbox_Update"

class SandboxUtilities
{
public:
    static void BindVMFunctions(lua_State* const luaVM);

    static void AddCollisionCallback(
        Sandbox* const sandbox,
        SandboxObject* const sandboxObject,
        lua_State* const luaVM,
        const int callbackIndex);

    static void AddEvent(Sandbox* const sandbox, const Event& event);

    static void AddEventCallback(
        Sandbox* const sandbox,
        Object* const object,
        lua_State* const luaVM,
        const int callbackIndex);

    static void CallLuaCollisionHandler(
        Sandbox* const sandbox,
        lua_State* const luaVM,
        int callbackIndex,
        Object* const objectA,
        Object* const objectB,
        const Ogre::Vector3& pointA,
        const Ogre::Vector3& pointB,
        const Ogre::Vector3& normalOnB);

    static void CallLuaEventHandler(
        Sandbox* const sandbox,
        Object* const object,
        lua_State* const luaVM,
        const int callbackIndex,
        const Event& event);

    static void CallLuaSandboxCleanup(Sandbox* const sandbox);

    static void CallLuaSandboxHandleKeyboardEvent(
        Sandbox* const sandbox, const Ogre::String& key, const bool pressed);

    static void CallLuaSandboxHandleMouseEvent(
        Sandbox* const sandbox,
        const int width,
        const int height,
        const Ogre::String button,
        const bool pressed);

    static void CallLuaSandboxHandleMouseMoveEvent(
        Sandbox* const sandbox,
        const int width,
        const int height);

    static void CallLuaSandboxInitialize(Sandbox* const sandbox);

    static void CallLuaSandboxUpdate(
        Sandbox* const sandbox, const int deltaTimeInMillis);

    static void ClearInfluenceMap(
        Sandbox* const sandbox, const size_t layer);

    static Agent* CreateAgent(
        Sandbox* const sandbox,
        const Ogre::String luaScriptFileName);

    static UserInterfaceComponent* CreateUIComponent(
        Sandbox* const sandbox, size_t layerIndex);

    static UserInterfaceComponent* CreateUIComponent3d(
        Sandbox* const sandbox, const Ogre::Vector3& position);

    static InfluenceMap* CreateInfluenceMap(
        Sandbox* const sandbox,
        const InfluenceMapConfig& config,
        const Ogre::String& navMeshName);

    static NavigationMesh* CreateNavigationMesh(
        Sandbox* const sandbox,
        rcConfig config,
        const Ogre::String& navMeshName);

    static SandboxObject* CreatePhysicsCapsule(
        Sandbox* const sandbox,
        const Ogre::Real height,
        const Ogre::Real radius);

    static SandboxObject* CreatePhysicsSphere(
        Sandbox* const sandbox,
        const Ogre::Real radius);

    static SandboxObject* CreateSandboxBox(
        Sandbox* const sandbox,
        const Ogre::Real width,
        const Ogre::Real height,
        const Ogre::Real length,
        const Ogre::Real uTile = 1.0f,
        const Ogre::Real vTile = 1.0f);

    static SandboxObject* CreateSandboxCapsule(
        Sandbox* const sandbox,
        const Ogre::Real height,
        const Ogre::Real radius);

    static SandboxObject* CreateSandboxObject(
        Sandbox* const sandbox, const Ogre::String& meshFileName);

    static SandboxObject* CreateSandboxObject(
        Sandbox* const sandbox, Ogre::SceneNode* const node);

    static SandboxObject* CreateSandboxPlane(
        Sandbox* const sandbox,
        const Ogre::Real length,
        const Ogre::Real width);

    static void CreateSkyBox(
        Sandbox* const sandbox,
        const Ogre::String materialName,
        const Ogre::Quaternion& orientation = Ogre::Quaternion::IDENTITY);

    static void DrawInfluenceMap(
        Sandbox* const sandbox,
        const size_t layer,
        const Ogre::ColourValue& positiveValue,
        const Ogre::ColourValue& zeroValue,
        const Ogre::ColourValue& negativeValue);

    static Ogre::Vector3 FindClosestPoint(
        Sandbox* const sandbox,
        const Ogre::String& navMeshName,
        const Ogre::Vector3& point);

    static void FindPath(
        Sandbox* const sandbox,
        const Ogre::String& navMeshName,
        const Ogre::Vector3& start,
        const Ogre::Vector3& end,
        std::vector<Ogre::Vector3>& outPath);

    static bool GetDrawPhysicsWorld(Sandbox* const sandbox);

    static bool GetEvent(lua_State* luaVM, const int index, Event& event);

    static float GetInertia(
        Sandbox* const sandbox,
        const size_t layer,
        const Ogre::Vector3& position);

    static long long GetProfileRenderTime(Sandbox* const sandbox);

    static long long GetProfileSimTime(Sandbox* const sandbox);

    static long long GetProfileTotalSimTime(Sandbox* const sandbox);

    static Ogre::Real GetTimeInMillis(Sandbox* const sandbox);

    static Ogre::Real GetTimeInSeconds(Sandbox* const sandbox);

    static bool IsSandbox(const LuaScriptType& type);

    static bool IsSandboxObject(const LuaScriptType& type);

    static void LoadScript(
        Sandbox* const sandbox,
        const char* const luaScriptContents,
        const size_t bufferSize,
        const char* const fileName);

    static int PushEvent(lua_State* luaVM, const Event& event);

    static int PushMarkupColor(
        lua_State* luaVM,
        const Sandbox* const sandbox,
        const int index);

    static int PushObject(lua_State* luaVM, Object* const object);

    static int PushObjectAttribute(
        lua_State* luaVM,
        Object* const object,
        const Ogre::String& attributeName,
        const int tableIndex);

    static int PushPath(
        lua_State* luaVM,
        const std::vector<Ogre::Vector3>& path);

    static int PushScreenHeight(lua_State* luaVM, const Sandbox* const sandbox);

    static int PushScreenWidth(lua_State* luaVM, const Sandbox* const sandbox);

    static Ogre::Vector3 RandomPoint(
        Sandbox* const sandbox, const Ogre::String& navMeshName);

    static bool RayCastToObject(
        Sandbox* const sandbox,
        const Ogre::Vector3& from,
        const Ogre::Vector3& to,
        Ogre::Vector3& hitPoint,
        Object*& object);

    static void RemoveSandboxObject(
        Sandbox* const sandbox, SandboxObject* object);

    static void SetAmbientLight(
        Sandbox* const sandbox, const Ogre::Vector3& ambient);

    static void SetCameraForward(
        Sandbox* const sandbox, const Ogre::Vector3& forward);

    static void SetCameraOrientation(
        Sandbox* const sandbox, const Ogre::Quaternion& rotation);

    static void SetCameraPosition(
        Sandbox* const sandbox, const Ogre::Vector3& position);

    static void SetDebugNavigationMesh(
        Sandbox* const sandbox,
        const Ogre::String& navMeshName,
        const bool debug);

    static void SetDrawInfluenceMap(
        Sandbox* const sandbox, const bool drawInfluenceMap);

    static void SetDrawPhysicsWorld(
        Sandbox* const sandbox, const bool drawPhysicsWorld);

    static void SetFalloff(
        Sandbox* const sandbox,
        const size_t layer,
        const float falloff);

    static void SetInertia(
        Sandbox* const sandbox,
        const size_t layer,
        const float inertia);

    static void SetInfluence(
        Sandbox* const sandbox,
        const size_t layer,
        const Ogre::Vector3& position,
        const float influence);

    static void SetMarkupColor(
        Sandbox* const sandbox,
        const int index,
        const Ogre::Real red,
        const Ogre::Real green,
        const Ogre::Real blue,
        const Ogre::Real alpha = 1.0f);

    static void SpreadInfluenceMap(
        Sandbox* const sandbox,
        const size_t layer);

    static void UpdateWorldTransform(SandboxObject* const sandboxObject);

private:
    SandboxUtilities();
    ~SandboxUtilities();
    SandboxUtilities(const SandboxUtilities&);
    SandboxUtilities& operator=(const SandboxUtilities&);
};

#endif  // DEMO_FRAMEWORK_SANDBOX_UTILITIES_H
