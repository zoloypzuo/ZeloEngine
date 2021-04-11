# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# zlinq.py
# created on 2020/11/10
# usage: zlinq


# System.Linq Namespace | Microsoft Docs
# https://docs.microsoft.com/en-us/dotnet/api/system.linq?view=net-5.0

from typing import Callable, Optional, Any, Iterable

Predicate = Callable[[], bool]

from itertools import imap as map, ifilter as filter


class LinqIterable(object):
    """
    Attributes:
    """

    def __init__(self, data):
        # type: (Iterable) -> None
        super(LinqIterable, self).__init__()
        self._data = data  # type: Iterable

    # ---------------------------------------------------
    # basic operation
    # ---------------------------------------------------
    def where(self, predicate):
        return LinqIterable(filter(predicate, self._data))

    def select(self, selector):
        return LinqIterable(map(selector, self._data))

    def ordered_by(self, key=None):
        """
        :param key:
        :return:
        """
        return LinqIterable(sorted(self._data, key=key))

    # ---------------------------------------------------
    # extra operation
    # ---------------------------------------------------

    def first_or_default(self, predicate, default=None):
        # type: (Callable, Any) -> Optional[LinqIterable]
        """

        :param predicate:
        :return:
        """
        for item in self._data:
            if predicate(item):
                return item
        return default

    def reversed(self):
        return LinqIterable(sorted(self._data, reverse=True))

    def count(self, predicate):
        return len(tuple(filter(predicate, self._data)))

    def take(self, key, num):
        from collections import Counter
        return LinqIterable(Counter(self.select(key)).most_common(num))

    # ---------------------------------------------------
    # set operation
    # ---------------------------------------------------
    @staticmethod
    def union(a, b):
        return LinqIterable(set(a._data) | set(b._data))

    @staticmethod
    def intersect(a, b):
        return LinqIterable(set(a._data) & set(b._data))

    # ---------------------------------------------------
    # get result
    # ---------------------------------------------------
    def to_set(self):
        return set(self._data)

    def to_list(self):
        return list(self._data)

    def to_tuple(self):
        return tuple(self._data)

    # ---------------------------------------------------
    # meta-method
    # ---------------------------------------------------
    def __and__(self, other):
        return LinqIterable.intersect(self, other)

    def __or__(self, other):
        return LinqIterable.union(self, other)

    def __iter__(self):
        return self._data.__iter__()

    def __eq__(self, other):
        return self._data.__eq__(other)
