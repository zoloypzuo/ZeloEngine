#include "PrecompiledHeaders.h"

#include "demo_framework/include/Agent.h"
#include "demo_framework/include/AgentUtilities.h"
#include "demo_framework/include/AnimationUtilities.h"
#include "demo_framework/include/Collision.h"
#include "demo_framework/include/Event.h"
#include "demo_framework/include/LuaScriptUtilities.h"
#include "demo_framework/include/InfluenceMap.h"
#include "demo_framework/include/InfluenceMapDrawer.h"
#include "demo_framework/include/NavigationMesh.h"
#include "demo_framework/include/PhysicsUtilities.h"
#include "demo_framework/include/PhysicsWorld.h"
#include "demo_framework/include/Sandbox.h"
#include "demo_framework/include/SandboxObject.h"
#include "demo_framework/include/SandboxUtilities.h"
#include "demo_framework/include/UserInterface.h"
#include "demo_framework/include/UserInterfaceComponent.h"
#include "demo_framework/include/UserInterfaceUtilities.h"

namespace
{
	Ogre::String MouseButtonToString(const OIS::MouseButtonID button)
	{
		switch (button)
		{
		case OIS::MB_Left:
			return "left_button";
		case OIS::MB_Right:
			return "right_button";
		case OIS::MB_Middle:
			return "middle_button";
		case OIS::MB_Button3:
			return "mouse_button_3";
		case OIS::MB_Button4:
			return "mouse_button_4";
		case OIS::MB_Button5:
			return "mouse_button_5";
		case OIS::MB_Button6:
			return "mouse_button_6";
		case OIS::MB_Button7:
			return "mouse_button_7";
		default:
			break;
		}

		return "unknown_button";
	}

