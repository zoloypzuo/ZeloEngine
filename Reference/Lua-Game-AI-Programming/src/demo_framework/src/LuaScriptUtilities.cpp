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

// TODO(David Young): Temp includes
#include "demo_framework/include/Agent.h"
#include "demo_framework/include/AgentUtilities.h"
#include "demo_framework/include/AnimationUtilities.h"
// end of TODO

#include "demo_framework/include/LuaFileManager.h"
#include "demo_framework/include/LuaFilePtr.h"
#include "demo_framework/include/LuaScriptBindings.h"
#include "demo_framework/include/LuaScriptUtilities.h"
#include "demo_framework/include/Sandbox.h"
#include "demo_framework/include/SandboxObject.h"

#define DEFAULT_MATERIAL "White"

namespace
{
const luaL_Reg LuaCoreFunctions[] =
{
    { "ApplyForce",                 Lua_Script_CoreApplyForce },
    { "ApplyImpulse",               Lua_Script_CoreApplyImpulse },
    { "ApplyAngularImpulse",        Lua_Script_CoreApplyAngularImpulse },
    { "CacheResource",              Lua_Script_CoreCacheResource },
    { "CreateBox",                  Lua_Script_CoreCreateBox },
    { "CreateCapsule",              Lua_Script_CoreCreateCapsule },
    { "CreateCircle",               Lua_Script_CoreCreateCircle },
    { "CreateCylinder",             Lua_Script_CoreCreateCylinder },
    { "CreateDirectionalLight",     Lua_Script_CoreCreateDirectionalLight },
    { "CreateLine",                 Lua_Script_CoreCreateLine },
    { "CreateMesh",                 Lua_Script_CoreCreateMesh },
    { "CreateParticle",             Lua_Script_CoreCreateParticle },
    { "CreatePlane",                Lua_Script_CoreCreatePlane },
    { "CreatePointLight",           Lua_Script_CoreCreatePointLight },
    { "DrawCircle",                 Lua_Script_CoreDrawCircle },
    { "DrawLine",                   Lua_Script_CoreDrawLine },
    { "DrawSphere",                 Lua_Script_CoreDrawSphere },
    { "DrawSquare",                 Lua_Script_CoreDrawSquare },
    { "GetMass",                    Lua_Script_CoreGetMass },
    { "GetPosition",                Lua_Script_CoreGetPosition },
    { "GetRadius",                  Lua_Script_CoreGetRadius },
    { "GetRotation",                Lua_Script_CoreGetRotation },
    { "IsVisisble",                 Lua_Script_CoreIsVisible },
    { "Remove",                     Lua_Script_CoreRemove },
    { "ResetParticle",              Lua_Script_CoreResetParticle },
    { "SetAxis",                    Lua_Script_CoreSetAxis },
    { "SetGravity",                 Lua_Script_CoreSetGravity },
    { "SetLightDiffuse",            Lua_Script_CoreSetLightDiffuse },
    { "SetLightRange",              Lua_Script_CoreSetLightRange },
    { "SetLightSpecular",           Lua_Script_CoreSetLightSpecular },
    { "SetLineStartEnd",            Lua_Script_CoreSetLineStartEnd },
    { "SetMass",                    Lua_Script_CoreSetMass },
    { "SetMaterial",                Lua_Script_CoreSetMaterial },
    { "SetParticleDirection",       Lua_Script_CoreSetParticleDirection },
    { "SetPosition",                Lua_Script_CoreSetPosition },
    { "SetRotation",                Lua_Script_CoreSetRotation },
    { "SetVisisble",                Lua_Script_CoreSetVisible },
    { NULL, NULL }
};

const luaL_Reg LuaScriptTypeMetatable[] =
{
    { "__towatch",                  Lua_Script_CoreTypeToWatch },
    { NULL, NULL }
};

const luaL_Reg LuaVector3Functions[] =
{
    { "CrossProduct",               Lua_Script_Vector3CrossProduct },
    { "Distance",                   Lua_Script_Vector3Distance },
    { "DistanceSquared",            Lua_Script_Vector3DistanceSquared },
    { "DotProduct",                 Lua_Script_Vector3DotProduct },
    { "Length",                     Lua_Script_Vector3Length },
    { "LengthSquared",              Lua_Script_Vector3LengthSquared },
    { "Normalize",                  Lua_Script_Vector3Normalize },
    { "new",                        Lua_Script_Vector3New },
    { "Rotate",                     Lua_Script_Vector3Rotate },
    { "RotationTo",                 Lua_Script_Vector3RotationTo },
    { NULL, NULL }
};

const luaL_Reg LuaVector3Metatable[] =
{
    { "__add",                      Lua_Script_Vector3Add },
    { "__div",                      Lua_Script_Vector3Divide },
    { "__eq",                       Lua_Script_Vector3Equal },
    { "__index",                    Lua_Script_Vector3Index },
    { "__mul",                      Lua_Script_Vector3Multiply },
    { "__newindex",                 Lua_Script_Vector3NewIndex },
    { "__sub",                      Lua_Script_Vector3Subtract },
    { "__tostring",                 Lua_Script_Vector3ToString },
    { "__towatch",                  Lua_Script_Vector3ToWatch },
    { "__unm",                      Lua_Script_Vector3Negation },
    { NULL, NULL }
};
}  // anonymous namespace

