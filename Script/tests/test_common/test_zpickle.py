# coding=utf-8
# test_zpickle.py
# created on 2020/11/15
# author @zoloypzuo
# usage: test_zpickle


import unittest
from collections import namedtuple

from common.zjson import loads, plain_json, parse, ZJsonValueError, is_namedtuple_instance


class Aoo:

    def __init__(self):
        self.a = 0

    def __eq__(self, other):
        return self.__class__ == other.__class__ and self.__dict__ == other.__dict__


class Boo:

    def __init__(self):
        self.b = Aoo()

    def __eq__(self, other):
        return self.__class__ == other.__class__ and self.__dict__ == other.__dict__


class Test0(unittest.TestCase):
    def test_is_namedtuple_instance(self):
        assert not is_namedtuple_instance(1)
        assert not is_namedtuple_instance('some ...')
        assert not is_namedtuple_instance([1, 2, 3])
        assert not is_namedtuple_instance((1, 2, 3))
        assert not is_namedtuple_instance({1: 2})
        a_cls = namedtuple('A', ['a'])
        a_instance = a_cls(a=1)
        assert is_namedtuple_instance(a_instance)

    def test_serialize(self):
        # ---- test primitive types
        assert plain_json(1) == '1'
        assert plain_json(1.1) == '1.1'
        assert plain_json('abc') == '"abc"'  # note 'abc' is wrong, "'abc'" is also wrong
        assert plain_json(True) == 'true'
        assert plain_json(None) == 'null'
        # ---- test collections
        assert plain_json([1, 2, 3]) == '[1,2,3]'
        self.assertRaises(AssertionError, plain_json, {1: 2})
        # ---- test class objects
        self.assertEqual(
            plain_json(Boo()),
            '{"__class_name__":"Boo","__class_dict__":{"b":{"__class_name__":"Aoo","__class_dict__":{"a":0},'
            '"__class_module__":"test_zpickle"}},"__class_module__":"test_zpickle"}')
        self.assertEqual(plain_json(Aoo(), decodable=False), '{"a":0}')
        self.assertEqual(plain_json(Boo(), decodable=False), '{"b":{"a":0}}')
        pass

    def test_deserialize(self):
        # ---- test primitive types
        assert loads(plain_json(1)) == 1
        assert loads(plain_json(1.1)) == 1.1
        assert loads(plain_json('abc')) == 'abc'
        assert loads(plain_json(True)) == True
        assert loads(plain_json(None)) == None
        # ---- test collections
        assert loads(plain_json([1, 2, 3])) == [1, 2, 3]
        self.assertEqual(
            loads(plain_json((1, 2, 3))),
            (1, 2, 3))
        assert loads(plain_json({'a': 1})) == {'a': 1}
        assert loads(plain_json({1, 2, 3})) == {1, 2, 3}
        assert loads(plain_json(frozenset([1, 2, 3]))) == frozenset([1, 2, 3])
        assert loads(plain_json([])) == []
        assert loads(plain_json(tuple())) == tuple()
        assert loads(plain_json(set())) == set()
        assert loads(plain_json(frozenset())) == frozenset()
        assert loads(plain_json(dict())) == dict()

        a_cls = namedtuple('A', ['a'])
        a_instance = a_cls(a=1)
        assert loads(plain_json(a_instance)) == a_instance

        # ---- test class objects
        assert loads(plain_json(Aoo())) == Aoo()
        assert loads(plain_json(Boo())) == Boo()
        pass


from functools import partial
from unittest import TestCase


class TestParse(TestCase):
    def test_basic(self):
        # test the 3 literal types in json
        assert None == parse('null')
        assert True == parse('true')
        assert False == parse('false')

        # test the 2 simple types in json
        assert 1 == parse('1')  # 1 == 1.0 in python
        assert 1.1 == parse('1.1')
        assert 'abc' == parse('"abc"')  # note that 'abc' is wrong, "'abc'" is also wrong

        # test the 2 composite types in json
        assert [1, 2, 3] == parse('[1,2,3]')
        assert {'a': 1} == parse(r'{"a": 1}')  # {'a': 1} == {'a': 1} is True

    def test_number(self):
        ''''''
        # TODO numbers: ...

    def test_string(self):
        ''''''
        # TODO strings: escape utf-8

    def test_error(self):
        ''''''
        # TODO more test to error
        assert_value_error = partial(self.assertRaises, ZJsonValueError, parse)
        assert_value_error('ull')
        assert_value_error('tre')

        assert_value_error('')
