# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# test_zlinq.py
# created on 2020/11/10
# usage: test_zlinq

from unittest import TestCase

from common.zlinq import LinqIterable


class TestLinqIterable(TestCase):

    def setUp(self):
        self.data0 = LinqIterable([1, 2, 3, 4, 5])
        self.data1 = LinqIterable([1, 2, 4, 3, 5])
        self.data2 = LinqIterable([1, 1, 1, 2, 2, 3])
        self.data3 = LinqIterable([1, 2, 3, 4, 5])
        self.data4 = LinqIterable([1, 2, 3, 4, 5])

    def test_where(self):
        self.assertEqual(self.data0.where(lambda item: item > 2).to_tuple(), (3, 4, 5))

    def test_select(self):
        self.assertEqual(self.data0.select(lambda item: item + 1).to_tuple(), (2, 3, 4, 5, 6))

    def test_ordered_by(self):
        self.assertEqual(self.data1.ordered_by().to_tuple(), (1, 2, 3, 4, 5))

    def test_first_or_default(self):
        self.assertEqual(self.data0.first_or_default(lambda item: item > 1), 2)

    def test_reversed(self):
        self.assertEqual(self.data0.reversed().to_tuple(), (5, 4, 3, 2, 1))

    def test_take(self):
        self.assertEqual(self.data0.take(lambda item: item, 2), [(1, 1), (2, 1)])

    def test_union(self):
        self.assertEqual(self.data0 & self.data1, {1, 2, 3, 4, 5})

    def test_intersect(self):
        self.assertEqual(self.data0 & self.data1, {1, 2, 3, 4, 5})

    def test_to_set(self):
        self.assertEqual(self.data0.to_set(), {1, 2, 3, 4, 5})

    def test_to_list(self):
        self.assertEqual(self.data0.to_list(), [1, 2, 3, 4, 5])

    def test_to_tuple(self):
        self.assertEqual(self.data0.to_tuple(), (1, 2, 3, 4, 5))