void LuaScriptUtilities::BindVMFunctions(lua_State* const luaVM)
{
    luaL_newmetatable(luaVM, LUA_SCRIPT_TYPE_METATABLE);
    luaL_register(luaVM, NULL, LuaScriptTypeMetatable);

    luaL_newmetatable(luaVM, LUA_VECTOR3_METATABLE);
    luaL_register(luaVM, NULL, LuaVector3Metatable);

    luaL_register(luaVM, "Core", LuaCoreFunctions);
    luaL_register(luaVM, "Vector", LuaVector3Functions);

    lua_register(luaVM, "require", Lua_Script_CoreRequireLuaModule);
}

void LuaScriptUtilities::CacheResource(const Ogre::String& resourceName)
{
    Ogre::ResourceGroupManager* const resourceManager =
        Ogre::ResourceGroupManager::getSingletonPtr();

    resourceManager->openResource(resourceName);
    resourceManager->loadResourceGroup(
        Ogre::ResourceGroupManager::DEFAULT_RESOURCE_GROUP_NAME);
}

bool LuaScriptUtilities::CheckArgumentCountOrDie(
    lua_State* const luaVM,
    const unsigned int argCount,
    const unsigned int optionalArgs)
{
    const unsigned int actualArgCount =
        static_cast<unsigned int>(lua_gettop(luaVM));

    if (actualArgCount < argCount || actualArgCount > (argCount + optionalArgs))
    {
        Ogre::LogManager* const logManager = Ogre::LogManager::getSingletonPtr();

        char buffer[2048];

        if (optionalArgs)
        {
            sprintf_s(
                buffer,
                sizeof(buffer),
                "LUA_ERROR: \"%s\" expected at least %d arguments but no more "
                "than %d arguments, encountered %d.",
                GetCallingFunctionName(luaVM).c_str(),
                argCount,
                argCount + optionalArgs,
                actualArgCount);
        }
        else
        {
            sprintf_s(
                buffer,
                sizeof(buffer),
                "LUA_ERROR: \"%s\" expected %d arguments, encountered %d.",
                GetCallingFunctionName(luaVM).c_str(),
                argCount,
                actualArgCount);
        }

        logManager->logMessage(
            buffer, Ogre::LML_CRITICAL);

        DumpStack(luaVM, Ogre::LML_CRITICAL);
        DumpStackTrace(luaVM, Ogre::LML_CRITICAL);

        PushErrorMessageAndDie(luaVM, buffer);

        return false;
    }

    return true;
}

Ogre::SceneNode* LuaScriptUtilities::CreateBox(
    Ogre::SceneNode* const parentNode,
    const Ogre::Real width,
    const Ogre::Real height,
    const Ogre::Real length,
    const Ogre::Real uTile,
    const Ogre::Real vTile)
{
    const Ogre::Real clampedWidth = std::max(Ogre::Real(0), width);
    const Ogre::Real clampedHeight = std::max(Ogre::Real(0), height);
    const Ogre::Real clampedLength = std::max(Ogre::Real(0), length);

    Procedural::BoxGenerator boxGenerator;
    boxGenerator.setSizeX(clampedWidth);
    boxGenerator.setSizeY(clampedHeight);
    boxGenerator.setSizeZ(clampedLength);
    boxGenerator.setUTile(uTile);
    boxGenerator.setVTile(vTile);

    const Ogre::MeshPtr mesh = boxGenerator.realizeMesh();

    Ogre::SceneNode* const box = parentNode->createChildSceneNode();

    Ogre::Entity* const boxEntity =
        box->getCreator()->createEntity(mesh);

    boxEntity->setMaterialName(DEFAULT_MATERIAL);

    box->attachObject(boxEntity);

    return box;
}

Ogre::SceneNode* LuaScriptUtilities::CreateCapsule(
    Ogre::SceneNode* const parentNode,
    const Ogre::Real height,
    const Ogre::Real radius)
{
    const Ogre::Real clampedHeight = std::max(Ogre::Real(0), height);
    const Ogre::Real clampedRadius = std::max(Ogre::Real(0), radius);

    Procedural::CapsuleGenerator capsuleGenerator;
    capsuleGenerator.setHeight(clampedHeight - clampedRadius * 2);
    capsuleGenerator.setRadius(clampedRadius);
    capsuleGenerator.setNumRings(4);
    capsuleGenerator.setNumSegments(16);

    const Ogre::MeshPtr mesh = capsuleGenerator.realizeMesh();

    Ogre::SceneNode* const capsule = parentNode->createChildSceneNode();

    Ogre::Entity* const capsuleEntity =
        capsule->getCreator()->createEntity(mesh);

    capsuleEntity->setMaterialName(DEFAULT_MATERIAL);

    capsule->attachObject(capsuleEntity);

    return capsule;
}

