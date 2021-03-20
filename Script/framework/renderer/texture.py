# coding=utf-8
# texture.py
# created on 2020/12/20
# author @zoloypzuo
# usage: texture
from OpenGL import GL as gl
from PIL import Image

TEXTURE_MAP = {}


class Texture(object):
    def __init__(self, filename):
        self.handle = 0
        self.filename = filename
        self.size = (0, 0)
        self.internal_format = 0
        self.data_format = 0
        TEXTURE_MAP[self.name] = self
        self.initialize()

    @property
    def width(self):
        return self.size[0]

    @property
    def height(self):
        return self.size[1]

    @property
    def name(self):
        import os
        return os.path.splitext(os.path.basename(self.filename))[0]

    def initialize(self):
        # load image as raw data
        image = Image.open(self.filename)
        self.size = image.size
        if image.mode == "RGB":  # if image has alpha channel
            self.internal_format = gl.GL_RGB8
            self.data_format = gl.GL_RGB
            image_raw = image.tobytes("raw", "RGBX", 0, -1)
        else:
            self.internal_format = gl.GL_RGBA8
            self.data_format = gl.GL_RGBA
            image_raw = image.tobytes("raw", "RGBA", 0, -1)

        # create texture object, set texture parameters
        self.handle = gl.glGenTextures(1)
        # NOTE cannot set active here, or error 1282
        # self.bind()
        gl.glBindTexture(gl.GL_TEXTURE_2D, self.handle)
        gl.glPixelStorei(gl.GL_UNPACK_ALIGNMENT, 1)
        gl.glTexImage2D(gl.GL_TEXTURE_2D, 0, gl.GL_RGBA8, self.size[0], self.size[1], 0, gl.GL_RGBA,
                        gl.GL_UNSIGNED_BYTE, image_raw)
        gl.glTexParameterf(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_S, gl.GL_CLAMP)
        gl.glTexParameterf(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_T, gl.GL_CLAMP)
        gl.glTexParameterf(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_S, gl.GL_REPEAT)
        gl.glTexParameterf(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_WRAP_T, gl.GL_REPEAT)
        gl.glTexParameterf(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_NEAREST)
        gl.glTexParameterf(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_NEAREST)
        # [DEBUG]Error closing: 'NoneType' object has no attribute 'close'
        image.close()

    def finalize(self):
        gl.glDeleteTextures(1, self.handle)

    def bind(self, slot=0):
        # same as:
        # gl.glActiveTexture(gl.GL_TEXTURE0)
        # gl.glBindTexture(gl.GL_TEXTURE_2D, self.tex_handle)
        gl.glBindTextureUnit(slot, self.handle)

    def unbind(self):
        gl.glBindTexture(gl.GL_TEXTURE_2D, 0)
