# coding=utf-8
# brain.py
# created on 2020/10/2
# author @zoloypzuo
# usage: brain


class Brain(object):
    """
    Attributes:
        inst: /
        current_behaviour: /
        behaviour_queue:
        events:
        think_period:
        last_think_time:
        bt:
        on_start: on_start()
        is_stopped:
        on_init_complete:
        do_update:
        on_stop:

    Optional Callbacks:
        on_start: on_start()
        on_init_complete: on_init_complete()
        on_stop: on_stop()
        do_update: do_update()
    """

    def __init__(self):
        super(Brain, self).__init__()
        self.inst = None
        self.current_behaviour = None
        self.behaviour_queue = []
        self.events = {}
        self.think_period = None
        self.last_think_time = None
        self.bt = None
        self.is_stopped = False

    # ---------------------------------------------------
    # used by entityscript
    # ---------------------------------------------------
    def start(self):
        on_start = getattr(self, 'on_start', None)
        on_start and on_start()
        self.is_stopped = False
        BrainManager.add_instance(self)
        on_init_complete = getattr(self, 'on_init_complete', None)
        on_init_complete and on_init_complete()

    def push_event(self, event, data):
        handler = self.events.get(event, None)
        handler and handler(data)

    def stop(self):
        on_stop = getattr(self, 'on_stop', None)
        on_stop and on_stop()
        self.bt and self.bt.stop()
        self.is_stopped = True
        BrainManager.remove_instance(self)

    # ---------------------------------------------------
    # other api
    # ---------------------------------------------------

    def add_event_handler(self, event, fn):
        self.events[event] = fn

    # @logger
    def on_update(self):
        do_update = getattr(self, 'do_update', None)
        do_update and do_update()
        self.bt and self.bt.update()


class BrainWrangler(object):
    def __init__(self):
        self.instances = {}
        self.updaters = set()

    def on_remove_entity(self, inst):
        if inst.brain and inst.brain in self.instances:
            self.remove_instance(inst)

    def sent_to_list(self, inst, list_):
        old_list = self.instances.get(inst, None)
        old_list and old_list.discard(inst)
        self.instances[inst] = list_
        list_.add(inst)

    def remove_instance(self, inst):
        old_list = self.instances.get(inst, None)
        if old_list:
            old_list.discard(inst)
            del self.instances[inst]
        self.updaters.discard(inst)

    def add_instance(self, inst):
        self.sent_to_list(inst, self.updaters)

    # @logger
    def update(self, dt):
        for updater in self.updaters:
            if not updater.inst.is_valid():
                continue
            updater.on_update()

    # ---------------------------------------------------
    # meta
    # ---------------------------------------------------
    def __str__(self):
        return "<BrainMgr>"

    __repr__ = __str__


BrainManager = BrainWrangler()
