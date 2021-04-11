# coding=utf-8
# prefab.py
# created on 2020/10/21
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# usage: prefab


class Asset(object):
    """
    Attributes:
        type: e.g. "ANIM", "SOUND"
        file: file name
        param: usually not used
    """
    def __init__(self, type_, file_, param):
        super(Asset, self).__init__()
        self.type = type_
        self.file = file_
        self.param = param


class Prefab(object):
    """
    Attributes:
        name: logic name, in category path format, e.g "common/monsters/abigail"
        fn: init fn
        assets: refed asset files
        deps: refed prefabs, usually not used
    """

    def __init__(self, name, fn, assets=None, deps=None):
        super(Prefab, self).__init__()
        self.name = name
        self.path = name
        self.desc = ""
        self.fn = fn
        self.assets = assets or []
        self.deps = deps or []
