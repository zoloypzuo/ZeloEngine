# coding=utf-8
# mesh_filter.py
# created on 2020/10/21
# author @zoloypzuo
# usage: mesh_filter


class MeshFilter(object):
    def __init__(self, inst):
        super(MeshFilter, self).__init__()
        self.inst = inst
        self.mesh = None


mesh_filter = MeshFilter
