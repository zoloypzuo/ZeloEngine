# coding=utf-8
# behaviourtree.py
# created on 2020/9/28
# author @zoloypzuo
# usage: behaviourtree
from common.zlogger import logger
from game_timer import now

SUCCESS = "SUCCESS"
FAILED = "FAILED"
READY = "READY"
RUNNING = "RUNNING"


class BT(object):
    """
    Attributes:
    """

    def __init__(self, inst, root):
        self.inst = inst
        self.root = root

    # @logger
    def update(self):
        self.root.visit()
        self.root.save_status()
        self.root.step()

    def reset(self):
        self.root.reset()

    def stop(self):
        self.root.stop()

    def __str__(self):
        # TODO dump tree
        pass


class NodeBase(object):
    """
    递归行为
    """
    import abc

    __metaclass__ = abc.ABCMeta

    @abc.abstractmethod
    def visit(self): pass

    @abc.abstractmethod
    def save_status(self): pass

    @abc.abstractmethod
    def step(self): pass

    @abc.abstractmethod
    def reset(self): pass

    @abc.abstractmethod
    def stop(self): pass


class BehaviourNode(NodeBase):
    """
    Attributes:
        status: /
        last_result: 保存的上次的状态，@save_status

    Event Callbacks:
        on_stop: on_stop()，stop的回调函数
    """

    def __init__(self, name="", children=None):
        self.name = name
        self.children = children or []
        self.status = READY
        self.last_result = READY
        self.parent = None
        if children:
            for child in children:
                child.parent = self

    def visit(self):
        """

        :return:
        """
        self.status = FAILED

    def save_status(self):
        """
        递归地保存状态
        :return:
        """
        self.last_result = self.status
        if self.children:
            for child in self.children:
                child.save_status()

    def step(self):
        """

        :return:
        """
        if self.status != RUNNING:
            self.reset()
        elif self.children:
            for child in self.children:
                child.step()

    def reset(self):
        """
        递归地设置状态为READY
        :return:
        """
        if self.status == READY:
            return
        self.status = READY
        if self.children:
            for child in self.children:
                child.reset()

    def stop(self):
        on_stop = getattr(self, 'on_stop', None)
        on_stop and on_stop()
        if self.children:
            for child in self.children:
                child.stop()

    def do_to_parents(self, fn):
        """
        对父节点链条上的节点应用fn
        :param fn:
        :return:
        """
        if self.parent:
            fn(self.parent)
            self.parent.do_to_parents(fn)

    def __str__(self):
        # TODO dump tree
        pass


class DecoratorNode(BehaviourNode):
    def __init__(self, name, child):
        super(DecoratorNode, self).__init__(name, [child])


class ConditionNode(BehaviourNode):
    def __init__(self, fn, name="Condition"):
        super(ConditionNode, self).__init__(name)
        self.fn = fn

    def visit(self):
        self.status = SUCCESS if self.fn() else FAILED


class ConditionWaitNode(BehaviourNode):
    def __init__(self, fn, name="Wait"):
        super(ConditionWaitNode, self).__init__(name)
        self.fn = fn

    def visit(self):
        self.status = SUCCESS if self.fn() else FAILED


class ActionNode(BehaviourNode):
    def __init__(self, action, name="ActionNode"):
        super(ActionNode, self).__init__(name)
        self.action = action

    def visit(self):
        self.action()
        self.status = SUCCESS


class WaitNode(BehaviourNode):
    """
    第一次访问触发等待开始，到等待时间结束成功
    Attributes:
        wait_time: /
        wake_time: /
    """

    def __init__(self, time):
        super(WaitNode, self).__init__("Wait")
        self.wait_time = time
        self.wake_time = 0

    def visit(self):
        current_time = now()
        if self.status != RUNNING:
            self.wake_time = current_time + self.wait_time
            self.status = RUNNING
        else:
            if current_time >= self.wake_time:
                self.status = SUCCESS
            # else:
            #     ？？？ sleep 《0
            # self.sleep(current_time - self.wake_time)

    def __str__(self):
        return '{:2.2f}'.format(self.wake_time - now())


