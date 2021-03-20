# coding=utf-8
import importlib
import logging
import random
import time

import conf
# from common import generate_id, memo, logger
from conf import USER_NAMES, AVATARS
from logic import RpcWrapper
from simple_host import SimpleHost
# from stategraph import StateMachine

map_border = (-10, 0, 0, 10)  # x-min,y-min,x-max,y-max


# 玩家信息
class ClientPlayerProfile(object):
    def __init__(self, hid, username, avatar_id):
        super(ClientPlayerProfile, self).__init__()
        self.hid = hid
        self.username = username
        self.avatar_id = avatar_id


class SimpleServer(object):
    singleton = None

    def __init__(self):
        super(SimpleServer, self).__init__()
        # 网络
        self.host = SimpleHost()
        self.host.startup(conf.PORT)

        # 消息队列
        self.message_queue_send_single = []  # (client_id, msg)
        self.message_queue_send_broadcast = []  # msg
        self.message_queue_send_except = []  # (client_id, msg)

        # 实体集合
        # entity type to entity map
        self.entity_collection = {}
        self.entity_map = {}

        self.login_successful_clients = set()
        self.client_rpc_proxy = {}

        # 状态机
        self.state_machine = StateMachine()
        self.state_machine.add_state('room', self.on_state_room_enter, self.on_state_room_exit)
        self.state_machine.add_state('matchgame', self.on_state_matchgame_enter, self.on_state_matchgame_exit)

        # 房间模块
        self.room = []
        self.player_profiles = {}
        self.room_player_ready = set()

        # 单局模块
        # eid
        self.ai_players = set()
        self.client_players = set()
        self.all_players = set()
        self.player_hid2eid_dict = {}
        self.remaining_players = set()

    def on_state_room_enter(self):
        self.room = []
        self.player_profiles = {}
        self.room_player_ready = set()

    def on_state_room_exit(self):
        pass

    def on_state_matchgame_enter(self):
        for client_player in self.room_player_ready:
            player_entity = self.create_entity('Player', client_player)
            player_entity.position = self.random_map_position()
            self.client_players.add(player_entity.eid)
            self.player_hid2eid_dict[client_player] = player_entity.eid
        for i in xrange(conf.N_AI_PLAYERS):
            # 为AI创建PlayerProfile
            ai_hid = self.random_ai_hid()
            player_entity = self.create_entity('Player', ai_hid)
            self.create_player_profile(ai_hid)
            player_entity.position = self.random_map_position()
            self.ai_players.add(player_entity.eid)
            self.player_hid2eid_dict[ai_hid] = player_entity.eid
            logging.info('[ai] create ai hid=%s, eid=%s' % (ai_hid, player_entity.eid))
        self.all_players = self.client_players | self.ai_players
        self.remaining_players = set(self.all_players)
        self.update_player_profiles()
        self.broadcast('SCGameStart')
        # 现在服务器创建所有对象，然后同步到客户端创建这些对象
        self.broadcast('SCInitPlayers', list(map(lambda eid: self.get_entity(eid), self.all_players)))

    def on_state_matchgame_exit(self):
        pass

    def random_map_position(self):
        x_min, y_min, x_max, y_max = map_border
        x = random.uniform(x_min, x_max)
        y = random.uniform(y_min, y_max)
        # TODO 避免出生过近
        return x, y

    def random_ai_hid(self):
        while True:
            i = random.randint(1, 10000)
            if i not in self.client_rpc_proxy.keys():
                return i
        logging.error('no keys available')
        return -1

    def update_player_profiles(self):
        self.broadcast('SCRoomUpdate', self.room, self.player_profiles)

    def player_eid2hid(self, eid):
        return self.get_entity(eid).hid

    def player_hid2eid(self, hid):
        return self.player_hid2eid_dict[hid]

    def create_entity(self, entity_type, *args):
        """创建某个类型的实体实例"""
        eid = generate_id()
        cls_name = entity_type + 'Entity'
        module_ = importlib.import_module('entity')
        class_ = getattr(module_, cls_name)
        instance = class_(*args)
        instance.eid = eid
        instance.server = self
        if entity_type not in self.entity_collection:
            self.entity_collection[entity_type] = {}
        self.entity_collection[entity_type][eid] = instance
        self.entity_map[eid] = instance
        logging.info('create_entity type=%s, eid=%s', entity_type, eid)
        return instance

    def remove_entity(self, entity_type, eid):
        if eid in self.entity_collection[entity_type]:
            del self.entity_collection[entity_type][eid]

    def get_entity(self, eid):
        return self.entity_map.get(eid, None)

    # 缓存entity的tick函数指针
    @memo
    def get_tick(self, eid):
        return getattr(self.entity_map[eid], 'tick', None)

    # @logger
    def run(self):
        logging.info('server start')
        game_time = time.time()
        self.state_machine.change_state('room')

        while True:
            # run server at 30 FPS
            time.sleep(0.001)
            now = time.time()
            if now - game_time < conf.GAME_DELTATIME:
                continue
            game_time = now

            # handle client msg
            self.host.process()
            event, hid, data = self.host.read()
            while event >= 0:
                # logging.info('event=%s,hid=%s,data=%s', event, hid, data)
                if event == conf.NET_CONNECTION_NEW:
                    # logging.info('NET_CONNECTION_NEW hid=%s,data=%s', hid, data)
                    self.connect_new_client(hid)
                elif event == conf.NET_CONNECTION_DATA:
                    # logging.info('NET_CONNECTION_DATA hid=%s,data=%s', hid, data)
                    try:
                        self.client_rpc_proxy[hid].caller.parse_rpc(data)
                    except RuntimeError as err:
                        logging.error('unhandled error \n%s', err)
                event, hid, data = self.host.read()

            # update entities
            for eid, e in self.entity_map.iteritems():
                tick = self.get_tick(eid)
                tick and tick()

            # send msg
            for hid, f, args in self.message_queue_send_single:
                getattr(self.client_rpc_proxy[hid].caller, f)(*args)
            for f, args in self.message_queue_send_broadcast:
                for hid in self.login_successful_clients:
                    getattr(self.client_rpc_proxy[hid].caller, f)(*args)
            for hid, f, args in self.message_queue_send_except:
                for succ_id in self.login_successful_clients:
                    if succ_id != hid:
                        getattr(self.client_rpc_proxy[hid].caller, f)(*args)
            self.message_queue_send_single = []
            self.message_queue_send_broadcast = []
            self.message_queue_send_except = []
            self.host.process()  # push client to send msg???

        logging.info('server end')

    @logger
    def connect_new_client(self, hid):
        # 创建网络代理
        code, client_net_stream = self.host.getClient(hid)
        assert code >= 0
        self.client_rpc_proxy[hid] = RpcWrapper(client_net_stream, hid, self)
        # 直接登录成功
        self.login_successful_clients.add(hid)
        # 服务器创建随机玩家信息
        player_profile = self.create_player_profile(hid)
        # 把hid单独发回去
        self.single(hid, 'SCHid', hid)

    def create_player_profile(self, hid):
        player_profile = ClientPlayerProfile(hid, random.choice(USER_NAMES), random.choice(AVATARS))
        self.player_profiles[hid] = player_profile
        return player_profile

    def single(self, hid, f, *args):
        self.message_queue_send_single.append((hid, f, args))

    def broadcast(self, f, *args):
        self.message_queue_send_broadcast.append((f, args))

    def queued_msg_except(self, hid, f, *args):
        self.message_queue_send_except.append((hid, f, args))

    def __str__(self):
        return '<svr>'

    __repr__ = __str__
