# coding=utf-8
# test_zelo.py
# created on 2021/3/28
# author @zoloypzuo
# usage: test_zelo
from unittest import TestCase


class TestZelo(TestCase):
    def test00(self):
        import zelo
        self.assertEqual(3, zelo.add(1, 2))

    def test01(self):
        import zelo
        class MyEngine(zelo.Engine):
            def __init__(self):
                super(MyEngine, self).__init__()

            def start_script(self):
                print 1

        MyEngine().start()
