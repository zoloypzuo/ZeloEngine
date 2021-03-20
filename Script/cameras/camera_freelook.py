# coding=utf-8
# camera_freelook.py
# created on 2020/11/1
# author @zoloypzuo
# usage: camera_freelook
import math

import G
from common.zlogger import logger
from components.transform import Transform
from framework.math.vector3 import Vector3


class CameraFreelook(object):
    def __init__(self):
        super(CameraFreelook, self).__init__()
        self._radius = 20.
        self._phi = .1 * math.pi
        self._theta = 1.5 * math.pi
        self.target_position = Vector3(0, 0, 0)
        self.kx = .1
        self.ky = .1
        self.up = Vector3(0, 1, 0)
        self.position = Vector3()
        self.transform = Transform(self)
        self.rx = 0
        self.ry = 0
        self.rx_last = 0
        self.ry_last = 0

    @property
    def control(self):
        return "Gamepad" if G.inputm.gamepad._gamepad else "Keyboard & Mouse"

    def update(self):
        # ---------------------------------------------------
        # input to change camera params
        # ---------------------------------------------------
        if self.control == "Gamepad":
            inputm = G.inputm
            gamepad = inputm.gamepad
            rx = gamepad.get_gamepad_states("ABS_RX")
            ry = gamepad.get_gamepad_states("ABS_RY")
        elif self.control == "Keyboard & Mouse":
            rx = self.rx - self.rx_last
            ry = self.ry - self.ry_last
            self.rx_last = self.rx
            self.ry_last = self.ry
        else:
            rx = 0
            ry = 0

        self._theta += rx * self.kx
        self._phi += ry * self.ky
        # ---------------------------------------------------
        # sphere coordinate to dikaer coordinate
        # ---------------------------------------------------
        self.x = self._radius * math.sin(self._phi) * math.cos(self._theta)
        self.z = self._radius * math.sin(self._phi) * math.sin(self._theta)
        self.y = self._radius * math.cos(self._phi)

        # ---------------------------------------------------
        # look at
        # ---------------------------------------------------
        self.position = Vector3(self.x, self.y, self.z)
        G.graphicsm.look_at(self.position, self.target_position, self.up)

    @logger
    def handle_rx(self, x):
        self._theta += x * self.kx

    @logger
    def handle_ry(self, y):
        self._phi += y * self.ky

    def __str__(self):
        return "<CameraFreelook>"

    __repr__ = __str__