class SequenceNode(BehaviourNode):
    def __init__(self, children):
        super(SequenceNode, self).__init__("Sequence", children)
        self.index = 0

    def reset(self):
        super(SequenceNode, self).reset()
        self.index = 0

    def visit(self):
        if self.status != RUNNING:
            self.index = 0

        idx = self.index
        len_children = len(self.children)
        while idx < len_children:
            child = self.children[idx]
            child.visit()
            if child.status == RUNNING or child.status == FAILED:
                self.status = child.status
                return
            idx += 1
        self.index = idx
        self.status = SUCCESS


class SelectorNode(BehaviourNode):
    def __init__(self, children):
        super(SelectorNode, self).__init__("Selector", children)
        self.index = 0

    def reset(self):
        super(SelectorNode, self).reset()
        self.index = 0

    def visit(self):
        if self.status != RUNNING:
            self.index = 0
        idx = self.index
        len_children = len(self.children)
        while idx < len_children:
            child = self.children[idx]
            child.visit()
            if child.status == RUNNING or child.status == SUCCESS:
                self.status = child.status
                return
            idx += 1
        self.index = idx
        self.status = FAILED


class NotDecorator(DecoratorNode):
    def __init__(self, child):
        super(NotDecorator, self).__init__("Not", child)

    def visit(self):
        child = self.children[0]
        child.visit()
        if child.status == SUCCESS:
            self.status = FAILED
        elif child.status == FAILED:
            self.status = SUCCESS
        else:
            self.status = child.status


class FailIfRunningDecorator(DecoratorNode):
    def __init__(self, child):
        super(FailIfRunningDecorator, self).__init__("FailIfRunning", child)

    def visit(self):
        child = self.children[0]
        child.visit()
        if child.status == RUNNING:
            self.status = FAILED
        else:
            self.status = child.status


class LoopNode(BehaviourNode):
    def __init__(self, children, maxreps):
        super(LoopNode, self).__init__("Sequence", children)
        self.index = 0
        self.maxreps = maxreps
        self.rep = 0

    def reset(self):
        super(LoopNode, self).reset()
        self.index = 0
        self.rep = 0

    def visit(self):
        if self.status != RUNNING:
            self.index = 0
            self.rep = 0
        idx = self.index
        len_children = len(self.children)
        while idx < len_children:
            child = self.children[idx]
            child.visit()
            if child.status == RUNNING or child.status == FAILED:
                self.status = child.status
                return
            idx += 1
        self.index = 0
        self.rep += 1
        if self.rep >= self.maxreps:
            self.status = SUCCESS
        else:
            for child in self.children:
                child.reset()


class RandomNode(BehaviourNode):
    def __init__(self, children):
        super(RandomNode, self).__init__("Random", children)
        self.index = None

    def reset(self):
        super(RandomNode, self).reset()
        self.index = None

    def visit(self):
        import random
        if self.status == READY:
            self.index = random.randint(0, len(self.children))
            start = self.index
            while True:
                child = self.children[self.index]
                if child.status != FAILED:
                    self.status = child.status

                self.index += 1
                if self.index == len(self.children):
                    self.index = 0
                if self.index == start:
                    self.status = FAILED
                    return
        else:
            child = self.children[self.index]
            child.visit()
            self.status = child.status


