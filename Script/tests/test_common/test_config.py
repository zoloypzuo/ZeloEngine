# coding=utf-8
# test_config.py
# created on 2020/9/21
# author @zoloypzuo
# usage: test_config
from unittest import TestCase
from common.zconfig import *

from common.ztable import *


class TestConfig(TestCase):
    def test_override(self):
        conf = Table.parse_pairs(DEFAULT)
        self.assertEqual(conf.debug, True)
        print conf
        conf.set_table(OVERRIDES['TEST'])
        self.assertEqual(conf.debug, False)
        print conf
        self.assert_(conf.frame)  # 重载部分选项不会把默认配置中的选项删除
