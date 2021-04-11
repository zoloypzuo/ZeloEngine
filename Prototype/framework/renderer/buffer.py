# coding=utf-8
# buffer.py
# created on 2020/12/26
# author @zoloypzuo
# usage: VBO and EBO
from OpenGL import GL as gl


class VertexBuffer(object):
    def __init__(self, vertices):
        """

        :type vertices: np.array
        :param vertices:
        """
        self.handle = 0
        self.initialize(vertices)

    def initialize(self, vertices):
        self.handle = gl.glGenBuffers(1)
        self.bind()
        gl.glBufferData(gl.GL_ARRAY_BUFFER, vertices.nbytes, vertices, gl.GL_STATIC_DRAW)
        self._len = len(vertices)

    def finalize(self):
        gl.glDeleteBuffers(1, self.handle)

    def bind(self):
        gl.glBindBuffer(gl.GL_ARRAY_BUFFER, self.handle)

    def unbind(self):
        gl.glBindBuffer(gl.GL_ARRAY_BUFFER, 0)

    def set_sub_data(self, data):
        """

        :type data: np.array
        :param data:
        :return:
        """
        self.bind()
        gl.glBufferSubData(gl.GL_ARRAY_BUFFER, 0, data.nbytes, data)

    def set_layout(self, layout):
        pass
    def __len__(self):
        return self._len


class IndexBuffer(object):
    def __init__(self, indices):
        self.handle = 0
        self.initialize(indices)

    def initialize(self, indices):
        self.handle = gl.glCreateBuffers(1)
        self.bind()
        gl.glBufferData(gl.GL_ELEMENT_ARRAY_BUFFER, indices.nbytes, indices, gl.GL_STATIC_DRAW)
        self._len = len(indices)

    def finalize(self):
        gl.glDeleteBuffers(self.handle)

    def bind(self):
        gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, self.handle)

    def unbind(self):
        gl.glBindBuffer(gl.GL_ELEMENT_ARRAY_BUFFER, 0)

    def __len__(self):
        return self._len