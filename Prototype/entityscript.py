# coding=utf-8
# entityscript.py
# created on 2020/8/31
# author @zoloypzuo
# usage: entityscript
import stategraph
from common.zglobal import load_script
from common.zlogger import logger_tail, logger
from common.ztable import Table


def add_listener(t, event, inst, fn):
    """
    事件表t的结构：
    t[event] -> listeners
    listeners[inst] -> fns
    :param t:
    :param event:
    :param inst:
    :param fn:
    :return:
    """
    assert t is not None
    listeners = t.get(event, None)
    if not listeners:
        listeners = {}
        t[event] = listeners
    listener_fns = listeners.get(inst, None)
    if not listener_fns:
        listener_fns = []
        listeners[inst] = listener_fns
    listener_fns.append(fn)


def remove_listener(t, event, inst, fn):
    if not t:
        return
    listeners = t.get(event, None)
    if not listeners:
        return
    listener_fns = listeners.get(inst, None)
    if listener_fns:
        listener_fns.remove(fn)
        # 删除fn后检查其容器，如果空，删除它
        if not listener_fns:
            del listeners[inst]
        if not listeners:
            del t[event]


class EntityScript(object):
    """
    Attributes:
        brain:
        brainfn:
        sg:
        event_listeners:
        event_listening:
    """

    def __init__(self):
        super(EntityScript, self).__init__()
        self.tags = set()
        self.brain = None
        self.brainfn = None
        self.sg = None
        self.event_listeners = {}  # 也可以由listen_for_event初始化
        self.event_listening = {}

        self.components = Table()

    # ---------------------------------------------------
    # 事件系统
    # ---------------------------------------------------
    @logger
    def push_event(self, event, data=None):
        """
        触发self上的事件
        :param event:
        :param data:
        :return:
        """
        # entity
        if self.event_listeners:
            listeners = self.event_listeners.get(event, None)
            if listeners:
                # 拷贝一份回调列表，以防一些handler中listener列表被修改
                to_call = []
                for ent, fns in listeners.iteritems():
                    for fn in fns:
                        to_call.append(fn)
                for fn in to_call:
                    fn(data)  # NOTE python use bound-method, DONT pass self into fn

        # sg
        if self.sg and self.sg.is_listening_for_event(event) and stategraph.SGManager.on_push_event(self.sg):
            self.sg.push_event(event, data)

        # brain
        if self.brain:
            self.brain.push_event(event, data)

    def listen_for_event(self, event, fn, source=None):
        """
        监听者self，监听事件源的事件
        :param source:
        :param event:_
        :param fn:
        :return:
        """
        # 事件源，被监听者，默认为None，本来是参数，为了简化去掉了
        source = source or self
        if not source.event_listeners:
            source.event_listeners = {}
        # 被监听者的监听者表
        add_listener(source.event_listeners, event, self, fn)
        # 监听者的正在监听表
        add_listener(self.event_listening, event, source, fn)

    def remove_event_callback(self, event, fn, source=None):
        """
        listen_for_event的逆操作
        :param event:
        :param fn:
        :param source:
        :return:
        """
        source = source or self
        remove_listener(source.event_listeners, event, self, fn)
        remove_listener(self.event_listening, event, source, fn)

    def remove_all_event_callbacks(self):
        """
        /
        :return:
        """
        # 不再监听事件
        if self.event_listening:
            for event, sources in self.event_listening.iteritems():
                for source, fns in sources.iteritems():
                    if source.event_listeners:
                        listeners = source.event_listeners.get(event, None)
                        if listeners:
                            del listeners[self]
            self.event_listening = {}
        if self.event_listeners:
            for event, listeners in self.event_listeners.iteritems():
                for listener, fns in listeners.iteritems:
                    if listener.event_listening:
                        sources = listener.event_listening.get(event, None)
                        if sources:
                            del sources[self]
            self.event_listeners = {}

    @logger_tail
    def dump_event_map(self):
        return self.event_listening, self.event_listeners

    # ---------------------------------------------------
    # stategraph
    # ---------------------------------------------------
    def set_stategraph(self, name):
        stategraph.set_stategraph(self, name)

    def clear_stategraph(self):
        stategraph.clear_stategraph(self)

    # ---------------------------------------------------
    # brain
    # ---------------------------------------------------
    @logger
    def restart_brain(self):
        self.stop_brain()
        if not self.brainfn:
            return
        self.brain = self.brainfn()
        if not self.brain:
            return
        self.brain.inst = self
        self.brain.start()

    @logger
    def stop_brain(self):
        self.brain and self.brain.stop()
        self.brain = None

    @logger
    def set_brain(self, brainfn):
        self.brainfn = brainfn
        self.restart_brain()

    # ---------------------------------------------------
    # 生命周期
    # ---------------------------------------------------
    def is_valid(self):
        """
        C++层是否存活
        :return:
        """
        # return self.entity:IsValid() and not self.retired
        return True

    @logger
    def return_to_scene(self):
        self.restart_brain()
        self.sg and self.sg.start()

    @logger
    def remove_from_scene(self):
        self.stop_brain()
        self.sg and self.sg.stop()

    # ---------------------------------------------------
    # component
    # ---------------------------------------------------
    def add_component(self, name, *args, **kwargs):
        if name in self.components:
            raise "component %s already exists!" % name
        cmptfn = load_script('components.', name)
        assert cmptfn, "component %s does not exists!" % name
        cmpt = cmptfn(self, *args, **kwargs)
        self.components[name] = cmpt

    def remove_component(self, name):
        cmpt = self.components[name]
        if not cmpt:
            return
        del self.components[name]
        on_remove_from_entity = getattr(cmpt, "on_remove_from_entity", None)
        on_remove_from_entity and on_remove_from_entity()

    def has_component(self, name):
        return name in self.components

    def get_component(self, name):
        return self.components[name]

    def get_component_try(self, name):
        return self.components[name] if self.has_component(name) else None

    def get_component_of_type(self, name):
        cls = load_script('components.', name)
        for _, cmpt in self.components:
            if isinstance(cmpt, cls):
                return cmpt
        return None

    # ---------------------------------------------------
    # tag
    # ---------------------------------------------------
    def add_tag(self, tag):
        self.tags.add(tag)

    def remove_tag(self, tag):
        self.tags.discard(tag)

    def has_tag(self, tag):
        return tag in self.tags

    # ---------------------------------------------------
    # meta-methods
    # ---------------------------------------------------
    def __str__(self):
        return "EntityScript" + repr((id(self),))

    __repr__ = __str__


if __name__ == '__main__':
    pass
