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

#include "PrecompiledHeaders.h"

#include "demo_framework/include/Agent.h"
#include "demo_framework/include/AgentUtilities.h"
#include "demo_framework/include/Collision.h"
#include "demo_framework/include/Event.h"
#include "demo_framework/include/InfluenceMap.h"
#include "demo_framework/include/LuaFileManager.h"
#include "demo_framework/include/LuaFilePtr.h"
#include "demo_framework/include/LuaScriptBindings.h"
#include "demo_framework/include/LuaScriptUtilities.h"
#include "demo_framework/include/NavigationMesh.h"
#include "demo_framework/include/PhysicsUtilities.h"
#include "demo_framework/include/Sandbox.h"
#include "demo_framework/include/SandboxObject.h"
#include "demo_framework/include/SandboxUtilities.h"

namespace
{
	const luaL_Reg SandboxFunctions[] =
	{
		{"AddCollisionCallback", Lua_Script_SandboxAddCollisionCallback},
		{"AddEvent", Lua_Script_SandboxAddEvent},
		{"AddEventCallback", Lua_Script_SandboxAddEventCallback},
		{"ClearInfluenceMap", Lua_Script_SandboxClearInfluenceMap},
		{"CreateAgent", Lua_Script_SandboxCreateAgent},
		{"CreateBox", Lua_Script_SandboxCreateBox},
		{"CreateCapsule", Lua_Script_SandboxCreateCapsule},
		{"CreateInfluenceMap", Lua_Script_SandboxCreateInfluenceMap},
		{"CreateNavigationMesh", Lua_Script_SandboxCreateNavigationMesh},
		{"CreateObject", Lua_Script_SandboxCreateObject},
		{"CreatePhysicsCapsule", Lua_Script_SandboxCreatePhysicsCapsule},
		{"CreatePhysicsSphere", Lua_Script_SandboxCreatePhysicsSphere},
		{"CreatePlane", Lua_Script_SandboxCreatePlane},
		{"CreateSkyBox", Lua_Script_SandboxCreateSkyBox},
		{"CreateUIComponent", Lua_Script_SandboxCreateUIComponent},
		{"CreateUIComponent3d", Lua_Script_SandboxCreateUIComponent3d},
		{"DrawInfluenceMap", Lua_Script_SandboxDrawInfluenceMap},
		{"FindClosestPoint", Lua_Script_SandboxFindClosestPoint},
		{"FindPath", Lua_Script_SandboxFindPath},
		{"GetAgents", Lua_Script_SandboxGetAgents},
		{"GetCameraForward", Lua_Script_SandboxGetCameraForward},
		{"GetCameraLeft", Lua_Script_SandboxGetCameraLeft},
		{"GetCameraOrientation", Lua_Script_SandboxGetCameraOrientation},
		{"GetCameraPosition", Lua_Script_SandboxGetCameraPosition},
		{"GetCameraUp", Lua_Script_SandboxGetCameraUp},
		{"GetDrawPhysicsWorld", Lua_Script_SandboxGetDrawPhysicsWorld},
		{"GetInertia", Lua_Script_SandboxGetInertia},
		{"GetMarkupColor", Lua_Script_SandboxGetMarkupColor},
		{"GetObjects", Lua_Script_SandboxGetObjects},
		{"GetRenderTime", Lua_Script_SandboxGetProfileRenderTime},
		{"GetSimulationTime", Lua_Script_SandboxGetProfileSimTime},
		{"GetTotalSimulationTime", Lua_Script_SandboxGetProfileTotalSimTime},
		{"GetScreenHeight", Lua_Script_SandboxGetScreenHeight},
		{"GetScreenWidth", Lua_Script_SandboxGetScreenWidth},
		{"GetTimeInSeconds", Lua_Script_SandboxGetTimeInSeconds},
		{"GetTimeInMillis", Lua_Script_SandboxGetTimeInMillis},
		{"RandomPoint", Lua_Script_SandboxRandomPoint},
		{"RayCastToObject", Lua_Script_SandboxRayCastToObject},
		{"RemoveObject", Lua_Script_SandboxRemoveObject},
		{"SetAmbientLight", Lua_Script_SandboxSetAmbientLight},
		{"SetCameraForward", Lua_Script_SandboxSetCameraForward},
		{"SetCameraOrientation", Lua_Script_SandboxSetCameraOrientation},
		{"SetCameraPosition", Lua_Script_SandboxSetCameraPosition},
		{"SetDebugNavigationMesh", Lua_Script_SandboxSetDebugNavigationMesh},
		{"SetDrawInfluenceMap", Lua_Script_SandboxSetDrawInfluenceMap},
		{"SetDrawPhysicsWorld", Lua_Script_SandboxSetDrawPhysicsWorld},
		{"SetFalloff", Lua_Script_SandboxSetFalloff},
		{"SetInertia", Lua_Script_SandboxSetInertia},
		{"SetInfluence", Lua_Script_SandboxSetInfluence},
		{"SetMarkupColor", Lua_Script_SandboxSetMarkupColor},
		{"SpreadInfluenceMap", Lua_Script_SandboxSpreadInfluenceMap},
		{nullptr, nullptr}
	};
} // anonymous namespace

