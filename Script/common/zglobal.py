# coding=utf-8
# zglobal.py
# created on 2020/9/19
# author @zoloypzuo
# usage: main & main-function
def load_script(directory, name):
    """

    :param directory:
    :param name:
    :return:
    """
    import importlib
    mod = importlib.import_module(directory + name)
    return getattr(mod, name, None)
