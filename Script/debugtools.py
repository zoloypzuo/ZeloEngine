# coding=utf-8
# debugtools.py
# created on 2020/9/7
# author @zoloypzuo
# usage: 调试打印
import traceback
import pprint


def debugstack():
    """
    打印堆栈

    Example
    # def f():
    #     g()
    #
    #
    # def g():
    #     debugstack()
    Output
    # C:\Python27\python.exe E:/MiniProj_01/ZeloEngineScript/debugtools.py
    #   File "E:/MiniProj_01/ZeloEngineScript/debugtools.py", line 28, in <module>
    #     f()
    #   File "E:/MiniProj_01/ZeloEngineScript/debugtools.py", line 11, in f
    #     g()
    """
    print ''.join(traceback.format_stack()[:-2])


def dumptable(o):
    """
    美观地打印一个对象
    :param o:
    """
    pprint.pprint(o)


def dumpcomponent(comp):
    """
    TODO
    :param comp:
    """
    pass


def dumpentity(ent):
    """
    TODO
    :param ent:
    """
    pass


def mem_report():
    """
    内存报告
    # MEM REPORT:
    # {<type 'str'>: 1,
    #  <type 'NoneType'>: 1,
    #  <type 'module'>: 2,
    #  <type 'function'>: 4,
    #  <type 'dict'>: 0}
    """
    seen = set()
    counts = {}

    def count_object(o):
        t = type(o)
        counts[t] = counts[t] + 1 if t in counts else 0

    def count_table(t):
        if id(t) in seen:
            return
        count_object(t)
        seen.add(id(t))
        for _, v in t.iteritems():
            if isinstance(v, dict):
                count_table(v)
            else:
                count_object(v)

    count_table(globals())
    print 'MEM REPORT:'
    dumptable(counts)


if __name__ == '__main__':
    mem_report()