	Ogre::String KeyCodeToString(const OIS::KeyCode keyCode)
	{
		switch (keyCode)
		{
		case OIS::KC_UNASSIGNED:
			return "unassigned_key";
		case OIS::KC_ESCAPE:
			return "escape_key";
		case OIS::KC_1:
			return "1_key";
		case OIS::KC_2:
			return "2_key";
		case OIS::KC_3:
			return "3_key";
		case OIS::KC_4:
			return "4_key";
		case OIS::KC_5:
			return "5_key";
		case OIS::KC_6:
			return "6_key";
		case OIS::KC_7:
			return "7_key";
		case OIS::KC_8:
			return "8_key";
		case OIS::KC_9:
			return "9_key";
		case OIS::KC_0:
			return "0_key";
		case OIS::KC_MINUS:
			return "minus_key";
		case OIS::KC_EQUALS:
			return "equals_key";
		case OIS::KC_BACK:
			return "back_key";
		case OIS::KC_TAB:
			return "tab_key";
		case OIS::KC_Q:
			return "q_key";
		case OIS::KC_W:
			return "w_key";
		case OIS::KC_E:
			return "e_key";
		case OIS::KC_R:
			return "r_key";
		case OIS::KC_T:
			return "t_key";
		case OIS::KC_Y:
			return "y_key";
		case OIS::KC_U:
			return "u_key";
		case OIS::KC_I:
			return "i_key";
		case OIS::KC_O:
			return "o_key";
		case OIS::KC_P:
			return "p_key";
		case OIS::KC_LBRACKET:
			return "left_bracket_key";
		case OIS::KC_RBRACKET:
			return "right_bracket_key";
		case OIS::KC_RETURN:
			return "return_key";
		case OIS::KC_LCONTROL:
			return "left_control_key";
		case OIS::KC_A:
			return "a_key";
		case OIS::KC_S:
			return "s_key";
		case OIS::KC_D:
			return "d_key";
		case OIS::KC_F:
			return "f_key";
		case OIS::KC_G:
			return "g_key";
		case OIS::KC_H:
			return "h_key";
		case OIS::KC_J:
			return "j_key";
		case OIS::KC_K:
			return "k_key";
		case OIS::KC_L:
			return "l_key";
		case OIS::KC_SEMICOLON:
			return "semicolon_key";
		case OIS::KC_APOSTROPHE:
			return "apostrophe_key";
		case OIS::KC_GRAVE:
			return "grave_key";
		case OIS::KC_LSHIFT:
			return "left_shift_key";
		case OIS::KC_BACKSLASH:
			return "backslash_key";
		case OIS::KC_Z:
			return "z_key";
		case OIS::KC_X:
			return "x_key";
		case OIS::KC_C:
			return "c_key";
		case OIS::KC_V:
			return "v_key";
		case OIS::KC_B:
			return "b_key";
		case OIS::KC_N:
			return "n_key";
		case OIS::KC_M:
			return "m_key";
		case OIS::KC_COMMA:
			return "comma_key";
		case OIS::KC_PERIOD:
			return "period_key";
		case OIS::KC_SLASH:
			return "slash_key";
		case OIS::KC_RSHIFT:
			return "right_shift_key";
		case OIS::KC_MULTIPLY:
			return "multiply_key";
		case OIS::KC_LMENU:
			return "left_menu_key";
		case OIS::KC_SPACE:
			return "space_key";
		case OIS::KC_CAPITAL:
			return "capital_key";
		case OIS::KC_F1:
			return "f1_key";
		case OIS::KC_F2:
			return "f2_key";
		case OIS::KC_F3:
			return "f3_key";
		case OIS::KC_F4:
			return "f4_key";
		case OIS::KC_F5:
			return "f5_key";
		case OIS::KC_F6:
			return "f6_key";
		case OIS::KC_F7:
			return "f7_key";
		case OIS::KC_F8:
			return "f8_key";
		case OIS::KC_F9:
			return "f9_key";
		case OIS::KC_F10:
			return "f10_key";
		case OIS::KC_NUMLOCK:
			return "numlock_key";
		case OIS::KC_SCROLL:
			return "scroll_key";
		case OIS::KC_NUMPAD7:
			return "numpad_7_key";
		case OIS::KC_NUMPAD8:
			return "numpad_8_key";
		case OIS::KC_NUMPAD9:
			return "numpad_9_key";
		case OIS::KC_SUBTRACT:
			return "subtract_key";
		case OIS::KC_NUMPAD4:
			return "numpad_4_key";
		case OIS::KC_NUMPAD5:
			return "numpad_5_key";
		case OIS::KC_NUMPAD6:
			return "numpad_6_key";
		case OIS::KC_ADD:
			return "add_key";
		case OIS::KC_NUMPAD1:
			return "numpad_1_key";
		case OIS::KC_NUMPAD2:
			return "numpad_2_key";
		case OIS::KC_NUMPAD3:
			return "numpad_3_key";
		case OIS::KC_NUMPAD0:
			return "numpad_0_key";
		case OIS::KC_DECIMAL:
			return "decimal_key";
		case OIS::KC_OEM_102:
			return "oem_102_key";
		case OIS::KC_F11:
			return "f11_key";
		case OIS::KC_F12:
			return "f12_key";
		case OIS::KC_F13:
			return "f13_key";
		case OIS::KC_F14:
			return "f14_key";
		case OIS::KC_F15:
			return "f15_key";
		case OIS::KC_KANA:
			return "kana_key";
		case OIS::KC_ABNT_C1:
			return "abnt_c1_key";
		case OIS::KC_CONVERT:
			return "convert_key";
		case OIS::KC_NOCONVERT:
			return "no_convert_key";
		case OIS::KC_YEN:
			return "yen_key";
		case OIS::KC_ABNT_C2:
			return "abnt_c2_key";
		case OIS::KC_NUMPADEQUALS:
			return "numpad_equals_key";
		case OIS::KC_PREVTRACK:
			return "prev_track_key";
		case OIS::KC_AT:
			return "at_key";
		case OIS::KC_COLON:
			return "colon_key";
		case OIS::KC_UNDERLINE:
			return "underline_key";
		case OIS::KC_KANJI:
			return "kanji_key";
		case OIS::KC_STOP:
			return "stop_key";
		case OIS::KC_AX:
			return "ax_key";
		case OIS::KC_UNLABELED:
			return "unlabeled_key";
		case OIS::KC_NEXTTRACK:
			return "next_track_key";
		case OIS::KC_NUMPADENTER:
			return "numpad_enter_key";
		case OIS::KC_RCONTROL:
			return "right_control_key";
		case OIS::KC_MUTE:
			return "mute_key";
		case OIS::KC_CALCULATOR:
			return "calculator_key";
		case OIS::KC_PLAYPAUSE:
			return "play_pause_key";
		case OIS::KC_MEDIASTOP:
			return "media_stop_key";
		case OIS::KC_VOLUMEDOWN:
			return "volume_down_key";
		case OIS::KC_VOLUMEUP:
			return "volume_up_key";
		case OIS::KC_WEBHOME:
			return "webhome_key";
		case OIS::KC_NUMPADCOMMA:
			return "numpad_comma_key";
		case OIS::KC_DIVIDE:
			return "divide_key";
		case OIS::KC_SYSRQ:
			return "system_request_key";
		case OIS::KC_RMENU:
			return "right_menu_key";
		case OIS::KC_PAUSE:
			return "pause_key";
		case OIS::KC_HOME:
			return "home_key";
		case OIS::KC_UP:
			return "up_key";
		case OIS::KC_PGUP:
			return "page_up_key";
		case OIS::KC_LEFT:
			return "left_key";
		case OIS::KC_RIGHT:
			return "right_key";
		case OIS::KC_END:
			return "end_key";
		case OIS::KC_DOWN:
			return "down_key";
		case OIS::KC_PGDOWN:
			return "page_down_key";
		case OIS::KC_INSERT:
			return "insert_key";
		case OIS::KC_DELETE:
			return "delete_key";
		case OIS::KC_LWIN:
			return "left_windows_key";
		case OIS::KC_RWIN:
			return "right_windows_key";
		case OIS::KC_APPS:
			return "application_key";
		case OIS::KC_POWER:
			return "power_key";
		case OIS::KC_SLEEP:
			return "sleep_key";
		case OIS::KC_WAKE:
			return "wake_key";
		case OIS::KC_WEBSEARCH:
			return "web_search_key";
		case OIS::KC_WEBFAVORITES:
			return "web_favorites_key";
		case OIS::KC_WEBREFRESH:
			return "web_refresh_key";
		case OIS::KC_WEBSTOP:
			return "web_stop_key";
		case OIS::KC_WEBFORWARD:
			return "web_forward_key";
		case OIS::KC_WEBBACK:
			return "web_back_key";
		case OIS::KC_MYCOMPUTER:
			return "my_computer_key";
		case OIS::KC_MAIL:
			return "mail_key";
		case OIS::KC_MEDIASELECT:
			return "media_select_key";
		default:
			break;
		}
		return "unknown_key";
	}
} // anonymous namespace