Ogre::SceneNode* LuaScriptUtilities::CreateCircle(
    Ogre::SceneNode* const parentNode, const Ogre::Real radius)
{
    Procedural::TorusGenerator torusGenerator;
    torusGenerator.setSectionRadius(0.01f);
    torusGenerator.setRadius(radius);

    const Ogre::MeshPtr mesh = torusGenerator.realizeMesh();

    Ogre::SceneNode* const circle = parentNode->createChildSceneNode();

    Ogre::Entity* const circleEntity =
        circle->getCreator()->createEntity(mesh);

    circleEntity->setMaterialName(DEFAULT_MATERIAL);

    circle->attachObject(circleEntity);

    return circle;
}

Ogre::SceneNode* LuaScriptUtilities::CreateCylinder(
    Ogre::SceneNode* const parentNode,
    const Ogre::Real height,
    const Ogre::Real radius)
{
    assert(parentNode);

    const Ogre::Real clampedHeight = std::max(Ogre::Real(0), height);
    const Ogre::Real clampedRadius = std::max(Ogre::Real(0), radius);

    Procedural::CylinderGenerator cylinderGenerator;
    cylinderGenerator.setHeight(clampedHeight);
    cylinderGenerator.setRadius(clampedRadius);
    cylinderGenerator.setNumSegHeight(1);
    cylinderGenerator.setNumSegBase(12);

    const Ogre::MeshPtr mesh = cylinderGenerator.realizeMesh();

    Ogre::SceneNode* const cylinder = parentNode->createChildSceneNode();

    Ogre::Entity* const cylinderEntity =
        cylinder->getCreator()->createEntity(mesh);

    cylinderEntity->setMaterialName(DEFAULT_MATERIAL);

    cylinder->attachObject(cylinderEntity);

    return cylinder;
}

Ogre::SceneNode* LuaScriptUtilities::CreateLine(
    Ogre::SceneNode* const parentNode,
    const Ogre::Vector3& start,
    const Ogre::Vector3& end)
{
    assert(parentNode);

    Ogre::SceneNode* const line = CreateCylinder(parentNode, 1.0f, 1.0f);

    SetLineStartEnd(line, start, end);

    return line;
}

Ogre::SceneNode* LuaScriptUtilities::CreateMesh(
    Ogre::SceneNode* const parentNode, const Ogre::String& meshFileName)
{
    assert(parentNode);

    Ogre::Entity* const meshEntity =
        parentNode->getCreator()->createEntity(meshFileName);

    Ogre::SceneNode* const mesh = parentNode->createChildSceneNode();

    mesh->attachObject(meshEntity);

    return mesh;
}

Ogre::SceneNode* LuaScriptUtilities::CreatePlane(
    Ogre::SceneNode* const parentNode,
    const Ogre::Real length,
    const Ogre::Real width)
{
    assert(parentNode);

    const Ogre::Real clampedLength = std::max(Ogre::Real(0), length);
    const Ogre::Real clampedWidth = std::max(Ogre::Real(0), width);

    Procedural::PlaneGenerator planeGenerator;
    planeGenerator.setSizeX(clampedLength);
    planeGenerator.setSizeY(clampedWidth);
    // TODO(David Young): Accept specifiers for UV tiling.
    planeGenerator.setUTile(clampedLength / 2);
    planeGenerator.setVTile(clampedWidth / 2);

    const Ogre::MeshPtr mesh = planeGenerator.realizeMesh();

    Ogre::SceneNode* const plane = parentNode->createChildSceneNode();

    Ogre::Entity* const planeEntity = plane->getCreator()->createEntity(mesh);

    planeEntity->setMaterialName(DEFAULT_MATERIAL);

    plane->attachObject(planeEntity);

    return plane;
}

lua_State* LuaScriptUtilities::CreateVM()
{
    lua_State* const luaVM = luaL_newstate();
    luaL_openlibs(luaVM);

    return luaVM;
}

lua_State* LuaScriptUtilities::CreateNamedVM(const char* const vmName)
{
    lua_State* const luaVM = CreateVM();

    NameVM(luaVM, vmName);

    return luaVM;
}

void LuaScriptUtilities::DestroyRigidBody(
    btDiscreteDynamicsWorld* const physicsWorld, btRigidBody* const rigidBody)
{
    physicsWorld->removeRigidBody(rigidBody);

    delete rigidBody->getMotionState();
    delete rigidBody;
}

void LuaScriptUtilities::DestroySceneNode(
    Ogre::SceneManager* const sceneManager, Ogre::SceneNode* const sceneNode)
{
    if (sceneManager == sceneNode->getCreator())
    {
        // TODO(David Young): Need to destroy attached entities here.
        sceneNode->getParent()->removeChild(sceneNode);
        sceneManager->destroySceneNode(sceneNode);
    }
    else
    {
        OGRE_DELETE sceneNode;
    }
}

