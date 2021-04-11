# coding=utf-8
# stategraph.py
# created on 2020/8/18
# author @zoloypzuo
# usage: 状态机
"""
构造状态机：Prefab构造中调用EntityScript.set_stategraph来实例化StateGraphInstance

"""
from common.zlogger import logger_tail, logger
from common.ztable import Table
from common.zutils import is_iterable_T
from game_timer import now


class StateGraphComponent(object):
    """
    SG移植到Messiah，以组件的形式
    Entity继承StateGraphComponent以获得SG
    """

    def __init__(self):
        super(StateGraphComponent, self).__init__()
        self.sg = None

    @logger
    def set_stategraph(self, name, sg_base='stategraphs.'):
        """

        :param sg_base:
        :param self: EntityScript
        :param name: 状态机名字，位于stategraphs/下的文件名
        :return:
        """
        if self.sg:
            SGManager.remove_instance(self.sg)
        sg = load_stategraph(sg_base + name, name)
        assert sg, "load stategraph failed"
        self.sg = StateGraphInstance(sg, self)
        SGManager.add_instance(self.sg)
        self.sg.go_to_state(sg.default_state)
        self.sg.start()  # TODO
        return self.sg

    @logger
    def clear_stategraph(self):
        if self.sg:
            self.sg.stop()  # TODO
            SGManager.remove_instance(self.sg)
            self.sg = None


class StateGraphInstance(object):
    """
    运行时状态机实例
    sg和inst由ctor参数初始化，其他是运行时需要并创建的数据结构
    Attributes:
        sg: StateGraph
        inst: EntityScript
        is_stopped: stop调用后为True
        on_start: 事件, 0 ref
        on_stop: 事件, 0 ref

        current_state: /
        last_state: /

        state_start_time: 当前状态的开始时间，从切状态开始

        buffered_events: 事件队列
        tags: 当前状态的tags，切状态时由State.tag的拷贝初始化，之后可以动态添加移除tag
        events: /

    """

    def __init__(self, sg, inst, on_start=None, on_stop=None):
        super(StateGraphInstance, self).__init__()
        self.sg = sg
        self.inst = inst

        self.current_state = None
        self.last_state = None
        self.state_start_time = 0
        self.buffered_events = []
        self.tags = set()
        self.events = {}

        self.on_start = on_start
        self.on_stop = on_stop

        self.is_stopped = False
        self.timeline_index = None

    # ---------------------------------------------------
    # property
    # ---------------------------------------------------
    @property
    def time_in_state(self):
        """
        当前状态开始到现在的时间差
        :return:
        """
        return now() - self.state_start_time

    # ---------------------------------------------------
    # goto-state
    # ---------------------------------------------------
    @logger
    def go_to_state(self, state_name, *params):
        """
        /
        :param state_name:
        :param params: Table
        :return:
        """
        assert state_name in self.sg.states, "TRIED TO GO TO INVALID STATE %s" % state_name
        from_state = self.current_state
        from_state and from_state.on_exit and from_state.on_exit(self.inst, state_name)
        to_state = self.sg.states[state_name]
        self.tags = set(to_state.tags) if to_state.tags else set()  # 拷贝新状态的tags
        self.last_state, self.current_state = self.current_state, to_state
        to_state.on_enter and to_state.on_enter(self.inst, params)
        self.inst.push_event('new_state', Table(state_name=state_name))
        self.state_start_time = now()
        self.timeline_index = 0 if to_state.timeline else None
        SGManager.on_enter_new_state(self)

    # ---------------------------------------------------
    # event
    # ---------------------------------------------------
    @logger_tail
    def is_listening_for_event(self, event):
        return event in self.current_state.events or event in self.sg.events

    @logger
    def push_event(self, event, data=None):
        """
        EntityScript.push_event
        :param event:
        :param data:
        :return:
        """
        data = data or Table()
        data.state = self.current_state.name
        self.buffered_events.append(Table(name=event, data=data))

    def handle_events(self):
        """
        处理事件
        StateGraphInstance.Stop时会再处理一次事件
        :return:
        """
        assert self.current_state, "we are not in a state!"
        if not self.inst.is_valid():
            return
        buffered_event = self.buffered_events
        for event in buffered_event:
            res = self.current_state.handle_event(self, event.name, event.data)
            if not res:
                handler = self.sg.events.get(event.name, None)
                handler and handler.fn(self.inst, event.data)
        self.clear_buffered_events()

    def clear_buffered_events(self):
        self.buffered_events = []

    # ---------------------------------------------------
    # tag
    # ---------------------------------------------------
    @logger
    def add_state_tag(self, tag):
        self.tags.add(tag)

    @logger
    def remove_stat_tag(self, tag):
        self.tags.remove(tag)

    # @logger_tail
    def has_state_tag(self, tag):
        return tag in self.tags

    # ---------------------------------------------------
    # start-update-stop
    # ---------------------------------------------------
    @logger
    def start(self):
        """

        :return:
        """
        self.on_start and self.on_start()
        self.is_stopped = False
        SGManager.add_instance(self)

    def _update_state(self, dt):
        """

        :param dt:
        :return:
        """
        if not self.current_state:
            return

        while self.timeline_index:
            idx = self.timeline_index
            timeline = self.current_state.timeline
            self.timeline_index = idx + 1 if idx < len(timeline) else None
            if self.timeline_index and timeline[idx].time <= self.time_in_state:
                time_event = timeline[idx]

        on_update = self.current_state.on_update
        on_update and on_update(self.inst, dt)

    def update(self, dt):
        """

        :return:
        """
        self._update_state(dt)

    @logger
    def stop(self):
        """

        :return:
        """
        self.handle_events()
        self.on_stop and self.on_stop()
        self.is_stopped = False
        SGManager.remove_instance(self)

    def __str__(self):
        return "SGI(%s)" % ', '.join(map(repr, [
            # id(self),
            self.sg.name,
            self.current_state.name if self.current_state else 'un_init',
            float('{:.2f}'.format(self.time_in_state)),
            list(self.tags)]))

    __repr__ = __str__