// ��ʼ��sandbox���ò���
// ����lua vm�����غ�����
Sandbox::Sandbox(
	const unsigned int sandboxId,
	Ogre::SceneNode* const sandboxNode,
	Ogre::Camera* const camera)
	: Object(sandboxId, Object::SANDBOX),
	  sandboxNode_(sandboxNode),
	  camera_(camera),
	  physicsWorld_(nullptr),
	  userInterface_(nullptr),
	  lastObjectId_(sandboxId),
	  influenceMap_(nullptr),
	  influenceMapDrawer_(nullptr),
	  drawPhysicsWorld_(false),
	  simulationTime_(0)
{
	for (size_t index = 0; index < PROFILE_TIME_COUNT; ++index)
	{
		profileTimes_[index] = 0;
	}

	luaVM_ = LuaScriptUtilities::CreateVM();

	// Add general Core library functions.
	LuaScriptUtilities::BindVMFunctions(luaVM_);

	// Add Sandbox specific library functions.
	SandboxUtilities::BindVMFunctions(luaVM_);

	// Add Agent specific library functions.
	AgentUtilities::BindVMFunctions(luaVM_);

	// Add Animation specific functions.
	AnimationUtilities::BindVMFunctions(luaVM_);

	// Add ui specific functions.
	UserInterfaceUtilities::BindVMFunctions(luaVM_);
}