void LuaScriptUtilities::DestroyVM(lua_State* const luaVM)
{
    lua_close(luaVM);
}

void LuaScriptUtilities::DumpStack(
    lua_State* const luaVM, const Ogre::LogMessageLevel messageLevel)
{
    Ogre::LogManager* const logManager = Ogre::LogManager::getSingletonPtr();

    char buffer[2048];

    int top = lua_gettop(luaVM);

    sprintf_s(buffer, sizeof(buffer), "Lua Stack: size %d", top);
    logManager->logMessage(buffer, messageLevel);

    for (int index = 1; index <= top; index++) {
        int type = lua_type(luaVM, index);

        switch (type) {
        case LUA_TSTRING:
            sprintf_s(
                buffer,
                sizeof(buffer),
                "        %d: [%s] %s",
                index,
                lua_typename(luaVM, type),
                lua_tostring(luaVM, index));
            break;

        case LUA_TBOOLEAN:
            sprintf_s(
                buffer,
                sizeof(buffer),
                "        %d: [%s] %s",
                index,
                lua_typename(luaVM, type),
                lua_toboolean(luaVM, index) ? "true" : "false");
            break;

        case LUA_TNUMBER:
            sprintf_s(
                buffer,
                sizeof(buffer),
                "        %d: [%s] %g",
                index,
                lua_typename(luaVM, type),
                lua_tonumber(luaVM, index));
            break;

        case LUA_TUSERDATA:
            sprintf_s(
                buffer,
                sizeof(buffer),
                "        %d: [%s] %s",
                index,
                lua_typename(luaVM, type),
                GetUserdataTypeName(luaVM, index).c_str());
            break;

        case LUA_TNIL:
            sprintf_s(
                buffer,
                sizeof(buffer),
                "        %d: [%s]",
                index,
                lua_typename(luaVM, type));
            break;

        default:
            sprintf_s(
                buffer,
                sizeof(buffer),
                "        %d: [%s]",
                index,
                lua_typename(luaVM, type));
            break;
        }

        logManager->logMessage(buffer, messageLevel);
    }
}

void LuaScriptUtilities::DumpStackTrace(
    lua_State* const luaVM, const Ogre::LogMessageLevel messageLevel)
{
    lua_Debug entry;
    int depth = 0;

    Ogre::LogManager* const logManager = Ogre::LogManager::getSingletonPtr();

    char buffer[2048];

    while (lua_getstack(luaVM, depth, &entry))
    {
        int status = lua_getinfo(luaVM, "Sln", &entry);
        assert(status);
        (void)status;

        sprintf_s(
            buffer,
            sizeof(buffer),
            (!depth) ? "Caused by: %s:%d %s" : "       at: %s:%d %s",
            entry.short_src,
            entry.currentline,
            entry.name ? entry.name : "");

        logManager->logMessage(buffer, messageLevel);

        depth++;
    }
}

Ogre::String LuaScriptUtilities::GetCallingFunctionName(lua_State* const luaVM)
{
    lua_Debug entry;

    if (lua_getstack(luaVM, 0, &entry))
    {
        if(lua_getinfo(luaVM, "n", &entry))
        {
            return (entry.name) ? entry.name : "";
        }
    }

    return "";
}

Ogre::ColourValue LuaScriptUtilities::GetColourValue(
    lua_State* const luaVM, const int stackIndex)
{
    return Ogre::ColourValue(
        GetRealAttribute(luaVM, 1, stackIndex),
        GetRealAttribute(luaVM, 2, stackIndex),
        GetRealAttribute(luaVM, 3, stackIndex),
        GetRealAttribute(luaVM, 4, stackIndex));
}

LuaScriptType* LuaScriptUtilities::GetDataType(
    lua_State* const luaVM, const int stackIndex)
{
    if (IsUserdataType(luaVM, stackIndex, LUA_SCRIPT_TYPE_METATABLE))
    {
        return static_cast<LuaScriptType*>(
            luaL_checkudata(luaVM, stackIndex, LUA_SCRIPT_TYPE_METATABLE));
    }

    return NULL;
}

Ogre::Entity* LuaScriptUtilities::GetEntity(
    Ogre::SceneNode& node, const unsigned short index)
{
    if (node.numAttachedObjects() >= index)
    {
        Ogre::MovableObject* const movable = node.getAttachedObject(index);

        return dynamic_cast<Ogre::Entity*>(movable);
    }

    return NULL;
}

Ogre::Light* LuaScriptUtilities::GetLight(
    lua_State* const luaVM, const int stackIndex)
{
    Ogre::SceneNode* const node = GetSceneNode(luaVM, stackIndex);

    if (node)
    {
        Ogre::SceneNode::ObjectIterator it = node->getAttachedObjectIterator();

        while (it.hasMoreElements())
        {
            const Ogre::String movableType =
                it.current()->second->getMovableType();

            if (movableType == Ogre::LightFactory::FACTORY_TYPE_NAME)
            {
                return static_cast<Ogre::Light*>(it.current()->second);
            }

            it.getNext();
        }
    }

    return NULL;
}

