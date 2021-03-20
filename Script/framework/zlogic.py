# coding=utf-8
# zlogic.py
# created on 2020/10/26
# author @zoloypzuo
# usage: zlogic
import G
from brain import BrainManager
from common.zlogger import logger
from components.transform import Transform
from entityscript import EntityScript
from interfaces.runtime import IRuntimeModule
from stategraph import SGManager


class Logic(object, IRuntimeModule):
    """
    Attributes:
        scene: entity map, hold all entities
        sg: fsm for game
        game views:  ???

    """

    def __init__(self):
        super(Logic, self).__init__()
        self.scene = {}
        self.root = Transform(None, None, True)

    def add_to_scene(self, ent):
        self.scene[id(ent)] = ent

    def find_by_tag(self, tag):
        # type: (str) -> EntityScript
        """

        :param tag:
        :return:
        """
        for ent in self.scene.values():
            # ent = None # type: EntityScript
            if ent.has_tag(tag):
                return ent
        return None

    # ---------------------------------------------------
    # IRuntimeModule
    # ---------------------------------------------------
    @logger
    def initialize(self):
        self.log(on_initialize=G.appm.on_initialize)
        G.appm.on_initialize and G.appm.on_initialize()

        for ent in self.scene.values():  # start sg
            ent.return_to_scene()

    @logger
    def finalize(self):

        for ent in self.scene.values():
            ent.remove_from_scene()
            ent.clear_stategraph()
            BrainManager.on_remove_entity(ent)
            SGManager.on_remove_entity(ent)

    def update(self):
        dt = G.deltatime()
        SGManager.update(dt)
        BrainManager.update(dt)

    @logger
    def log(self, *args, **kwargs):
        pass