class PriorityNode(BehaviourNode):
    def __init__(self, children, period=1.):
        super(PriorityNode, self).__init__("Priority", children)
        self.period = period
        self.index = None
        self.last_time = None

    @logger
    def reset(self):
        super(PriorityNode, self).reset()
        self.index = None

    @property
    def time_till(self):
        """
        离下一次计算的时间
        >0时说明还差n秒进行下一次计算
        <0时visit会执行一次计算
        :return:
        """
        return self.last_time or 0. + self.period - now()

    @logger
    def visit(self):
        """

        :return:
        """
        # 如果没计算过，或者周期到了
        do_eval = not self.last_time or not self.period or self.time_till < 0.
        if do_eval:
            # ---------------------------------------------------
            # 遍历子节点
            # 找到第一个成功的节点
            # ---------------------------------------------------
            old_event = None
            if self.index is not None:
                child = self.children[self.index]
                old_event = child if isinstance(child, EventNode) else None
            self.last_time = now()
            found = False
            for index, child in enumerate(self.children):
                should_test_anyway = old_event and isinstance(child, EventNode) and old_event.priority <= child.priority
                if not found or should_test_anyway:
                    if child.status == FAILED or child.status == SUCCESS:
                        child.reset()
                    child.visit()
                    cs = child.status
                    if cs == SUCCESS or cs == RUNNING:
                        if should_test_anyway and self.index != index:
                            self.children[self.index].reset()
                        self.status = cs
                        found = True
                        self.index = index
                else:
                    child.reset()
            if not found:
                self.status = FAILED
        else:
            # ---------------------------------------------------
            # 运行当前节点
            # ---------------------------------------------------
            if self.index is not None:
                child = self.children[self.index]
                if child.status == RUNNING:
                    child.visit()
                    self.status = child.status
                    if self.status != RUNNING:
                        self.last_time = None


class ParallelNode(BehaviourNode):
    def __init__(self, children, name="Parallel"):
        super(ParallelNode, self).__init__(name, children)
        self.stoponanycomplete = False

    def step(self):
        if self.status != RUNNING:
            self.reset()
        elif self.children:
            for child in self.children:
                if child.status == SUCCESS and isinstance(child, ConditionNode):
                    child.reset()

    def visit(self):
        """

        :return:
        """
        done = True
        any_done = False
        for child in self.children:
            if isinstance(child, ConditionNode):
                child.reset()
            if child.status != SUCCESS:
                child.visit()
                if child.status == FAILED:
                    self.status = FAILED
                    return
            if child.status == RUNNING:
                done = False
            else:
                any_done = True

        self.status = SUCCESS if done or (self.stoponanycomplete and any_done) else RUNNING


class ParallelNodeAny(ParallelNode):
    def __init__(self, children):
        super(ParallelNodeAny, self).__init__(children, "Parallel(Any)")
        self.stoponanycomplete = True


class EventNode(BehaviourNode):
    def __init__(self, inst, event, child, priority=0):
        super(EventNode, self).__init__("Event(\"%s\")" % event, [child])
        self.inst = inst
        self.event = event
        self.priority = priority
        self.eventfn = lambda data: self.on_event(data)
        self.inst.listen_for_event(self.event, self.eventfn)
        self.triggered = False
        self.data = None

    @logger
    def on_event(self, data):
        def parent_handler(node):
            if isinstance(node, PriorityNode):
                node.last_time = None

        if self.status == RUNNING:
            self.children[0].reset()
        self.triggered = True
        self.data = data
        if self.inst.brain:
            self.inst.brain.force_update()

        self.do_to_parents(parent_handler)

    # ---------------------------------------------------
    # override base functions
    # ---------------------------------------------------
    @logger
    def step(self):
        super(EventNode, self).step()
        self.triggered = False

    @logger
    def reset(self):
        self.triggered = False
        super(EventNode, self).reset()

    @logger
    def visit(self):
        if self.status == READY and self.triggered:
            self.status = RUNNING
        if self.status == RUNNING:
            if self.children and len(self.children) == 1:
                child = self.children[0]
                child.visit()
                self.status = child.status
            else:
                self.status = FAILED

    # ---------------------------------------------------
    # event callbacks
    # ---------------------------------------------------
    @logger
    def on_stop(self):
        if self.eventfn:
            self.inst.remove_event_callback(self.event, self.eventfn)
            self.eventfn = None


def WhileNode(cond, name, node):
    return ParallelNode([
        ConditionNode(cond, name),
        node
    ])


def IfNode(cond, name, node):
    return SequenceNode([
        ConditionNode(cond, name),
        node
    ])