class StateGraphWrangler(object):
    """
    管理所有StateGraphInstance
    SGInstance要先注册到SGManager，才能触发PushEvent
    """

    def __init__(self):
        self.instances = {}  # sg-inst -> 当前所在表
        self.updaters = set()
        self.tick_waiters = set()
        self.have_events = set()

    def _send_to_list(self, sg_inst, _list):
        """
        将inst从旧表中移, 加入list中
        :param sg_inst:
        :param _list:
        :return:
        """
        old_list = self.instances.get(sg_inst, None)
        old_list and old_list.discard(sg_inst)
        self.instances[sg_inst] = _list
        _list.add(sg_inst)

    def has_instance(self, sg_inst):
        return sg_inst in self.instances

    @logger_tail
    def on_push_event(self, sg_inst):
        if sg_inst in self.instances:
            self.have_events.add(sg_inst)
            return True
        return False

    def update(self, current_tick):
        for updater in self.updaters:
            updater.update(current_tick)

        events = self.have_events
        self.have_events = set()
        for e in events:
            e.handle_events()

    # ---------------------------------------------------
    # 增删inst
    # ---------------------------------------------------
    @logger
    def add_instance(self, sg_inst):
        self._send_to_list(sg_inst, self.updaters)

    @logger
    def remove_instance(self, sg_inst):
        old_list = self.instances.get(sg_inst, None)
        if old_list:
            old_list.discard(sg_inst)
            del self.instances[sg_inst]
        self.updaters.discard(sg_inst)
        self.have_events.discard(sg_inst)

    # ---------------------------------------------------
    # on
    # ---------------------------------------------------
    # @logger
    def on_enter_new_state(self, sg_inst):
        pass

    @logger
    def on_remove_entity(self, inst):
        self.remove_instance(inst.sg)

    def __str__(self):
        return "<SGMgr>"

    __repr__ = __str__


SGManager = StateGraphWrangler()


