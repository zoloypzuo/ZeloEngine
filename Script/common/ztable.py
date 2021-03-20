# coding=utf-8
# ztable.py
# created on 2020/9/14
# author @zoloypzuo
# usage: lua table

# modules for debug
# from utils import trace
# from zlogger import logger, logger_full


class Table(object):
    """
    Table是一个可以动态访问kv的对象
    kv是可以嵌套的

    Example
    # 构造Table
    Table(a=1, b=2)  # 程序中构造
    Config.parse_options({'a'=1, 'b'=2})  # 读表构造，很容易改写成读取json构造
    # 访问kv
    c.a -> 1
    c.b -> 2
    """

    def __init__(self, **pairs):
        """
        :param options:
        """
        super(Table, self).__init__()
        self.set_table(pairs)

    def set_table(self, pairs):
        """
        接受一个字典，写入self，可以覆写已有kv
        :param pairs:
        :return:
        """
        Table._parse_pairs_internal(pairs, self)

    @staticmethod
    # @logger_full
    # @trace
    def parse_pairs(pairs):
        """
        接受一个字典，递归解析后，返回一个Table
        :param pairs:
        :return:
        """
        return Table._parse_pairs_internal(pairs, None)

    @staticmethod
    # @logger_full
    # @trace
    def _parse_pairs_internal(pairs, node):
        node = node or Table()
        for k, v in pairs.iteritems():
            if isinstance(v, dict):
                v = Table.parse_pairs(v)
            setattr(node, k, v)
        return node

    def compile(self):
        """
        TODO 预编译静态table到py代码，用类组织，比如类似ini的配置文件，生成桩文件，便于开发

        TheConfig = Table(window=Table(width=500,height=300))
        => TheConfig = Config()
        class Config:
            window = Window()

        class Window:
            width = 0
            height = 0

        那你为什么不直接用这种方式呢？
        Table的意义只是方便吗？
        :return:
        """
        pass

    # ---------------------------------------------------
    # meta-methods
    # ---------------------------------------------------
    def __str__(self):
        return '%s%s' % (Table.__name__, self.__dict__.__str__())

    __repr__ = __str__

    # def __getattr__(self, item):
    #     return self.__dict__[item]
    #
    # def __setattr__(self, key, value):
    #     self.__dict__[key] = value  # TODO

    def __contains__(self, item):
        assert item and isinstance(item, str)
        return hasattr(self, item)

    def __getitem__(self, item):
        return getattr(self, item, None)

    def __setitem__(self, key, value):
        assert key and isinstance(key, str)
        setattr(self, key, value)

    def __delitem__(self, key):
        assert key in self
        delattr(self, key)

    def __iter__(self):
        return self.__dict__.iteritems()


if __name__ == '__main__':
    # Table{'a': 1, 'b': 2}
    # 1
    # Table{'a': 1, 'b': Table{'c': 'hello'}}
    # hello
    c = Table(a=1, b=2)
    print c
    print c.a
    c = Table.parse_pairs({'a': 1, 'b': {'c': 'hello'}})
    print c
    print c.b.c
