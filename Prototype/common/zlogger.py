# coding=utf-8
# zlogger.py
# created on 2020/9/10
# author @zoloypzuo
import datetime

from common.zconfig import TheConfig
from zutils import decorator

# ---------------------------------------------------
# config
# ---------------------------------------------------
_ENABLE_MOD = False
_MOD = 'default'
_PRETTY_PRINT = False
_USE_GAME_TIMESTAMP = True


# ---------------------------------------------------
# time
# ---------------------------------------------------
def _now():
    """

    :return:
    """
    return datetime.datetime.now()


def _now_str():
    """

    :return:
    """
    return str(datetime.datetime.now().strftime("%H:%M:%S"))


def _dt():
    """

    :return:
    """
    return _now() - _logger_start_ts


def _dt_str():
    """

    :return:
    """
    return str(_dt()).split('.')[0]


def _time_tag():
    return _dt_str() if _USE_GAME_TIMESTAMP else _now_str()


_logger_start_ts = _now()


# ---------------------------------------------------
# pprint
# ---------------------------------------------------
def set_enable_pretty_print(val):
    global _PRETTY_PRINT
    _PRETTY_PRINT = val


# ---------------------------------------------------
# module
# ---------------------------------------------------
# HINT 运气很好，这种方案行得通，导致模块标签实现起来非常简单；注意mod=MOD，这里用到闭包了
def set_logger_mod(name):
    global _MOD
    _MOD = name


def get_logger_mod():
    return _MOD if _ENABLE_MOD else ''


def reset_logger_mod():
    global _MOD
    _MOD = 'default'


# ---------------------------------------------------
# function defined file and line
# ---------------------------------------------------
def _func_defined_tag(fn):
    import inspect
    import os
    def_file = os.path.basename(inspect.getsourcefile(fn))
    def_line = inspect.getsourcelines(fn)[1]
    return '%s:%s' % (def_file, def_line)


# ---------------------------------------------------
# init logger
# ---------------------------------------------------
def init_logger():
    import logging
    import os

    log_txt = TheConfig.Common.localdataDir + '\\log.txt'
    log_backup_txt = TheConfig.Common.localdataDir + '\\log_backup.txt'
    cmd_cpy = 'copy /q %s %s > nul' % (log_txt, log_backup_txt)
    os.system(cmd_cpy)
    cmd_del = 'del /q %s' % log_txt
    os.system(cmd_del)
    logging.basicConfig(
        filename=log_txt,
        format='[%(levelname)s]%(message)s',
        datefmt='%Y-%m-%d:%H:%M:%S',
        level=logging.DEBUG)
    global _logger_default
    _logger_default = logging.getLogger(__name__)


_logger_default = None
init_logger()


# ---------------------------------------------------
# logger api
# ---------------------------------------------------
@decorator
def logger(fn):
    """
    打印函数入口，包含函数名，实参列表

    实现说明：这就是个工具，不要画蛇添足，如果需要复杂的，请使用logger手打，不要试图把这个工具去兼容logger，打各种tag
    """
    mod_tag = get_logger_mod()
    log_fn = _logger_default.info
    func_defined_tag = _func_defined_tag(fn)

    def wrapper(*args, **kwargs):
        log_fn(_call([_time_tag(), mod_tag, func_defined_tag], fn, *args, **kwargs))
        res = fn(*args, **kwargs)
        return res

    return wrapper


@decorator
def logger_full(fn):
    """
    打印函数入口和出口，出口包含返回值
    HINT 特别适用于函数式的函数
    """
    mod_tag = get_logger_mod()
    log_fn = _logger_default.info
    func_defined_tag = _func_defined_tag(fn)

    def wrapper(*args, **kwargs):
        log_fn(_call([_time_tag(), mod_tag, func_defined_tag], fn, *args, **kwargs))
        res = fn(*args, **kwargs)
        log_fn(_ret_simple(res, [_time_tag(), mod_tag, func_defined_tag], fn))
        return res

    return wrapper


@decorator
def logger_tail(fn):
    mod_tag = get_logger_mod()
    log_fn = _logger_default.info
    func_defined_tag = _func_defined_tag(fn)

    def wrapper(*args, **kwargs):
        res = fn(*args, **kwargs)
        log_fn(_ret(res, [_time_tag(), mod_tag, func_defined_tag], fn, *args, **kwargs))
        return res

    return wrapper


logger = logger_tail = lambda fn: fn  # noqa


def _object(o):
    import common.zjson
    return common.zjson.beautified_json(o, decodable=False)


def _arglist(*args, **kwargs):
    """
    输出函数参数列表，包含两侧圆括号
    :param args:
    :param kwargs:
    :return:
    """
    if _PRETTY_PRINT:
        return _object(args) + _object(kwargs)
    SEP = ', '
    # NOTE 不是str()，比如'a'.__repr__() -> "'a'"，而str('a') -> 'a'
    args_list = list((map(repr, args)))
    kwargs_list = ['%s=%s' % (k, repr(v)) for k, v in kwargs.iteritems()]
    args_list = tuple(args_list + kwargs_list)
    return '(%s)' % SEP.join(args_list)


def _result(res):
    if _PRETTY_PRINT:
        return _object(res)
    return res


def _function(f, *args, **kwargs):
    return '%s%s' % (f.__name__, _arglist(*args, **kwargs))


def _tags(tags):
    return ''.join(['[%s]' % tag for tag in tags if tag])


def _call(tags, f, *args, **kwargs):
    return '%s %s' % (_tags(tags), _function(f, *args, **kwargs))


def _ret(res, tags, f, *args, **kwargs):
    return '%s %s -> %s' % (_tags(tags), _function(f, *args, **kwargs), _result(res))


def _ret_simple(res, tags, f):
    return '%s %s -> %s' % (_tags(tags), f.__name__, _result(res))
