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

#include "OGRE/OgrePrerequisites.h"
#include "OGRE/OgreQuaternion.h"

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
	static void BindVMFunctions(lua_State* luaVM);

	static void AddCollisionCallback(
		Sandbox* sandbox,
		SandboxObject* sandboxObject,
		lua_State* luaVM,
		int callbackIndex);

	static void AddEvent(Sandbox* sandbox, const Event& event);

	static void AddEventCallback(
		Sandbox* sandbox,
		Object* object,
		lua_State* luaVM,
		int callbackIndex);

	static void CallLuaCollisionHandler(
		Sandbox* sandbox,
		lua_State* luaVM,
		int callbackIndex,
		Object* objectA,
		Object* objectB,
		const Ogre::Vector3& pointA,
		const Ogre::Vector3& pointB,
		const Ogre::Vector3& normalOnB);

	static void CallLuaEventHandler(
		Sandbox* sandbox,
		Object* object,
		lua_State* luaVM,
		int callbackIndex,
		const Event& event);

	static void CallLuaSandboxCleanup(Sandbox* sandbox);

	static void CallLuaSandboxHandleKeyboardEvent(
		Sandbox* sandbox, const Ogre::String& key, bool pressed);

	static void CallLuaSandboxHandleMouseEvent(
		Sandbox* sandbox,
		int width,
		int height,
		Ogre::String button,
		bool pressed);

	static void CallLuaSandboxHandleMouseMoveEvent(
		Sandbox* sandbox,
		int width,
		int height);

	static void CallLuaSandboxInitialize(Sandbox* sandbox);

	static void CallLuaSandboxUpdate(
		Sandbox* sandbox, int deltaTimeInMillis);

	static void ClearInfluenceMap(
		Sandbox* sandbox, size_t layer);

	static Agent* CreateAgent(
		Sandbox* sandbox,
		Ogre::String luaScriptFileName);

	static UserInterfaceComponent* CreateUIComponent(
		Sandbox* sandbox, size_t layerIndex);

	static UserInterfaceComponent* CreateUIComponent3d(
		Sandbox* sandbox, const Ogre::Vector3& position);

	static InfluenceMap* CreateInfluenceMap(
		Sandbox* sandbox,
		const InfluenceMapConfig& config,
		const Ogre::String& navMeshName);

	static NavigationMesh* CreateNavigationMesh(
		Sandbox* sandbox,
		rcConfig config,
		const Ogre::String& navMeshName);

	static SandboxObject* CreatePhysicsCapsule(
		Sandbox* sandbox,
		Ogre::Real height,
		Ogre::Real radius);

	static SandboxObject* CreatePhysicsSphere(
		Sandbox* sandbox,
		Ogre::Real radius);

	static SandboxObject* CreateSandboxBox(
		Sandbox* sandbox,
		Ogre::Real width,
		Ogre::Real height,
		Ogre::Real length,
		Ogre::Real uTile = 1.0f,
		Ogre::Real vTile = 1.0f);

	static SandboxObject* CreateSandboxCapsule(
		Sandbox* sandbox,
		Ogre::Real height,
		Ogre::Real radius);

	static SandboxObject* CreateSandboxObject(
		Sandbox* sandbox, const Ogre::String& meshFileName);

	static SandboxObject* CreateSandboxObject(
		Sandbox* sandbox, Ogre::SceneNode* node);

	static SandboxObject* CreateSandboxPlane(
		Sandbox* sandbox,
		Ogre::Real length,
		Ogre::Real width);

	static void CreateSkyBox(
		Sandbox* sandbox,
		Ogre::String materialName,
		const Ogre::Quaternion& orientation = Ogre::Quaternion::IDENTITY);

	static void DrawInfluenceMap(
		Sandbox* sandbox,
		size_t layer,
		const Ogre::ColourValue& positiveValue,
		const Ogre::ColourValue& zeroValue,
		const Ogre::ColourValue& negativeValue);

	static Ogre::Vector3 FindClosestPoint(
		Sandbox* sandbox,
		const Ogre::String& navMeshName,
		const Ogre::Vector3& point);

	static void FindPath(
		Sandbox* sandbox,
		const Ogre::String& navMeshName,
		const Ogre::Vector3& start,
		const Ogre::Vector3& end,
		std::vector<Ogre::Vector3>& outPath);

	static bool GetDrawPhysicsWorld(Sandbox* sandbox);

	static bool GetEvent(lua_State* luaVM, int index, Event& event);

	static float GetInertia(
		Sandbox* sandbox,
		size_t layer,
		const Ogre::Vector3& position);

	static long long GetProfileRenderTime(Sandbox* sandbox);

	static long long GetProfileSimTime(Sandbox* sandbox);

	static long long GetProfileTotalSimTime(Sandbox* sandbox);

	static Ogre::Real GetTimeInMillis(Sandbox* sandbox);

	static Ogre::Real GetTimeInSeconds(Sandbox* sandbox);

	static bool IsSandbox(const LuaScriptType& type);

	static bool IsSandboxObject(const LuaScriptType& type);

	static void LoadScript(
		Sandbox* sandbox,
		const char* luaScriptContents,
		size_t bufferSize,
		const char* fileName);

	static int PushEvent(lua_State* luaVM, const Event& event);

	static int PushMarkupColor(
		lua_State* luaVM,
		const Sandbox* sandbox,
		int index);

	static int PushObject(lua_State* luaVM, Object* object);

	static int PushObjectAttribute(
		lua_State* luaVM,
		Object* object,
		const Ogre::String& attributeName,
		int tableIndex);

	static int PushPath(
		lua_State* luaVM,
		const std::vector<Ogre::Vector3>& path);

	static int PushScreenHeight(lua_State* luaVM, const Sandbox* sandbox);

	static int PushScreenWidth(lua_State* luaVM, const Sandbox* sandbox);

	static Ogre::Vector3 RandomPoint(
		Sandbox* sandbox, const Ogre::String& navMeshName);

	static bool RayCastToObject(
		Sandbox* sandbox,
		const Ogre::Vector3& from,
		const Ogre::Vector3& to,
		Ogre::Vector3& hitPoint,
		Object*& object);

	static void RemoveSandboxObject(
		Sandbox* sandbox, SandboxObject* object);

	static void SetAmbientLight(
		Sandbox* sandbox, const Ogre::Vector3& ambient);

	static void SetCameraForward(
		Sandbox* sandbox, const Ogre::Vector3& forward);

	static void SetCameraOrientation(
		Sandbox* sandbox, const Ogre::Quaternion& rotation);

	static void SetCameraPosition(
		Sandbox* sandbox, const Ogre::Vector3& position);

	static void SetDebugNavigationMesh(
		Sandbox* sandbox,
		const Ogre::String& navMeshName,
		bool debug);

	static void SetDrawInfluenceMap(
		Sandbox* sandbox, bool drawInfluenceMap);

	static void SetDrawPhysicsWorld(
		Sandbox* sandbox, bool drawPhysicsWorld);

	static void SetFalloff(
		Sandbox* sandbox,
		size_t layer,
		float falloff);

	static void SetInertia(
		Sandbox* sandbox,
		size_t layer,
		float inertia);

	static void SetInfluence(
		Sandbox* sandbox,
		size_t layer,
		const Ogre::Vector3& position,
		float influence);

	static void SetMarkupColor(
		Sandbox* sandbox,
		int index,
		Ogre::Real red,
		Ogre::Real green,
		Ogre::Real blue,
		Ogre::Real alpha = 1.0f);

	static void SpreadInfluenceMap(
		Sandbox* sandbox,
		size_t layer);

	static void UpdateWorldTransform(SandboxObject* sandboxObject);

private:
	SandboxUtilities();
	~SandboxUtilities();
	SandboxUtilities(const SandboxUtilities&);
	SandboxUtilities& operator=(const SandboxUtilities&);
};

#endif  // DEMO_FRAMEWORK_SANDBOX_UTILITIES_H
