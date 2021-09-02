# coding=utf-8
# vector3.py
# created on 2020/11/1
# author @zoloypzuo
# usage: vector3
import math

import glm

if glm.vec3:
    class Vector3(glm.vec3):
        # ---------------------------------------------------
        # static property
        # ---------------------------------------------------
        # same as Unity
        @staticmethod
        def forward():
            # type: () -> Vector3
            return Vector3(0, 0, 1)

        @staticmethod
        def right():
            # type: () -> Vector3
            return Vector3(1, 0, 0)

        @staticmethod
        def up():
            # type: () -> Vector3
            return Vector3(0, 1, 0)

        # ---------------------------------------------------
        # cast to vec4
        # ---------------------------------------------------
        def to_vec4(self):
            return glm.vec4(self.x, self.y, self.z, 0)

        def to_point4(self):
            return glm.vec4(self.x, self.y, self.z, 1)
else:
    class Vector3(object):

        def __init__(self, x=0., y=0., z=0.):
            self.x = float(x)  # make sure float division
            self.y = float(y)
            self.z = float(z)

        def tuple(self):
            return self.x, self.y, self.z

        # ---------------------------------------------------
        # static property
        # ---------------------------------------------------
        # same as Unity
        @staticmethod
        def forward():
            # type: () -> Vector3
            return Vector3(0, 0, 1)

        @staticmethod
        def right():
            # type: () -> Vector3
            return Vector3(1, 0, 0)

        @staticmethod
        def up():
            # type: () -> Vector3
            return Vector3(0, 1, 0)

        # ---------------------------------------------------
        # static method
        # ---------------------------------------------------
        @staticmethod
        def dot(lhs, rhs):
            return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z

        @staticmethod
        def cross(lhs, rhs):
            return Vector3(
                lhs.y * rhs.z - lhs.z * rhs.y,
                lhs.z * rhs.x - lhs.x * rhs.z,
                lhs.x * rhs.y - lhs.y * rhs.x
            )

        @staticmethod
        def distsq(lhs, rhs):
            delta = lhs - rhs
            return delta.x * delta.x + delta.y * delta.y + delta.z * delta.z

        @staticmethod
        def dist(lhs, rhs):
            return math.sqrt(Vector3.distsq(lhs, rhs))

        # ---------------------------------------------------
        # property
        # ---------------------------------------------------
        @property
        def lengthsq(self):
            return self.x * self.x + self.y * self.y + self.z * self.z

        @property
        def length(self):
            return math.sqrt(self.lengthsq)

        @property
        def normalized(self):
            len_ = self.length
            return self / len_

        @property
        def inverse(self):
            return Vector3(-self.x, -self.y, -self.z)

        # ---------------------------------------------------
        # meta-method
        # ---------------------------------------------------
        def __add__(self, other):
            return Vector3(self.x + other.x, self.y + other.y, self.z + other.z)

        def __sub__(self, other):
            return Vector3(self.x - other.x, self.y - other.y, self.z - other.z)

        def __mul__(self, other):
            return Vector3(self.x * other, self.y * other, self.z * other)

        def __div__(self, other):
            return Vector3(self.x / other, self.y / other, self.z / other)

        def __str__(self):
            return "({:<7.2}, {:<7.2}, {:7.2})".format(self.x, self.y, self.z)

        def __eq__(self, other):
            return self.x == other.x and self.y == other.y and self.z == other.z

        __repr__ = __str__

Point3 = Vector3

if __name__ == '__main__':
    print Vector3()
    print Vector3(1, 2, 3)
    print Vector3(1. / 3, 1. / 3, 2. / 3)
    print Vector3(21. / 3, 121. / 3, 13542. / 3)
