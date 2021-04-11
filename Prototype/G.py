# coding=utf-8
# G.py
# created on 2020/10/16
# author @zoloypzuo
# usage: G
from common.zlogger import logger
from editor.zeditor import Editor
from framework.zgui import Gui
from framework.zinput import Input
from framework.zlogic import Logic
from framework.zphysics import Physics

debug = True
rhi_type = "OpenGL"


# ---------------------------------------------------
# debug
# ---------------------------------------------------
@logger
def logfn(*args, **kwargs):
    """
    use this as callback for debug
    :param args:
    :param kwargs:
    :return:
    """
    pass


# ---------------------------------------------------
# data
# ---------------------------------------------------
cmd_argv = None
use_glut = False


def deltatime():
    return appm.dt


# ---------------------------------------------------
# managers
# ---------------------------------------------------
appm = None
graphicsm = None
logicm = Logic()  # type: Logic
inputm = Input()  # type: Input
guim = Gui()  # type: Gui
editorm = Editor()
physicsm = Physics()


def init_order():
    return [
        appm,
        graphicsm,
        logicm,
        inputm,
        physicsm,
    ] if use_glut else [
        appm,
        graphicsm,
        logicm,
        inputm,
        physicsm,
        guim,
        editorm,
    ]


@logger
def main_initialize():
    for m in init_order():
        m.initialize()


@logger
def main_finalize():
    for m in init_order()[::-1]:
        m.finalize()


def main_update():
    """
    mainloop
    :return:
    """
    if use_glut:
        appm.update()
        inputm.update()
        logicm.update()
        physicsm.update()
        graphicsm.update()
    else:
        appm.update()
        inputm.update()
        logicm.update()
        physicsm.update()
        graphicsm.update()
        guim.update()
        # editorm.update() use guim to update
