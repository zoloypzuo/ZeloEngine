# coding=utf-8
# test_zinput.py
# created on 2020/10/10
# author @zoloypzuo
# usage: test_zinput

import unittest

from framework.zinput import *


class TestZeloInput(unittest.TestCase):
    @unittest.skip('gamepad vibrate')
    def test_vibrate(self):
        inputm = Input()
        inputm.gamepad.vibrate(0, 1, 1000)

