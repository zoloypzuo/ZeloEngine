# coding=utf-8
# game_timer.py
# created on 2020/8/19
# author @zoloypzuo
import heapq
import time


class GameTimer(object):
    def __init__(self):
        """
        一般的游戏时钟，需要游戏循环tick
        """
        super(GameTimer, self).__init__()
        self.pause = False
        self.dt = -1.0  # 最近两次tick的时间差
        self.curr_time = 0.0  # 最近一次tick的时间戳
        self.prev_time = 0.0  # 最近一次的上一次tick的时间戳
        self.stop_time = 0.0  # stop时的时间戳
        self.base_time = 0.0  # reset时的时间戳
        self.paused_time = 0.0  # 暂停时间累积
        self.reset()

    def reset(self):
        """
        reset timer
        """
        curr_time = now()
        self.base_time = curr_time
        self.prev_time = curr_time
        self.stop_time = 0.0
        self.pause = False

    def stop(self):
        if self.pause:
            return
        curr_time = now()
        self.stop_time = curr_time
        self.pause = True

    def tick(self):
        if self.pause:
            self.dt = 0.0
            return
        curr_time = now()
        self.dt = curr_time - self.prev_time
        self.curr_time = curr_time
        self.prev_time = curr_time
        if self.dt < 0.0:
            self.dt = 0.0

    def resume(self):
        """
        //                     |<-------d------->|
        // ----*---------------*-----------------*------------> time
        //  mBaseTime       mStopTime        startTime
        """
        if not self.pause:
            return
        curr_time = now()
        self.paused_time += curr_time - self.stop_time
        self.prev_time = curr_time
        self.stop_time = 0.0
        self.pause = False

    @property
    def total_time(self):
        """
        time elapsed since Reset() is called, in seconds
        NOTE time in pause state is not included
        //                     |<--paused time-->|
        // ----*---------------*-----------------*------------*------------*------> time
        //  mBaseTime       mStopTime        startTime     mStopTime    mCurrTime
        :return: float
        """
        last_time = self.stop_time if self.pause else self.curr_time
        return last_time - self.base_time - self.paused_time


class CountdownTimer(object):
    """倒计时时钟：timer是一个倒计时器，单位为s"""

    def __init__(self, timer):
        self.timer = timer
        self.base_time = now()

    @property
    def countdown(self):
        curr_time = now()
        elapsed_time = curr_time - self.base_time
        return self.timer - elapsed_time

    @property
    def is_timeout(self):
        return self.countdown <= 0.0

    def __str__(self):
        return '%s(%s, %s)' % (CountdownTimer.__name__, self.timer, self.countdown)

    __repr__ = __str__


class CallLater(object):
    """Calls a function at a later time.
    """

    def __init__(self, seconds, target, *args, **kwargs):
        super(CallLater, self).__init__()

        self._delay = seconds
        self._target = target
        self._args = args
        self._kwargs = kwargs

        self.cancelled = False
        self.timeout = time.time() + self._delay

    def __le__(self, other):
        return self.timeout <= other.timeout

    def call(self):
        try:
            self._target(*self._args, **self._kwargs)
        except (KeyboardInterrupt, SystemExit):
            raise

        return False

    def cancel(self):
        self.cancelled = True


class CallEvery(CallLater):
    """Calls a function every x seconds.
    """

    def call(self):
        try:
            self._target(*self._args, **self._kwargs)
        except (KeyboardInterrupt, SystemExit):
            raise

        self.timeout = time.time() + self._delay

        return True


class Timer(object):
    """计时器管理器"""
    tasks = []
    cancelled_num = 0

    @staticmethod
    def addTimer(delay, func, *args, **kwargs):
        timer = CallLater(delay, func, *args, **kwargs)

        heapq.heappush(Timer.tasks, timer)

        return timer

    @staticmethod
    def addRepeatTimer(delay, func, *args, **kwargs):
        timer = CallEvery(delay, func, *args, **kwargs)

        heapq.heappush(Timer.tasks, timer)

        return timer

    @staticmethod
    def scheduler():
        now = time.time()

        while Timer.tasks and now >= Timer.tasks[0].timeout:
            call = heapq.heappop(Timer.tasks)
            if call.cancelled:
                Timer.cancelled_num -= 1
                continue

            try:
                repeated = call.call()
            except (KeyboardInterrupt, SystemExit):
                raise

            if repeated:
                heapq.heappush(Timer.tasks, call)

    @staticmethod
    def cancel(timer):
        if not timer in Timer.tasks:
            return

        timer.cancel()
        Timer.cancelled_num += 1

        if float(Timer.cancelled_num) / len(Timer.tasks) > 0.25:
            Timer.removeCancelledTasks()

        return

    @staticmethod
    def removeCancelledTasks():
        print 'remove cancelled tasks'
        tmp_tasks = []
        for t in Timer.tasks:
            if not t.cancelled:
                tmp_tasks.append(t)

        Timer.tasks = tmp_tasks
        heapq.heapify(Timer.tasks)

        Timer.cancelled_num = 0

        return


def now():
    """
    当前时间
    :return: float
    """
    return time.time()


def second_watch(n_seconds, callback, second_callback):
    """
    秒表计时器，倒计时n秒，每秒触发second_callback，倒计时结束触发callback
    用于游戏中的秒表倒计时，需要每秒更新显示
    second_callback参数是CountdownTimerr，使用CountdownTimer.countdown获取countdown
    """

    t1 = Timer.addTimer(n_seconds, callback)
    ct = CountdownTimer(n_seconds)
    t2 = Timer.addRepeatTimer(1, second_callback, ct)
    t3 = Timer.addTimer(n_seconds, lambda: t2.cancel())
    return t1, t2, t3


def get_tick_time():
    """
    dt
    :return:
    """
    return 1.0 / 30


if __name__ == '__main__':
    # now=1598232435.49
    # 2.0
    # False
    # -1.00100016594
    # True
    print 'now=%s' % now()
    gt = CountdownTimer(5)
    time.sleep(3)
    print gt.countdown
    print gt.is_timeout
    time.sleep(3)
    print gt.countdown
    print gt.is_timeout
