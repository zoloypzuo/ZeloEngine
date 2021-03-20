# coding=utf-8
# zgraphics.py
# created on 2020/9/27
# author @zoloypzuo
# usage: rhi

from OpenGL.GL import *
from OpenGL.GLU import *

import G
from common.zlogger import logger
from common.ztable import Table
from interfaces.runtime import IRuntimeModule


class Graphics(object, IRuntimeModule):
    """
    Attributes:
        enable_light: 启用光照，默认添加一个全局太阳

    """

    def __init__(self):
        super(Graphics, self).__init__()
        self.enable_shader = True
        self.enable_text = False
        self.renderable_map = {}
        self.clear_flag = GL_COLOR_BUFFER_BIT
        self.current_matrix_mode = None
        self.enable_depth_test = True
        self.enable_light = True
        self.enable_texture = True
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

        if self.enable_depth_test:
            self.clear_flag = GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT

    # @logger
    def look_at(self, eye_position, target_position, up):
        self._look_at_args = Table(
            eye_position=eye_position,
            target_position=target_position,
            up=up
        )

    @logger
    def disable_look_at(self):
        self._look_at_args = None

    @logger
    def recalculate_projection_matrix(
            self, width, height):
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
        # glScissor(0, 0, width, height)
        self.recalculate_projection_matrix(width, height)

    def add_renderable(self, renderable):
        self.renderable_map[id(renderable)] = renderable

    @logger
    def _debug_callback(self, *args):
        """
        GLDEBUGPROCARB
        GLenum,  # source,
        GLenum, #type,
        GLuint, # id
        GLenum, # severity
        GLsizei, # length
        ctypes.c_char_p, # message
        GLvoidp, # userParam
        :param args:
        :return:
        """
        raise RuntimeError("OpenGL error")

    # ---------------------------------------------------
    # IRuntimeModule
    # ---------------------------------------------------
    @logger
    def initialize(self):
        @logger
        def init_gfx():
            glClearColor(*self.clear_color)

        # TODO bug
        # glDebugMessageCallback(self._debug_callback, None)

        @logger
        def init_depth_test():
            glEnable(GL_DEPTH_TEST)
            glDepthFunc(GL_LESS)
            # glDepthMask(GL_FALSE)

        @logger
        def init_shader():
            # GL_FLAT
            glShadeModel(GL_SMOOTH)

        @logger
        def init_light():
            # ---------------------------------------------------
            # 设置材质
            # ---------------------------------------------------
            mat_specular = [1., 0., 1., 1.]
            mat_shininess = [50.]
            glMaterialfv(GL_FRONT, GL_SPECULAR, mat_specular)
            glMaterialfv(GL_FRONT, GL_SHININESS, mat_shininess)

            # ---------------------------------------------------
            # 设置全局环境光
            # ---------------------------------------------------
            light_model_ambient = [.2, .2, .2, 1.]
            glLightModelfv(GL_LIGHT_MODEL_AMBIENT, light_model_ambient)

            # ---------------------------------------------------
            # 设置光源属性
            # ---------------------------------------------------
            light_ambient = [0., 0., 1., 1.]
            light_diffuse = [0., 0., 1., 1.]
            light_specular = [0., 0., 1., 1.]
            light_position = [1., 1., 1., 0.]

            glLightfv(GL_LIGHT0, GL_AMBIENT, light_ambient)
            glLightfv(GL_LIGHT0, GL_DIFFUSE, light_diffuse)
            glLightfv(GL_LIGHT0, GL_SPECULAR, light_specular)
            glLightfv(GL_LIGHT0, GL_POSITION, light_position)

            glEnable(GL_LIGHTING)
            glEnable(GL_LIGHT0)

        @logger
        def init_text():
            glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_MODULATE)
            # glEnable(GL_DEPTH_TEST)
            glEnable(GL_BLEND)
            glEnable(GL_COLOR_MATERIAL)
            glColorMaterial(GL_FRONT_AND_BACK, GL_AMBIENT_AND_DIFFUSE)
            glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
            glEnable(GL_TEXTURE_2D)

        @logger
        def init_texture():
            # initialize texture mapping
            glEnable(GL_TEXTURE_2D)
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST)
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST)
            glTexEnvf(GL_TEXTURE_ENV, GL_TEXTURE_ENV_MODE, GL_DECAL)

        init_gfx()
        if self.enable_depth_test:
            init_depth_test()
        if self.enable_shader:
            init_shader()
        if self.enable_light:
            init_light()
        if self.enable_text:
            init_text()
        if self.enable_texture:
            init_texture()
        self.recalculate_projection_matrix(G.appm.width, G.appm.height)

    def update(self):
        def init_render():
            glClearColor(*self.clear_color)
            # glClear(self.clear_flag)
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
            glMatrixMode(GL_MODELVIEW)
            glLoadIdentity()
            if self._look_at_args:
                look_at_args = self._look_at_args
                eye_position = look_at_args.eye_position
                target_position = look_at_args.target_position
                up = look_at_args.up
                args = list(eye_position) + list(target_position) + list(up)
                gluLookAt(*args)

        def finalize_render():
            from OpenGL.raw.GLUT import glutSwapBuffers
            glutSwapBuffers()

        def in_render():
            for renderable in self.renderable_map.values():
                renderable.render()

        init_render()
        in_render()
        finalize_render()

    @logger
    def finalize(self):
        pass
