'''struct in UnityEngine/Implemented in:UnityEngine.CoreModule
Description
Quaternions are used to represent rotations.

They are compact, don't suffer from gimbal lock and can easily be interpolated.
Unity internally uses Quaternions to represent all rotations.

They are based on complex numbers and are not easy to understand intuitively.
You almost never access or modify individual Quaternion components (x,y,z,w); most often you would just take existing rotations (e.g.
from the Transform) and use them to construct new rotations (e.g.
to smoothly interpolate between two rotations).
The Quaternion functions that you use 99% of the time are: Quaternion.LookRotation, Quaternion.Angle, Quaternion.Euler, Quaternion.Slerp, Quaternion.FromToRotation, and Quaternion.identity.
(The other functions are only for exotic uses.)

You can use the Quaternion.operator * to rotate one rotation by another, or to rotate a vector by a rotation.

Note that Unity expects Quaternions to be normalized.'''
class Quaternion():
	# region Static Properties
	identity=0  # The identity rotation (Read Only).
	# endregion
	# region Properties
	@property
	def eulerAngles(self):
		'''Returns or sets the euler angle representation of the rotation.'''
		pass
	@property
	def normalized(self):
		'''Returns this quaternion with a magnitude of 1 (Read Only).'''
		pass
	def __getitem__(self, key):
		'''Access the x, y, z, w components using [0], [1], [2], [3] respectively.'''
		pass
	def __setitem__(self, key, value):
		'''Access the x, y, z, w components using [0], [1], [2], [3] respectively.'''
		pass
	@property
	def w(self):
		'''W component of the Quaternion. Do not directly modify quaternions.'''
		pass
	@property
	def x(self):
		'''X component of the Quaternion. Don't modify this directly unless you know quaternions inside out.'''
		pass
	@property
	def y(self):
		'''Y component of the Quaternion. Don't modify this directly unless you know quaternions inside out.'''
		pass
	@property
	def z(self):
		'''Z component of the Quaternion. Don't modify this directly unless you know quaternions inside out.'''
		pass
	# endregion
	def __init__(self):
		'''Constructs new Quaternion with given x,y,z,w components.'''
		pass
	# region Public Methods
	def Set(self):
		'''Set x, y, z and w components of an existing Quaternion.'''
		pass
	def SetFromToRotation(self):
		'''Creates a rotation which rotates from fromDirection to toDirection.'''
		pass
	def SetLookRotation(self):
		'''Creates a rotation with the specified forward and upwards directions.'''
		pass
	def ToAngleAxis(self):
		'''Converts a rotation to angle-axis representation (angles in degrees).'''
		pass
	def ToString(self):
		'''Returns a nicely formatted string of the Quaternion.'''
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
	def Angle():
		'''Returns the angle in degrees between two rotations a and b.'''
		pass
	@staticmethod
	def AngleAxis():
		'''Creates a rotation which rotates angle degrees around axis.'''
		pass
	@staticmethod
	def Dot():
		'''The dot product between two rotations.'''
		pass
	@staticmethod
	def Euler():
		'''Returns a rotation that rotates z degrees around the z axis, x degrees around the x axis, and y degrees around the y axis.'''
		pass
	@staticmethod
	def FromToRotation():
		'''Creates a rotation which rotates from fromDirection to toDirection.'''
		pass
	@staticmethod
	def Inverse():
		'''Returns the Inverse of rotation.'''
		pass
	@staticmethod
	def Lerp():
		'''Interpolates between a and b by t and normalizes the result afterwards. The parameter t is clamped to the range [0, 1].'''
		pass
	@staticmethod
	def LerpUnclamped():
		'''Interpolates between a and b by t and normalizes the result afterwards. The parameter t is not clamped.'''
		pass
	@staticmethod
	def LookRotation():
		'''Creates a rotation with the specified forward and upwards directions.'''
		pass
	@staticmethod
	def Normalize():
		'''Converts this quaternion to one with the same orientation but with a magnitude of 1.'''
		pass
	@staticmethod
	def RotateTowards():
		'''Rotates a rotation from towards to.'''
		pass
	@staticmethod
	def Slerp():
		'''Spherically interpolates between a and b by t. The parameter t is clamped to the range [0, 1].'''
		pass
	@staticmethod
	def SlerpUnclamped():
		'''Spherically interpolates between a and b by t. The parameter t is not clamped.'''
		pass
	# endregion
	# region Operators
	def __mul__(self, other):
		'''Combines rotations lhs and rhs.'''
		pass
	def __eq__(self, other):
		'''Are two quaternions equal to each other?'''
		return self.Equals(other)
	# endregion

