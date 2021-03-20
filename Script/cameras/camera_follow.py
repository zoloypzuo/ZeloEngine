# coding=utf-8
# camera_follow.py
# created on 2020/11/1
# author @zoloypzuo
# usage: camera_follow
import G
from entityscript import EntityScript


class CameraFollow(object):
    def __init__(self):
        self.auto_follow_player = True
        self.target_entity = None # type: EntityScript

    def find_player(self):
        return G.logicm.find_by_tag("player")