void SandboxUtilities::BindVMFunctions(lua_State* const luaVM)
{
	luaL_register(luaVM, SANDBOX_LUA_PACKAGE, SandboxFunctions);
}

void SandboxUtilities::AddCollisionCallback(
	Sandbox* const sandbox,
	SandboxObject* const sandboxObject,
	lua_State* const luaVM,
	const int functionIndex)
{
	sandbox->AddSandboxObjectCollisionCallback(
		sandboxObject, luaVM, functionIndex);
}

void SandboxUtilities::AddEvent(Sandbox* const sandbox, const Event& event)
{
	sandbox->AddEvent(event);
}

void SandboxUtilities::AddEventCallback(
	Sandbox* const sandbox,
	Object* const object,
	lua_State* const luaVM,
	const int callbackIndex)
{
	sandbox->AddObjectEventCallback(object, luaVM, callbackIndex);
}

void SandboxUtilities::CallLuaCollisionHandler(
	Sandbox* const sandbox,
	lua_State* const luaVM,
	int callbackIndex,
	Object* const objectA,
	Object* const objectB,
	const Ogre::Vector3& pointA,
	const Ogre::Vector3& pointB,
	const Ogre::Vector3& normalOnB)
{
	lua_rawgeti(luaVM, LUA_REGISTRYINDEX, callbackIndex);

	if (lua_isfunction(luaVM, -1))
	{
		LuaScriptUtilities::PushDataType(luaVM, sandbox, SCRIPT_SANDBOX);
		lua_newtable(luaVM);
		const int tableIndex = lua_gettop(luaVM);

		assert(objectA);

		PushObjectAttribute(luaVM, objectA, "objectA", tableIndex);
		PushObjectAttribute(luaVM, objectB, "objectB", tableIndex);

		LuaScriptUtilities::PushVector3Attribute(
			luaVM, pointA, "pointA", tableIndex);

		LuaScriptUtilities::PushVector3Attribute(
			luaVM, pointB, "pointB", tableIndex);

		LuaScriptUtilities::PushVector3Attribute(
			luaVM, normalOnB, "normalOnB", tableIndex);

		if (lua_pcall(luaVM, 2, 0, 0) != 0)
		{
			assert(false);
		}
	}
	else
	{
		lua_pop(luaVM, 1);
	}
}

void SandboxUtilities::CallLuaEventHandler(
	Sandbox* const sandbox,
	Object* const object,
	lua_State* const luaVM,
	const int callbackIndex,
	const Event& event)
{
	lua_rawgeti(luaVM, LUA_REGISTRYINDEX, callbackIndex);

	if (lua_isfunction(luaVM, -1))
	{
		LuaScriptUtilities::PushDataType(luaVM, sandbox, SCRIPT_SANDBOX);
		PushObject(luaVM, object);
		LuaScriptUtilities::PushString(luaVM, event.GetEventType());
		PushEvent(luaVM, event);

		if (lua_pcall(luaVM, 4, 0, 0) != 0)
		{
			assert(false);
		}
	}
	else
	{
		lua_pop(luaVM, 1);
	}
}

void SandboxUtilities::CallLuaSandboxCleanup(Sandbox* const sandbox)
{
	lua_State* const luaVM = sandbox->GetLuaVM();

	lua_getglobal(luaVM, SANDBOX_CLEANUP_FUNC);

	if (lua_isfunction(luaVM, -1))
	{
		LuaScriptUtilities::PushDataType(luaVM, sandbox, SCRIPT_SANDBOX);

		if (lua_pcall(luaVM, 1, 0, 0) != 0)
		{
			assert(false);
		}
	}
	else
	{
		lua_pop(luaVM, 1);
	}
}

