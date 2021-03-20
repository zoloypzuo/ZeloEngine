# coding=utf-8
# test_brain.py
# created on 2020/10/2
# author @zoloypzuo
# usage: test_brain
from behaviourtree import PriorityNode, BT
from brain import Brain
from common.zlogger import logger


class TestBrain(Brain):
    def __init__(self):
        super(TestBrain, self).__init__()

    @logger
    def on_start(self):
        root = PriorityNode([
            # TODO 节点，EventNode
        ])
        self.bt = BT(self.inst, root)
