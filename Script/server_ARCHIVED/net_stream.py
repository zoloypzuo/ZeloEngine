# -*- coding: GBK -*-

# =========================================================================
#
# NOTE: We use 4 bytes little endian (x86) by default.
# If you choose a different endian, you may have to modify header length.
#
# =========================================================================

import errno
import json
import logging
import socket
import struct

import conf


# 将类实例转换成可json序列化的对象
def net_arg(o):
    if o is None:
        return None
    if isinstance(o, (int, float, str, bool, unicode)):
        return o
    elif isinstance(o, (list, tuple)):
        return [net_arg(i) for i in o]
    elif isinstance(o, dict):
        return {k: net_arg(v) for k, v in o.iteritems()}
    # TODO 过滤掉server，import循环没法解决
    d = o.__dict__
    if 'server' in d:
        o.server = None
    return o.__dict__


class RpcProxy(object):
    def __init__(self, owner, netstream):
        self.owner = owner
        self.netstream = netstream

    def close(self):
        self.owner = None
        self.netstream = None

    def __getattr__(self, name):
        def call(self, *args):
            # not support key-value pairs
            info = {
                'method': name,
                'args': map(net_arg, args),
                'kwargs': {},
            }

            self.netstream and self.netstream.send(json.dumps(info))

        setattr(RpcProxy, name, call)
        return getattr(self, name)

    def parse_rpc(self, data):
        info = json.loads(data)
        method = info.get('method', None)
        if method is None:
            return

        func = getattr(self.owner, method, None)
        if func:
            # 检查元标记
            if not conf.RPC_CHECK or (conf.RPC_CHECK and getattr(func, '__exposed__', False)):
                func(*info['args'], **info['kwargs'])
            else:
                logging.error('[rpc] invalid rpc call, NOT PERMITTED: %s', method)
        else:
            logging.error('[rpc] invalid rpc call, NOT EXSIT: %s', method)


class NetStream(object):
    def __init__(self):
        super(NetStream, self).__init__()

        self.sock = None  # socket object
        self.send_buf = ''  # send buffer
        self.recv_buf = ''  # recv buffer

        self.state = conf.NET_STATE_STOP
        self.errd = (errno.EINPROGRESS, errno.EALREADY, errno.EWOULDBLOCK)
        self.conn = (errno.EISCONN, 10057, 10053)
        self.errc = 0

        return

    def status(self):
        return self.state

    # connect the remote server
    def connect(self, address, port):
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.sock.setblocking(0)
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
        self.sock.connect_ex((address, port))
        self.state = conf.NET_STATE_CONNECTING
        self.send_buf = ''
        self.recv_buf = ''
        self.errc = 0

        return 0

    # close connection
    def close(self):
        self.state = conf.NET_STATE_STOP

        if not self.sock:
            return 0
        try:
            self.sock.close()
        except:
            pass  # should logging here

        self.sock = None

        return 0

    # assign a socket to netstream
    def assign(self, sock):
        self.close()
        self.sock = sock
        self.sock.setblocking(0)
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
        self.state = conf.NET_STATE_ESTABLISHED

        self.send_buf = ''
        self.recv_buf = ''

        return 0

    # set tcp nodelay flag
    def nodelay(self, nodelay=0):
        if not 'TCP_NODELAY' in socket.__dict__:
            return -1
        if self.state != 2:
            return -2

        self.sock.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, nodelay)

        return 0

    # update
    def process(self):
        if self.state == conf.NET_STATE_STOP:
            return 0
        if self.state == conf.NET_STATE_CONNECTING:
            self.__tryConnect()
        if self.state == conf.NET_STATE_ESTABLISHED:
            self.__tryRecv()
        if self.state == conf.NET_STATE_ESTABLISHED:
            self.__trySend()

        return 0

    def __tryConnect(self):
        if (self.state == conf.NET_STATE_ESTABLISHED):
            return 1
        if (self.state != conf.NET_STATE_CONNECTING):
            return -1
        try:
            self.sock.recv(0)
        except socket.error, (code, strerror):
            if code in self.conn:
                return 0
            if code in self.errd:
                self.state = conf.NET_STATE_ESTABLISHED
                self.recv_buf = ''
                return 1

            self.close()
            return -1

        self.state = conf.NET_STATE_ESTABLISHED

        return 1

    # append data into send_buf with a size header
    def send(self, data):
        size = len(data) + conf.NET_HEAD_LENGTH_SIZE
        wsize = struct.pack(conf.NET_HEAD_LENGTH_FORMAT, size)
        self.__sendRaw(wsize + data)

        return 0

    # append data to send_buf then try to send it out (__try_send)
    def __sendRaw(self, data):
        self.send_buf = self.send_buf + data
        self.process()

        return 0

    # send data from send_buf until block (reached system buffer limit)
    def __trySend(self):
        wsize = 0
        if (len(self.send_buf) == 0):
            return 0

        try:
            wsize = self.sock.send(self.send_buf)
        except socket.error, (code, strerror):
            if not code in self.errd:
                self.errc = code
                self.close()

                return -1

        self.send_buf = self.send_buf[wsize:]
        return wsize

    # recv an entire message from recv_buf
    def recv(self):
        rsize = self.__peekRaw(conf.NET_HEAD_LENGTH_SIZE)
        if (len(rsize) < conf.NET_HEAD_LENGTH_SIZE):
            return ''

        size = struct.unpack(conf.NET_HEAD_LENGTH_FORMAT, rsize)[0]
        if (len(self.recv_buf) < size):
            return ''

        self.__recvRaw(conf.NET_HEAD_LENGTH_SIZE)

        return self.__recvRaw(size - conf.NET_HEAD_LENGTH_SIZE)

    # try to receive all the data into recv_buf
    def __tryRecv(self):
        rdata = ''
        while 1:
            text = ''
            try:
                text = self.sock.recv(1024)
                if not text:
                    self.errc = 10000
                    self.close()

                    return -1
            except socket.error, (code, strerror):
                if not code in self.errd:
                    self.errc = code
                    self.close()
                    return -1
            if text == '':
                break

            rdata = rdata + text

        self.recv_buf = self.recv_buf + rdata
        return len(rdata)

    # peek data from recv_buf (read without delete it)
    def __peekRaw(self, size):
        self.process()
        if len(self.recv_buf) == 0:
            return ''

        if size > len(self.recv_buf):
            size = len(self.recv_buf)
        rdata = self.recv_buf[0:size]

        return rdata

    # read data from recv_buf (read and delete it from recv_buf)
    def __recvRaw(self, size):
        rdata = self.__peekRaw(size)
        size = len(rdata)
        self.recv_buf = self.recv_buf[size:]

        return rdata
