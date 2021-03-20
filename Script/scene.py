# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# scene.py
# created on 2020/12/28
# usage: scene

class Scene(object):
    def __init__(self):
        self.registry = None  # set of entity

    def create_entity(self, name):
        pass

    def destroy_entity(self, entity):
        pass

    def on_update_runtime(self):
        pass

    def on_update_editor(self):
        pass

    def on_viewport_resize(self, width, height):
        pass

    @property
    def main_camera(self):
        return

    def _on_component_added(self, entity, component):
        pass
