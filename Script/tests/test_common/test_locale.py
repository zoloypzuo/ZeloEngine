# coding=utf-8
# test_locale.py
# created on 2020/9/27
# author @zoloypzuo
# usage: test_locale

import unittest
from common.zstrings import *
from common.zlanguage import *


class TestLocale(unittest.TestCase):
    def test_locale(self):
        print _(STRINGS.HelloWorld)
        print _("fweufhaehfgo e")
