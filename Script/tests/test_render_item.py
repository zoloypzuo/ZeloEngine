# coding=utf-8
# test_render_item.py
# created on 2020/10/21
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# usage: test_render_item

import unittest
from framework._archived import zapp_glut
from framework.renderer.render_item import *
from framework._archived.text_renderer import TextRenderer


class TestRenderItem(unittest.TestCase):

    def test_renderer(self, cls):
        self.app = zapp_glut.App()
        self.app.add_renderable(cls())
        self.app.main()

    def test_polygon(self):
        # failed
        self.test_renderer(Polygon2DRenderer)

    def test_polygon3d(self):
        self.test_renderer(Polygon3DRenderer)

    def test_line(self):
        # failed
        self.test_renderer(LineRenderer)

    def test_sphere(self):
        self.test_renderer(SphereRenderer)

    def test_text(self):
        import datetime
        self.app = zapp_glut.App()
        self.app.projection_mode = 1
        self.app.enable_depth_test = False
        text = '''
Hello World !
line 1 
line 2
line 3
%s''' % datetime.datetime.now()
        r = TextRenderer()
        r.text = text
        self.app.add_renderable(r)
        self.app.main()
