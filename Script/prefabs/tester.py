# coding=utf-8
# test_prefab.py
# created on 2020/10/2
# author @zoloypzuo
# usage: test_prefab
import G
from common.zlogger import logger
from main_functions import create_entity
from prefab import Prefab
from framework.math.vector3 import Vector3

color = Vector3()


def color_updater():
    color.x += 1. / 255 if color.x < 1. else -1
    color.y += 2. / 255 if color.y < 1. else -1
    color.z += 3. / 255 if color.z < 1. else -1
    return color


position = Vector3()


def position_updater():
    # position.x += 1 if position.x < 20 else -20
    position.y += 1 if position.y < 20 else -20
    # position.z += 1 if position.z < 20 else -20
    return position.tuple()


def bind_transform_to_render_item(transform, render_item):
    render_item.position = transform.position_updater


@logger
def fn():
    # ---------------------------------------------------
    # init steps:
    # 1. create entity
    # 2. tag
    # 3. create components
    # 4. listen for event
    # ---------------------------------------------------
    inst = create_entity()
    inst.add_tag("test")
    inst.add_tag("player")
    inst.add_component("transform")
    inst.listen_for_event("test_event", G.logfn)

    transform = inst.components.transform

    # ---------------------------------------------------
    # renderer
    # ---------------------------------------------------
    from framework.renderer.render_item import SolidPrimitiveRenderer
    renderer_cls = SolidPrimitiveRenderer("teapot", 1)
    render_item = renderer_cls(
        # position_updater=inst.components.transform.position_updater,
        position_updater=position_updater,
        color_updater=color_updater
    )
    bind_transform_to_render_item(inst.components.transform, render_item)

    # render_item = TexturedCubeRenderer("container")
    inst.render_item = render_item

    # ---------------------------------------------------
    # BT
    # ---------------------------------------------------
    # inst.set_brain(TestBrain)
    return inst


assets = []
prefabs = []

tester = Prefab("test/tester", fn, assets, prefabs)
