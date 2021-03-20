# coding=utf-8
import logging
import random

from common.zlogger import logger
from server_ARCHIVED.net_stream import RpcProxy


def roulette(chance_weights):
    s = sum(chance_weights)
    chosen = random.uniform(0, s)
    p = 0
    for i in xrange(len(chance_weights)):
        p += chance_weights[i]
        if p > chosen:
            return i
    return len(chance_weights)


def roulette2(chance):
    return roulette([chance, 1 - chance]) == 0


def test():
    s = 0
    t = 100000
    for i in xrange(t):
        s = s + 1 if roulette2(0.3) else s
    print s / float(t)  # NOTE division in python2 is integer division


def parse_vector3(v):
    return list(map(float, v.strip('()').split(',')))


def calculate_damage(attacker, defender):
    # 参考值，浮动2~5，暴击率.3，暴击乘子2
    critical = roulette2(attacker.critical_chance)
    critical_multiplier = attacker.critical_multiplier if critical else 1
    attack_float = random.uniform(attacker.min_float_damage, attacker.max_float_damage)
    return (attacker.attack + attack_float) * critical_multiplier - defender.defense


class RpcWrapper(object):
    def __init__(self, net_stream, hid, server):
        self.caller = RpcProxy(self, net_stream)
        self.hid = hid
        self.server = server

    def __str__(self):
        return "<%s>" % self.hid

    __repr__ = __str__

    @logger
    def hello_world_from_client(self, stat, msg):
        self.server.single(self.hid, 'recv_msg_from_server', 2, msg)
        # self.server.single(self.hid, 'SCTest', [1, 2, 3])
        # self.server.single(self.hid, 'SCTest', [1, 'this is a str', 3])
        # self.server.single(self.hid, 'SCTest', [1, [1, 2, 3], 3])
        # self.server.single(self.hid, 'SCTest', [1, [1, 2, 3], 3])
        # self.server.single(self.hid, 'SCTest', {'s': 1, 'b': 2})
        # self.server.single(self.hid, 'SCTestDict', {'s': 1, 'b': 2})

    @logger
    def cs_combo_attack(self, eid):
        self.server.broadcast('SCComboAttack', eid)

    @logger
    def cs_gm(self, gm_code):
        eval(gm_code)
        # 下面这个是不对的，code被运行会发生复杂的错误
        # try:
        #     eval(gm_code)
        # except SyntaxError:
        #     logging.error('syntax error %s', gm_code)

    @logger
    def cs_room_enter(self):
        server = self.server
        server.room.append(self.hid)
        server.update_player_profiles()

    @logger
    def cs_room_player_ready(self):
        room_player_ready = self.server.room_player_ready
        room_player_ready.add(self.hid)
        # 玩家人数大于1且所有玩家都准备了
        n_player_ready = len(room_player_ready)
        if n_player_ready > 1 and n_player_ready == len(self.server.room):
            self.server.state_machine.change_state('matchgame')
        else:
            self.server.broadcast('SCRoomPlayerReady', n_player_ready)

    # @logger
    def cs_debug_start_matchgame(self):
        self.server.room_player_ready.add(self.hid)
        self.server.state_machine.change_state('matchgame')

    def cs_agent_move_to(self, destination):
        destination = parse_vector3(destination)
        self.server.broadcast('SCAgentMoveToDestination',
                              self.server.player_hid2eid(self.hid),
                              destination)

    def cs_attack(self, attack_type, player_position, target_position):
        player_position = parse_vector3(player_position)
        target_position = parse_vector3(target_position)
        self.server.broadcast('SCAttack',
                              self.server.player_hid2eid(self.hid),
                              attack_type, player_position, target_position)

    def cs_attack_hit(self, eid):
        # [x] 同步生命值
        self.server.broadcast('SCAttackHit', eid, self.hid)
        defender_entity = self.server.get_entity(eid)
        defender_entity.health -= 30.0
        self.server.broadcast('SCAgentHealth', eid, defender_entity.health)
        if defender_entity.health <= 0:
            remainder = self.server.remaining_players
            remainder.remove(eid)
            if len(remainder) == 1:
                winner = remainder.pop()
                logging.info('winner=%s', winner)
                self.server.broadcast('SCWin')
            self.server.broadcast('SCAgentDead', eid)

    def cs_agent_dead(self):
        eid = self.server.player_hid2eid(self.hid)
        self.server.broadcast("SCAgentDead", eid)

        # @logger
    # def cs_agent_attack(self, attack_type):
    #     # TODO attack args
    #     assert attack_type == ATTACK_TYPE_Debug
    #     # 触发攻击事件
    #     self.server.broadcast('SCAttack', self.hid)
    #     for player in overlap_shpere(attacker.position, attacker.range):
    #         damage = calculate_damage(attacker, defender)
    #         # 触发攻击命中事件
    #         self.server.broadcast('SCAttackHit', attacker, defender, damage)
    # TODO 主角为最后一位幸存玩家则胜利，主角死亡则游戏失败
    # TODO 战斗胜利，失败结算
