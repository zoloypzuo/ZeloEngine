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

#ifndef DEMO_FRAMEWORK_LUA_SCRIPT_UTILITIES_H
#define DEMO_FRAMEWORK_LUA_SCRIPT_UTILITIES_H

#include "OGRE/OgreLog.h"
#include "OGRE/OgrePrerequisites.h"

struct lua_State;

class btDiscreteDynamicsWorld;
class btRigidBody;
class Object;
class Sandbox;
class SandboxObject;

namespace Ogre
{
	class Light;
	class Quaternion;
	class SceneManager;
	class SceneNode;
}

#define LUA_SCRIPT_TYPE_METATABLE "LuaScriptType"
#define LUA_VECTOR3_METATABLE "Vector3Type"

enum RawScriptType
{
	SCRIPT_ANIMATION,
	SCRIPT_SANDBOX,
	SCRIPT_SANDBOX_OBJECT,
	SCRIPT_SCENENODE
};

static const char* const RawScriptTypeName[] =
{
	"Animation",
	"Sandbox",
	"SandboxObject",
	"SceneNode"
};

struct LuaScriptType
{
	void* rawPointer;
	RawScriptType type;
};

class LuaScriptUtilities
{
public:
	static void BindVMFunctions(lua_State* luaVM);

	static void CacheResource(const Ogre::String& resourceName);

	static bool CheckArgumentCountOrDie(
		lua_State* luaVM,
		unsigned int mandatoryArgs,
		unsigned int optionalArgs = 0);

	static Ogre::SceneNode* CreateBox(
		Ogre::SceneNode* parentNode,
		Ogre::Real width,
		Ogre::Real height,
		Ogre::Real length,
		Ogre::Real uTile = 1.0f,
		Ogre::Real vTile = 1.0f);

	static Ogre::SceneNode* CreateCapsule(
		Ogre::SceneNode* parentNode,
		Ogre::Real height,
		Ogre::Real radius);

	static Ogre::SceneNode* CreateCircle(
		Ogre::SceneNode* parentNode, Ogre::Real radius);

	static Ogre::SceneNode* CreateCylinder(
		Ogre::SceneNode* parentNode,
		Ogre::Real height,
		Ogre::Real radius);

	static Ogre::SceneNode* CreateLine(
		Ogre::SceneNode* parentNode,
		const Ogre::Vector3& start,
		const Ogre::Vector3& end);

	static Ogre::SceneNode* CreateMesh(
		Ogre::SceneNode* parentNode,
		const Ogre::String& meshFileName);

	static Ogre::SceneNode* CreatePlane(
		Ogre::SceneNode* parentNode,
		Ogre::Real length,
		Ogre::Real width);

	static lua_State* CreateVM();

	static lua_State* CreateNamedVM(const char* vmName);

	static void DestroyRigidBody(
		btDiscreteDynamicsWorld* physicsWorld,
		btRigidBody* rigidBody);

	static void DestroySceneNode(
		Ogre::SceneManager* sceneManager,
		Ogre::SceneNode* sceneNode);

	static void DestroyVM(lua_State* luaVM);

	static void DumpStack(
		lua_State* luaVM,
		Ogre::LogMessageLevel messageLevel = Ogre::LML_NORMAL);

	static void DumpStackTrace(
		lua_State* luaVM,
		Ogre::LogMessageLevel messageLevel = Ogre::LML_NORMAL);

	static Ogre::String GetCallingFunctionName(lua_State* luaVM);

	static Ogre::ColourValue GetColourValue(
		lua_State* luaVM, int stackIndex);

	static LuaScriptType* GetDataType(
		lua_State* luaVM, int stackIndex);

	static Ogre::Entity* GetEntity(
		Ogre::SceneNode& node, unsigned short index = 0);

	static Ogre::Light* GetLight(lua_State* luaVM, int stackIndex);

	static Object* GetObject(
		lua_State* luaVM, int stackIndex);

	static Ogre::Real GetRadius(Ogre::SceneNode* sceneNode);

	static Ogre::Real GetReal(lua_State* luaVM, int stackIndex);

	static Ogre::Real GetRealAttribute(
		lua_State* luaVM,
		Ogre::String attributeName,
		int tableIndex);

	static Ogre::Real GetRealAttribute(
		lua_State* luaVM,
		int index,
		int tableIndex);

	static Sandbox* GetSandbox(
		lua_State* luaVM, int stackIndex);

	static SandboxObject* GetSandboxObject(
		lua_State* luaVM, int stackIndex);

