# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# zapp_glfw.py
# created on 2020/12/24
# usage: zapp_glfw

import glfw

import G
from common.zlogger import logger
from framework.renderer.graphics_context import GraphicsContext
from interfaces.runtime import IRuntimeModule


class App(object, IRuntimeModule):
    def __init__(self):
        super(App, self).__init__()
        # ---------------------------------------------------
        # config
        # ---------------------------------------------------
        self.width = 640
        self.height = 320
        self.init_window_position = (0, 0)
        self.dt = 1.0 / 30
        self.enable_msaa = True
        # ---------------------------------------------------
        # window
        # ---------------------------------------------------
        self.window_handle = None  # window handle
        self.graphics_context = None
        # ---------------------------------------------------
        # singleton
        # ---------------------------------------------------
        assert not G.appm, "duplicate singleton app"
        G.appm = self
        # ---------------------------------------------------
        # callbacks
        # ---------------------------------------------------
        self.on_initialize = getattr(self, 'on_initialize', None)
        self.on_finalize = getattr(self, 'on_finalize', None)
        self.on_update = getattr(self, 'on_update', None)
        self.on_render = getattr(self, 'on_render', None)
        self.on_resize = getattr(self, 'on_resize', None)
        self.on_mouse = getattr(self, 'on_mouse', None)
        self.on_keyboard = getattr(self, 'on_keyboard', None)
        self.on_motion = getattr(self, 'on_motion', None)
        self.on_input = getattr(self, "on_input", None)
        self.on_gui = getattr(self, "on_gui", None)
        self.on_scroll = getattr(self, "on_scroll", None)

    # ---------------------------------------------------
    # properties
    # ---------------------------------------------------
    @property
    def title(self):
        import sys
        return sys.argv[1] if len(sys.argv) > 1 else sys.argv[0]

    @property
    def aspect_ratio(self):
        self.height = self.height if self.height else 1
        return float(self.width) / self.height

    # ---------------------------------------------------
    # events
    # ---------------------------------------------------
    @logger
    def main(self):
        # start main loop
        main_update = G.main_update
        window_should_close = glfw.window_should_close
        window_handle = self.window_handle
        get_key = glfw.get_key
        key_escape = glfw.KEY_ESCAPE
        press = glfw.PRESS
        while get_key(window_handle, key_escape) != press and not window_should_close(window_handle):
            main_update()

    @logger
    def initialize(self):
        @logger
        def init_window():
            if not glfw.init():
                print("Could not initialize OpenGL context")
                exit(1)
            # OS X supports only forward-compatible core profiles from 3.2
            glfw.window_hint(glfw.CONTEXT_VERSION_MAJOR, 3)
            glfw.window_hint(glfw.CONTEXT_VERSION_MINOR, 3)
            glfw.window_hint(glfw.OPENGL_PROFILE, glfw.OPENGL_CORE_PROFILE)
            glfw.window_hint(glfw.OPENGL_FORWARD_COMPAT, True)
            if self.enable_msaa:
                glfw.window_hint(glfw.SAMPLES, 4)
            # Create a windowed mode window and its OpenGL context
            self.window_handle = window = glfw.create_window(
                int(self.width), int(self.height), self.title, None, None
            )
            if not window:
                glfw.terminate()
                raise RuntimeError("Could not initialize Window")
            self.graphics_context = GraphicsContext(window)

        @logger
        def init_callbacks():
            window = self.window_handle
            glfw.set_framebuffer_size_callback(window, self._resize_callback_wrapper)
            glfw.set_cursor_pos_callback(window, self._mouse_callback_wrapper)
            glfw.set_scroll_callback(window, self._scroll_callback_wrapper)

        init_window()
        init_callbacks()

    @logger
    def finalize(self):
        self.on_finalize and self.on_finalize()
        glfw.terminate()

    def update(self):
        glfw.poll_events()
        self.graphics_context.swap_buffers()
        self.on_input and self.on_input(self.window_handle)

    # ---------------------------------------------------
    # callbacks
    # ---------------------------------------------------
    def _resize_callback_wrapper(self, window, width, height):
        if width <= 400:
            width = 400
        if height <= 300:
            height = 300
        self.width = width
        self.height = height
        G.graphicsm.on_resize(width, height)

    def _mouse_callback_wrapper(self, window, xpos, ypos):
        self.on_mouse and self.on_mouse(window, xpos, ypos)

    def _scroll_callback_wrapper(self, window, xoffset, yoffset):
        self.on_scroll and self.on_scroll(window, xoffset, yoffset)

    # ---------------------------------------------------
    # debug
    # ---------------------------------------------------
    @logger
    def log(self, *args, **kwargs):
        pass
