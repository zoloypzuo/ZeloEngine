#ifndef DEMO_FRAMEWORK_SANDBOX_H
#define DEMO_FRAMEWORK_SANDBOX_H

#include <map>
#include <vector>

#include "demo_framework/include/Object.h"

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


// 场景图的根节点
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
		unsigned int sandboxId,
		Ogre::SceneNode* sandboxNode,
		Ogre::Camera* camera);

	~Sandbox();

	void AddAgent(Agent* agent);

	void AddEvent(const Event& event);

	void AddNavigationMesh(const Ogre::String& name, NavigationMesh& navMesh);

	void AddObjectEventCallback(
		Object* object, lua_State* luaVM, int functionIndex);

	void AddSandboxObject(SandboxObject* sandboxObject);

	void AddSandboxObjectCollisionCallback(
		SandboxObject* sandboxObject,
		lua_State* luaVM,
		int functionIndex);

	void Cleanup();

	UserInterfaceComponent* CreateUIComponent(size_t layerIndex) const;

	UserInterfaceComponent* CreateUIComponent3d(const Ogre::Vector3& position) const;

	void DrawInfluenceMap(
		size_t layer,
		const Ogre::ColourValue& positiveValue,
		const Ogre::ColourValue& zeroValue,
		const Ogre::ColourValue& negativeValue) const;

	int GenerateAgentId();

	int GenerateObjectId();

	Agent* GetAgent(unsigned int agentId);

	const Agent* GetAgent(unsigned int agentId) const;

	std::vector<Agent*>& GetAgents();

	const std::vector<Agent*>& GetAgents() const;

	Ogre::Camera* GetCamera() const;

	Ogre::Vector3 GetCameraForward() const;

	Ogre::Vector3 GetCameraLeft() const;

	Ogre::Quaternion GetCameraOrientation() const;

	const Ogre::Vector3& GetCameraPosition() const;

	Ogre::Vector3 GetCameraUp() const;

	bool GetDrawPhysicsWorld() const;

	std::vector<SandboxObject*> GetFixedObjects();

	InfluenceMap* GetInfluenceMap() const;

	InfluenceMapDrawer* GetInfluenceMapDrawer() const;

	lua_State* GetLuaVM() const;

	Ogre::ColourValue GetMarkupColor(int index) const;

	NavigationMesh* GetNavigationMesh(const Ogre::String& navMeshName);

	size_t GetNumberOfAgents() const;

	std::map<unsigned int, SandboxObject*>& GetObjects();

	const std::map<unsigned int, SandboxObject*>& GetObjects() const;

	Ogre::SceneNode* GetRootNode();

	const Ogre::SceneNode* GetRootNode() const;

	PhysicsWorld* GetPhysicsWorld();

	const PhysicsWorld* GetPhysicsWorld() const;

	long long GetProfileTime(ProfileTime profile) const;

	SandboxObject* GetSandboxObject(unsigned int objectId);

	Ogre::SceneManager* GetSceneManager() const;

	int GetScreenHeight() const;

	int GetScreenWidth() const;

	Ogre::Real GetTimeInMillis() const;

	Ogre::Real GetTimeInSeconds() const;

	UserInterface* GetUserInterface() const;

	void HandleKeyPress(OIS::KeyCode keycode, unsigned int key);

	void HandleKeyRelease(OIS::KeyCode keycode, unsigned int key);

	void HandleMouseMove(int width, int height);

	void HandleMousePress(
		int width, int height, OIS::MouseButtonID button);

	void HandleMouseRelease(
		int width, int height, OIS::MouseButtonID button);

	void Initialize();

	void LoadScript(
		const char* luaScript,
		size_t bufferSize,
		const char* fileName);

	bool RayCastToObject(
		const Ogre::Vector3& from,
		const Ogre::Vector3& to,
		Ogre::Vector3& hitPoint,
		Object*& object) const;

	static bool ReloadScript(
		const char* luaScript,
		size_t bufferSize,
		const char* fileName);

	void RemoveSandboxObject(SandboxObject* sandboxObject);

	void SetDrawInfluenceMap(bool drawInfluenceMap) const;

	void SetDrawPhysicsWorld(bool drawPhysicsWorld);

	void SetInfluence(
		size_t layer,
		const Ogre::Vector3& position,
		float influence) const;

	void SetInfluenceMap(InfluenceMap* influenceMap);

	void SetMarkupColor(int index, const Ogre::ColourValue& color) const;

	void SetProfileTime(ProfileTime profile, long long time);

	void Update(int deltaMilliseconds);

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
}; // class Sandbox

#endif  // DEMO_FRAMEWORK_SANDBOX_H
