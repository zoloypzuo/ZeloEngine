# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# renderer.py
# created on 2020/12/31
# usage: renderer
class RendererBase(object):
    def __init__(self, inst):
        super(RendererBase, self).__init__()
        self.inst = inst
        self.mesh = None

    # ---------------------------------------------------
    # debug
    # ---------------------------------------------------
    def __repr__(self):
        return self.__class__.__name__


renderer = RendererBase
