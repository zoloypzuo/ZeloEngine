# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# matrix4.py
# created on 2020/11/4
# usage: matrix4


import glm

if glm.mat4:
    class Matrix4(glm.mat4):

        @staticmethod
        def identity():
            return glm.mat4(1)

        @property
        def inverse(self):
            # type: () -> Matrix4
            return glm.inverse(self)

        @staticmethod
        def rotate(angle, axis):
            m = Matrix4.identity()
            return glm.rotate(m, angle, axis)

        @staticmethod
        def translate(v):
            m = Matrix4.identity()
            return glm.translate(m, v)

        @staticmethod
        def scale(v):
            m = Matrix4.identity()
            return glm.scale(m, v)

        @staticmethod
        def rotate_yaw_pitch_row(eulers):
            # type: (Vector3) -> Matrix4
            m = Matrix4.identity()
            # NOTE in zxy order
            m = glm.rotate(m, eulers.z, Vector3(0, 0, 1))
            m = glm.rotate(m, eulers.x, Vector3(1, 0, 0))
            m = glm.rotate(m, eulers.y, Vector3(0, 1, 0))
            return m

else:
    from vector3 import Vector3


    class Matrix4(object):
        """
        Holds a transform matrix, consisting of a rotation matrix and a position.

        The matrix has 12 elements, it is assumed that the remaining four are (0,0,0,1);
        producing a homogenous matrix.
        """

        def __init__(self):
            self.data = \
                [
                    [1., 0., 0., 0.],
                    [0., 1., 0., 0.],
                    [0., 0., 1., 0.],
                    [0., 0., 0., 1.],
                ]

        def get_by_index(self, index):
            # type: (int) -> float
            """

            :param index:
            :return:
            """
            x = index // 4
            y = index % 4
            return self.data[x][y]

        def get_by_xy(self, x, y):
            return self.data[x][y]

        def set_by_index(self, index, val):
            # type: (int, float) -> None
            """

            :param index:
            :param val:
            :return:
            """
            x = index // 4
            y = index % 4
            self.data[x][y] = val

        def set_by_xy(self, x, y, val):
            # type: (int, int, float) -> None
            """

            :param x:
            :param y:
            :param val:
            :return:
            """
            self.data[x][y] = val

        def set_diagonal(self, a, b, c):
            # type: (float, float, float)->None
            """

            :param a:
            :param b:
            :param c:
            :return:
            """
            self.data[0][0] = a
            self.data[1][1] = b
            self.data[2][2] = c

        @staticmethod
        def mm_mul(a, b):
            # type: (Matrix4, Matrix4) -> Matrix4
            """

            :param a:
            :param o:
            :return:
            """
            result = Matrix4()
            result.data[0] = (b[0] * a[0]) + (b[4] * a[1]) + (b[8] * a[2])
            result.data[4] = (b[0] * a[4]) + (b[4] * a[5]) + (b[8] * a[6])
            result.data[8] = (b[0] * a[8]) + (b[4] * a[9]) + (b[8] * a[10])

            result.data[1] = (b[1] * a[0]) + (b[5] * a[1]) + (b[9] * a[2])
            result.data[5] = (b[1] * a[4]) + (b[5] * a[5]) + (b[9] * a[6])
            result.data[9] = (b[1] * a[8]) + (b[5] * a[9]) + (b[9] * a[10])

            result.data[2] = (b[2] * a[0]) + (b[6] * a[1]) + (b[10] * a[2])
            result.data[6] = (b[2] * a[4]) + (b[6] * a[5]) + (b[10] * a[6])
            result.data[10] = (b[2] * a[8]) + (b[6] * a[9]) + (b[10] * a[10])

            result.data[3] = (b[3] * a[0]) + (b[7] * a[1]) + (b[11] * a[2]) + a[3]
            result.data[7] = (b[3] * a[4]) + (b[7] * a[5]) + (b[11] * a[6]) + a[7]
            result.data[11] = (b[3] * a[8]) + (b[7] * a[9]) + (b[11] * a[10]) + a[11]
            return result

        @staticmethod
        def mv_mul(m, v):
            # type: (Matrix4, Vector3) -> Matrix4
            """

            :param m:
            :param v:
            :return:
            """
            return Vector3(
                v.x * m[0] +
                v.y * m[1] +
                v.z * m[2] + m[3],

                v.x * m[4] +
                v.y * m[5] +
                v.z * m[6] + m[7],

                v.x * m[8] +
                v.y * m[9] +
                v.z * m[10] + m[11]
            )

        @property
        def determinant(self):
            # type: ()->float
            """

            :return:
            """
            return 0

        @property
        def inverse(self):
            pass

        # TODO a lot of work

        # ---------------------------------------------------
        # meta method
        # ---------------------------------------------------
        def __getitem__(self, item):
            # type: (int) -> float
            return self.get_by_index(item)

        def __setitem__(self, key, value):
            # type: (int, float) -> None
            self.set_by_index(key, value)

        def __mul__(self, other):
            # type: (Matrix4 | Vector3) -> Matrix4
            if isinstance(other, Vector3):
                return Matrix4.mv_mul(self, other)
            elif isinstance(other, Matrix4):
                return Matrix4.mm_mul(self, other)