void SandboxUtilities::CallLuaSandboxHandleKeyboardEvent(
	Sandbox* const sandbox, const Ogre::String& key, const bool pressed)
{
	lua_State* const luaVM = sandbox->GetLuaVM();

	lua_getglobal(luaVM, SANDBOX_HANDLE_EVENT_FUNC);

	if (lua_isfunction(luaVM, -1))
	{
		LuaScriptUtilities::PushDataType(luaVM, sandbox, SCRIPT_SANDBOX);
		LuaScriptUtilities::PushKeyboardEvent(luaVM, key, pressed);

		if (lua_pcall(luaVM, 2, 0, 0) != 0)
		{
			Ogre::LogManager::getSingletonPtr()->logMessage(
				Ogre::String(lua_tostring(luaVM, -1)), Ogre::LML_CRITICAL);
			assert(false);
		}
	}
	else
	{
		lua_pop(luaVM, 1);
	}
}

void SandboxUtilities::CallLuaSandboxHandleMouseEvent(
	Sandbox* const sandbox,
	const int width,
	const int height,
	const Ogre::String button,
	const bool pressed)
{
	lua_State* const luaVM = sandbox->GetLuaVM();

	lua_getglobal(luaVM, SANDBOX_HANDLE_EVENT_FUNC);

	if (lua_isfunction(luaVM, -1))
	{
		LuaScriptUtilities::PushDataType(luaVM, sandbox, SCRIPT_SANDBOX);
		LuaScriptUtilities::PushMouseEvent(
			luaVM, width, height, button, pressed);

		if (lua_pcall(luaVM, 2, 0, 0) != 0)
		{
			assert(false);
		}
	}
	else
	{
		lua_pop(luaVM, 1);
	}
}

void SandboxUtilities::CallLuaSandboxHandleMouseMoveEvent(
	Sandbox* const sandbox, const int width, const int height)
{
	lua_State* const luaVM = sandbox->GetLuaVM();

	lua_getglobal(luaVM, SANDBOX_HANDLE_EVENT_FUNC);

	if (lua_isfunction(luaVM, -1))
	{
		LuaScriptUtilities::PushDataType(luaVM, sandbox, SCRIPT_SANDBOX);
		LuaScriptUtilities::PushMouseMoveEvent(luaVM, width, height);

		if (lua_pcall(luaVM, 2, 0, 0) != 0)
		{
			assert(false);
		}
	}
	else
	{
		lua_pop(luaVM, 1);
	}
}

void SandboxUtilities::CallLuaSandboxInitialize(Sandbox* const sandbox)
{
	lua_State* luaVM = sandbox->GetLuaVM();

	lua_getglobal(luaVM, SANDBOX_INITIALIZE_FUNC);

	if (lua_isfunction(luaVM, -1))
	{
		LuaScriptUtilities::PushDataType(luaVM, sandbox, SCRIPT_SANDBOX);

		if (lua_pcall(luaVM, 1, 0, 0) != 0)
		{
			// Lua error.
			assert(false);
		}
	}
	else
	{
		lua_pop(luaVM, 1);
	}
}

void SandboxUtilities::CallLuaSandboxUpdate(
	Sandbox* const sandbox, const int deltaTimeInMillis)
{
	lua_State* luaVM = sandbox->GetLuaVM();

	lua_getglobal(luaVM, SANDBOX_UPDATE_FUNC);

	if (lua_isfunction(luaVM, -1))
	{
		LuaScriptUtilities::PushDataType(luaVM, sandbox, SCRIPT_SANDBOX);
		lua_pushinteger(luaVM, deltaTimeInMillis);

		if (lua_pcall(luaVM, 2, 0, 0) != 0)
		{
			assert(false);
		}
	}
	else
	{
		lua_pop(luaVM, 1);
	}
}

void SandboxUtilities::ClearInfluenceMap(
	Sandbox* const sandbox, const size_t layer)
{
	sandbox->GetInfluenceMap()->ClearInfluence(layer);
}

Agent* SandboxUtilities::CreateAgent(
	Sandbox* const sandbox, const Ogre::String luaScriptFileName)
{
	LuaFileManager* const fileManager = LuaFileManager::getSingletonPtr();

	const LuaFilePtr script = fileManager->load(
		luaScriptFileName,
		Ogre::ResourceGroupManager::DEFAULT_RESOURCE_GROUP_NAME);

	Ogre::LogManager::getSingletonPtr()->logMessage(
		"Sandbox Agent: Creating agent \"" + luaScriptFileName + "\"",
		Ogre::LML_NORMAL);

	Agent* const agent = new Agent(
		sandbox->GenerateAgentId(),
		sandbox->GetRootNode()->createChildSceneNode(),
		nullptr);

	agent->LoadScript(
		script->GetData(), script->GetDataLength(), script->getName().c_str());

	agent->SetSandbox(sandbox);

	sandbox->AddAgent(agent);

	Ogre::LogManager::getSingletonPtr()->logMessage(
		"Sandbox Agent: Finished creating agent \"" + luaScriptFileName + "\"",
		Ogre::LML_NORMAL);

	return agent;
}

