# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# renderer_api.py
# created on 2020/12/25
# usage: renderer_api

from OpenGL import GL as gl


class RendererApi(object):
    def __init__(self):
        self.enable_blend = False
        self.enable_depth_test = True

    def initialize(self):
        if self.enable_blend:
            gl.glEnable(gl.GL_BLEND)
            gl.glBlendFunc(gl.GL_SRC_ALPHA, gl.GL_ONE_MINUS_SRC_ALPHA)
        if self.enable_depth_test:
            gl.glEnable(gl.GL_DEPTH_TEST)

    def set_viewport(self, x, y, width, height):
        gl.glViewport(x, y, width, height)

    def set_clear_color(self, color):
        gl.glClearColor(*color)

    def clear(self):
        gl.glClear(gl.GL_COLOR_BUFFER_BIT | gl.GL_DEPTH_BUFFER_BIT)

    def draw_indexed(self, vertex_array, index_count=None):
        index_count = index_count or len(vertex_array)
        vertex_array.bind()
        gl.glDrawElements(gl.GL_TRIANGLES, index_count, gl.GL_UNSIGNED_INT, None)
        gl.glBindTexture(gl.GL_TEXTURE_2D, 0)  # NOTE 避免状态泄露

    def draw_array(self, vertex_array):
        vertex_array.bind()
        gl.glDrawArrays(gl.GL_TRIANGLES, 0, 36)
