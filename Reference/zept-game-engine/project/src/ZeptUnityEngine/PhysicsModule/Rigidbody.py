'''class in UnityEngine/Inherits from:Component/Implemented in:UnityEngine.PhysicsModule
Description
Control of an object's position through physics simulation.

Adding a Rigidbody component to an object will put its motion under the control of Unity's physics engine.
Even without adding any code, a Rigidbody object will be pulled downward by gravity and will react to collisions with incoming objects if the right Collider component is also present.

The Rigidbody also has a scripting API that lets you apply forces to the object and control it in a physically realistic way.
For example, a car's behaviour can be specified in terms of the forces applied by the wheels.
Given this information, the physics engine can handle most other aspects of the car's motion, so it will accelerate realistically and respond correctly to collisions.

In a script, the FixedUpdate function is recommended as the place to apply forces and change Rigidbody settings (as opposed to Update, which is used for most other frame update tasks).
The reason for this is that physics updates are carried out in measured time steps that don't coincide with the frame update.
FixedUpdate is called immediately before each physics update and so any changes made there will be processed directly.

A common problem when starting out with Rigidbodies is that the game physics appears to run in "slow motion".
This is actually due to the scale used for your models.
The default gravity settings assume that one world unit corresponds to one metre of distance.
With non-physical games, it doesn't make much difference if your models are all 100 units long but when using physics, they will be treated as very large objects.
If a large scale is used for objects that are supposed to be small, they will appear to fall very slowly - the physics engine thinks they are very large objects falling over very large distances.
With this in mind, be sure to keep your objects more or less at their scale in real life (so a car should be about 4 units = 4 metres, for example).'''
from project.src.ZeptUnityEngine.CoreModule.Component import Component


class Rigidbody(Component):
	# region Properties
	@property
	def angularDrag(self):
		'''The angular drag of the object.'''
		pass
	@property
	def angularVelocity(self):
		'''The angular velocity vector of the rigidbody measured in radians per second.'''
		pass
	@property
	def centerOfMass(self):
		'''The center of mass relative to the transform's origin.'''
		pass
	@property
	def collisionDetectionMode(self):
		'''The Rigidbody's collision detection mode.'''
		pass
	@property
	def constraints(self):
		'''Controls which degrees of freedom are allowed for the simulation of this Rigidbody.'''
		pass
	@property
	def detectCollisions(self):
		'''Should collision detection be enabled? (By default always enabled).'''
		pass
	@property
	def drag(self):
		'''The drag of the object.'''
		pass
	@property
	def freezeRotation(self):
		'''Controls whether physics will change the rotation of the object.'''
		pass
	@property
	def inertiaTensor(self):
		'''The diagonal inertia tensor of mass relative to the center of mass.'''
		pass
	@property
	def inertiaTensorRotation(self):
		'''The rotation of the inertia tensor.'''
		pass
	@property
	def interpolation(self):
		'''Interpolation allows you to smooth out the effect of running physics at a fixed frame rate.'''
		pass
	@property
	def isKinematic(self):
		'''Controls whether physics affects the rigidbody.'''
		pass
	@property
	def mass(self):
		'''The mass of the rigidbody.'''
		pass
	@property
	def maxAngularVelocity(self):
		'''The maximimum angular velocity of the rigidbody measured in radians per second. (Default 7) range { 0, infinity }.'''
		pass
	@property
	def maxDepenetrationVelocity(self):
		'''Maximum velocity of a rigidbody when moving out of penetrating state.'''
		pass
	@property
	def position(self):
		'''The position of the rigidbody.'''
		pass
	@property
	def rotation(self):
		'''The rotation of the rigidbody.'''
		pass
	@property
	def sleepThreshold(self):
		'''The mass-normalized energy threshold, below which objects start going to sleep.'''
		pass
	@property
	def solverIterations(self):
		'''The solverIterations determines how accurately Rigidbody joints and collision contacts are resolved. Overrides Physics.defaultSolverIterations. Must be positive.'''
		pass
	@property
	def solverVelocityIterations(self):
		'''The solverVelocityIterations affects how how accurately Rigidbody joints and collision contacts are resolved. Overrides Physics.defaultSolverVelocityIterations. Must be positive.'''
		pass
	@property
	def useGravity(self):
		'''Controls whether gravity affects this rigidbody.'''
		pass
	@property
	def velocity(self):
		'''The velocity vector of the rigidbody.'''
		pass
	@property
	def worldCenterOfMass(self):
		'''The center of mass of the rigidbody in world space (Read Only).'''
		pass
	# endregion
	# region Public Methods
	def AddExplosionForce(self):
		'''Applies a force to a rigidbody that simulates explosion effects.'''
		pass
	def AddForce(self):
		'''Adds a force to the Rigidbody.'''
		pass
	def AddForceAtPosition(self):
		'''Applies force at position. As a result this will apply a torque and force on the object.'''
		pass
	def AddRelativeForce(self):
		'''Adds a force to the rigidbody relative to its coordinate system.'''
		pass
	def AddRelativeTorque(self):
		'''Adds a torque to the rigidbody relative to its coordinate system.'''
		pass
	def AddTorque(self):
		'''Adds a torque to the rigidbody.'''
		pass
	def ClosestPointOnBounds(self):
		'''The closest point to the bounding box of the attached colliders.'''
		pass
	def GetPointVelocity(self):
		'''The velocity of the rigidbody at the point worldPoint in global space.'''
		pass
	def GetRelativePointVelocity(self):
		'''The velocity relative to the rigidbody at the point relativePoint.'''
		pass
	def IsSleeping(self):
		'''Is the rigidbody sleeping?'''
		pass
	def MovePosition(self):
		'''Moves the rigidbody to position.'''
		pass
	def MoveRotation(self):
		'''Rotates the rigidbody to rotation.'''
		pass
	def ResetCenterOfMass(self):
		'''Reset the center of mass of the rigidbody.'''
		pass
	def ResetInertiaTensor(self):
		'''Reset the inertia tensor value and rotation.'''
		pass
	def SetDensity(self):
		'''Sets the mass based on the attached colliders assuming a constant density.'''
		pass
	def Sleep(self):
		'''Forces a rigidbody to sleep at least one frame.'''
		pass
	def SweepTest(self):
		'''Tests if a rigidbody would collide with anything, if it was moved through the Scene.'''
		pass
	def SweepTestAll(self):
		'''Like Rigidbody.SweepTest, but returns all hits.'''
		pass
	def WakeUp(self):
		'''Forces a rigidbody to wake up.'''
		pass
	def __str__(self):
		''''''
		return self.ToString()
	def __repr__(self):
		''''''
		return self.ToString()
	# endregion
	# region Messages
	def OnCollisionEnter(self):
		'''OnCollisionEnter is called when this collider/rigidbody has begun touching another rigidbody/collider.'''
		pass
	def OnCollisionExit(self):
		'''OnCollisionExit is called when this collider/rigidbody has stopped touching another rigidbody/collider.'''
		pass
	def OnCollisionStay(self):
		'''OnCollisionStay is called once per frame for every collider/rigidbody that is touching rigidbody/collider.'''
		pass
	# endregion