class State(object):
    """
    Attributes:
        name: /；必须有，"State needs name"
        on_enter: on_enter(EntityScript, params)
        on_exit: on_exit(EntityScript, to_state_name)
        on_update: on_update(EntityScript, dt)
        tags: set<str>，初始化时拷贝一份集合
        events: 事件表，EventHandler.name -> EventHandler
        timeline: 延时事件表，list<TimeEvent>，初始化时按TimeEvent.time排序
    """

    def __init__(self, name,
                 on_enter=None, on_update=None, on_exit=None,
                 tags=None, events=None, timeline=None):
        """
        构造一个状态，名字是必须的，作为标识符，其他都是可选的，默认为None
        # [x] timeline
        :param on_enter: on_enter(inst, params)
        :param on_exit: on_exit(inst, to_state_name)
        :param on_update: on_update(inst, dt)
        """
        super(State, self).__init__()
        assert name, "state needs name"
        self.name = name
        self.on_enter = on_enter
        self.on_update = on_update
        self.on_exit = on_exit

        if tags:
            assert is_iterable_T(tags, str)
        self.tags = set(tags) if tags else set()

        if events:
            assert is_iterable_T(events, EventHandler)
        self.events = {e.name: e for e in events} if events else {}

        if timeline:
            assert is_iterable_T(timeline, TimeEvent)
        self.timeline = sorted(list(timeline), key=lambda o: o.time) if timeline else []

    @logger_tail
    def handle_event(self, sg, event_name, data):
        """
        处理事件
        如果事件状态不是当前状态，则返回处理失败
        否则使用事件表处理该事件（仍然可能处理失败）
        :param sg: StateGraphInstance
        :param event_name:
        :param data: Table
        :return: bool，是否成功处理，是则结束，不是则传递事件给SG层事件表处理
        """
        if data and data.state and data.state != self.name:
            return False
        handler = self.events.get(event_name, None)
        if handler:
            return handler.fn(sg.inst, data)
        return False

    def __str__(self):
        return self.name

    __repr__ = __str__


class EventHandler(object):
    """
    Attributes:
        name: 事件名，事件标识符
        fn: fn(sg.inst, data) -> bool
            sg.inst is EntityScript
            返回是否成功处理
            成功处理，事件将停止传递给SG层事件表处理
            如果不，事件将传递给SG层事件表处理
    """

    def __init__(self, name, fn):
        self.name = name
        self.fn = fn


class TimeEvent(object):
    """
    timeline上延时触发函数
    状态拥有timeline，timeline是TimeEvent列表
    当前状态中才能触发TimeEvent，过了就没了
    Attributes:
        time: 延迟，比如5 * FRAMES，代表延迟5帧
        fn: fn(inst)
    """

    def __init__(self, time, fn):
        self.time = time
        self.fn = fn


class StateGraph(object):
    """
    静态的状态机
    Attributes:
        name: 必须有，"You must specify a name for this stategraph"
        states: 状态表，State.name -> State
        events: SG层事件表，处理State事件表未能成功处理的事件
        default_state: /
    """

    def __init__(self, name, events, states, default_state):
        super(StateGraph, self).__init__()
        assert name, "You must specify a name for this stategraph"
        self.name = name
        self.default_state = default_state
        assert is_iterable_T(events, EventHandler)
        self.events = {e.name: e for e in events} if events else {}
        assert is_iterable_T(states, State)
        self.states = {s.name: s for s in states} if states else {}

    def __str__(self):
        return "State(%s)" % repr(self.name)

    __repr__ = __str__


# @memo
def load_stategraph(path, name):
    """
    加载sg模块

    加载配置文件是程序错误，总应该正确，所以不做异常处理
    """
    import importlib
    sg_mod = importlib.import_module(path)
    return getattr(sg_mod, name)


def set_stategraph(inst, name, sg_base='stategraphs.'):
    """
    :param sg_base:
    :param inst: EntityScript
    :param name: 状态机名字，位于stategraphs/下的文件名
    :return:
    """

    if inst.sg:
        SGManager.remove_instance(inst.sg)
    sg = load_stategraph(sg_base + name, name)
    assert sg, "load stategraph failed"
    inst.sg = StateGraphInstance(sg, inst)
    SGManager.add_instance(inst.sg)
    inst.sg.go_to_state(sg.default_state)
    return inst.sg


def clear_stategraph(inst):
    if inst.sg:
        SGManager.remove_instance(inst.sg)
        inst.sg = None
