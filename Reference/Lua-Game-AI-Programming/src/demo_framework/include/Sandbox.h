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

#ifndef DEMO_FRAMEWORK_SANDBOX_H
#define DEMO_FRAMEWORK_SANDBOX_H

#include <map>
#include <vector>

#include "demo_framework/include/Object.h"
#include "ogre3d/include/OgreTimer.h"

struct lua_State;

class Agent;
class AgentGroup;
class Collision;
class Event;
class InfluenceMap;
class InfluenceMapDrawer;
class NavigationMesh;
class PhysicsWorld;
class SandboxObject;
class UserInterface;
class UserInterfaceComponent;

namespace OIS
{
enum KeyCode;
enum MouseButtonID;
}

namespace Ogre
{
class Camera;
class SceneNode;
class Quaternion;
class Vector3;
}

class Sandbox : public Object
{
public:
    enum ProfileTime
    {
        RENDER_TIME,
        SIMULATION_TIME,
        TOTAL_SIMULATION_TIME,

        PROFILE_TIME_COUNT
    };

    Sandbox(
        const unsigned int sandboxId,
        Ogre::SceneNode* const sandboxNode,
        Ogre::Camera* const camera);

    ~Sandbox();

    void AddAgent(Agent* const agent);

    void AddEvent(const Event& event);

    void AddNavigationMesh(const Ogre::String& name, NavigationMesh& navMesh);

    void AddObjectEventCallback(
        Object* const object, lua_State* luaVM, const int functionIndex);

    void AddSandboxObject(SandboxObject* const sandboxObject);

    void AddSandboxObjectCollisionCallback(
        SandboxObject* const sandboxObject,
        lua_State* luaVM,
        const int functionIndex);

    void Cleanup();

    UserInterfaceComponent* CreateUIComponent(size_t layerIndex);

    UserInterfaceComponent* CreateUIComponent3d(const Ogre::Vector3& position);

    void DrawInfluenceMap(
        const size_t layer,
        const Ogre::ColourValue& positiveValue,
        const Ogre::ColourValue& zeroValue,
        const Ogre::ColourValue& negativeValue);

    int GenerateAgentId();

    int GenerateObjectId();

    Agent* GetAgent(const unsigned int agentId);

    const Agent* GetAgent(const unsigned int agentId) const;

    std::vector<Agent*>& GetAgents();

    const std::vector<Agent*>& GetAgents() const;

    Ogre::Camera* GetCamera();

    Ogre::Vector3 GetCameraForward();

    Ogre::Vector3 GetCameraLeft();

    Ogre::Quaternion GetCameraOrientation();

    const Ogre::Vector3& GetCameraPosition();

    Ogre::Vector3 GetCameraUp();

    bool GetDrawPhysicsWorld();

    std::vector<SandboxObject*> GetFixedObjects();

    InfluenceMap* GetInfluenceMap();

    InfluenceMapDrawer* GetInfluenceMapDrawer();

    lua_State* GetLuaVM();

    Ogre::ColourValue GetMarkupColor(const int index) const;

    NavigationMesh* GetNavigationMesh(const Ogre::String& navMeshName);

    size_t GetNumberOfAgents() const;

    std::map<unsigned int, SandboxObject*>& GetObjects();

    const std::map<unsigned int, SandboxObject*>& GetObjects() const;

    Ogre::SceneNode* GetRootNode();

    const Ogre::SceneNode* GetRootNode() const;

    PhysicsWorld* GetPhysicsWorld();

    const PhysicsWorld* GetPhysicsWorld() const;

    long long GetProfileTime(const ProfileTime profile) const;

    SandboxObject* GetSandboxObject(const unsigned int objectId);

    Ogre::SceneManager* GetSceneManager();

    int GetScreenHeight() const;

    int GetScreenWidth() const;

    Ogre::Real GetTimeInMillis();

    Ogre::Real GetTimeInSeconds();

    UserInterface* GetUserInterface();

    void HandleKeyPress(const OIS::KeyCode keycode, unsigned int key);

    void HandleKeyRelease(const OIS::KeyCode keycode, unsigned int key);

    void HandleMouseMove(const int width, const int height);

    void HandleMousePress(
        const int width, const int height, const OIS::MouseButtonID button);

    void HandleMouseRelease(
        const int width, const int height, const OIS::MouseButtonID button);

    void Initialize();

    void LoadScript(
        const char* const luaScript,
        const size_t bufferSize,
        const char* const fileName);

    bool RayCastToObject(
        const Ogre::Vector3& from,
        const Ogre::Vector3& to,
        Ogre::Vector3& hitPoint,
        Object*& object) const;

    bool ReloadScript(
        const char* const luaScript,
        const size_t bufferSize,
        const char* const fileName);

    void RemoveSandboxObject(SandboxObject* const sandboxObject);

    void SetDrawInfluenceMap(const bool drawInfluenceMap);

    void SetDrawPhysicsWorld(const bool drawPhysicsWorld);

    void SetInfluence(
        const size_t layer,
        const Ogre::Vector3& position,
        const float influence);

    void SetInfluenceMap(InfluenceMap* const influenceMap);

    void SetMarkupColor(const int index, const Ogre::ColourValue& color);

    void SetProfileTime(const ProfileTime profile, const long long time);

    void Update(const int deltaMilliseconds);

private:
    struct LuaCallback
    {
        lua_State* luaVM;
        int callbackIndex;
        Object* object;
    };

    long long profileTimes_[PROFILE_TIME_COUNT];

    lua_State* luaVM_;
    Ogre::SceneNode* sandboxNode_;
    Ogre::Camera* camera_;
    PhysicsWorld* physicsWorld_;
    UserInterface* userInterface_;

    int lastAgentId_;
    std::vector<Agent*> agents_;

    int lastObjectId_;
    std::map<unsigned int, SandboxObject*> objects_;
    std::map<unsigned int, SandboxObject*> objectsForRemoval_;
    std::map<unsigned int, std::vector<LuaCallback>> collisionCallbacks_;

    std::map<Ogre::String, NavigationMesh*> navMeshes_;

    InfluenceMap* influenceMap_;
    InfluenceMapDrawer* influenceMapDrawer_;

    std::vector<Event> events_;
    std::map<unsigned int, LuaCallback> eventCallbacks_;

    bool drawPhysicsWorld_;

    long long simulationTime_;

    Sandbox(const Sandbox&);
    Sandbox& operator=(const Sandbox&);

    void HandleCollisions(std::vector<Collision>& collisions);

    void HandleEvents(std::vector<Event>& events);

    void RemoveSandboxObjects();
};  // class Sandbox

#endif  // DEMO_FRAMEWORK_SANDBOX_H