UserInterfaceComponent* SandboxUtilities::CreateUIComponent(
	Sandbox* const sandbox, size_t layerIndex)
{
	return sandbox->CreateUIComponent(layerIndex);
}

UserInterfaceComponent* SandboxUtilities::CreateUIComponent3d(
	Sandbox* const sandbox, const Ogre::Vector3& position)
{
	return sandbox->CreateUIComponent3d(position);
}

InfluenceMap* SandboxUtilities::CreateInfluenceMap(
	Sandbox* const sandbox,
	const InfluenceMapConfig& config,
	const Ogre::String& navMeshName)
{
	NavigationMesh* const mesh = sandbox->GetNavigationMesh(navMeshName);

	if (mesh)
	{
		Ogre::Timer timer;
		const unsigned long startTime = timer.getMilliseconds();

		sandbox->SetInfluenceMap(
			new InfluenceMap(config, *mesh->GetDebugMesh()));

		const unsigned long endTime = timer.getMilliseconds();

		Ogre::LogManager::getSingletonPtr()->logMessage(
			"Influence Map: Finished creating influence map in " +
			Ogre::StringConverter::toString(
				static_cast<float>(endTime - startTime) / 1000.0f) +
			" seconds",
			Ogre::LML_NORMAL);

		return sandbox->GetInfluenceMap();
	}

	Ogre::LogManager::getSingletonPtr()->logMessage(
		"ERROR: Unable to find navmesh \"" + navMeshName + "\" to create "
		"influence map from.",
		Ogre::LML_CRITICAL);

	return nullptr;
}

NavigationMesh* SandboxUtilities::CreateNavigationMesh(
	Sandbox* const sandbox,
	rcConfig config,
	const Ogre::String& navMeshName)
{
	Ogre::Timer timer;
	const unsigned long startTime = timer.getMilliseconds();

	Ogre::LogManager::getSingletonPtr()->logMessage(
		"Navigation Mesh: Creating navigation mesh \"" + navMeshName + "\"",
		Ogre::LML_NORMAL);

	NavigationMesh* const mesh = new NavigationMesh(
		config, sandbox->GetFixedObjects(), sandbox->GetSceneManager());

	sandbox->AddNavigationMesh(navMeshName, *mesh);

	const unsigned long endTime = timer.getMilliseconds();

	Ogre::LogManager::getSingletonPtr()->logMessage(
		"Navigation Mesh: Finished creating navigation mesh \"" +
		navMeshName + "\" in " +
		Ogre::StringConverter::toString(
			static_cast<float>(endTime - startTime) / 1000.0f) +
		" seconds",
		Ogre::LML_NORMAL);

	return mesh;
}

SandboxObject* SandboxUtilities::CreatePhysicsCapsule(
	Sandbox* const sandbox,
	const Ogre::Real height,
	const Ogre::Real radius)
{
	Ogre::SceneNode* const node = sandbox->GetRootNode()->createChildSceneNode();

	btRigidBody* const capsuleRigidBody =
		PhysicsUtilities::CreateCapsule(height, radius);

	SandboxObject* const object = new SandboxObject(
		sandbox->GenerateObjectId(), node, capsuleRigidBody);

	capsuleRigidBody->setUserPointer(object);

	sandbox->AddSandboxObject(object);

	return object;
}

SandboxObject* SandboxUtilities::CreatePhysicsSphere(
	Sandbox* const sandbox,
	const Ogre::Real radius)
{
	Ogre::SceneNode* const node = sandbox->GetRootNode()->createChildSceneNode();

	btRigidBody* const sphereRigidBody = PhysicsUtilities::CreateSphere(radius);

	SandboxObject* const object = new SandboxObject(
		sandbox->GenerateObjectId(), node, sphereRigidBody);

	sphereRigidBody->setUserPointer(object);

	sandbox->AddSandboxObject(object);

	return object;
}

SandboxObject* SandboxUtilities::CreateSandboxBox(
	Sandbox* const sandbox,
	const Ogre::Real width,
	const Ogre::Real height,
	const Ogre::Real length,
	const Ogre::Real uTile,
	const Ogre::Real vTile)
{
	Ogre::SceneNode* const box =
		LuaScriptUtilities::CreateBox(
			sandbox->GetRootNode(), width, height, length, uTile, vTile);

	btRigidBody* const boxRigidBody =
		PhysicsUtilities::CreateBox(width, height, length);

	SandboxObject* const object = new SandboxObject(
		sandbox->GenerateObjectId(), box, boxRigidBody);

	boxRigidBody->setUserPointer(object);

	sandbox->AddSandboxObject(object);

	return object;
}

