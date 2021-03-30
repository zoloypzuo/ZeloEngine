# coding=utf-8
# test_zelo.py
# created on 2021/3/28
# author @zoloypzuo
# usage: test_zelo
from unittest import TestCase


class TestZelo(TestCase):
    def test00_import(self):
        try:
            import zelo
        except ImportError as e:
            raise RuntimeError(e.message.decode("gbk").encode("utf-8"))

    def test01_add(self):
        import zelo
        self.assertEqual(3, zelo.add(1, 2))

    def test02_callback(self):
        import zelo
        class MyEngine(zelo.Engine):
            def __init__(self):
                super(MyEngine, self).__init__()

            def start_script(self):
                print 1

        MyEngine().start()