Sandbox::~Sandbox()
{
	LuaScriptUtilities::DestroyVM(luaVM_);

	std::vector<Agent*>::iterator it;

	for (it = agents_.begin(); it != agents_.end(); ++it)
	{
		delete *it;
	}

	if (influenceMapDrawer_)
	{
		delete influenceMapDrawer_;
	}

	if (influenceMap_)
	{
		delete influenceMap_;
	}

	agents_.clear();
}

void Sandbox::AddAgent(Agent* const agent)
{
	agents_.push_back(agent);

	agent->Initialize();
}

void Sandbox::AddEvent(const Event& event)
{
	events_.push_back(event);
}

void Sandbox::AddNavigationMesh(
	const Ogre::String& name, NavigationMesh& navMesh)
{
	if (navMeshes_[name])
	{
		delete navMeshes_[name];
	}

	navMeshes_[name] = &navMesh;
}

void Sandbox::AddObjectEventCallback(
	Object* const object, lua_State* luaVM, const int functionIndex)
{
	eventCallbacks_[object->GetId()].luaVM = luaVM;
	eventCallbacks_[object->GetId()].callbackIndex = functionIndex;
	eventCallbacks_[object->GetId()].object = object;
}

void Sandbox::AddSandboxObject(SandboxObject* const sandboxObject)
{
	objects_[sandboxObject->GetId()] = sandboxObject;

	sandboxObject->Initialize();

	if (physicsWorld_)
	{
		physicsWorld_->AddRigidBody(sandboxObject->GetRigidBody());
	}
}

void Sandbox::AddSandboxObjectCollisionCallback(
	SandboxObject* const sandboxObject,
	lua_State* luaVM,
	const int functionIndex)
{
	LuaCallback callback;
	callback.luaVM = luaVM;
	callback.callbackIndex = functionIndex;
	callback.object = sandboxObject;

	if (collisionCallbacks_.find(sandboxObject->GetId()) == collisionCallbacks_.end())
	{
		collisionCallbacks_[sandboxObject->GetId()] = std::vector<LuaCallback>();
	}

	collisionCallbacks_[sandboxObject->GetId()].push_back(callback);
}

void Sandbox::Cleanup()
{
	std::vector<Agent*>::iterator agentIt;
	for (agentIt = agents_.begin(); agentIt != agents_.end(); ++agentIt)
	{
		(*agentIt)->Cleanup();
	}

	std::map<unsigned int, SandboxObject*>::iterator objectIt;
	for (objectIt = objects_.begin(); objectIt != objects_.end(); ++objectIt)
	{
		objectIt->second->Cleanup();
	}

	SandboxUtilities::CallLuaSandboxCleanup(this);

	if (physicsWorld_)
	{
		physicsWorld_->Cleanup();
		delete physicsWorld_;
		physicsWorld_ = nullptr;
	}

	if (userInterface_)
	{
		delete userInterface_;
		userInterface_ = nullptr;
	}
}

UserInterfaceComponent* Sandbox::CreateUIComponent(size_t layerIndex) const
{
	return userInterface_->CreateComponent(layerIndex);
}

UserInterfaceComponent* Sandbox::CreateUIComponent3d(
	const Ogre::Vector3& position) const
{
	UserInterfaceComponent* const component =
		userInterface_->Create3DComponent(*sandboxNode_->createChildSceneNode());

	component->SetWorldPosition(position);

	return component;
}

void Sandbox::DrawInfluenceMap(
	const size_t layer,
	const Ogre::ColourValue& positiveValue,
	const Ogre::ColourValue& zeroValue,
	const Ogre::ColourValue& negativeValue) const
{
	if (influenceMap_ && influenceMapDrawer_ && layer < MAX_INFLUENCE_LAYERS)
	{
		influenceMapDrawer_->DrawInfluenceMap(
			*influenceMap_,
			layer,
			positiveValue,
			zeroValue,
			negativeValue);
	}
}

