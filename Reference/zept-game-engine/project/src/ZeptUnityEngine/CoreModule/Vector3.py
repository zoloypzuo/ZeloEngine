'''struct in UnityEngine/Implemented in:UnityEngine.CoreModuleOther
Description
Representation of 3D vectors and points.

This structure is used throughout Unity to pass 3D positions and directions around.
It also contains functions for doing common vector operations.

Besides the functions listed below, other classes can be used to manipulate vectors and points as well.
For example the Quaternion and the Matrix4x4 classes are useful for rotating or transforming vectors and points.'''
from __future__ import annotations  # handle typing bug

from project.src.ZeptUnityEngine.CoreModule.Mathf import Mathf


class Vector3:
    # *Undocumented*
    kEpsilon = 0.00001
    # *Undocumented*
    kEpsilonNormalSqrt = 1e-15

    # region Static Properties
    back = None  # Shorthand for writing Vector3(0, 0, -1).
    down = None  # Shorthand for writing Vector3(0, -1, 0).
    forward = None  # Shorthand for writing Vector3(0, 0, 1).
    left = None  # Shorthand for writing Vector3(-1, 0, 0).
    negativeInfinity = None  # Shorthand for writing Vector3(float.NegativeInfinity, float.NegativeInfinity, float.NegativeInfinity).
    one = None  # Shorthand for writing Vector3(1, 1, 1).
    positiveInfinity = None  # Shorthand for writing Vector3(float.PositiveInfinity, float.PositiveInfinity, float.PositiveInfinity).
    right = None  # Shorthand for writing Vector3(1, 0, 0).
    up = None  # Shorthand for writing Vector3(0, 1, 0).
    zero = None  # Shorthand for writing Vector3(0, 0, 0).

    # endregion
    # region Properties
    @property
    def magnitude(self) -> float:
        '''Returns the length of this vector (Read Only).'''
        x = self.x
        y = self.y
        z = self.z
        return Mathf.Sqrt(x * x + y * y + z * z)

    @property
    def normalized(self) -> Vector3:
        '''Returns this vector with a magnitude of 1 (Read Only).'''
        mag = self.magnitude
        if mag > Vector3.kEpsilon:
            return self / mag
        else:
            return Vector3.zero

    @property
    def sqrMagnitude(self) -> float:
        '''Returns the squared length of this vector (Read Only).'''
        x = self.x
        y = self.y
        z = self.z
        return x * x + y * y + z * z

    def __getitem__(self, key: int):
        '''Access the x, y, z components using [0], [1], [2] respectively.'''
        if key == 0:
            return self.x
        elif key == 1:
            return self.y
        elif key == 2:
            return self.z
        else:
            raise IndexError("Invalid Vector3 index!")

    def __setitem__(self, key: int, value: float):
        '''Access the x, y, z components using [0], [1], [2] respectively.'''
        if key == 0:
            self.x = value
        elif key == 1:
            self.y = value
        elif key == 2:
            self.z = value
        else:
            raise IndexError("Invalid Vector3 index!")

    # endregion
    def __init__(self, x, y, z):
        '''Creates a new vector with given x, y, z components.'''

        '''X component of the vector.'''
        self.x = x
        '''Y component of the vector.'''
        self.y = y
        '''Z component of the vector.'''
        self.z = z

    # region Public Methods
    def Equals(self, other):
        '''Returns true if the given vector is exactly equal to this vector.'''
        if not isinstance(other, Vector3):
            return False
        return self.x == other.x and self.y == other.y and self.z == other.z

    def Set(self, newX, newY, newZ):
        '''Set x, y and z components of an existing Vector3.'''
        self.x = newX
        self.y = newY
        self.z = newZ

    def ToString(self):
        '''Returns a nicely formatted string for this vector.'''
        return (self.x, self.y, self.z).__str__()

    def __str__(self):
        ''''''
        return self.ToString()

    def __repr__(self):
        ''''''
        return self.ToString()

    def __hash__(self):
        '''used to allow Vector3s to be used as keys in hash tables'''
        return hash((self.x, self.y, self.z))

    # endregion
    # region Static Methods
    @staticmethod
    def Angle(from_: Vector3, to: Vector3) -> float:
        '''Returns the angle in degrees between from and to.'''
        # sqrt(a) * sqrt(b) = sqrt(a * b) -- valid for real numbers
        denominator = Mathf.Sqrt(from_.sqrMagnitude * to.sqrMagnitude)
        if denominator < Vector3.kEpsilonNormalSqrt:
            return 0.0
        else:
            dot = Mathf.Clamp(Vector3.Dot(to) / denominator, -1.0, 1.0)
            return Mathf.Acos(dot) * Mathf.Rad2Deg

    @staticmethod
    def ClampMagnitude(vector: Vector3, maxLength: float) -> Vector3:
        '''Returns a copy of vector with its magnitude clamped to maxLength.'''
        if vector.sqrMagnitude > maxLength ** 2:
            return vector.normalized * maxLength
        return vector

    @staticmethod
    def Cross(lhs: Vector3, rhs: Vector3) -> Vector3:
        '''Cross Product of two vectors.'''
        return Vector3(
            lhs.y * rhs.z - lhs.z * rhs.y,
            lhs.z * rhs.x - lhs.x * rhs.z,
            lhs.x * rhs.y - lhs.y * rhs.x
        )

    @staticmethod
    def Distance(a: Vector3, b: Vector3) -> float:
        '''Returns the distance between a and b.'''
        vec = a - b
        return vec.sqrMagnitude

    @staticmethod
    def Dot(lhs: Vector3, rhs: Vector3) -> float:
        '''Dot Product of two vectors.'''
        return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z

    @staticmethod
    def Lerp(a: Vector3, b: Vector3, t: float) -> Vector3:
        '''Linearly interpolates between two vectors.'''
        t = Mathf.Clamp01(t)
        return a + (b - a) * t

    @staticmethod
    def LerpUnclamped(a: Vector3, b: Vector3, t: float) -> Vector3:
        '''Linearly interpolates between two vectors.'''
        return a + (b - a) * t

    @staticmethod
    def Max(lhs: Vector3, rhs: Vector3) -> Vector3:
        '''Returns a vector that is made from the largest components of two vectors.'''
        return Vector3(Mathf.Max(lhs.x, rhs.x),
                       Mathf.Max(lhs.y, rhs.y),
                       Mathf.Max(lhs.z, rhs.z)
                       )

    @staticmethod
    def Min(lhs: Vector3, rhs: Vector3) -> Vector3:
        '''Returns a vector that is made from the smallest components of two vectors.'''
        return Vector3(Mathf.Min(lhs.x, rhs.x),
                       Mathf.Min(lhs.y, rhs.y),
                       Mathf.Min(lhs.z, rhs.z)
                       )

    @staticmethod
    def MoveTowards(current: Vector3, target: Vector3, maxDistanceDelta: float) -> Vector3:
        '''Calculate a position between the points specified by current and target, moving no farther than the distance specified by maxDistanceDelta.'''
        toVector = target - current
        dist = toVector.magnitude
        if dist <= maxDistanceDelta or dist < 1.401298E-45:  # float.Epsilon
            return target
        else:
            return current + toVector * (maxDistanceDelta / dist)

    @staticmethod
    def OrthoNormalize(vector: Vector3, rhs: Vector3) -> Vector3:
        '''Makes vectors normalized and orthogonal to each other.'''
        pass
        # TODO not found

    @staticmethod
    def Project(vector: Vector3, onNormal: Vector3) -> Vector3:
        '''Projects a vector onto another vector.'''
        sqrMag = Vector3.Dot(onNormal, onNormal)
        if sqrMag < Mathf.Epsilon:
            return Vector3.zero
        else:
            return onNormal * Vector3.Dot(vector, onNormal) / sqrMag

    @staticmethod
    def ProjectOnPlane(vector: Vector3, planeNormal: Vector3) -> Vector3:
        '''Projects a vector onto a plane defined by a normal orthogonal to the plane.'''
        return vector - Vector3.Project(vector, planeNormal)

    @staticmethod
    def Reflect(inDirection: Vector3, inNormal: Vector3) -> Vector3:
        '''Reflects a vector off the plane defined by a normal.'''
        return -2 * Vector3.Dot(inNormal, inDirection) * inNormal + inDirection

    @staticmethod
    def RotateTowards():
        '''Rotates a vector current towards target.'''
        # extern C implementation
        pass

    @staticmethod
    def Scale(a: Vector3, b: Vector3):
        '''Multiplies two vectors component-wise.'''
        return Vector3(a.x * b.x,
                       a.y * b.y,
                       a.z * b.z)

    @staticmethod
    def SignedAngle(from_: Vector3, to: Vector3, axis: Vector3) -> float:
        '''Returns the signed angle in degrees between from and to.
        The smaller of the two possible angles between the two vectors is returned, therefore the result will never be greater than 180 degrees or smaller than -180 degrees.
        If you imagine the from and to vectors as lines on a piece of paper, both originating from the same point, then the /axis/ vector would point up out of the paper.
        The measured angle between the two vectors would be positive in a clockwise direction and negative in an anti-clockwise direction.
        '''
        unsignedAngle = Vector3.Angle(from_, to)
        sign = Mathf.Sign(Vector3.Dot(axis, Vector3.Cross(from_, to)))
        return unsignedAngle * sign

    @staticmethod
    def Slerp(self):
        '''Spherically interpolates between two vectors.'''
        # extern C implementation
        pass

    @staticmethod
    def SlerpUnclamped(self):
        '''Spherically interpolates between two vectors.'''
        # extern C implementation
        pass

    @staticmethod
    def SmoothDamp(self):
        '''Gradually changes a vector towards a desired goal over time.'''
        # extern C implementation
        pass

    # endregion
    # region Operators
    def __sub__(self, other)->Vector3:
        '''Subtracts one vector from another.'''
        return Vector3(self.x - other.x, self.y - other.y, self.z - other.z)

    def __neg__(self)->Vector3:
        '''Negates a vector.'''
        return Vector3(-self.x, -self.y, -self.z)

    def __ne__(self, other)->bool:
        '''Returns true if vectors different.'''
        return not self.Equals(other)

    def __mul__(self, other: float)->Vector3:
        '''Multiplies a vector by a number.'''
        return Vector3(self.x * other, self.y * other, self.z * other)

    def __rmul__(self, other: float)->Vector3:
        return Vector3(self.x * other, self.y * other, self.z * other)

    def __truediv__(self, other: float)->Vector3:
        '''Divides a vector by a number.'''
        return Vector3(self.x / other, self.y / other, self.z / other)

    def __add__(self, other: Vector3)->Vector3:
        '''Adds two vectors.'''
        return Vector3(self.x + other.x, self.y + other.y, self.z + other.z)

    def __eq__(self, other: Vector3)->bool:
        '''Returns true if two vectors are approximately equal.'''
        return (self - other).sqrMagnitude < Vector3.kEpsilon ** 2


