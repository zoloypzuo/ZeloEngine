# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# quaternion.py
# created on 2020/11/5
# usage: quaternion


import glm

if glm.quat:
    class Quaternion(glm.quat):
        pass
else:
    import math

    from vector3 import Vector3


    class Quaternion(object):
        """
        (r,         | i, j, k      )
        | real part | complex part |
        Attributes:
            # r:
            # i:
            # j:
            # k:
        """

        def __init__(self, r_=0., i_=0., j_=0., k_=0.):
            super(Quaternion, self).__init__()
            # self.data = [0., 0., 0., 0.]
            self.data = [r_, i_, j_, k_]

        # ---------------------------------------------------
        # data access
        # ---------------------------------------------------
        @property
        def r(self):
            # type: ()->float
            return self.data[0]

        @r.setter
        def r(self, val):
            # type: (float) -> None
            self.data[0] = val

        @property
        def i(self):
            # type: ()->float
            return self.data[1]

        @i.setter
        def i(self, val):
            # type: (float) -> None
            self.data[1] = val

        @property
        def j(self):
            # type: ()->float
            return self.data[2]

        @j.setter
        def j(self, val):
            # type: (float) -> None
            self.data[2] = val

        @property
        def k(self):
            # type: ()->float
            return self.data[3]

        @k.setter
        def k(self, val):
            # type: (float) -> None
            self.data[3] = val

        # ---------------------------------------------------
        # property
        # ---------------------------------------------------
        @property
        def normalize(self):
            # type: () -> Quaternion
            """
            normalize and validate self to a unit and valid Quaternion
            :return:
            """
            r = self.r
            i = self.i
            j = self.j
            k = self.k
            d = r * r + i * i + j * j + k * k
            # Check for zero length quaternion, and use the no-rotation
            # quaternion in that case.
            if d < 0.:
                r = 1
                return Quaternion(r, i, j, k)
            d = 1. / math.sqrt(d)
            r *= d
            i *= d
            j *= d
            k *= d
            return Quaternion(r, i, j, k)

        # ---------------------------------------------------
        # static method
        # ---------------------------------------------------
        @staticmethod
        def qq_mul(self, multiplier):
            # type: (Quaternion, Quaternion) -> Quaternion
            """
            self * multiplier
            :param self:
            :param multiplier:
            :return:
            """
            q = self
            r = q.r * multiplier.r - q.i * multiplier.i - \
                q.j * multiplier.j - q.k * multiplier.k
            i = q.r * multiplier.i + q.i * multiplier.r + \
                q.j * multiplier.k - q.k * multiplier.j
            j = q.r * multiplier.j + q.j * multiplier.r + \
                q.k * multiplier.i - q.i * multiplier.k
            k = q.r * multiplier.k + q.k * multiplier.r + \
                q.i * multiplier.j - q.j * multiplier.i
            return Quaternion(r, i, j, k)

        @staticmethod
        def add_scaled_vector(self, vector, scale):
            # type: (Quaternion, Vector3, float) -> Quaternion
            """

            :param self:
            :param vector:
            :param scale:
            :return:
            """
            q = Quaternion(0,
                           vector.x * scale,
                           vector.y * scale,
                           vector.z * scale)
            q *= self
            r = self.r
            i = self.i
            j = self.j
            k = self.k
            r += q.r * 0.5
            i += q.i * 0.5
            j += q.j * 0.5
            k += q.k * 0.5
            return Quaternion(r, i, j, k)

        @staticmethod
        def rotate_by_vector(self, vector):
            # type: (Quaternion, Vector3) -> Vector3
            """

            :param self:
            :param vector:
            :return:
            """
            q = Quaternion(0, vector.x, vector.y, vector.z)
            return self * q

        # ---------------------------------------------------
        # meta method
        # ---------------------------------------------------
        def __getitem__(self, item):
            # type: (int) -> float
            return self.data[item]

        def __setitem__(self, key, value):
            # type: (int, float) -> None
            self.data[key] = value

        def __mul__(self, other):
            # type: (Quaternion) -> Quaternion
            return Quaternion.qq_mul(self, other)