int Sandbox::GenerateAgentId()
{
	return ++lastObjectId_;
}

int Sandbox::GenerateObjectId()
{
	return ++lastObjectId_;
}

Agent* Sandbox::GetAgent(const unsigned int agentId)
{
	std::vector<Agent*>::iterator it;

	for (it = agents_.begin(); it != agents_.end(); ++it)
	{
		if ((*it)->GetId() == agentId)
		{
			return *it;
		}
	}
	return nullptr;
}

const Agent* Sandbox::GetAgent(const unsigned int agentId) const
{
	std::vector<Agent*>::const_iterator it;

	for (it = agents_.begin(); it != agents_.end(); ++it)
	{
		if ((*it)->GetId() == agentId)
		{
			return *it;
		}
	}
	return nullptr;
}

std::vector<Agent*>& Sandbox::GetAgents()
{
	return agents_;
}

const std::vector<Agent*>& Sandbox::GetAgents() const
{
	return agents_;
}

Ogre::Camera* Sandbox::GetCamera() const
{
	return camera_;
}

Ogre::Vector3 Sandbox::GetCameraForward() const
{
	return camera_->getDerivedDirection();
}

Ogre::Vector3 Sandbox::GetCameraLeft() const
{
	return -1.0f * camera_->getDerivedRight();
}

Ogre::Quaternion Sandbox::GetCameraOrientation() const
{
	return camera_->getDerivedOrientation();
}

const Ogre::Vector3& Sandbox::GetCameraPosition() const
{
	return camera_->getDerivedPosition();
}

Ogre::Vector3 Sandbox::GetCameraUp() const
{
	return camera_->getDerivedUp();
}

bool Sandbox::GetDrawPhysicsWorld() const
{
	return drawPhysicsWorld_;
}

std::vector<SandboxObject*> Sandbox::GetFixedObjects()
{
	size_t fixedObjects = 0;

	std::map<unsigned int, SandboxObject*>::iterator it;

	for (it = objects_.begin(); it != objects_.end(); ++it)
	{
		if (it->second->GetMass() <= 0.0f)
		{
			if (!PhysicsUtilities::IsPlane(*it->second->GetRigidBody()))
			{
				++fixedObjects;
			}
		}
	}

	std::vector<SandboxObject*> objects;
	objects.reserve(fixedObjects);

	for (it = objects_.begin(); it != objects_.end(); ++it)
	{
		if (it->second->GetMass() <= 0.0f)
		{
			if (!PhysicsUtilities::IsPlane(*it->second->GetRigidBody()))
			{
				objects.push_back(it->second);
			}
		}
	}

	return objects;
}

InfluenceMap* Sandbox::GetInfluenceMap() const
{
	return influenceMap_;
}

InfluenceMapDrawer* Sandbox::GetInfluenceMapDrawer() const
{
	return influenceMapDrawer_;
}

lua_State* Sandbox::GetLuaVM() const
{
	return luaVM_;
}

Ogre::ColourValue Sandbox::GetMarkupColor(const int index) const
{
	return userInterface_->GetMarkupColor(index);
}

NavigationMesh* Sandbox::GetNavigationMesh(const Ogre::String& navMeshName)
{
	if (navMeshes_.find(navMeshName) != navMeshes_.end())
	{
		return navMeshes_[navMeshName];
	}

	return nullptr;
}

size_t Sandbox::GetNumberOfAgents() const
{
	return agents_.size();
}

std::map<unsigned int, SandboxObject*>& Sandbox::GetObjects()
{
	return objects_;
}

const std::map<unsigned int, SandboxObject*>& Sandbox::GetObjects() const
{
	return objects_;
}

Ogre::SceneNode* Sandbox::GetRootNode()
{
	return sandboxNode_;
}

const Ogre::SceneNode* Sandbox::GetRootNode() const
{
	return sandboxNode_;
}

PhysicsWorld* Sandbox::GetPhysicsWorld()
{
	return physicsWorld_;
}

