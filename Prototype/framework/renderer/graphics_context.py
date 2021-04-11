# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# graphics_context.py
# created on 2020/12/24
# usage: graphics_context
import glfw

class GraphicsContext(object):
    def __init__(self, window_handle):
        super(GraphicsContext, self).__init__()
        self.window_handle = window_handle
        self.initialize()

    def initialize(self):
        glfw.make_context_current(self.window_handle)

    def swap_buffers(self):
        glfw.swap_buffers(self.window_handle)

