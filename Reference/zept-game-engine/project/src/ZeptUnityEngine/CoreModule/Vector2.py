'''struct in UnityEngine/Implemented in:UnityEngine.CoreModule
Description
Representation of 2D vectors and points.

This structure is used in some places to represent 2D positions and vectors (e.g.
texture coordinates in a Mesh or texture offsets in Material).
In the majority of other cases a Vector3 is used.'''
class Vector2():
	# region Static Properties
	down=0  # Shorthand for writing Vector2(0, -1).
	left=0  # Shorthand for writing Vector2(-1, 0).
	negativeInfinity=0  # Shorthand for writing Vector2(float.NegativeInfinity, float.NegativeInfinity).
	one=0  # Shorthand for writing Vector2(1, 1).
	positiveInfinity=0  # Shorthand for writing Vector2(float.PositiveInfinity, float.PositiveInfinity).
	right=0  # Shorthand for writing Vector2(1, 0).
	up=0  # Shorthand for writing Vector2(0, 1).
	zero=0  # Shorthand for writing Vector2(0, 0).
	# endregion
	# region Properties
	@property
	def magnitude(self):
		'''Returns the length of this vector (Read Only).'''
		pass
	@property
	def normalized(self):
		'''Returns this vector with a magnitude of 1 (Read Only).'''
		pass
	@property
	def sqrMagnitude(self):
		'''Returns the squared length of this vector (Read Only).'''
		pass
	def __getitem__(self, key):
		'''Access the x or y component using [0] or [1] respectively.'''
		pass
	def __setitem__(self, key, value):
		'''Access the x or y component using [0] or [1] respectively.'''
		pass
	@property
	def x(self):
		'''X component of the vector.'''
		pass
	@property
	def y(self):
		'''Y component of the vector.'''
		pass
	# endregion
	def __init__(self):
		'''Constructs a new vector with given x, y components.'''
		pass
	# region Public Methods
	def Equals(self):
		'''Returns true if the given vector is exactly equal to this vector.'''
		pass
	def Normalize(self):
		'''Makes this vector have a magnitude of 1.'''
		pass
	def Set(self):
		'''Set x and y components of an existing Vector2.'''
		pass
	def ToString(self):
		'''Returns a nicely formatted string for this vector.'''
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
		'''Returns the unsigned angle in degrees between from and to.'''
		pass
	@staticmethod
	def ClampMagnitude():
		'''Returns a copy of vector with its magnitude clamped to maxLength.'''
		pass
	@staticmethod
	def Distance():
		'''Returns the distance between a and b.'''
		pass
	@staticmethod
	def Dot():
		'''Dot Product of two vectors.'''
		pass
	@staticmethod
	def Lerp():
		'''Linearly interpolates between vectors a and b by t.'''
		pass
	@staticmethod
	def LerpUnclamped():
		'''Linearly interpolates between vectors a and b by t.'''
		pass
	@staticmethod
	def Max():
		'''Returns a vector that is made from the largest components of two vectors.'''
		pass
	@staticmethod
	def Min():
		'''Returns a vector that is made from the smallest components of two vectors.'''
		pass
	@staticmethod
	def MoveTowards():
		'''Moves a point current towards target.'''
		pass
	@staticmethod
	def Perpendicular():
		'''Returns the 2D vector perpendicular to this 2D vector. The result is always rotated 90-degrees in a counter-clockwise direction for a 2D coordinate system where the positive Y axis goes up.'''
		pass
	@staticmethod
	def Reflect():
		'''Reflects a vector off the vector defined by a normal.'''
		pass
	@staticmethod
	def Scale():
		'''Multiplies two vectors component-wise.'''
		pass
	@staticmethod
	def SignedAngle():
		'''Returns the signed angle in degrees between from and to.'''
		pass
	@staticmethod
	def SmoothDamp():
		'''Gradually changes a vector towards a desired goal over time.'''
		pass
	# endregion
	# region Operators
	def __sub__(self, other):
		'''Subtracts one vector from another.'''
		pass
	def __mul__(self, other):
		'''Multiplies a vector by a number.'''
		pass
	def __truediv__(self, other):
		'''Divides a vector by a number.'''
		pass
	def __add__(self, other):
		'''Adds two vectors.'''
		pass
	def __eq__(self, other):
		'''Returns true if two vectors are approximately equal.'''
		return self.Equals(other)
	# endregion

# Vector2	Converts a Vector3 to a Vector2.
# Vector3	Converts a Vector2 to a Vector3.