const PhysicsWorld* Sandbox::GetPhysicsWorld() const
{
	return physicsWorld_;
}

long long Sandbox::GetProfileTime(const ProfileTime profile) const
{
	assert(profile < PROFILE_TIME_COUNT);

	return profileTimes_[profile];
}

SandboxObject* Sandbox::GetSandboxObject(const unsigned int objectId)
{
	return objects_[objectId];
}

Ogre::SceneManager* Sandbox::GetSceneManager() const
{
	return sandboxNode_->getCreator();
}

int Sandbox::GetScreenHeight() const
{
	return camera_->getViewport()->getActualHeight();
}

int Sandbox::GetScreenWidth() const
{
	return camera_->getViewport()->getActualWidth();
}

Ogre::Real Sandbox::GetTimeInMillis() const
{
	return Ogre::Real(simulationTime_);
}

Ogre::Real Sandbox::GetTimeInSeconds() const
{
	return GetTimeInMillis() / 1000.0f;
}

UserInterface* Sandbox::GetUserInterface() const
{
	return userInterface_;
}

void Sandbox::HandleCollisions(std::vector<Collision>& collisions)
{
	std::vector<Collision>::iterator it;

	for (it = collisions.begin(); it != collisions.end(); ++it)
	{
		Collision& collision = *it;

		Object* const objectA =
			PhysicsUtilities::ToObject(collision.GetObjectA());

		Object* const objectB =
			PhysicsUtilities::ToObject(collision.GetObjectB());

		if (objectA)
		{
			if (collisionCallbacks_.find(objectA->GetId()) != collisionCallbacks_.end())
			{
				std::vector<LuaCallback>& callbacks =
					collisionCallbacks_[objectA->GetId()];

				std::vector<LuaCallback>::iterator callbackIt;
				for (callbackIt = callbacks.begin(); callbackIt != callbacks.end(); ++callbackIt)
				{
					// A callback may immediately remove both objects from the sandbox.
					SandboxUtilities::CallLuaCollisionHandler(
						this,
						callbackIt->luaVM,
						callbackIt->callbackIndex,
						objectA,
						objectB,
						collision.GetPointA(),
						collision.GetPointB(),
						collision.GetNormalOnB());

					if (collisionCallbacks_.find(objectA->GetId()) == collisionCallbacks_.end())
					{
						break;
					}
				}
			}
		}

		if (objectB)
		{
			if (collisionCallbacks_.find(objectB->GetId()) != collisionCallbacks_.end())
			{
				std::vector<LuaCallback>& callbacks =
					collisionCallbacks_[objectB->GetId()];

				std::vector<LuaCallback>::iterator callbackIt;
				for (callbackIt = callbacks.begin(); callbackIt != callbacks.end(); ++callbackIt)
				{
					SandboxUtilities::CallLuaCollisionHandler(
						this,
						callbackIt->luaVM,
						callbackIt->callbackIndex,
						objectB,
						objectA,
						collision.GetPointB(),
						collision.GetPointA(),
						-collision.GetNormalOnB());

					if (collisionCallbacks_.find(objectB->GetId()) == collisionCallbacks_.end())
					{
						break;
					}
				}
			}
		}
	}
}

void Sandbox::HandleEvents(std::vector<Event>& events)
{
	std::vector<Event>::iterator eIt;

	for (eIt = events.begin(); eIt != events.end(); ++eIt)
	{
		std::map<unsigned int, LuaCallback>::iterator it;

		for (it = eventCallbacks_.begin(); it != eventCallbacks_.end(); ++it)
		{
			SandboxUtilities::CallLuaEventHandler(
				this,
				it->second.object,
				it->second.luaVM,
				it->second.callbackIndex,
				*eIt);
		}
	}
}

