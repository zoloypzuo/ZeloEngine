# coding=utf-8
# camera_god.py
# created on 2020/11/3
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# usage: camera_god
from OpenGL.raw.GLUT import GLUT_SCREEN_HEIGHT, GLUT_SCREEN_WIDTH

import G
from framework.math.vector3 import Vector3

print GLUT_SCREEN_HEIGHT, GLUT_SCREEN_WIDTH

import ctypes

user32 = ctypes.windll.user32
screensize = user32.GetSystemMetrics(0), user32.GetSystemMetrics(1)
print screensize


class CameraGod(object):
    def __init__(self):
        super(CameraGod, self).__init__()
        self.speed = 1.
        self.k = 1.
        self.k1 = -1.
        self.k2 = 1.
        self.k3 = 1.
        self.position = Vector3(
            -2.838275047825612e-16,
            4.755282581475767,
            -1.545084971874737)
        self.target = Vector3()
        self.up = Vector3(0, 1, 0)
        self.in_god_mode = True
        self.offset = Vector3()
        self.forward = Vector3.forward()
        self.k4 = .1

    def update(self):
        if not self.in_god_mode:
            return
        inputm = G.inputm
        gamepad = inputm.gamepad
        rx = gamepad.get_gamepad_states("ABS_RX")
        ry = gamepad.get_gamepad_states("ABS_RY")
        lx = gamepad.get_gamepad_states("ABS_X")
        ly = gamepad.get_gamepad_states("ABS_Y")
        lt = gamepad.get_gamepad_states("ABS_Z")
        rt = gamepad.get_gamepad_states("ABS_RZ")

        # move position
        # print lx
        self.offset = Vector3(self.k1 * lx, self.k2 * (rt - lt), self.k3 * ly)
        self.position = self.position + self.offset

        # look at forward
        self.target = self.position + self.forward + Vector3(-rx, ry, 0) * self.k4

        G.graphicsm.look_at(self.position, self.target, self.up)
