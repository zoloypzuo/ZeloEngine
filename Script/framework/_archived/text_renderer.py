# coding=utf-8
# text_renderer.py
# created on 2020/10/22
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# usage: text_renderer

import numpy
from freetype import *
import OpenGL.GL as gl
import OpenGL.GLUT as glut

import G

base, texid = 0, 0


class TextRenderer(object):
    def __init__(self):
        super(TextRenderer, self).__init__()
        self.text = '''Hello World !'''
        self.font = r'D:\MiniProj_01\data\DejaVuSansMono.ttf'
        self.font_size = 10
        self.color = (0., 0., 0.)

    @property
    def width(self):
        return G.appm.width

    @property
    def height(self):
        return G.appm.height

    def render(self):
        global texid
        makefont(self.font, self.font_size)

        def text():
            gl.glColor3f(*self.color)
            gl.glBindTexture(gl.GL_TEXTURE_2D, texid)
            gl.glColor(0, 0, 0, 1)
            gl.glPushMatrix()
            gl.glTranslate(10, 100, 0)
            gl.glPushMatrix()
            gl.glListBase(base + 1)
            gl.glCallLists([ord(c) for c in self.text])
            gl.glPopMatrix()
            gl.glPopMatrix()

        gl.glDisable(gl.GL_DEPTH_TEST)

        gl.glMatrixMode(gl.GL_PROJECTION)
        gl.glPushMatrix()
        gl.glLoadIdentity()
        gl.glOrtho(0., self.width, 0., self.height, -1., 1.)

        gl.glMatrixMode(gl.GL_MODELVIEW)
        gl.glPushMatrix()
        gl.glLoadIdentity()

        text()

        gl.glPopMatrix()
        gl.glMatrixMode(gl.GL_PROJECTION)
        gl.glPopMatrix()
        gl.glMatrixMode(gl.GL_MODELVIEW)
        # gl.glEnable(gl.GL_DEPTH_TEST)


def makefont(filename, size):
    global texid

    # Load font  and check it is monotype
    face = Face(filename)
    face.set_char_size(size * 64)
    if not face.is_fixed_width:
        raise 'Font is not monotype'

    # Determine largest glyph size
    width, height, ascender, descender = 0, 0, 0, 0
    for c in range(32, 128):
        face.load_char(chr(c), FT_LOAD_RENDER | FT_LOAD_FORCE_AUTOHINT)
        bitmap = face.glyph.bitmap
        width = max(width, bitmap.width)
        ascender = max(ascender, face.glyph.bitmap_top)
        descender = max(descender, bitmap.rows - face.glyph.bitmap_top)
    height = ascender + descender
    # Generate texture data
    Z = numpy.zeros((height * 6, width * 16), dtype=numpy.ubyte)
    for j in range(6):
        for i in range(16):
            face.load_char(chr(32 + j * 16 + i), FT_LOAD_RENDER | FT_LOAD_FORCE_AUTOHINT)
            bitmap = face.glyph.bitmap
            x = i * width + face.glyph.bitmap_left
            y = j * height + ascender - face.glyph.bitmap_top
            Z[y:y + bitmap.rows, x:x + bitmap.width].flat = bitmap.buffer


    # Bound texture
    texid = gl.glGenTextures(1)
    # gl.glBindTexture(gl.GL_TEXTURE_2D, texid)
    # gl.glTexParameterf(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MAG_FILTER, gl.GL_LINEAR)
    # gl.glTexParameterf(gl.GL_TEXTURE_2D, gl.GL_TEXTURE_MIN_FILTER, gl.GL_LINEAR)
    # gl.glTexImage2D(gl.GL_TEXTURE_2D, 0, gl.GL_ALPHA, Z.shape[1], Z.shape[0], 0,
    #                 gl.GL_ALPHA, gl.GL_UNSIGNED_BYTE, Z)

    # Generate display lists
    dx, dy = width / float(Z.shape[1]), height / float(Z.shape[0])
    base = gl.glGenLists(8 * 16)

    def foo(c_):
        if (c_ == '\n'):
            gl.glPopMatrix()
            gl.glTranslatef(0, -height, 0)
            gl.glPushMatrix()
        elif (c_ == '\t'):
            gl.glTranslatef(4 * width, 0, 0)
        elif (i >= 32):
            gl.glBegin(gl.GL_QUADS)
            gl.glTexCoord2f((x) * dx, (y + 1) * dy), gl.glVertex(0, -height)
            gl.glTexCoord2f((x) * dx, (y) * dy), gl.glVertex(0, 0)
            gl.glTexCoord2f((x + 1) * dx, (y) * dy), gl.glVertex(width, 0)
            gl.glTexCoord2f((x + 1) * dx, (y + 1) * dy), gl.glVertex(width, -height)
            gl.glEnd()
            gl.glTranslatef(width, 0, 0)

    for i in range(8 * 16):
        c = chr(i)
        x = i % 16
        y = i // 16 - 2
        gl.glNewList(base + i, gl.GL_COMPILE)
        foo(c)
        gl.glEndList()
