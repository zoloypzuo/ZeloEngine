# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# physics.py
# created on 2020/12/31
# usage: physics
import pybullet


def Float3(vec):
    import numpy as np
    return np.array([vec.x, vec.y, vec.z], dtype=np.float32)


class PhysicsComponent(object):  # avoid name conflict
    def __init__(self, inst, name="cube"):
        self.physics_handle = 0
        self.inst = inst
        self.name = name
        self.initialized = False

    def init_by_physics_module(self):
        pass  # NOTE pybullet takes np.array, not glm.vec3
        self.physics_handle = pybullet.loadURDF(self.urdf_path, Float3(self.entity_transform.position))

    @property
    def entity_transform(self):
        return self.inst.components.transform

    @property
    def urdf_base(self):
        return r"D:\MiniProj_01\ZeloEngineScript\media\physics"

    @property
    def urdf_path(self):
        import os
        return os.path.join(self.urdf_base, "%s.urdf" % self.name)

    # ---------------------------------------------------
    # debug
    # ---------------------------------------------------
    def __repr__(self):
        return self.__class__.__name__

physics = PhysicsComponent