SandboxObject* SandboxUtilities::CreateSandboxCapsule(
	Sandbox* const sandbox, const Ogre::Real height, const Ogre::Real radius)
{
	Ogre::SceneNode* const capsule =
		LuaScriptUtilities::CreateCapsule(
			sandbox->GetRootNode(), height, radius);

	btRigidBody* const capsuleRigidBody =
		PhysicsUtilities::CreateCapsule(height, radius);

	SandboxObject* const object = new SandboxObject(
		sandbox->GenerateObjectId(), capsule, capsuleRigidBody);

	capsuleRigidBody->setUserPointer(object);

	sandbox->AddSandboxObject(object);

	return object;
}

// ��һ��mesh�ļ�������һ��ɳ�����?
SandboxObject* SandboxUtilities::CreateSandboxObject(
        Sandbox* const sandbox, const Ogre::String& meshFileName)
{
    Ogre::SceneNode* const node =
            sandbox->GetRootNode()->createChildSceneNode();

    Ogre::Entity* const meshEntity =
            node->getCreator()->createEntity(meshFileName);

    node->attachObject(meshEntity);

    btRigidBody* const rigidBody = PhysicsUtilities::CreateRigidBodyFromMesh(
            *meshEntity->getMesh().getPointer(), btVector3(0, 0, 0), 1.0f);

    SandboxObject* const object = new SandboxObject(
            sandbox->GenerateObjectId(), node, rigidBody);

    rigidBody->setUserPointer(object);

    sandbox->AddSandboxObject(object);

    return object;
}

SandboxObject* SandboxUtilities::CreateSandboxObject(
	Sandbox* const sandbox, Ogre::SceneNode* const node)
{
	// Check if the node isn't parented to the sandbox.
	if (!sandbox->GetRootNode()->getChild(node->getName()))
	{
		node->getParentSceneNode()->removeChild(node);
		sandbox->GetRootNode()->addChild(node);
	}

	// Currently sandbox object's only handle one attached object.
	if (node->numAttachedObjects() != 1)
	{
		assert(false);
		return nullptr;
	}

	Ogre::MovableObject* movableObject = node->getAttachedObject(0);

	if (movableObject->getMovableType() !=
		Ogre::EntityFactory::FACTORY_TYPE_NAME)
	{
		// Can only handle ogre mesh entities.
		assert(false);
		return nullptr;
	}

	Ogre::Entity* entity = static_cast<Ogre::Entity*>(movableObject);

	if (entity->getNumSubEntities() != 1)
	{
		// Can only handle one submesh.
		assert(false);
		return nullptr;
	}

	btRigidBody* const rigidBody =
		PhysicsUtilities::CreateRigidBodyFromMesh(
			*entity->getMesh().getPointer(), btVector3(0, 0, 0), 0);

	SandboxObject* const object = new SandboxObject(
		sandbox->GenerateObjectId(), node, rigidBody);

	rigidBody->setUserPointer(object);

	sandbox->AddSandboxObject(object);

	return object;
}

SandboxObject* SandboxUtilities::CreateSandboxPlane(
	Sandbox* const sandbox, const Ogre::Real length, const Ogre::Real width)
{
	Ogre::SceneNode* const plane =
		LuaScriptUtilities::CreatePlane(sandbox->GetRootNode(), length, width);

	btRigidBody* const planeRigidBody =
		PhysicsUtilities::CreatePlane(btVector3(0, 1.0f, 0), 0);

	SandboxObject* const object = new SandboxObject(
		sandbox->GenerateObjectId(), plane, planeRigidBody);

	planeRigidBody->setUserPointer(object);

	sandbox->AddSandboxObject(object);

	return object;
}

void SandboxUtilities::CreateSkyBox(
	Sandbox* const sandbox,
	const Ogre::String materialName,
	const Ogre::Quaternion& orientation)
{
	sandbox->GetRootNode()->getCreator()->setSkyBox(
		true,
		materialName,
		5000.0f,
		true,
		orientation);
}

void SandboxUtilities::DrawInfluenceMap(
	Sandbox* const sandbox,
	const size_t layer,
	const Ogre::ColourValue& positiveValue,
	const Ogre::ColourValue& zeroValue,
	const Ogre::ColourValue& negativeValue)
{
	sandbox->DrawInfluenceMap(layer, positiveValue, zeroValue, negativeValue);
}

