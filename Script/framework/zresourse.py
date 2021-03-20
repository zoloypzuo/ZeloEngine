# coding=utf-8
# zresourse.py
# created on 2020/10/26
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# usage: zresourse
from interfaces.runtime import IRuntimeModule


class IResource:
    def __init__(self):
        self.name = ""

    def open(self): return -1

    @property
    def raw_size(self): return 0

    @property
    def raw_resource(self): return None


class IResourceLoader:
    def __init__(self):
        self.pattern = ""
        self.use_raw_file = False
        self.discard_raw_buffer_after_load = False
        self.add_null_terminator = False

    @property
    def size(self): return 0

    def load_resource(self, raw_buffer, res_handler):
        pass


class DefaultResourceHandler:
    pass

class ResourceHandler:
    def __init__(self):
        self.resource = None
        self.buffer = None
        self.size = None
        




class ResourceManager(object, IRuntimeModule):
    """
    lru res mgr
    """
    def __init__(self):
        super(ResourceManager, self).__init__()

    def register_loader(self, res_loader):
        pass

    def get_handle(self, res):
        pass

    def preload(self, pattern, progress_cb):
        pass

    def release_all_resource(self):
        pass

    # ---------------------------------------------------
    # IRuntimeModule
    # ---------------------------------------------------
    def initialize(self):
        pass

    def finalize(self):
        pass

    def update(self):
        pass
