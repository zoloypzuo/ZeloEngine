'''struct in UnityEngine/Implemented in:UnityEngine.CoreModule
Description
Representation of four-dimensional vectors.

This structure is used in some places to represent four component vectors (e.g.
mesh tangents, parameters for shaders).
In the majority of other cases a Vector3 is used.'''
class Vector4():
	# region Static Properties
	negativeInfinity=0  # Shorthand for writing Vector4(float.NegativeInfinity, float.NegativeInfinity, float.NegativeInfinity, float.NegativeInfinity).
	one=0  # Shorthand for writing Vector4(1,1,1,1).
	positiveInfinity=0  # Shorthand for writing Vector4(float.PositiveInfinity, float.PositiveInfinity, float.PositiveInfinity, float.PositiveInfinity).
	zero=0  # Shorthand for writing Vector4(0,0,0,0).
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
		'''Access the x, y, z, w components using [0], [1], [2], [3] respectively.'''
		pass
	def __setitem__(self, key, value):
		'''Access the x, y, z, w components using [0], [1], [2], [3] respectively.'''
		pass
	@property
	def w(self):
		'''W component of the vector.'''
		pass
	@property
	def x(self):
		'''X component of the vector.'''
		pass
	@property
	def y(self):
		'''Y component of the vector.'''
		pass
	@property
	def z(self):
		'''Z component of the vector.'''
		pass
	# endregion
	def __init__(self):
		'''Creates a new vector with given x, y, z, w components.'''
		pass
	# region Public Methods
	def Equals(self):
		'''Returns true if the given vector is exactly equal to this vector.'''
		pass
	def Set(self):
		'''Set x, y, z and w components of an existing Vector4.'''
		pass
	def ToString(self):
		'''Return the Vector4 formatted as a string.'''
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
	def Distance():
		'''Returns the distance between a and b.'''
		pass
	@staticmethod
	def Dot():
		'''Dot Product of two vectors.'''
		pass
	@staticmethod
	def Lerp():
		'''Linearly interpolates between two vectors.'''
		pass
	@staticmethod
	def LerpUnclamped():
		'''Linearly interpolates between two vectors.'''
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
	def normalized():
		'''TODO'''
		pass
	@staticmethod
	def Project():
		'''Projects a vector onto another vector.'''
		pass
	@staticmethod
	def Scale():
		'''Multiplies two vectors component-wise.'''
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

# Vector2	Converts a Vector4 to a Vector2.
# Vector3	Converts a Vector4 to a Vector3.
# Vector4	Converts a Vector3 to a Vector4.
# Vector4	Converts a Vector2 to a Vector4.