Ogre::Vector3 SandboxUtilities::FindClosestPoint(
	Sandbox* const sandbox,
	const Ogre::String& navMeshName,
	const Ogre::Vector3& point)
{
	NavigationMesh* const navMesh = sandbox->GetNavigationMesh(navMeshName);

	if (navMesh)
	{
		return navMesh->FindClosestPoint(point);
	}

	return point;
}

void SandboxUtilities::FindPath(
	Sandbox* const sandbox,
	const Ogre::String& navMeshName,
	const Ogre::Vector3& start,
	const Ogre::Vector3& end,
	std::vector<Ogre::Vector3>& outPath)
{
	NavigationMesh* const mesh = sandbox->GetNavigationMesh(navMeshName);

	if (mesh)
	{
		mesh->FindPath(start, end, outPath);
	}
}

bool SandboxUtilities::GetDrawPhysicsWorld(Sandbox* const sandbox)
{
	return sandbox->GetDrawPhysicsWorld();
}

bool SandboxUtilities::GetEvent(
	lua_State* luaVM, const int eventIndex, Event& event)
{
	if (lua_istable(luaVM, eventIndex))
	{
		int tableIndex = eventIndex;

		if (tableIndex < 0)
		{
			tableIndex = lua_gettop(luaVM) + eventIndex + 1;
		}

		lua_pushnil(luaVM);
		while (lua_next(luaVM, tableIndex))
		{
			// Copy the key so the original variable type isn't modified.
			lua_pushvalue(luaVM, -2);

			if (lua_isstring(luaVM, -1))
			{
				if (lua_isnumber(luaVM, -2))
				{
					event.AddAttribute(
						LuaScriptUtilities::GetString(luaVM, -1),
						static_cast<float>(lua_tonumber(luaVM, -2)));
				}
				else if (lua_isboolean(luaVM, -2))
				{
					event.AddAttribute(
						LuaScriptUtilities::GetString(luaVM, -1),
						lua_toboolean(luaVM, -2));
				}
				else if (lua_isstring(luaVM, -2))
				{
					event.AddAttribute(
						LuaScriptUtilities::GetString(luaVM, -1),
						LuaScriptUtilities::GetString(luaVM, -2));
				}
				else if (LuaScriptUtilities::IsVector3(luaVM, -2))
				{
					event.AddAttribute(
						LuaScriptUtilities::GetString(luaVM, -1),
						*LuaScriptUtilities::GetVector3(luaVM, -2));
				}
				else if (LuaScriptUtilities::IsObject(luaVM, -2))
				{
					event.AddAttribute(
						LuaScriptUtilities::GetString(luaVM, -1),
						LuaScriptUtilities::GetObject(luaVM, -2));
				}
			}

			lua_pop(luaVM, 2); // remove the copied key and value
		}

		return true;
	}

	return false;
}

float SandboxUtilities::GetInertia(
	Sandbox* const sandbox, const size_t layer, const Ogre::Vector3& position)
{
	InfluenceMap* const influenceMap = sandbox->GetInfluenceMap();

	if (influenceMap)
	{
		return influenceMap->GetInfluenceAt(position, layer);
	}

	return 0;
}

long long SandboxUtilities::GetProfileRenderTime(Sandbox* const sandbox)
{
	return sandbox->GetProfileTime(Sandbox::RENDER_TIME);
}

long long SandboxUtilities::GetProfileSimTime(Sandbox* const sandbox)
{
	return sandbox->GetProfileTime(Sandbox::SIMULATION_TIME);
}

long long SandboxUtilities::GetProfileTotalSimTime(Sandbox* const sandbox)
{
	return sandbox->GetProfileTime(Sandbox::TOTAL_SIMULATION_TIME);
}

Ogre::Real SandboxUtilities::GetTimeInMillis(Sandbox* const sandbox)
{
	return sandbox->GetTimeInMillis();
}

Ogre::Real SandboxUtilities::GetTimeInSeconds(Sandbox* const sandbox)
{
	return sandbox->GetTimeInSeconds();
}

bool SandboxUtilities::IsSandbox(const LuaScriptType& type)
{
	return type.type == SCRIPT_SANDBOX;
}

bool SandboxUtilities::IsSandboxObject(const LuaScriptType& type)
{
	return type.type == SCRIPT_SANDBOX_OBJECT;
}

