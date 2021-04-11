# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# shader.py
# created on 2020/12/24
# usage: shader
from OpenGL import GL as gl
import glm


class Shader(object):
    def __init__(self, vs, fs):
        super(Shader, self).__init__()
        self.sp_handle = 0
        self._vs_src = vs
        self._fs_src = fs
        self._vs_handle = 0
        self._fs_handle = 0
        self.initialize()  # for convenience

    def initialize(self):
        self.sp_handle = gl.glCreateProgram()
        self._vs_handle = self._attach_shader(self.sp_handle, gl.GL_VERTEX_SHADER, self._vs_src)
        self._fs_handle = self._attach_shader(self.sp_handle, gl.GL_FRAGMENT_SHADER, self._fs_src)
        gl.glLinkProgram(self.sp_handle)
        # check for linking errors
        if not gl.glGetProgramiv(self.sp_handle, gl.GL_LINK_STATUS):
            raise RuntimeError("LINKING_FAILED %s" % gl.glGetProgramInfoLog(self.sp_handle))
        # delete vs and fs
        gl.glDeleteShader(self._vs_handle)
        gl.glDeleteShader(self._fs_handle)

    def _attach_shader(self, shader_program, shader_type, src):
        shader = gl.glCreateShader(shader_type)
        gl.glShaderSource(shader, src)
        gl.glCompileShader(shader)
        if not gl.glGetShaderiv(shader, gl.GL_COMPILE_STATUS):
            raise RuntimeError("COMPILATION_FAILED %s" % gl.glGetShaderInfoLog(shader))
        gl.glAttachShader(shader_program, shader)
        return shader

    def bind(self):
        gl.glUseProgram(self.sp_handle)

    def unbind(self):
        gl.glUseProgram(0)

    def finalize(self):
        gl.glDeleteProgram(self.sp_handle)

    # ---------------------------------------------------
    # uniform
    # ---------------------------------------------------
    def get_location(self, name):
        return gl.glGetUniformLocation(self.sp_handle, name)

    def set_bool(self, name, value):
        gl.glUniform1i(self.get_location(name), int(value))

    def set_int(self, name, value):
        gl.glUniform1i(self.get_location(name), value)

    def set_float(self, name, value):
        gl.glUniform1f(self.get_location(name), value)

    def set_int_array(self, name, values, len_=None):
        gl.glUniform1iv(self.get_location(name), len_ or len(values), values)

    def set_float2(self, name, x, y):
        gl.glUniform2f(self.get_location(name), x, y)

    def set_float3(self, name, x, y, z):
        gl.glUniform3f(self.get_location(name), x, y, z)

    def set_float4(self, name, x, y, z, w):
        gl.glUniform4f(self.get_location(name), x, y, z, w)

    def set_mat3(self, name, mat3):
        gl.glUniformMatrix3fv(self.get_location(name), 1, gl.GL_FALSE, glm.value_ptr(mat3))

    def set_mat4(self, name, mat4):
        gl.glUniformMatrix4fv(self.get_location(name), 1, gl.GL_FALSE, glm.value_ptr(mat4))