Object* LuaScriptUtilities::GetObject(
    lua_State* const luaVM, const int stackIndex)
{
    Agent* const agent = AgentUtilities::GetAgent(luaVM, stackIndex);

    if (agent)
    {
        return static_cast<Object*>(agent);
    }

    LuaScriptType* const type =
        LuaScriptUtilities::GetDataType(luaVM, stackIndex);

    if (type && type->type == SCRIPT_SANDBOX_OBJECT)
    {
        return static_cast<Object*>(type->rawPointer);
    }
    else if (type && type->type == SCRIPT_SANDBOX)
    {
        return static_cast<Object*>(type->rawPointer);
    }

    return NULL;
}

Ogre::Real LuaScriptUtilities::GetRadius(Ogre::SceneNode* const sceneNode)
{
    sceneNode->_updateBounds();
    const Ogre::AxisAlignedBox aabb = sceneNode->_getWorldAABB();

    return aabb.getHalfSize().length();
}

Ogre::Real LuaScriptUtilities::GetReal(
    lua_State* const luaVM, const int stackIndex)
{
    return static_cast<Ogre::Real>(luaL_checknumber(luaVM, stackIndex));
}

Ogre::Real LuaScriptUtilities::GetRealAttribute(
    lua_State* const luaVM,
    const Ogre::String attributeName,
    const int tableIndex)
{
    if (!lua_istable(luaVM, tableIndex))
        return Ogre::Real();

    lua_pushstring(luaVM, attributeName.c_str());
    lua_gettable(luaVM, tableIndex);

    Ogre::Real value = lua_tonumber(luaVM, -1);

    lua_pop(luaVM, 1);

    return value;
}

Ogre::Real LuaScriptUtilities::GetRealAttribute(
    lua_State* const luaVM, const int index, const int tableIndex)
{
    if (!lua_istable(luaVM, tableIndex))
        return Ogre::Real();

    lua_pushinteger(luaVM, index);
    lua_gettable(luaVM, tableIndex);

    Ogre::Real value = lua_tonumber(luaVM, -1);

    lua_pop(luaVM, 1);

    return value;
}

Sandbox* LuaScriptUtilities::GetSandbox(
    lua_State* const luaVM, const int stackIndex)
{
    LuaScriptType* const type =
        LuaScriptUtilities::GetDataType(luaVM, stackIndex);

    if (type && type->type == SCRIPT_SANDBOX)
    {
        return static_cast<Sandbox*>(type->rawPointer);
    }

    return NULL;
}

SandboxObject* LuaScriptUtilities::GetSandboxObject(
    lua_State* const luaVM, const int stackIndex)
{
    LuaScriptType* const type =
        LuaScriptUtilities::GetDataType(luaVM, stackIndex);

    if (type && type->type == SCRIPT_SANDBOX_OBJECT)
    {
        return static_cast<SandboxObject*>(type->rawPointer);
    }

    return NULL;
}

Ogre::SceneNode* LuaScriptUtilities::GetSceneNode(
    lua_State* const luaVM, const int stackIndex)
{
    LuaScriptType* const type =
        LuaScriptUtilities::GetDataType(luaVM, stackIndex);

    if (type && type->type == SCRIPT_SCENENODE)
    {
        return static_cast<Ogre::SceneNode*>(type->rawPointer);
    }
    else if (type && type->type == SCRIPT_SANDBOX)
    {
        Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);
        return sandbox->GetRootNode();
    }
    else if (type && type->type == SCRIPT_SANDBOX_OBJECT)
    {
        SandboxObject* const object =
            static_cast<SandboxObject*>(type->rawPointer);

        return object->GetSceneNode();
    }

    return NULL;
}

Ogre::SceneNode* LuaScriptUtilities::GetSceneNode(LuaScriptType& type)
{
    Ogre::SceneNode* node = NULL;

    switch (type.type)
    {
    case SCRIPT_SANDBOX:
        {
            Sandbox* const sandbox =
                static_cast<Sandbox*>(type.rawPointer);
            node = sandbox->GetRootNode();
            break;
        }
    case SCRIPT_SCENENODE:
        {
            node = static_cast<Ogre::SceneNode*>(type.rawPointer);
            break;
        }
    case SCRIPT_SANDBOX_OBJECT:
        {
            node = static_cast<SandboxObject*>(type.rawPointer)->GetSceneNode();
            break;
        }
    default:
        assert(false);
        break;
    }

    return node;
}

Ogre::String LuaScriptUtilities::GetString(
    lua_State* const luaVM, const int stackIndex)
{
    return Ogre::String(lua_tostring(luaVM, stackIndex));
}

