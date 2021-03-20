# coding=utf-8
# SG_test.py
# created on 2020/9/14
# author @zoloypzuo
# usage: SG_test
from stategraph import *


class _None:
    def __init__(self):
        pass

    @staticmethod
    @logger
    def on_enter(inst, params):
        pass

    @staticmethod
    @logger
    def on_exit(inst, to_state_name):
        pass

    @staticmethod
    @logger
    def on_update(inst, dt):
        pass

    @staticmethod
    @logger
    def handle_c(inst, data):
        print 'handle event-c in state none'


class _Run:
    def __init__(self):
        pass

    @staticmethod
    @logger
    def handle_c(inst, data):
        print 'handle event-c in state run'


class _SGTest:
    def __init__(self):
        pass

    @staticmethod
    @logger
    def test(inst, data):
        inst.sg.go_to_state('run')

    @staticmethod
    @logger
    def handle_c(inst, data):
        print 'handle event c in sg scope'


states = [
    State(
        name='none',
        on_enter=_None.on_enter,
        on_update=_None.on_update,
        on_exit=_None.on_exit,
        events=[
            EventHandler('event-c', _None.handle_c)
        ]
    ),
    State(
        name='run',
        events=[
            EventHandler('event-c', _Run.handle_c)
        ]
    )
]

events = [
    EventHandler('event-c', _SGTest.handle_c),
    EventHandler('go_to_run', _SGTest.test)
]

SG_test = StateGraph(name='room', states=states, events=events, default_state='none')
