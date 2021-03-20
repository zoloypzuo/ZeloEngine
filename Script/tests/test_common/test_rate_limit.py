# coding=utf-8
# test_rate_limit.py
# created on 2020/9/9
# author @zoloypzuo

import datetime
import time
import unittest

from common.zutils import rate_limit
from common.zlogger import logger


class TestEnt:
    """
    模拟Entity

    Attribute:
        id: 模拟Entity用的id
    """

    def __init__(self, _id):
        self.id = _id
        self.call_foo_time = -100
        self.call_tee_time = -100

    @rate_limit(5)
    @logger
    def test_foo(self):
        _now = time.time()
        # print 'delta=%s' % (_now - self.call_foo_time)
        assert _now - self.call_foo_time > 5
        self.call_foo_time = time.time()

    @rate_limit()
    @logger
    def test_tee(self):
        _now = time.time()
        assert _now - self.call_foo_time > 10
        self.call_foo_time = time.time()

    # ---------------------------------------------------
    # meta-method
    # ---------------------------------------------------
    def __str__(self):
        return 'TestEnt("%s")' % self.id

    __repr__ = __str__


@unittest.skip("the test is time-consuming because sleep")
class TestRateLimit(unittest.TestCase):
    def setUp(self):
        self.a = TestEnt('aEnt')
        self.b = TestEnt('bEnt')

    def test0(self):
        # aEnt test_foo @2020-09-08 23:58:25.839000
        # aEnt test_foo @2020-09-08 23:58:39.840000
        self.a.test_foo()  # OK
        time.sleep(3)
        self.a.test_foo()  # 会被忽略
        time.sleep(3)
        self.a.test_foo()  # OK

    def test1(self):
        # aEnt test_foo @2020-09-08 23:59:09.882000
        # bEnt test_foo @2020-09-08 23:59:12.883000
        # aEnt test_foo @2020-09-08 23:59:23.883000
        self.a.test_foo()  # OK
        time.sleep(3)
        self.a.test_foo()  # 会被忽略
        self.b.test_foo()  # OK
        time.sleep(3)
        self.a.test_foo()  # OK

    def test_simple(self):
        a = TestEnt('EntA')
        a.test_foo()
        a.test_foo()
        time.sleep(3)
        a.test_foo()
        time.sleep(3)
        a.test_foo()


if __name__ == '__main__':
    unittest.main()
