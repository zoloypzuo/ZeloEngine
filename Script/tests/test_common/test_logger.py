# coding=utf-8
# test_logger.py
# created on 2020/9/17
# author @zoloypzuo
# usage: test_logger
import unittest
from common.zlogger import *


class CTest:
    def __init__(self):
        self.a = 1
        self.b = 'afafw'


class MyTestCase(unittest.TestCase):
    def test_pretty_print(self):
        set_enable_pretty_print(True)

        @logger_tail
        def foo(*args, **kwargs):
            return {'a': 1}

        foo(1, False, 'sssss', a='awr', c='awrqwr')
        foo(CTest())
        set_enable_pretty_print(False)


if __name__ == '__main__':
    unittest.main()
