# coding=utf-8
# empty_glfw_app.py
# created on 2020/10/20
# author @zoloypzuo
# usage: empty_glfw_app

from common.zlogger import logger
from framework.zapp_glfw import App
from main import game_main_from_app


class EmptyGlfwApp(App):
    def __init__(self):
        super(EmptyGlfwApp, self).__init__()

    # ---------------------------------------------------
    # callbacks
    # ---------------------------------------------------
    @logger
    def on_initialize(self):
        return

    def on_update(self, dt):
        pass


if __name__ == '__main__':
    game_main_from_app(EmptyGlfwApp)