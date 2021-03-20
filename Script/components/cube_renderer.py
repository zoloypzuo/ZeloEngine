# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# cube_renderer.py
# created on 2020/12/31
# usage: cube_renderer
import ctypes
from math import sin

import glfw
import glm
import imgui
import numpy as np
from OpenGL import GL as gl
from imgui.integrations.glfw import GlfwRenderer

import G
from components.renderer import RendererBase
from framework.renderer.buffer import VertexBuffer
from framework.renderer.shader import Shader
from framework.renderer.texture import Texture
from framework.renderer.vertex_array import VertexArray

vertexShaderSource = '''
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec2 aTexCoord;

out vec2 TexCoord;

uniform mat4 model;
uniform mat4 view;
uniform mat4 projection;

void main()
{
	gl_Position = projection * view * model * vec4(aPos, 1.0);
	TexCoord = vec2(aTexCoord.x, aTexCoord.y);
}
'''.strip()

fragmentShaderSource = '''
#version 330 core
out vec4 FragColor;

in vec3 ourColor;
in vec2 TexCoord;

// texture samplers
uniform sampler2D texture1;
uniform sampler2D texture2;

void main()
{
	// linearly interpolate between both textures (80% container, 20% awesomeface)
	FragColor = mix(texture(texture1, TexCoord), texture(texture2, TexCoord), 0.2);
}
'''.strip()

# @formatter:off
vertices = np.array([

    -0.5, -0.5, -0.5,  0.0, 0.0,
     0.5, -0.5, -0.5,  1.0, 0.0,
     0.5,  0.5, -0.5,  1.0, 1.0,
     0.5,  0.5, -0.5,  1.0, 1.0,
    -0.5,  0.5, -0.5,  0.0, 1.0,
    -0.5, -0.5, -0.5,  0.0, 0.0,

    -0.5, -0.5,  0.5,  0.0, 0.0,
     0.5, -0.5,  0.5,  1.0, 0.0,
     0.5,  0.5,  0.5,  1.0, 1.0,
     0.5,  0.5,  0.5,  1.0, 1.0,
    -0.5,  0.5,  0.5,  0.0, 1.0,
    -0.5, -0.5,  0.5,  0.0, 0.0,

    -0.5,  0.5,  0.5,  1.0, 0.0,
    -0.5,  0.5, -0.5,  1.0, 1.0,
    -0.5, -0.5, -0.5,  0.0, 1.0,
    -0.5, -0.5, -0.5,  0.0, 1.0,
    -0.5, -0.5,  0.5,  0.0, 0.0,
    -0.5,  0.5,  0.5,  1.0, 0.0,

     0.5,  0.5,  0.5,  1.0, 0.0,
     0.5,  0.5, -0.5,  1.0, 1.0,
     0.5, -0.5, -0.5,  0.0, 1.0,
     0.5, -0.5, -0.5,  0.0, 1.0,
     0.5, -0.5,  0.5,  0.0, 0.0,
     0.5,  0.5,  0.5,  1.0, 0.0,

    -0.5, -0.5, -0.5,  0.0, 1.0,
     0.5, -0.5, -0.5,  1.0, 1.0,
     0.5, -0.5,  0.5,  1.0, 0.0,
     0.5, -0.5,  0.5,  1.0, 0.0,
    -0.5, -0.5,  0.5,  0.0, 0.0,
    -0.5, -0.5, -0.5,  0.0, 1.0,

    -0.5,  0.5, -0.5,  0.0, 1.0,
     0.5,  0.5, -0.5,  1.0, 1.0,
     0.5,  0.5,  0.5,  1.0, 0.0,
     0.5,  0.5,  0.5,  1.0, 0.0,
    -0.5,  0.5,  0.5,  0.0, 0.0,
    -0.5,  0.5, -0.5,  0.0, 1.0
], dtype="float32")
# @formatter:on


class CubeRenderer(RendererBase):
    def __init__(self, inst):
        super(CubeRenderer, self).__init__(inst)
        self.is_initialized = False

    def initialize(self):
        self.sp = sp = Shader(vertexShaderSource, fragmentShaderSource)
        self.vao = vao = VertexArray()
        self.vbo = vbo = VertexBuffer(vertices)
        vao.add_vertex_buffer(vbo, self.layout)

        # texture
        self.tex1 = Texture(r"D:\PlayProj_00\playpy\play_garage\play_opengl\_resources\container.jpg")
        self.tex2 = Texture(r"D:\PlayProj_00\playpy\play_garage\play_opengl\_resources\awesomeface.png")
        sp.bind()
        self.tex1_slot = 0
        self.tex2_slot = 1
        sp.set_int("texture1", self.tex1_slot)
        sp.set_int("texture2", self.tex2_slot)

    def layout(self):
        # layout
        size_of_float = 4
        pos = ctypes.c_void_p(None)
        texture = ctypes.c_void_p(3 * size_of_float)
        gl.glVertexAttribPointer(0, 3, gl.GL_FLOAT, gl.GL_FALSE, 5 * size_of_float, pos)
        gl.glEnableVertexAttribArray(0)
        gl.glVertexAttribPointer(1, 2, gl.GL_FLOAT, gl.GL_FALSE, 5 * size_of_float, texture)
        gl.glEnableVertexAttribArray(1)

        # reset
        gl.glBindBuffer(gl.GL_ARRAY_BUFFER, 0)
        gl.glBindVertexArray(0)

    def on_render(self):
        # TODO get camera
        view = G.appm.view
        projection = G.appm.projection

        self.tex1.bind(self.tex1_slot)
        self.tex2.bind(self.tex2_slot)
        sp = self.sp
        sp.bind()
        sp.set_mat4("view", view)
        sp.set_mat4("projection", projection)
        self.vao.bind()
        model = glm.mat4(1)
        model = glm.translate(model, self.entity_transform.position)
        # TODO handle rotation
        sp.set_mat4("model", model)

    @property
    def entity_transform(self):
        return self.inst.components.transform

    # ---------------------------------------------------
    # debug
    # ---------------------------------------------------
    def __repr__(self):
        return self.__class__.__name__


cube_renderer = CubeRenderer
