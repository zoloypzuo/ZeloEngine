'''struct in UnityEngine/Implemented in:UnityEngine.CoreModule
Description
A standard 4x4 transformation matrix.

A transformation matrix can perform arbitrary linear 3D transformations (i.e.
translation, rotation, scale, shear etc.) and perspective transformations using homogenous coordinates.
You rarely use matrices in scripts; most often using Vector3s, Quaternions and functionality of Transform class is more straightforward.
Plain matrices are used in special cases like setting up nonstandard camera projection.

Consult any graphics textbook for in depth explanation of transformation matrices.

In Unity, Matrix4x4 is used by several Transform, Camera, Material and GL functions.

Matrices in unity are column major.
Data is accessed as: row + (column*4).
Matrices can be indexed like 2D arrays but in an expression like mat[a, b], a refers to the row index, while b refers to the column index (note that this is the opposite way round to Cartesian coordinates).'''
from typing import Tuple


class Matrix4x4():
	# region Static Properties
	identity=0  # Returns the identity matrix (Read Only).
	zero=0  # Returns a matrix with all elements set to zero (Read Only).
	# endregion
	# region Properties
	@property
	def decomposeProjection(self):
		'''This property takes a projection matrix and returns the six plane coordinates that define a projection frustum.'''
		pass
	@property
	def determinant(self):
		'''The determinant of the matrix.'''
		pass
	@property
	def inverse(self):
		'''The inverse of this matrix (Read Only).'''
		pass
	@property
	def isIdentity(self):
		'''Is this the identity matrix?'''
		pass
	@property
	def lossyScale(self):
		'''Attempts to get a scale value from the matrix.'''
		pass
	@property
	def rotation(self):
		'''Attempts to get a rotation quaternion from this matrix.'''
		pass
	# @property
	def __getitem__(self, key: Tuple[int,int]):
		'''Access element at [row, column].'''
		pass
	@property
	def transpose(self):
		'''Returns the transpose of this matrix (Read Only).'''
		pass
	# endregion
	# region Public Methods
	def GetColumn(self):
		'''Get a column of the matrix.'''
		pass
	def GetRow(self):
		'''Returns a row of the matrix.'''
		pass
	def MultiplyPoint(self):
		'''Transforms a position by this matrix (generic).'''
		pass
	def MultiplyPoint3x4(self):
		'''Transforms a position by this matrix (fast).'''
		pass
	def MultiplyVector(self):
		'''Transforms a direction by this matrix.'''
		pass
	def SetColumn(self):
		'''Sets a column of the matrix.'''
		pass
	def SetRow(self):
		'''Sets a row of the matrix.'''
		pass
	def SetTRS(self):
		'''Sets this matrix to a translation, rotation and scaling matrix.'''
		pass
	def ToString(self):
		'''Returns a nicely formatted string for this matrix.'''
		pass
	def TransformPlane(self):
		'''Returns a plane that is transformed in space.'''
		pass
	def ValidTRS(self):
		'''Checks if this matrix is a valid transform matrix.'''
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
	def Frustum():
		'''This function returns a projection matrix with viewing frustum that has a near plane defined by the coordinates that were passed in.'''
		pass
	@staticmethod
	def LookAt():
		'''Given a source point, a target point, and an up vector, computes a transformation matrix that corresponds to a camera viewing the target from the source, such that the right-hand vector is perpendicular to the up vector.'''
		pass
	@staticmethod
	def Ortho():
		'''Creates an orthogonal projection matrix.'''
		pass
	@staticmethod
	def Perspective():
		'''Creates a perspective projection matrix.'''
		pass
	@staticmethod
	def Rotate():
		'''Creates a rotation matrix.'''
		pass
	@staticmethod
	def Scale():
		'''Creates a scaling matrix.'''
		pass
	@staticmethod
	def Translate():
		'''Creates a translation matrix.'''
		pass
	@staticmethod
	def TRS():
		'''Creates a translation, rotation and scaling matrix.'''
		pass
	# endregion
	# region Operators
	def __mul__(self, other):
		'''Multiplies two matrices.'''
		pass
	# endregion