Ogre::Vector3* LuaScriptUtilities::GetVector3(
        lua_State* const luaVM, const int stackIndex)
{
    return static_cast<Ogre::Vector3*>(
        luaL_checkudata(luaVM, stackIndex, LUA_VECTOR3_METATABLE));
}

Ogre::Vector3* LuaScriptUtilities::GetVector3Attribute(
    lua_State* const luaVM,
    const Ogre::String attributeName,
    const int tableIndex)
{
    if (!lua_istable(luaVM, tableIndex))
        return NULL;

    lua_pushstring(luaVM, attributeName.c_str());
    lua_gettable(luaVM, tableIndex);

    Ogre::Vector3* const vector = static_cast<Ogre::Vector3*>(
        luaL_checkudata(luaVM, -1, LUA_VECTOR3_METATABLE));

    lua_pop(luaVM, 1);

    return vector;
}

Ogre::String LuaScriptUtilities::GetUserdataTypeName(
    lua_State* const luaVM, const int stackIndex)
{
    // TODO(David Young): Need to make a more generalized way of getting the
    // userdata type name.  Attaching a "type" to the metatable sounds
    // reasonable.  Looking into the LuaScriptType would still be required.
    if (IsUserdataType(luaVM, stackIndex, LUA_SCRIPT_TYPE_METATABLE))
    {
        LuaScriptType* const type =
            LuaScriptUtilities::GetDataType(luaVM, stackIndex);

        return RawScriptTypeName[type->type];
    }
    else if (IsUserdataType(luaVM, stackIndex, LUA_VECTOR3_METATABLE))
    {
        return "Vector3";
    }
    else if (IsUserdataType(luaVM, stackIndex, LUA_ANIMATION_METATABLE))
    {
        return "Animation";
    }
    else if (IsUserdataType(luaVM, stackIndex, LUA_AGENT_METATABLE))
    {
        return "Agent";
    }

    return "";
}

bool LuaScriptUtilities::HasAttribute(
    lua_State* const luaVM,
    const int tableIndex,
    const Ogre::String& attributeName)
{
    if (!lua_istable(luaVM, tableIndex))
        return false;

    lua_pushstring(luaVM, attributeName.c_str());
    lua_gettable(luaVM, tableIndex);

    const bool result = lua_isnil(luaVM, -1);

    lua_pop(luaVM, 1);

    return !result;
}

bool LuaScriptUtilities::IsObject(lua_State* const luaVM, const int stackIndex)
{
    if (AgentUtilities::IsAgent(luaVM, stackIndex))
    {
        return true;
    }

    LuaScriptType* const type =
        LuaScriptUtilities::GetDataType(luaVM, stackIndex);

    if (type && type->type == SCRIPT_SANDBOX_OBJECT)
    {
        return true;
    }
    else if (type && type->type == SCRIPT_SANDBOX)
    {
        return true;
    }

    return false;
}

bool LuaScriptUtilities::IsUserdataType(
    lua_State* const luaVM, const int stackIndex, const Ogre::String type)
{
    void* pointer = lua_touserdata(luaVM, stackIndex);
    if (pointer != NULL)
    {
        if (lua_getmetatable(luaVM, stackIndex))
        {
            lua_getfield(luaVM, LUA_REGISTRYINDEX, type.c_str());
            if (lua_rawequal(luaVM, -1, -2))
            {
                lua_pop(luaVM, 2);
                return true;
            }
            lua_pop(luaVM, 2);
        }
    }
    return false;
}

bool LuaScriptUtilities::IsVector3(
    lua_State* const luaVM, const int stackIndex)
{
    return IsUserdataType(luaVM, stackIndex, LUA_VECTOR3_METATABLE);
}

bool LuaScriptUtilities::IsVisisble(Ogre::SceneNode* const node)
{
    bool visible = false;

    const unsigned short numAttachedObjects = node->numAttachedObjects();

    for (unsigned short index = 0; index < numAttachedObjects; ++index)
    {
        const Ogre::MovableObject* const object = node->getAttachedObject(index);

        if (object->isVisible())
        {
            visible = true;
            break;
        }
    }

    return visible;
}

void LuaScriptUtilities::LoadScript(
    lua_State* const luaVM,
    const char* const luaScriptContents,
    const size_t bufferSize,
    const char* const fileName)
{
    assert(luaVM);

    // Using luaL_loadbuffer allows Decoda to match which lua files the VM is
    // using.
    // The loadbuffer's name must match the lua filename.
    luaL_loadbuffer(luaVM, luaScriptContents, bufferSize, fileName);
    lua_pcall(luaVM, 0, LUA_MULTRET, 0);
}

void LuaScriptUtilities::NameVM(
    lua_State* const luaVM, const char* const vmName)
{
    assert(luaVM);

    // Set's the name of the VM that shows up in Decoda's Virtual Machine
    // window.
    lua_pushstring(luaVM, vmName);
    lua_setglobal(luaVM, "decoda_name");
}

