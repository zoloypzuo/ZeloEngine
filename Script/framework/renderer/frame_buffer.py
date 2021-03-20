# coding=utf-8
# frame_buffer.py
# created on 2020/12/26
# author @zoloypzuo
# usage: frame_buffer
from OpenGL import GL as gl


class FrameBuffer(object):
    def __init__(self, width=0, height=0, samples=1, swap_chain_target=False):
        self.handle = 0
        self.color_attachment_handle = 0
        self.depth_attachment_handle = 0
        self.width = width
        self.height = height
        self.samples = samples
        self.swap_chain_targets = swap_chain_target
        self.initialize()

    def initialize(self):
        if self.handle:
            self.finalize()
        self.handle = gl.glGenFramebuffers(1)

        self.color_attachment_handle = color_attachment_handle = gl.glCreateTextures(gl.GL_TEXTURE_2D, 1)
        gl.glBindTexture(gl.GL_TEXTURE_2D, color_attachment_handle)
        gl.glTexImage2D(gl.GL_TEXTURE_2D, 0, gl.GL_RGBA8, self.width, self.height, 0, gl.GL_RGBA,
                        gl.GL_UNSIGNED_BYTE, None)
        gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)
        gl.glTexParameteri(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)

        gl.glFramebufferTexture2D(gl.GL_FRAMEBUFFER, gl.GL_COLOR_ATTACHMENT0, gl.GL_TEXTURE_2D,
                                  color_attachment_handle, 0)

        self.depth_attachment_handle = depth_attachment_handle = gl.glCreateTextures(gl.GL_TEXTURE_2D, 1)
        gl.glBindTexture(gl.GL_TEXTURE_2D, depth_attachment_handle)
        gl.glTexStorage2D(gl.GL_TEXTURE_2D, 1, gl.GL_DEPTH24_STENCIL8, self.width, self.height)
        gl.glFramebufferTexture2D(gl.GL_FRAMEBUFFER, gl.GL_DEPTH_STENCIL_ATTACHMENT, gl.GL_TEXTURE_2D,
                                  depth_attachment_handle, 0)

        gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, 0)

    def finalize(self):
        gl.glDeleteFramebuffers(1, self.handle)
        gl.glDeleteTextures(1, self.color_attachment_handle)
        gl.glDeleteTextures(1, self.depth_attachment_handle)

    def bind(self):
        gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, self.handle)
        gl.glViewport(gl.GL_FRAMEBUFFER, 0)

    def unbind(self):
        gl.glBindFramebuffer(gl.GL_FRAMEBUFFER, 0)

    def resize(self, width, height):
        if width <= 0 or height <= 0 or width > 8192 or height > 8192:
            return
        self.width = width
        self.height = height
        self.initialize()
