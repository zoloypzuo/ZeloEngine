# coding=utf-8
# main_functions.py
# created on 2020/11/1
# author @zoloypzuo
# usage: main_functions
from entityscript import EntityScript

num_ents = 0
ents = {}


def inc_num_ents():
    global num_ents
    num_ents += 1


def dec_num_ents():
    global num_ents
    num_ents -= 1


def register_ent(ent):
    ents[id(ent)] = ent


def create_entity():
    # dst: create cpp entity, and attach script entity to it
    ent = EntityScript()
    inc_num_ents()
    register_ent(ent)
    return ent


def spawn_prefab(name):
    # (str) -> EntityScript
    """

    :param name:
    :return:
    """
    # dst: done by cpp\
    import importlib
    module = importlib.import_module("prefabs." + name)
    prefab = getattr(module, name)
    inst = prefab.fn()
    return inst


def remove_entity(ent):
    dec_num_ents()
    global ents
    ents.pop(id(ent))


def on_remove_entity(entity_guid):
    ent = ents.get(entity_guid, None)
    if not ent:
        return
    ent.clear_stategraph()
    from brain import BrainManager
    BrainManager.on_remove_entity(ent)
    from stategraph import SGManager
    SGManager.on_remove_entity(ent)