	static Ogre::SceneNode* GetSceneNode(
		lua_State* luaVM, int stackIndex);

	static Ogre::SceneNode* GetSceneNode(LuaScriptType& type);

	static Ogre::String GetString(lua_State* luaVM, int stackIndex);

	static Ogre::String GetUserdataTypeName(
		lua_State* luaVM, int stackIndex);

	static Ogre::Vector3* GetVector3(
		lua_State* luaVM, int stackIndex);

	static Ogre::Vector3* GetVector3Attribute(
		lua_State* luaVM,
		Ogre::String attributeName,
		int tableIndex);

	static bool HasAttribute(
		lua_State* luaVM,
		int tableIndex,
		const Ogre::String& attributeName);

	static bool IsObject(lua_State* luaVM, int stackIndex);

	static bool IsUserdataType(
		lua_State* luaVM,
		int stackIndex,
		Ogre::String datatype);

	static bool IsVector3(lua_State* luaVM, int stackIndex);

	static bool IsVisisble(Ogre::SceneNode* node);

	static void LoadScript(
		lua_State* luaVM,
		const char* luaScriptContents,
		size_t bufferSize,
		const char* fileName);

	static void NameVM(lua_State* luaVM, const char* vmName);

	static int PushBoolAttribute(
		lua_State* luaVM,
		bool value,
		Ogre::String attributeName,
		int tableIndex);

	static int PushColorValue(
		lua_State* luaVM, const Ogre::ColourValue& color);

	static int PushDataType(
		lua_State* luaVM,
		void* rawPointer,
		RawScriptType type);

	static int PushDataTypeAttribute(
		lua_State* luaVM,
		void* rawPointer,
		const Ogre::String& attributeName,
		RawScriptType type,
		int tableIndex);

	static int PushErrorMessageAndDie(
		lua_State* luaVM,
		const Ogre::String& message);

	static int PushInt(lua_State* luaVM, int value);

	static int PushIntAttribute(
		lua_State* luaVM,
		int value,
		Ogre::String attributeName,
		int tableIndex);

	static int PushKeyboardEvent(
		lua_State* luaVM, Ogre::String key, bool pressed);

	static int PushMouseEvent(
		lua_State* luaVM,
		int width,
		int height,
		Ogre::String button,
		bool pressed);

	static int PushMouseMoveEvent(
		lua_State* luaVM, int width, int height);

	static int PushReal(lua_State* luaVM, Ogre::Real real);

	static int PushRealAttribute(
		lua_State* luaVM,
		Ogre::Real real,
		Ogre::String attributeName,
		int tableIndex);

	static int PushString(lua_State* luaVM, Ogre::String value);

	static int PushStringAttribute(
		lua_State* luaVM,
		Ogre::String attributeValue,
		Ogre::String attributeName,
		int tableIndex);

	static int PushVector2(
		lua_State* luaVM, const Ogre::Vector2& vector);

	static int LuaScriptUtilities::PushVector2Attribute(
		lua_State* luaVM,
		const Ogre::Vector2& vector,
		Ogre::String attributeName,
		int tableIndex);

	static int PushVector3(
		lua_State* luaVM, const Ogre::Vector3& vector);

	static int PushVector3Attribute(
		lua_State* luaVM,
		const Ogre::Vector3& vector,
		Ogre::String attributeName,
		int tableIndex);

	static Ogre::Quaternion QuaternionFromRotationDegrees(
		const Ogre::Vector3& degrees);

	static Ogre::Quaternion QuaternionFromRotationDegrees(
		Ogre::Real xRotation, Ogre::Real yRotation, Ogre::Real zRotation);

	static Ogre::Vector3 QuaternionToRotationDegrees(
		const Ogre::Quaternion& quaternion);

	static void RequireLuaModule(
		lua_State* luaVM, Ogre::String luaScriptFileName);

	static void Remove(Ogre::SceneNode* node);

	static void SetLineStartEnd(
		Ogre::SceneNode* line,
		const Ogre::Vector3& start,
		const Ogre::Vector3& end);

	static void SetLightRange(Ogre::Light* light, Ogre::Real range);

private:
	LuaScriptUtilities();
	~LuaScriptUtilities();
	LuaScriptUtilities(const LuaScriptUtilities&);
	LuaScriptUtilities& operator=(const LuaScriptUtilities&);
};

#endif  // DEMO_FRAMEWORK_LUA_SCRIPT_UTILITIES_H
