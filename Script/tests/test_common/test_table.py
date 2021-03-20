# coding=utf-8
# test_table.py
# created on 2020/9/22
# author @zoloypzuo
# usage: test_table
from unittest import TestCase
from common.ztable import Table


class TestTable(TestCase):
    def test_set_table(self):
        conf = Table(a=Table(b=1))
        self.assertEqual(conf.a.b, 1)
        conf.a.b = 2
        self.assertEqual(conf.a.b, 2)

    def test_parse_pairs(self):
        self.fail()

    def test__parse_pairs_internal(self):
        self.fail()