int LuaScriptUtilities::PushBoolAttribute(
    lua_State* const luaVM,
    const bool value,
    const Ogre::String attributeName,
    const int tableIndex)
{
    lua_pushstring(luaVM, attributeName.c_str());
    lua_pushboolean(luaVM, value);
    lua_settable(luaVM, tableIndex);
    return 1;
}

int LuaScriptUtilities::PushColorValue(
    lua_State* const luaVM, const Ogre::ColourValue& color)
{
    lua_newtable(luaVM);
    const int tableIndex = lua_gettop(luaVM);

    LuaScriptUtilities::PushRealAttribute(luaVM, color.r, "red", tableIndex);
    LuaScriptUtilities::PushRealAttribute(luaVM, color.g, "green", tableIndex);
    LuaScriptUtilities::PushRealAttribute(luaVM, color.b, "blue", tableIndex);
    LuaScriptUtilities::PushRealAttribute(luaVM, color.a, "alpha", tableIndex);

    return 2;
}

int LuaScriptUtilities::PushDataType(
    lua_State* const luaVM,
    void* const rawPointer,
    const RawScriptType type)
{
    const size_t scriptTypeSize = sizeof(LuaScriptType);

    LuaScriptType* const scriptType =
        static_cast<LuaScriptType*>(lua_newuserdata(luaVM, scriptTypeSize));

    scriptType->rawPointer = rawPointer;
    scriptType->type = type;

    luaL_getmetatable(luaVM, LUA_SCRIPT_TYPE_METATABLE);
    lua_setmetatable(luaVM, -2);

    return 1;
}

int LuaScriptUtilities::PushDataTypeAttribute(
    lua_State* const luaVM,
    void* const rawPointer,
    const Ogre::String& attributeName,
    const RawScriptType type,
    const int tableIndex)
{
    PushString(luaVM, attributeName);
    PushDataType(luaVM, rawPointer, type);
    lua_settable(luaVM, tableIndex);
    return 1;
}

int LuaScriptUtilities::PushErrorMessageAndDie(
    lua_State* const luaVM, const Ogre::String& message)
{
    PushString(luaVM, message);
    lua_error(luaVM);
    return 0;
}

int LuaScriptUtilities::PushInt(lua_State* const luaVM, const int value)
{
    lua_pushinteger(luaVM, value);
    return 1;
}

int LuaScriptUtilities::PushIntAttribute(
    lua_State* const luaVM,
    const int value,
    const Ogre::String attributeName,
    const int tableIndex)
{
    PushString(luaVM, attributeName);
    PushInt(luaVM, value);
    lua_settable(luaVM, tableIndex);
    return 1;
}

int LuaScriptUtilities::PushKeyboardEvent(
    lua_State* const luaVM, const Ogre::String key, const bool pressed)
{
    lua_newtable(luaVM);
    const int eventTableIndex = lua_gettop(luaVM);
    PushStringAttribute(luaVM, "keyboard", "source", eventTableIndex);
    PushBoolAttribute(luaVM, pressed, "pressed", eventTableIndex);
    PushStringAttribute(luaVM, key, "key", eventTableIndex);

    return 1;
}

int LuaScriptUtilities::PushMouseEvent(
    lua_State* const luaVM,
    const int width,
    const int height,
    const Ogre::String button,
    const bool pressed)
{
    lua_newtable(luaVM);
    const int eventTableIndex = lua_gettop(luaVM);
    PushStringAttribute(luaVM, "mouse", "source", eventTableIndex);
    PushIntAttribute(luaVM, width, "width", eventTableIndex);
    PushIntAttribute(luaVM, height, "height", eventTableIndex);
    PushBoolAttribute(luaVM, pressed, "pressed", eventTableIndex);
    PushStringAttribute(luaVM, button, "button", eventTableIndex);

    return 1;
}

int LuaScriptUtilities::PushMouseMoveEvent(
    lua_State* const luaVM,
    const int width,
    const int height)
{
    lua_newtable(luaVM);
    const int eventTableIndex = lua_gettop(luaVM);
    PushStringAttribute(luaVM, "mouse", "source", eventTableIndex);
    PushIntAttribute(luaVM, width, "width", eventTableIndex);
    PushIntAttribute(luaVM, height, "height", eventTableIndex);

    return 1;
}

int LuaScriptUtilities::PushReal(lua_State* const luaVM, const Ogre::Real real)
{
    lua_pushnumber(luaVM, static_cast<lua_Number>(real));
    return 1;
}

int LuaScriptUtilities::PushRealAttribute(
    lua_State* const luaVM,
    const Ogre::Real real,
    const Ogre::String attributeName,
    const int tableIndex)
{
    PushString(luaVM, attributeName);
    PushReal(luaVM, real);
    lua_settable(luaVM, tableIndex);
    return 1;
}

int LuaScriptUtilities::PushString(
    lua_State* const luaVM, const Ogre::String value)
{
    lua_pushstring(luaVM, value.c_str());
    return 1;
}

