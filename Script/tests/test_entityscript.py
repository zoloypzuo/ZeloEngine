# coding=utf-8
# test_entityscript.py
# created on 2020/10/20
# author @zoloypzuo
# usage: test_entityscript

import unittest

from entityscript import EntityScript


class TestEntityScript(unittest.TestCase):
    def test_component(self):
        e0 = EntityScript()
        e0.add_component('transform')
        transform = e0.components.transform
        e0.remove_component('transform')