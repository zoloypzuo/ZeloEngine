# coding=utf-8
# SG_room.py
# created on 2020/8/31
# author @zoloypzuo
from stategraph import *


class StateNone(State):
    def __init__(self):
        super(StateNone, self).__init__(
            name='none',
            tags=['tag0', ],
            on_enter=StateNone.on_enter,
            on_update=StateNone.on_update,
            on_exit=StateNone.on_exit,
            events=[
                EventHandler('animover', StateNone.event_handle_animover)
            ]
        )

    @staticmethod
    def on_enter(inst):
        pass

    @staticmethod
    def on_update(inst):
        pass

    @staticmethod
    def on_exit(inst):
        pass

    @staticmethod
    def event_handle_animover(inst):
        pass


states = [
    # 对于复杂的状态，这种写法是不可行的
    # State(
    #     name='none',
    #     tags=['tag0'],
    #     on_enter=onenter_do_nothing,
    #     on_update=onupdate_do_nothing,
    #     events=[
    #         EventHandler('animover', )
    #     ]
    # )
    StateNone()
]


def event_handle_attacked(inst):
    is_dead = inst.components.health.is_dead
    is_dissipate = inst.sg.has_state_tag('dissipate')
    if not (is_dead or is_dissipate):
        inst.sg.go_to_state('hit')


events = [
    EventHandler('attacked', event_handle_attacked),
]

# 文件包含这个全局变量，会被SG反射加载
# name, states, events, default-state
SG_room = StateGraph(name='room', states=states, events=events, default_state='none')
