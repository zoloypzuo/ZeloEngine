# coding=utf-8
# zrandom.py
# created on 2020/11/15
# author @zoloypzuo
# usage: zrandom
import random


def roulette(chance_weights):
    """
    轮盘赌
    :param chance_weights: 一个权重列表，权值是相对比例的，和不必为1
    :return: 轮盘停下时指向的权重索引
    """
    s = sum(chance_weights)
    chosen = random.uniform(0, s)
    p = 0
    for i in xrange(len(chance_weights)):
        p += chance_weights[i]
        if p > chosen:
            return i
    return len(chance_weights)


def roulette2(chance):
    """
    轮盘赌抛硬币
    :param chance: 硬币正面概率
    :return: 结果是正面为True
    """
    return roulette([chance, 1 - chance]) == 0
