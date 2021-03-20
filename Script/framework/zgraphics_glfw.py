# coding=utf-8
# zgraphics.py
# created on 2020/9/27
# author @zoloypzuo
# usage: rhi

from OpenGL.GL import *
from OpenGL.GLU import *
from OpenGL.raw.GL.VERSION.GL_1_0 import glClearColor, glClear, GL_COLOR_BUFFER_BIT, GL_DEPTH_BUFFER_BIT

import G
from common.zlogger import logger
from common.ztable import Table
from framework.renderer.renderer_api import RendererApi
from interfaces.runtime import IRuntimeModule

# TODO 接入glfw渲染器
#   [] camera
#   [] 渲染项
#   [] render loop
from main_functions import ents


class Graphics(RendererApi, IRuntimeModule):
    """
    Attributes:
        enable_light: 启用光照，默认添加一个全局太阳

    """

    def __init__(self):
        super(Graphics, self).__init__()
        self.enable_msaa = True
        self.enable_shader = True
        self.enable_text = False
        self.renderable_map = {}
        self.clear_flag = GL_COLOR_BUFFER_BIT
        self.current_matrix_mode = None
        self.enable_depth_test = True
        self.enable_light = False
        self.enable_texture = False
        self.clear_color = (.9, .95, 1.0, 1.0)
        self.near = 0.1
        self.far = 1000.
        self.fov = 60.
        self.projection_mode = 0  # 0 for perspective, 1 for ortho
        self._look_at_args = Table(
            eye_position=(-25.0, 8.0, 5.0),
            target_position=(0.0, 5.0, 22.0),
            up=(0.0, 1.0, 0.0)
        )

    @logger
    def recalculate_projection_matrix(self, width, height):
        """
        重新计算projection-matrix
        :return:
        """
        aspect_ratio = width / height
        glMatrixMode(GL_PROJECTION)
        glLoadIdentity()
        if self.projection_mode == 0:
            gluPerspective(self.fov, aspect_ratio, self.near, self.far)
        else:
            gluOrtho2D(0., width, 0.01, height)
        glMatrixMode(GL_MODELVIEW)

    @logger
    def on_resize(self, width, height):
        glViewport(0, 0, width, height)
        # if GL_SCISSOR_TEST enabled:
        pass  # glScissor(0, 0, width, height)
        pass  # self.recalculate_projection_matrix(width, height)

    def add_renderable(self, renderable):
        self.renderable_map[id(renderable)] = renderable

    # ---------------------------------------------------
    # IRuntimeModule
    # ---------------------------------------------------
    @logger
    def initialize(self):
        @logger
        def init_depth_test():
            glEnable(GL_DEPTH_TEST)
            glDepthFunc(GL_LESS)
            # glDepthMask(GL_FALSE)

        if self.enable_depth_test:
            init_depth_test()
        if self.enable_msaa:
            glEnable(GL_MULTISAMPLE)
        pass  # self.recalculate_projection_matrix(G.appm.width, G.appm.height)

    def update(self):
        # init render
        glClearColor(*self.clear_color)
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
        # in render
        for renderer in self.renderers:
            if not renderer.is_initialized:
                renderer.initialize()
                renderer.is_initialized = True
            renderer.on_render()
            self.draw_array(renderer.vao)
        # fini render
        pass  # import glfw
        pass  # glfw.swap_buffers(G.appm.window_handle)

    @property
    def renderers(self):
        return filter(None, [entity.get_component_of_type("renderer") for _, entity in ents.iteritems()])

    @logger
    def finalize(self):
        pass