# endregion

# region global initialization
Vector3.back = Vector3(0, 0, -1)  # Shorthand for writing Vector3(0, 0, -1).
Vector3.down = Vector3(0, -1, 0)  # Shorthand for writing Vector3(0, -1, 0).
Vector3.forward = Vector3(0, 0, 1)  # Shorthand for writing Vector3(0, 0, 1).
Vector3.left = Vector3(-1, 0, 0)  # Shorthand for writing Vector3(-1, 0, 0).
Vector3.negativeInfinity = Vector3(float('-inf'), float('-inf'), float(
    '-inf'))  # Shorthand for writing Vector3(float.NegativeInfinity, float.NegativeInfinity, float.NegativeInfinity).
Vector3.one = Vector3(1, 1, 1)  # Shorthand for writing Vector3(1, 1, 1).
Vector3.positiveInfinity = Vector3(float('inf'), float('inf'), float(
    'inf'))  # Shorthand for writing Vector3(float.PositiveInfinity, float.PositiveInfinity, float.PositiveInfinity).
Vector3.right = Vector3(1, 0, 0)  # Shorthand for writing Vector3(1, 0, 0).
Vector3.up = Vector3(0, 1, 0)  # Shorthand for writing Vector3(0, 1, 0).
Vector3.zero = Vector3(0, 0, 0)  # Shorthand for writing Vector3(0, 0, 0).
# endregion