int LuaScriptUtilities::PushStringAttribute(
    lua_State* const luaVM,
    const Ogre::String attributeValue,
    const Ogre::String attributeName,
    const int tableIndex)
{
    PushString(luaVM, attributeName);
    PushString(luaVM, attributeValue);
    lua_settable(luaVM, tableIndex);
    return 1;
}

int LuaScriptUtilities::PushVector2(
    lua_State* const luaVM, const Ogre::Vector2& vector)
{
    lua_newtable(luaVM);
    const int tableIndex = lua_gettop(luaVM);

    LuaScriptUtilities::PushRealAttribute(luaVM, vector.x, "x", tableIndex);
    LuaScriptUtilities::PushRealAttribute(luaVM, vector.y, "y", tableIndex);

    return 1;
}

int LuaScriptUtilities::PushVector2Attribute(
    lua_State* const luaVM,
    const Ogre::Vector2& vector,
    const Ogre::String attributeName,
    const int tableIndex)
{
    lua_pushstring(luaVM, attributeName.c_str());
    PushVector2(luaVM, vector);
    lua_settable(luaVM, tableIndex);
    return 1;
}

int LuaScriptUtilities::PushVector3(
    lua_State* const luaVM, const Ogre::Vector3& vector)
{
    const size_t vectorSize = sizeof(Ogre::Vector3);

    Ogre::Vector3* const scriptType =
        static_cast<Ogre::Vector3*>(lua_newuserdata(luaVM, vectorSize));

    *scriptType = vector;

    luaL_getmetatable(luaVM, LUA_VECTOR3_METATABLE);
    lua_setmetatable(luaVM, -2);
    return 1;
}

int LuaScriptUtilities::PushVector3Attribute(
    lua_State* const luaVM,
    const Ogre::Vector3& vector,
    const Ogre::String attributeName,
    const int tableIndex)
{
    lua_pushstring(luaVM, attributeName.c_str());
    PushVector3(luaVM, vector);
    lua_settable(luaVM, tableIndex);
    return 1;
}

Ogre::Quaternion LuaScriptUtilities::QuaternionFromRotationDegrees(
    const Ogre::Vector3& degrees)
{
    return QuaternionFromRotationDegrees(degrees.x, degrees.y, degrees.z);
}

Ogre::Quaternion LuaScriptUtilities::QuaternionFromRotationDegrees(
    Ogre::Real xRotation, Ogre::Real yRotation, Ogre::Real zRotation)
{
    Ogre::Matrix3 matrix;
    matrix.FromEulerAnglesXYZ(
        Ogre::Degree(xRotation), Ogre::Degree(yRotation), Ogre::Degree(zRotation));
    return Ogre::Quaternion(matrix);
}

Ogre::Vector3 LuaScriptUtilities::QuaternionToRotationDegrees(
    const Ogre::Quaternion& quaternion)
{
    Ogre::Vector3 angles;

    Ogre::Radian xAngle;
    Ogre::Radian yAngle;
    Ogre::Radian zAngle;

    Ogre::Matrix3 rotation;
    quaternion.ToRotationMatrix(rotation);
    rotation.ToEulerAnglesXYZ(xAngle, yAngle, zAngle);

    angles.x = xAngle.valueDegrees();
    angles.y = yAngle.valueDegrees();
    angles.z = zAngle.valueDegrees();

    return angles;
}

void LuaScriptUtilities::RequireLuaModule(
    lua_State* const luaVM, const Ogre::String luaScriptFileName)
{
    LuaFileManager* const fileManager = LuaFileManager::getSingletonPtr();

    const LuaFilePtr script = fileManager->load(
        luaScriptFileName,
        Ogre::ResourceGroupManager::DEFAULT_RESOURCE_GROUP_NAME);

    LoadScript(
        luaVM,
        script->GetData(),
        script->GetDataLength(),
        script->getName().c_str());
}

void LuaScriptUtilities::Remove(Ogre::SceneNode* node)
{
    node->getParent()->removeChild(node);
    node->getCreator()->destroySceneNode(node);
}

void LuaScriptUtilities::SetLineStartEnd(
    Ogre::SceneNode* line,
    const Ogre::Vector3& start,
    const Ogre::Vector3& end)
{
    Ogre::Vector3 lineVector = end - start;

    Ogre::Quaternion lineRotation =
        Ogre::Vector3::UNIT_Z.getRotationTo(lineVector.normalisedCopy());

    line->setOrientation(lineRotation *
        Ogre::Quaternion(Ogre::Degree(90), Ogre::Vector3::UNIT_X));
    line->setPosition(start);
    line->setScale(0.01f, lineVector.length(), 0.01f);
}

void LuaScriptUtilities::SetLightRange(
    Ogre::Light* const light, const Ogre::Real range)
{
    light->setAttenuation(range, 1.0, 4.5f/range, 75.0f / (range * range));
}