void SandboxUtilities::LoadScript(
	Sandbox* const sandbox,
	const char* const luaScriptContents,
	const size_t bufferSize,
	const char* const fileName)
{
	char sandboxName[1024];
	sprintf_s(
		sandboxName,
		sizeof sandboxName,
		"%s - \"%s\"",
		SANDBOX_LUA_VM_NAME,
		fileName);

	lua_State* luaVM = sandbox->GetLuaVM();
	LuaScriptUtilities::NameVM(luaVM, sandboxName);
	LuaScriptUtilities::LoadScript(
		luaVM, luaScriptContents, bufferSize, fileName);
}

int SandboxUtilities::PushEvent(lua_State* luaVM, const Event& event)
{
	lua_newtable(luaVM);
	const int tableIndex = lua_gettop(luaVM);

	std::vector<Ogre::String> attributeKeys;

	event.GetAttributeNames(attributeKeys);

	std::vector<Ogre::String>::iterator it;

	for (it = attributeKeys.begin(); it != attributeKeys.end(); ++it)
	{
		const Ogre::String& key = *it;

		LuaScriptUtilities::PushString(luaVM, key);

		switch (event.GetAttributeType(key))
		{
		case Event::ATTRIBUTE_BOOLEAN:
			lua_pushboolean(luaVM, event.GetBoolAttribute(key));
			break;
		case Event::ATTRIBUTE_INT:
			LuaScriptUtilities::PushInt(luaVM, event.GetIntAttribute(key));
			break;
		case Event::ATTRIBUTE_FLOAT:
			lua_pushnumber(luaVM, event.GetFloatAttribute(key));
			break;
		case Event::ATTRIBUTE_OBJECT:
			PushObject(luaVM, event.GetObjectAttribute(key));
			break;
		case Event::ATTRIBUTE_STRING:
			LuaScriptUtilities::PushString(
				luaVM, event.GetStringAttribute(key));
			break;
		case Event::ATTRIBUTE_VECTOR3:
			LuaScriptUtilities::PushVector3(
				luaVM, event.GetVector3Attribute(key));
			break;
		}

		lua_settable(luaVM, tableIndex);
	}

	return 1;
}

int SandboxUtilities::PushMarkupColor(
	lua_State* luaVM, const Sandbox* const sandbox, const int index)
{
	return LuaScriptUtilities::PushColorValue(
		luaVM, sandbox->GetMarkupColor(index));
}

int SandboxUtilities::PushObject(lua_State* luaVM, Object* const object)
{
	if (object && object->GetType() == Object::SANDBOX_OBJECT)
	{
		return LuaScriptUtilities::PushDataType(
			luaVM, object, SCRIPT_SANDBOX_OBJECT);
	}
	else if (object && object->GetType() == Object::SANDBOX)
	{
		return LuaScriptUtilities::PushDataType(
			luaVM, object, SCRIPT_SANDBOX);
	}
	else if (object && object->GetType() == Object::AGENT)
	{
		AgentUtilities::PushAgent(luaVM, static_cast<Agent*>(object));
	}

	return 0;
}

int SandboxUtilities::PushObjectAttribute(
	lua_State* luaVM,
	Object* const object,
	const Ogre::String& attributeName,
	const int tableIndex)
{
	if (object && object->GetType() == Object::SANDBOX_OBJECT)
	{
		return LuaScriptUtilities::PushDataTypeAttribute(
			luaVM,
			object,
			attributeName,
			SCRIPT_SANDBOX_OBJECT,
			tableIndex);
	}
	else if (object && object->GetType() == Object::AGENT)
	{
		return AgentUtilities::PushAgentAttribute(
			luaVM,
			static_cast<Agent*>(object),
			attributeName,
			tableIndex);
	}

	return 0;
}

int SandboxUtilities::PushPath(
	lua_State* luaVM,
	const std::vector<Ogre::Vector3>& path)
{
	lua_newtable(luaVM);
	const int tableIndex = lua_gettop(luaVM);

	std::vector<Ogre::Vector3>::const_iterator it;

	size_t count = 1;

	for (it = path.begin(); it != path.end(); ++it)
	{
		lua_pushinteger(luaVM, count);
		LuaScriptUtilities::PushVector3(luaVM, *it);
		lua_settable(luaVM, tableIndex);

		++count;
	}

	return 1;
}

int SandboxUtilities::PushScreenHeight(
	lua_State* luaVM, const Sandbox* const sandbox)
{
	return LuaScriptUtilities::PushInt(luaVM, sandbox->GetScreenHeight());
}

int SandboxUtilities::PushScreenWidth(
	lua_State* luaVM, const Sandbox* const sandbox)
{
	return LuaScriptUtilities::PushInt(luaVM, sandbox->GetScreenWidth());
}

