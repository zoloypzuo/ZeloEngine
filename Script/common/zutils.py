# -*- coding:utf-8 -*-
# usage: 常用工具
import functools
import os
import random
import sys
import time

from common.zconfig import TheConfig

LOCAL_PYTHON_SYS_PATH = TheConfig.Python.sys_path
__DEBUG = TheConfig.Common.debug

print LOCAL_PYTHON_SYS_PATH, __DEBUG


def decorator(d):
    """标记一个函数是装饰器"""

    def _d(fn):
        return functools.update_wrapper(d(fn), fn)

    functools.update_wrapper(_d, d)
    return _d


# TODO 这个是不对的，有参数的装饰器写法有点奇怪
# @decorator
# def deprecated(fn, msg=''):
#     """
#     标记一个函数已过期
#     可以指定附加的msg
#     """
#
#     def wrapper(*args, **kwargs):
#         print 'ERROR using a deprecated API %s; %s' % (fn.__name__, msg)
#         return fn(*args, **kwargs)
#
#     return wrapper

@decorator
def deprecated(fn):
    """
    标记一个函数已过期
    可以指定附加的msg
    """
    import logging
    log_fn = logging.warn

    def wrapper(*args, **kwargs):
        log_fn('using a deprecated API %s', fn.__name__)
        return fn(*args, **kwargs)

    return wrapper


def defined(name):
    """
/
    :param name:
    :return:
    """
    return hasattr(globals(), name)


def getglobal(name):
    """
    /
    :param name:
    :return:
    """
    return getattr(globals(), name)


# ---------------------------------------------------
# log
# ---------------------------------------------------


def init_logger():
    """
    NOTSET < DEBUG < INFO < WARNING < ERROR < CRITICAL
    """
    import logging
    # log to console
    logging.basicConfig(
        level=logging.DEBUG if __DEBUG else logging.INFO,
        format='%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s',
        datefmt='%a, %d %b %Y %H:%M:%S',
        filename='./server_log.txt',
        filemode='w'
    )

    root_logger = logging.getLogger()
    console_handler = logging.StreamHandler(sys.stdout)
    log_formatter = logging.Formatter("%(asctime)s [%(levelname)-5.5s]  %(message)s")
    console_handler.setFormatter(log_formatter)
    root_logger.addHandler(console_handler)


# ---------------------------------------------------
# 程序分析
# ---------------------------------------------------
@decorator
def trace(f):
    """
    在调用链上的函数打上标记，打印堆栈
    Example 1
    # @trace
    # def f():
    #     g()
    #
    # @trace
    # def g():
    #     pass
    #
    # f()
    Outputs:
    # --> f()
    #    --> g()
    #    <-- g() == None
    # <-- f() == None

    Example 2
    # @trace
    # def fib(n):
    #     if n == 0 or n == 1:
    #         return 1
    #     else:
    #         return fib(n-1) + fib(n-2)
    #
    # fib(2)
    Outputs:
    # --> fib(2)
    #    --> fib(1)
    #    <-- fib(1) == 1
    #    --> fib(0)
    #    <-- fib(0) == 1
    # <-- fib(2) == 2
    """
    indent = '   '

    def _f(*args):
        signature = '%s(%s)' % (f.__name__, ', '.join(map(repr, args)))
        print '%s--> %s' % (trace.level * indent, signature)
        trace.level += 1
        try:
            result = f(*args)
            print '%s<-- %s == %s' % ((trace.level - 1) * indent,
                                      signature, result)
        finally:
            trace.level -= 1
        return result

    trace.level = 0
    return _f


def pycallgraph_call(f, *args, **kwargs):
    if not __DEBUG:
        return
    # 注意先在本地安装pycallgraph
    import sys
    sys.path += LOCAL_PYTHON_SYS_PATH
    from pycallgraph import PyCallGraph
    from pycallgraph.output import GraphvizOutput

    with PyCallGraph(output=GraphvizOutput()):
        return f(*args, **kwargs)


@decorator
def pycallgraph_trace(f):
    def wrapper(*args, **kwargs):
        return pycallgraph_call(f, *args, **kwargs)

    return wrapper


# ---------------------------------------------------
# 文件
# ---------------------------------------------------
def read_all(path):
    with open(path, 'r') as f:
        return f.read()


def write_all(path, s):
    make_dirs(path)
    with open(path, 'w') as f:
        return f.write(s)


def read_lines(path):
    with open(path, 'r') as f:
        text = f.read()
        lines = text.splitlines(keepends=True)
        return lines


def make_dirs(path):
    """
    输入完整路径（包含文件名），为该路径上所有目录创建目录保证能写入改文件
    :param path:
    :return:
    """
    if not os.path.exists(os.path.dirname(path)):
        os.makedirs(os.path.dirname(path))


def list_files(startpath):
    for root, dirs, files in os.walk(startpath):
        for f in files:
            yield root + '/' + f


