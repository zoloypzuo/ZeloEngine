# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# zphysics.py
# created on 2020/12/31
# usage: zphysics
import pybullet

from interfaces.runtime import IRuntimeModule

# [x] create physics class
# [x] add to mainloop
# [x] logic transform-> physics transform -> physics compute -> logic transform
from main_functions import ents


def pretty_vec(bt_vec):
    return map("{:>5.2f}".format, bt_vec)


class Physics(object, IRuntimeModule):
    def __init__(self):
        super(Physics, self).__init__()
        self.physics_client = None

    def initialize(self):
        self.physics_client = pybullet.connect(pybullet.DIRECT)
        pass  # pybullet.setAdditionalSearchPath(pybullet_data.getDataPath())
        pass  # pybullet.setAdditionalSearchPath(self.resource_manager.project_path)
        pybullet.setGravity(0,-10,0)

    def finalize(self):
        pass

    def update(self):
        pybullet.stepSimulation()

        for physics_cmpt in self.physics_actors:
            if not physics_cmpt.initialized:
                physics_cmpt.init_by_physics_module()
                physics_cmpt.initialized = True
            position, rotation = pybullet.getBasePositionAndOrientation(physics_cmpt.physics_handle)
            physics_cmpt.entity_transform.position = position
            physics_cmpt.entity_transform.orientation = rotation

        # TODO debug draw
        #         self.debug_line_manager.draw_debug_line_3d(Float3(0.0, 0.0, 0.0), Float3(3.0, 0.0, 0.0), Float4(1.0, 0.0, 0.0, 1.0), width=3.0)
        #         self.debug_line_manager.draw_debug_line_3d(Float3(0.0, 0.0, 0.0), Float3(0.0, 3.0, 0.0), Float4(0.0, 1.0, 0.0, 1.0), width=3.0)
        #         self.debug_line_manager.draw_debug_line_3d(Float3(0.0, 0.0, 0.0), Float3(0.0, 0.0, 3.0), Float4(0.0, 0.0, 1.0, 1.0), width=3.0)
        pass

    @property
    def physics_actors(self):
        return [entity.components.physics for entity in ents.itervalues() if entity.has_component("physics")]
