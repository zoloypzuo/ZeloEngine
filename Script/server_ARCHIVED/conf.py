# -*- coding: GBK -*-

MSG_CS_LOGIN = 0x1001
MSG_SC_CONFIRM = 0x2001

MSG_CS_MOVETO = 0x1002
MSG_SC_MOVETO = 0x2002

NET_STATE_STOP = 0  # state: init value
NET_STATE_CONNECTING = 1  # state: connecting
NET_STATE_ESTABLISHED = 2  # state: connected

NET_HEAD_LENGTH_SIZE = 4  # 4 bytes little endian (x86)
NET_HEAD_LENGTH_FORMAT = '<I'

NET_CONNECTION_NEW = 0  # new connection
NET_CONNECTION_LEAVE = 1  # lost connection
NET_CONNECTION_DATA = 2  # data comming

NET_HOST_DEFAULT_TIMEOUT = 70

MAX_HOST_CLIENTS_INDEX = 0xffff
MAX_HOST_CLIENTS_BYTES = 16

# run code in debug mode
__DEBUG = True

GAME_DELTATIME = 0.033

RPC_CHECK = False
if not RPC_CHECK:
    print "WARNING, RPC_CHECK=False"

entity_types = [
    'Player',
]


def type_id(t):
    return entity_types.index(t)


USER_NAMES = ['Killer Queen', 'The World', 'Star Platinum', 'Magician\'s Red',
              'The Fool', 'Emperor', 'Empress', 'The Greatful Dead', 'Metallica']
AVATARS = [0, 1]  # 目前只有内置两个头像
ROOM_SIZE = 10

ADDRESS = '127.0.0.1'
PORT = 2000

N_AI_PLAYERS = 2
ATTACK_TYPE_None = 0
ATTACK_TYPE_Debug = 1
ATTACK_TYPE_Debug1 = 2
ATTACK_TYPE_MikeNormalAttack = 3
ATTACK_TYPE_MikeSpecialAttack = 4
ATTACK_TYPE_SherryNormalAttack = 5
ATTACK_TYPE_SherrySpecialAttack = 6