# ---------------------------------------------------
# 其他
# ---------------------------------------------------
class Singleton(type):
    """单例元类"""
    CLASS_METHOD_IS_INITIALIZED = classmethod(lambda klass: klass in Singleton._instances)
    CLASS_METHOD_FINIALIZE = classmethod(lambda klass: Singleton._instances.pop(klass, None))

    _instances = {}

    def __new__(cls, name, bases, attrs):
        attrs.setdefault("is_initialized", classmethod(lambda klass: klass in Singleton._instances))
        attrs.setdefault("finialize", classmethod(lambda klass: Singleton._instances.pop(klass, None)))

        classtype = type.__new__(cls, name, bases, attrs)
        return classtype

    def __call__(klass, *args, **kwargs):
        # try-except is faster than if-in-else if dict contains key in most cases
        try:
            return Singleton._instances[klass]
        except KeyError:
            instance = Singleton._instances[klass] = super(Singleton, klass).__call__(*args, **kwargs)
            return instance


def is_iterable(o):
    from collections import Iterable
    return isinstance(o, Iterable)


def is_iterable_T(o, T):
    """是否是类型T的序列，比如List<T>"""
    if not is_iterable(o):
        return False
    return all(map(lambda item: isinstance(item, T), o))


@decorator
def memo(f):
    """memoization"""
    cache = {}

    def _f(*args):
        try:
            return cache[args]
        except KeyError:
            cache[args] = result = f(*args)
            return result
        except TypeError:
            # some element of args can't be a dict key
            return f(*args)

    _f.cache = cache
    return _f


# ---------------------------------------------------
# 游戏逻辑
# ---------------------------------------------------

_ID_COUNTER = 0


def generate_id():
    global _ID_COUNTER
    _ID_COUNTER += 1
    return _ID_COUNTER


def roulette(chance_weights):
    """
    轮盘赌
    :param chance_weights: 一个权重列表，权值是相对比例的，和不必为1
    :return: 轮盘停下时指向的权重索引
    """
    s = sum(chance_weights)
    chosen = random.uniform(0, s)
    p = 0
    for i in xrange(len(chance_weights)):
        p += chance_weights[i]
        if p > chosen:
            return i
    return len(chance_weights)


def roulette2(chance):
    """
    轮盘赌抛硬币
    :param chance: 硬币正面概率
    :return: 结果是正面为True
    """
    return roulette([chance, 1 - chance]) == 0


def allmax(iterable, key=None):
    """
    返回序列中最大的元素的列表

    Example
    allmax([1,2,2,3,4,5,5,5])
    Outputs:
    [5,5,5]
    """
    L = list(iterable)
    import itertools
    mx = max(key(x) for x in L)
    return list(itertools.ifilter(lambda x: key(x) == mx, iter(L)))


_RATE_LIMIT_TABLE = {}


# TODO calls限制实现
#   性价比不高，本来不需要RateLimit和时间戳队列结构的
#   calls含义模糊，是这个函数总共只能调用n次，还是一段时间内n次
# rate_limit(f, period=10.0, calls=1):
# class RateLimit:
#     def __init__(self, _id, fn, calls):
#         self.id = _id  # entity-id
#         self.fn = fn  # entity's method to call
#         self.name = fn.__name__  # method name
#         self.calls = calls  # call limit
#         self.time_queue = []  # 时间戳队列，记录最多最近n次调用时间戳
#
#     def __call__(self, *args, **kwargs):
#         self.fn(*args, **kwargs)

def rate_limit(period=10.0):
    """
    限制调用频率
    NOTE 函数的要求：Entity的方法，无返回值
        Entity.id和方法名作为ID
        因为限制频率，所以调用可能不执行，所以不应该也不能有返回值
    TODO 定期清理长期不用的的记录，可以添加period，超出了其实可以清空这项记录了
        这个需要绑到游戏循环上
        看性能需求，作为优化
    HINT 装饰器顺序，其他需要执行的装饰器放在rate_limit下面
    比如，logger执行时才打日志，如果放在上面，test_foo没执行也会打日志
    # @rate_limit(5)
    # @logger
    # def test_foo(self):
    #   pass
    :param period:
    :return:
    """

    @decorator
    def _outer_wrapper(fn):
        def _inner_wrapper(self, *args, **kwargs):
            rid = self.id, fn.__name__  # f是function，args[0]是self
            _now = time.time()
            if rid in _RATE_LIMIT_TABLE:
                last = _RATE_LIMIT_TABLE[rid]
                # print _now - last  # @zoloypzuo: for debug
                if _now - last < period:
                    return
            res = fn(self, *args, **kwargs)
            assert not res, '%s should not return thing' % fn.__name__
            _RATE_LIMIT_TABLE[rid] = _now

        return _inner_wrapper

    return _outer_wrapper


# ---------------------------------------------------
# 测试
# ---------------------------------------------------
def do_times(func, times=10000, *args, **kwargs):
    for i in xrange(times):
        func(*args, **kwargs)


def test():
    s = 0
    t = 100000
    for i in xrange(t):
        s = s + 1 if roulette2(0.3) else s
    print s / float(t)  # NOTE division in python2 is integer division


if __name__ == '__main__':
    test()
