# coding=utf-8
# transform.py
# created on 2020/10/20
# author @zoloypzuo
# usage: transform

from typing import Union, List

import G
from framework.math.matrix4 import Matrix4
from framework.math.quaternion import Quaternion
from framework.math.vector3 import Vector3


class NodeBase(object):
    """
    scene graph node
    TODO weakref list children or weakref parent
    """

    def __init__(self):
        self.parent = None  # type: Union[Transform, None]
        self.children = []  # type: List[Transform]
        # self.index = -1  # type: int

    def get_child(self, index):
        # type: (int) -> Transform
        """

        :param index:
        :return:
        """
        return self.children[index]

    def set_parent(self, parent):
        # type: (Transform) -> None
        """

        :param parent:
        :return:
        """
        old_parent = self.parent
        if old_parent:
            old_parent.children.remove(self)
        self.parent = parent  # type: NodeBase
        # index = len(parent.children)
        self.parent.children.append(self)
        # self.index = index


class Transform(NodeBase):
    """
    Attributes:
        size: uniformed scale
        rotation: euler
    """

    def __init__(self, inst, parent=None, is_root=False):
        super(Transform, self).__init__()
        self.inst = inst
        if not is_root:
            parent = parent or G.logicm.root
            self.set_parent(parent)

        # ---------------------------------------------------
        # local space transform
        # ---------------------------------------------------
        self.position = Vector3()
        self.scale = Vector3(1, 1, 1)
        self.orientation = Quaternion()
        self.rotation = Vector3()

        # ---------------------------------------------------
        # world space transform
        # ---------------------------------------------------
        # self.derived_position = Vector3()
        # self.derived_rotation = Vector3()
        # self.derived_scale = Vector3(1, 1, 1)
        # self.derived_transform = Matrix4()

    # ---------------------------------------------------
    # property
    # ---------------------------------------------------
    @property
    def forward(self):
        f = Vector3.forward().to_vec4()
        return self.local_to_world_matrix * f

    def right(self):
        r = Vector3.right().to_vec4()
        return self.local_to_world_matrix * r

    def up(self):
        u = Vector3.up().to_vec4()
        return self.local_to_world_matrix * u

    @property
    def local_to_world_matrix(self):
        # type: () -> Matrix4
        res = Matrix4.identity()  # type: Matrix4
        t = self  # type: Transform
        while t:
            # NOTE OpenGL vs DirectX
            #   column major vs row major
            #   lrs and rhs order
            res = t.local_srt_matrix * res
            t = t.parent
        return res

    @property
    def world_to_local_matrix(self):
        # type: () -> Matrix4
        return self.local_to_world_matrix.inverse()

    @property
    def local_srt_matrix(self):
        # type: () -> Matrix4
        return Matrix4.translate(self.position) * Matrix4.rotate(self.rotation) * Matrix4.scale(self.scale)

    # ---------------------------------------------------
    # basic srt operation
    # ---------------------------------------------------
    @property
    def size(self):
        return self.scale.x

    @size.setter
    def size(self, val):
        self.scale = Vector3(val, val, val)

    def rotate(self, eulers):
        # type: (Vector3) -> None
        """

        :param eulers:
        :return:
        """
        self.rotation += eulers

    def translate(self, offset):
        # type: (Vector3) -> None
        """

        :param offset:
        :return:
        """
        self.position += offset

    # ---------------------------------------------------
    # other transform operation
    # ---------------------------------------------------
    def lookat(self, target):
        # type: (Vector3) -> None
        """
        may be HARD
        :param target:
        :return:
        """
        pass

    # ---------------------------------------------------
    # misc
    # ---------------------------------------------------

    @property
    def world_position(self):
        """
        x, y, z
        :return:
        """
        return self.local_to_world_matrix * self.position

    # TODO rm it
    def position_updater(self):
        return self.position


transform = Transform