void Sandbox::HandleKeyPress(const OIS::KeyCode keycode, unsigned int key)
{
	(void)key;

	const Ogre::String keyCodeString = KeyCodeToString(keycode);

	SandboxUtilities::CallLuaSandboxHandleKeyboardEvent(
		this, keyCodeString, true);

	std::vector<Agent*>::iterator it;

	for (it = agents_.begin(); it != agents_.end(); ++it)
	{
		AgentUtilities::CallLuaAgentHandleKeyboardEvent(
			*it, keyCodeString, true);
	}
}

void Sandbox::HandleKeyRelease(const OIS::KeyCode keycode, unsigned int key)
{
	(void)key;

	const Ogre::String keyCodeString = KeyCodeToString(keycode);

	SandboxUtilities::CallLuaSandboxHandleKeyboardEvent(
		this, keyCodeString, false);

	std::vector<Agent*>::iterator it;

	for (it = agents_.begin(); it != agents_.end(); ++it)
	{
		AgentUtilities::CallLuaAgentHandleKeyboardEvent(
			*it, keyCodeString, false);
	}
}

void Sandbox::HandleMouseMove(const int width, const int height)
{
	SandboxUtilities::CallLuaSandboxHandleMouseMoveEvent(
		this, width, height);

	std::vector<Agent*>::iterator it;

	for (it = agents_.begin(); it != agents_.end(); ++it)
	{
		AgentUtilities::CallLuaAgentHandleMouseMoveEvent(
			*it, width, height);
	}
}

void Sandbox::HandleMousePress(
	const int width, const int height, const OIS::MouseButtonID button)
{
	const Ogre::String mouseButton = MouseButtonToString(button);

	SandboxUtilities::CallLuaSandboxHandleMouseEvent(
		this, width, height, mouseButton, true);

	std::vector<Agent*>::iterator it;

	for (it = agents_.begin(); it != agents_.end(); ++it)
	{
		AgentUtilities::CallLuaAgentHandleMouseEvent(
			*it, width, height, mouseButton, true);
	}
}

void Sandbox::HandleMouseRelease(
	const int width, const int height, const OIS::MouseButtonID button)
{
	const Ogre::String mouseButton = MouseButtonToString(button);

	SandboxUtilities::CallLuaSandboxHandleMouseEvent(
		this, width, height, mouseButton, false);

	std::vector<Agent*>::iterator it;

	for (it = agents_.begin(); it != agents_.end(); ++it)
	{
		AgentUtilities::CallLuaAgentHandleMouseEvent(
			*it, width, height, mouseButton, false);
	}
}

void Sandbox::Initialize()
{
	Ogre::LogManager::getSingletonPtr()->logMessage(
		"Physics: Creating sandbox physics.", Ogre::LML_NORMAL);

	physicsWorld_ = new PhysicsWorld();
	physicsWorld_->Initialize();

	Ogre::LogManager::getSingletonPtr()->logMessage(
		"Physics: Finished initializing sandbox physics.", Ogre::LML_NORMAL);

	userInterface_ = new UserInterface(camera_->getViewport());

	SandboxUtilities::CallLuaSandboxInitialize(this);
}

void Sandbox::LoadScript(
	const char* const luaScript,
	const size_t bufferSize,
	const char* const fileName)
{
	SandboxUtilities::LoadScript(this, luaScript, bufferSize, fileName);
}

bool Sandbox::RayCastToObject(
	const Ogre::Vector3& from,
	const Ogre::Vector3& to,
	Ogre::Vector3& hitPoint,
	Object*& object) const
{
	btVector3 physicsHitPoint;
	const btRigidBody* rigidBody;

	const bool result = physicsWorld_->RayCastToRigidBody(
		PhysicsUtilities::Vector3ToBtVector3(from),
		PhysicsUtilities::Vector3ToBtVector3(to),
		physicsHitPoint,
		rigidBody);

	if (result)
	{
		object = PhysicsUtilities::ToObject(rigidBody);
		hitPoint = PhysicsUtilities::BtVector3ToVector3(physicsHitPoint);
	}

	return result;
}

bool Sandbox::ReloadScript(
	const char* const luaScript,
	const size_t bufferSize,
	const char* const fileName)
{
	(void)luaScript;
	(void)bufferSize;
	(void)fileName;

	return false;
}

