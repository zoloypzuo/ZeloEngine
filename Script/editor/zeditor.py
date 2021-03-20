# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# zeditor.py
# created on 2020/12/28
# usage: zeditor
from editor.panels.scene_hierarchy_panel import SceneHierarchyPanel
from interfaces.runtime import IRuntimeModule

from main_functions import create_entity, ents, remove_entity


class SceneGraph:
    def __init__(self, entities_conf=None):
        for ent in entities_conf:
            self.create_entity(ent["name"])

    @property
    def entities(self):
        return ents

    def create_entity(self, name):
        ent = create_entity()
        ent.tag = name
        ent.add_component("transform")
        ent.add_component("physics", name)
        ent.add_component("cube_renderer")

    def destroy_entity(self, entity):
        remove_entity(entity)

    def __iter__(self):
        return self.entities.itervalues()


class Editor(object, IRuntimeModule):
    def __init__(self):
        super(Editor, self).__init__()
        self.scene_hierarchy_panel = None
        self.active_scene = SceneGraph([
            # {"name": "cube"},
            # {"name": "plane"},
        ])

    def initialize(self):
        self.scene_hierarchy_panel = SceneHierarchyPanel(self.active_scene)

    def finalize(self):
        pass

    def on_gui(self):
        self.scene_hierarchy_panel.on_gui()
