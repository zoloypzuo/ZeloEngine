'''class in UnityEngine/Inherits from:Behaviour/Implemented in:UnityEngine.CoreModule
Description
MonoBehaviour is the base class from which every Unity script derives.

When you use C#, you must explicitly derive from MonoBehaviour.

This class doesn't support the null-conditional operator (?.) and the null-coalescing operator (??).

Note: There is a checkbox for disabling MonoBehaviour on the Unity Editor.
It disables functions when unticked.
If none of these functions are present in the script, the Editor does not display the checkbox.
The functions are:

Start()
Update()
FixedUpdate()
LateUpdate()
OnGUI()
OnDisable()
OnEnable()

See Also: The Deactivating GameObjects page in the manual.'''
from project.src.ZeptUnityEngine.CoreModule.Behaviour import Behaviour


class MonoBehaviour(Behaviour):
    # region Properties
    # @property
    # def runInEditMode(self):
    # 	'''Allow a specific instance of a MonoBehaviour to run in edit mode (only available in the editor).'''
    # 	pass
    # @property
    # def useGUILayout(self):
    # 	'''Disabling this lets you skip the GUI layout phase.'''
    # 	pass
    # endregion
    # region Public Methods
    # def CancelInvoke(self):
    # 	'''Cancels all Invoke calls on this MonoBehaviour.'''
    # 	pass
    # def Invoke(self):
    # 	'''Invokes the method methodName in time seconds.'''
    # 	pass
    # def InvokeRepeating(self):
    # 	'''Invokes the method methodName in time seconds, then repeatedly every repeatRate seconds.'''
    # 	pass
    # def IsInvoking(self):
    # 	'''Is any invoke on methodName pending?'''
    # 	pass
    def StartCoroutine(self):
        '''Starts a coroutine.'''
        pass

    def StopAllCoroutines(self):
        '''Stops all coroutines running on this behaviour.'''
        pass

    def StopCoroutine(self):
        '''Stops the first coroutine named methodName, or the coroutine stored in routine running on this behaviour.'''
        pass

    def __str__(self):
        ''''''
        return self.ToString()

    def __repr__(self):
        ''''''
        return self.ToString()

    # endregion
    # region Static Methods
    @staticmethod
    def print():
        '''Logs message to the Unity Console (identical to Debug.Log).'''
        pass

    # endregion
    # region Messages
    def Awake(self):
        '''Awake is called when the script instance is being loaded.'''
        pass

    def FixedUpdate(self):
        '''Frame-rate independent MonoBehaviour.FixedUpdate message for physics calculations.'''
        pass

    def LateUpdate(self):
        '''LateUpdate is called every frame, if the Behaviour is enabled.'''
        pass

    def OnAnimatorIK(self):
        '''Callback for setting up animation IK (inverse kinematics).'''
        pass

    def OnAnimatorMove(self):
        '''Callback for processing animation movements for modifying root motion.'''
        pass

    def OnApplicationFocus(self):
        '''Sent to all GameObjects when the player gets or loses focus.'''
        pass

    def OnApplicationPause(self):
        '''Sent to all GameObjects when the application pauses.'''
        pass

    def OnApplicationQuit(self):
        '''Sent to all game objects before the application quits.'''
        pass

    def OnAudioFilterRead(self):
        '''If OnAudioFilterRead is implemented, Unity will insert a custom filter into the audio DSP chain.'''
        pass

    def OnBecameInvisible(self):
        '''OnBecameInvisible is called when the renderer is no longer visible by any camera.'''
        pass

    def OnBecameVisible(self):
        '''OnBecameVisible is called when the renderer became visible by any camera.'''
        pass

    def OnCollisionEnter(self):
        '''OnCollisionEnter is called when this collider/rigidbody has begun touching another rigidbody/collider.'''
        pass

    def OnCollisionEnter2D(self):
        '''Sent when an incoming collider makes contact with this object's collider (2D physics only).'''
        pass

    def OnCollisionExit(self):
        '''OnCollisionExit is called when this collider/rigidbody has stopped touching another rigidbody/collider.'''
        pass

    def OnCollisionExit2D(self):
        '''Sent when a collider on another object stops touching this object's collider (2D physics only).'''
        pass

    def OnCollisionStay(self):
        ''':ref::OnCollisionStay is called once per frame for every collider/rigidbody that is touching rigidbody/collider.'''
        pass

    def OnCollisionStay2D(self):
        '''Sent each frame where a collider on another object is touching this object's collider (2D physics only).'''
        pass

    def OnConnectedToServer(self):
        '''Called on the client when you have successfully connected to a server.'''
        pass

    def OnControllerColliderHit(self):
        '''OnControllerColliderHit is called when the controller hits a collider while performing a Move.'''
        pass

    def OnDestroy(self):
        '''Destroying the attached Behaviour will result in the game or Scene receiving OnDestroy.'''
        pass

    def OnDisable(self):
        '''This function is called when the behaviour becomes disabled.'''
        pass

    def OnDisconnectedFromServer(self):
        '''Called on the client when the connection was lost or you disconnected from the server.'''
        pass

    def OnDrawGizmos(self):
        '''Implement OnDrawGizmos if you want to draw gizmos that are also pickable and always drawn.'''
        pass

    def OnDrawGizmosSelected(self):
        '''Implement OnDrawGizmosSelected to draw a gizmo if the object is selected.'''
        pass

    def OnEnable(self):
        '''This function is called when the object becomes enabled and active.'''
        pass

    def OnFailedToConnect(self):
        '''Called on the client when a connection attempt fails for some reason.'''
        pass

    def OnFailedToConnectToMasterServer(self):
        '''Called on clients or servers when there is a problem connecting to the MasterServer.'''
        pass

    def OnGUI(self):
        '''OnGUI is called for rendering and handling GUI events.'''
        pass

    def OnJointBreak(self):
        '''Called when a joint attached to the same game object broke.'''
        pass

    def OnJointBreak2D(self):
        '''Called when a Joint2D attached to the same game object breaks.'''
        pass

    def OnMasterServerEvent(self):
        '''Called on clients or servers when reporting events from the MasterServer.'''
        pass

    def OnMouseDown(self):
        '''OnMouseDown is called when the user has pressed the mouse button while over the GUIElement or Collider.'''
        pass

    def OnMouseDrag(self):
        '''OnMouseDrag is called when the user has clicked on a GUIElement or Collider and is still holding down the mouse.'''
        pass

    def OnMouseEnter(self):
        '''Called when the mouse enters the GUIElement or Collider.'''
        pass

    def OnMouseExit(self):
        '''Called when the mouse is not any longer over the GUIElement or Collider.'''
        pass

    def OnMouseOver(self):
        '''Called every frame while the mouse is over the GUIElement or Collider.'''
        pass

    def OnMouseUp(self):
        '''OnMouseUp is called when the user has released the mouse button.'''
        pass

    def OnMouseUpAsButton(self):
        '''OnMouseUpAsButton is only called when the mouse is released over the same GUIElement or Collider as it was pressed.'''
        pass

    def OnNetworkInstantiate(self):
        '''Called on objects which have been network instantiated with Network.Instantiate.'''
        pass

    def OnParticleCollision(self):
        '''OnParticleCollision is called when a particle hits a Collider.'''
        pass

    def OnParticleSystemStopped(self):
        '''OnParticleSystemStopped is called when all particles in the system have died, and no new particles will be born. New particles cease to be created either after Stop is called, or when the duration property of a non-looping system has been exceeded.'''
        pass

    def OnParticleTrigger(self):
        '''OnParticleTrigger is called when any particles in a particle system meet the conditions in the trigger module.'''
        pass

    def OnPlayerConnected(self):
        '''Called on the server whenever a new player has successfully connected.'''
        pass

    def OnPlayerDisconnected(self):
        '''Called on the server whenever a player disconnected from the server.'''
        pass

    def OnPostRender(self):
        '''OnPostRender is called after a camera finished rendering the Scene.'''
        pass

    def OnPreCull(self):
        '''OnPreCull is called before a camera culls the Scene.'''
        pass

    def OnPreRender(self):
        '''OnPreRender is called before a camera starts rendering the Scene.'''
        pass

    def OnRenderImage(self):
        '''OnRenderImage is called after all rendering is complete to render image.'''
        pass

    def OnRenderObject(self):
        '''OnRenderObject is called after camera has rendered the Scene.'''
        pass

    def OnSerializeNetworkView(self):
        '''Used to customize synchronization of variables in a script watched by a network view.'''
        pass

    def OnServerInitialized(self):
        '''Called on the server whenever a Network.InitializeServer was invoked and has completed.'''
        pass

    def OnTransformChildrenChanged(self):
        '''This function is called when the list of children of the transform of the GameObject has changed.'''
        pass

    def OnTransformParentChanged(self):
        '''This function is called when the parent property of the transform of the GameObject has changed.'''
        pass

    def OnTriggerEnter(self):
        '''OnTriggerEnter is called when the GameObject collides with another GameObject.'''
        pass

    def OnTriggerEnter2D(self):
        '''Sent when another object enters a trigger collider attached to this object (2D physics only).'''
        pass

    def OnTriggerExit(self):
        '''OnTriggerExit is called when the Collider other has stopped touching the trigger.'''
        pass

    def OnTriggerExit2D(self):
        '''Sent when another object leaves a trigger collider attached to this object (2D physics only).'''
        pass

    def OnTriggerStay(self):
        '''OnTriggerStay is called once per physics update for every Collider other that is touching the trigger.'''
        pass

    def OnTriggerStay2D(self):
        '''Sent each frame where another object is within a trigger collider attached to this object (2D physics only).'''
        pass

    def OnValidate(self):
        '''This function is called when the script is loaded or a value is changed in the inspector (Called in the editor only).'''
        pass

    def OnWillRenderObject(self):
        '''OnWillRenderObject is called for each camera if the object is visible and not a UI element.'''
        pass

    def Reset(self):
        '''Reset to default values.'''
        pass

    def Start(self):
        '''Start is called on the frame when a script is enabled just before any of the Update methods are called the first time.'''
        pass

    def Update(self):
        '''Update is called every frame, if the MonoBehaviour is enabled.'''
        pass
    # endregion