void Sandbox::RemoveSandboxObject(SandboxObject* const sandboxObject)
{
	if (sandboxObject->GetType() == SandboxObject::SANDBOX_OBJECT)
	{
		objectsForRemoval_[sandboxObject->GetId()] = sandboxObject;
	}
}

void Sandbox::RemoveSandboxObjects()
{
	std::map<unsigned int, SandboxObject*>::iterator it;

	for (it = objectsForRemoval_.begin(); it != objectsForRemoval_.end(); ++it)
	{
		SandboxObject* const sandboxObject = it->second;

		std::map<unsigned int, SandboxObject*>::iterator objectIt =
			objects_.find(sandboxObject->GetId());

		if (objectIt != objects_.end())
		{
			objects_.erase(objectIt);

			sandboxObject->Cleanup();

			GetPhysicsWorld()->RemoveRigidBody(sandboxObject->GetRigidBody());

			std::map<unsigned int, std::vector<LuaCallback>>::iterator cIt =
				collisionCallbacks_.find(sandboxObject->GetId());

			if (cIt != collisionCallbacks_.end())
			{
				collisionCallbacks_.erase(sandboxObject->GetId());
			}

			std::map<unsigned int, LuaCallback>::iterator eIt =
				eventCallbacks_.find(sandboxObject->GetId());

			if (eIt != eventCallbacks_.end())
			{
				eventCallbacks_.erase(sandboxObject->GetId());
			}

			delete sandboxObject;
		}
	}

	objectsForRemoval_.clear();
}

void Sandbox::SetDrawInfluenceMap(const bool drawInfluenceMap) const
{
	if (influenceMapDrawer_)
	{
		influenceMapDrawer_->SetVisible(drawInfluenceMap);
	}
}

void Sandbox::SetDrawPhysicsWorld(const bool drawPhysicsWorld)
{
	drawPhysicsWorld_ = drawPhysicsWorld;
}

void Sandbox::SetInfluence(
	const size_t layer,
	const Ogre::Vector3& position,
	const float influence) const
{
	if (influenceMap_ && layer < MAX_INFLUENCE_LAYERS)
	{
		influenceMap_->SetInfluence(position, layer, influence);
	}
}

void Sandbox::SetInfluenceMap(InfluenceMap* const influenceMap)
{
	if (influenceMap_)
	{
		delete influenceMap_;
	}

	if (influenceMapDrawer_)
	{
		delete influenceMapDrawer_;
	}

	influenceMap_ = influenceMap;

	influenceMapDrawer_ = new InfluenceMapDrawer(*sandboxNode_->getCreator());
}

void Sandbox::SetMarkupColor(const int index, const Ogre::ColourValue& color) const
{
	userInterface_->SetMarkupColor(index, color);
}

void Sandbox::SetProfileTime(const ProfileTime profile, const long long time)
{
	if (profile < PROFILE_TIME_COUNT)
	{
		profileTimes_[profile] = time;
	}
}

void Sandbox::Update(const int deltaMilliseconds)
{
	simulationTime_ += deltaMilliseconds;

	RemoveSandboxObjects();

	HandleEvents(events_);
	events_.clear();

	std::vector<Agent*>::iterator agentIt;
	for (agentIt = agents_.begin(); agentIt != agents_.end(); ++agentIt)
	{
		(*agentIt)->Update(deltaMilliseconds);
	}

	std::map<unsigned int, SandboxObject*>::iterator objectIt;
	for (objectIt = objects_.begin(); objectIt != objects_.end(); ++objectIt)
	{
		objectIt->second->Update(deltaMilliseconds);
	}

	if (physicsWorld_)
	{
		physicsWorld_->StepWorld();

		std::vector<Collision> collisions;

		physicsWorld_->GetCollisions(collisions);
		HandleCollisions(collisions);
	}

	if (drawPhysicsWorld_)
	{
		physicsWorld_->DrawDebugWorld();
	}

	SandboxUtilities::CallLuaSandboxUpdate(this, deltaMilliseconds);
}
