# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# camera_glfw.py
# created on 2020/12/24
# usage: camera_glfw
from math import cos, sin
import glm

# @formatter:off
# Camera_Movement
FORWARD  = "FORWARD"
BACKWARD = "BACKWARD"
LEFT     = "LEFT"
RIGHT    = "RIGHT"

YAW         = -90.0
PITCH       =  0.0
SPEED       =  2.5
SENSITIVITY =  0.1
ZOOM        =  45.0
# @formatter:on

class AbstractCameraBase(object):
    @property
    def view_matrix(self):
        return glm.mat4(1.)


class CameraGlfw:
    def __init__(self, position=None, up=None, yaw=None, pitch=None):
        self.position = position or glm.vec3()
        self.front = glm.vec3(0., 0., -1)
        self.up = glm.vec3()  # up由worldup正交化得到
        self.right = up or glm.vec3()
        self.worldup = up or glm.vec3(0., 1., 0.)
        self.yaw = yaw or YAW
        self.pitch = pitch or PITCH
        self.movement_speed = SPEED
        self.mouse_sensitivity = SENSITIVITY
        self.zoom = ZOOM
        self._recompute_internal()

    @property
    def view_matrix(self):
        return glm.lookAt(self.position, self.position + self.front, self.up)

    # @logger
    def on_camera_move(self, direction, dt):
        # 按键输入控制移动，输入并无优先级，比如左右一起按下就是不动
        velocity = self.movement_speed * dt
        if direction == FORWARD:
            self.position += self.front * velocity
        if direction == BACKWARD:
            self.position -= self.front * velocity
        if direction == LEFT:
            self.position -= self.right * velocity
        if direction == RIGHT:
            self.position += self.right * velocity

    # @logger
    def on_camera_rotate(self, xoffset, yoffset):
        xoffset *= self.mouse_sensitivity
        yoffset *= self.mouse_sensitivity
        self.yaw += xoffset
        self.pitch += yoffset
        # constrain pitch:
        self.pitch = glm.clamp(self.pitch, -89, 89)
        self._recompute_internal()

    def on_camera_zoom(self, yoffset):
        self.zoom -= yoffset
        self.zoom = glm.clamp(self.zoom, 1, 45)

    def _recompute_internal(self):
        front = glm.vec3()
        front.x = cos(glm.radians(self.yaw)) * \
                  cos(glm.radians(self.pitch))
        front.y = sin(glm.radians(self.pitch))
        front.z = sin(glm.radians(self.yaw)) * \
                  cos(glm.radians(self.pitch))
        self.front = glm.normalize(front)
        self.right = glm.normalize(glm.cross(self.front, self.worldup))
        self.up = glm.normalize(glm.cross(self.right, self.front))

    def __repr__(self):
        return "CameraGlfw"