Ogre::Vector3 SandboxUtilities::RandomPoint(
	Sandbox* const sandbox, const Ogre::String& navMeshName)
{
	NavigationMesh* const mesh = sandbox->GetNavigationMesh(navMeshName);

	if (mesh)
	{
		return mesh->RandomPoint();
	}

	return Ogre::Vector3();
}

bool SandboxUtilities::RayCastToObject(
	Sandbox* const sandbox,
	const Ogre::Vector3& from,
	const Ogre::Vector3& to,
	Ogre::Vector3& hitPoint,
	Object*& object)
{
	return sandbox->RayCastToObject(from, to, hitPoint, object);
}

void SandboxUtilities::RemoveSandboxObject(
	Sandbox* const sandbox, SandboxObject* object)
{
	sandbox->RemoveSandboxObject(object);
}

void SandboxUtilities::SetAmbientLight(
	Sandbox* const sandbox, const Ogre::Vector3& ambient)
{
	sandbox->GetRootNode()->getCreator()->setAmbientLight(
		Ogre::ColourValue(ambient.x, ambient.y, ambient.z));
}

void SandboxUtilities::SetCameraForward(
	Sandbox* const sandbox, const Ogre::Vector3& forward)
{
	Ogre::Camera* const camera = sandbox->GetCamera();

	camera->setOrientation(Ogre::Vector3::UNIT_Z.getRotationTo(forward));
}

void SandboxUtilities::SetCameraOrientation(
	Sandbox* const sandbox, const Ogre::Quaternion& rotation)
{
	Ogre::Camera* const camera = sandbox->GetCamera();

	camera->setOrientation(rotation);
}

void SandboxUtilities::SetCameraPosition(
	Sandbox* const sandbox, const Ogre::Vector3& position)
{
	Ogre::Camera* const camera = sandbox->GetCamera();

	camera->setPosition(position);
}

void SandboxUtilities::SetDebugNavigationMesh(
	Sandbox* const sandbox,
	const Ogre::String& navMeshName,
	const bool debug)
{
	NavigationMesh* mesh = sandbox->GetNavigationMesh(navMeshName);

	if (mesh)
	{
		mesh->SetNavmeshDebug(debug);
	}
}

void SandboxUtilities::SetDrawInfluenceMap(
	Sandbox* const sandbox, const bool drawInfluenceMap)
{
	sandbox->SetDrawInfluenceMap(drawInfluenceMap);
}

void SandboxUtilities::SetDrawPhysicsWorld(
	Sandbox* const sandbox, const bool drawPhysicsWorld)
{
	sandbox->SetDrawPhysicsWorld(drawPhysicsWorld);
}

void SandboxUtilities::SetFalloff(
	Sandbox* const sandbox, const size_t layer, const float falloff)
{
	sandbox->GetInfluenceMap()->SetFalloff(layer, falloff);
}

void SandboxUtilities::SetInertia(
	Sandbox* const sandbox, const size_t layer, const float inertia)
{
	sandbox->GetInfluenceMap()->SetInertia(layer, inertia);
}

void SandboxUtilities::SetInfluence(
	Sandbox* const sandbox,
	const size_t layer,
	const Ogre::Vector3& position,
	const float influence)
{
	sandbox->SetInfluence(layer, position, influence);
}

void SandboxUtilities::SetMarkupColor(
	Sandbox* const sandbox,
	const int index,
	const Ogre::Real red,
	const Ogre::Real green,
	const Ogre::Real blue,
	const Ogre::Real alpha)
{
	sandbox->SetMarkupColor(
		index, Ogre::ColourValue(red, green, blue, alpha));
}

void SandboxUtilities::SpreadInfluenceMap(
	Sandbox* const sandbox, const size_t layer)
{
	sandbox->GetInfluenceMap()->SpreadInfluence(layer);
}

void SandboxUtilities::UpdateWorldTransform(SandboxObject* const sandboxObject)
{
	btRigidBody* const rigidBody = sandboxObject->GetRigidBody();
	Ogre::SceneNode* const sceneNode = sandboxObject->GetSceneNode();

	const btVector3& rigidBodyPosition =
		rigidBody->getWorldTransform().getOrigin();

	sceneNode->setPosition(
		rigidBodyPosition.m_floats[0],
		rigidBodyPosition.m_floats[1],
		rigidBodyPosition.m_floats[2]);

	const btQuaternion rigidBodyOrientation =
		rigidBody->getWorldTransform().getRotation();

	sceneNode->setOrientation(
		rigidBodyOrientation.w(),
		rigidBodyOrientation.x(),
		rigidBodyOrientation.y(),
		rigidBodyOrientation.z());
}
