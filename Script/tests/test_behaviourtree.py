# coding=utf-8
# test_behaviourtree.py
# created on 2020/10/2
# author @zoloypzuo
# usage: test_behaviourtree

import unittest

from behaviourtree import *
from brain import Brain
from common.zlogger import logger
from entityscript import EntityScript
from framework.zmain import add_to_scene, main


class TestBehaviourTree(unittest.TestCase):
    def setUp(self):
        self.ent = EntityScript()
        add_to_scene(self.ent)

    def tearDown(self):
        main()

    def test_priority_node(self):
        """
        :return:
        """

        class TestPriorityNodeBrain(Brain):
            @logger
            def on_start(self):
                @logger
                def cond_true():
                    return True

                @logger
                def cond_false():
                    return False

                root = PriorityNode([
                    ConditionNode(cond_false),
                    ConditionNode(cond_false),
                    ConditionNode(cond_true)
                ])
                self.bt = BT(self.inst, root)

        self.ent.set_brain(TestPriorityNodeBrain)

    def test_event_node(self):
        class TestEventNodeBrain(Brain):
            @logger
            def on_start(self):
                root = EventNode(self.inst, 'test_event', BehaviourNode(), 1)
                self.bt = BT(self.inst, root)

        # 构造EventNode时在ent上注册事件
        self.ent.set_brain(TestEventNodeBrain)
        print self.ent.event_listening
        print self.ent.event_listeners
        # 在ent上触发事件
        self.ent.push_event('test_event')
