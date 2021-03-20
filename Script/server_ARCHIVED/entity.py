# coding=utf-8
HERO_TYPE_NONE = 0
HERO_TYPE_Mike = 0
HERO_TYPE_Sherry = 0


class Entity(object):
    def __init__(self):
        super(Entity, self).__init__()
        self.eid = 0
        self.server = None


class PlayerEntity(Entity):
    def __init__(self, hid):
        super(PlayerEntity, self).__init__()
        self.hid = hid
        self.hero_type = 0
        self.position = [0, 0]
        self.health = 100.0

# 没时间做c了，全部放Entity里面
# class Component(object):
#     def __init__(self):
#         super(Component, self).__init__()
#         self.cid = 0
#         self.server = 0
#
