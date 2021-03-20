# coding=utf-8
import unittest

from common.zlogger import *
from common.ztable import Table
from entityscript import EntityScript


class MyTestCase(unittest.TestCase):
    def test0(self):
        """
        entA监听自己的事件，触发自己的事件
        # {'etest': {<entityscript.EntityScript object at 0x02E4E690>: [<function handle_event_etest at 0x02E50EF0>]}}
        # {'etest': {<entityscript.EntityScript object at 0x02E4E690>: [<function handle_event_etest at 0x02E50EF0>]}}
        # @zoloypzuo [2020-09-17 09:27:51.609000][Default] handle_event_etest(Table{'a': 1, 'b': 2, 'd': 'dtest'})
        :return:
        """

        @logger
        def handle_event_etest(dtest):
            pass

        entA = EntityScript()
        entA.listen_for_event('etest', handle_event_etest)
        entA.dump_event_map()
        entA.push_event('etest', Table(a=1, b=2, d='dtest'))

    def test1(self):
        """
        entA监听entB的事件，entB触发事件
        """

        @logger
        def handle_event_etest(dtest):
            pass

        entA = EntityScript()
        entB = EntityScript()
        entA.listen_for_event('etest', handle_event_etest, entB)
        entA.dump_event_map()
        entB.dump_event_map()
        entB.push_event('etest', Table(a=1, b=2, d='dtest'))

    def test_destroy(self):
        """
        测试销毁ent后事件系统是否正常
        # @zoloypzuo [2020-09-17 11:50:49.818000][Default] dump_event_map[
        #     "<entityscript.EntityScript object at 0x03C2EAF0>"
        # ]{} -> [
        #     {
        #         "etest": {
        #             "<entityscript.EntityScript object at 0x03C2EAD0>": [
        #                 "<function handle_event_etest at 0x03C49170>"
        #             ]
        #         }
        #     },
        #     {}
        # ]
        # @zoloypzuo [2020-09-17 11:50:49.823000][Default] dump_event_map[
        #     "<entityscript.EntityScript object at 0x03C2EAD0>"
        # ]{} -> [
        #     {},
        #     {
        #         "etest": {
        #             "<entityscript.EntityScript object at 0x03C2EAF0>": [
        #                 "<function handle_event_etest at 0x03C49170>"
        #             ]
        #         }
        #     }
        # ]
        # @zoloypzuo [2020-09-17 11:50:49.823000][Default] dump_event_map[
        #     "<entityscript.EntityScript object at 0x03C2EAD0>"
        # ]{} -> [
        #     {},
        #     {
        #         "etest": {
        #             "<entityscript.EntityScript object at 0x03C2EAF0>": [
        #                 "<function handle_event_etest at 0x03C49170>"
        #             ]
        #         }
        #     }
        # ]
        # @zoloypzuo [2020-09-17 11:50:49.824000][Default] handle_event_etest[
        #     "Table{'a': 1, 'b': 2, 'd': 'dtest'}"
        # ]{}
        :return:
        """

        @logger
        def handle_event_etest(dtest):
            pass

        set_enable_pretty_print(True)
        entA = EntityScript()
        entB = EntityScript()
        entA.listen_for_event('etest', handle_event_etest, entB)
        entA.dump_event_map()
        entB.dump_event_map()
        entB.dump_event_map()
        entB.push_event('etest', Table(a=1, b=2, d='dtest'))
        entA.remove_all_event_callbacks()
        set_enable_pretty_print(False)

    def test_remove_all_event_callbacks(self):
        """
        # @zoloypzuo [2020-09-17 13:01:44.022000][Default] dump_event_map[
        #     "<entityscript.EntityScript object at 0x03470B10>"
        # ]{} -> [
        #     {
        #         "etest": {
        #             "<entityscript.EntityScript object at 0x03470AF0>": [
        #                 "<function handle_event_etest at 0x0347A2F0>"
        #             ]
        #         }
        #     },
        #     {}
        # ]
        # @zoloypzuo [2020-09-17 13:01:44.027000][Default] dump_event_map[
        #     "<entityscript.EntityScript object at 0x03470AF0>"
        # ]{} -> [
        #     {},
        #     {
        #         "etest": {
        #             "<entityscript.EntityScript object at 0x03470B10>": [
        #                 "<function handle_event_etest at 0x0347A2F0>"
        #             ]
        #         }
        #     }
        # ]
        # @zoloypzuo [2020-09-17 13:01:44.028000][Default] handle_event_etest[
        #     "Table{'a': 1, 'b': 2, 'd': 'dtest'}"
        # ]{}
        # @zoloypzuo [2020-09-17 13:01:44.028000][Default] dump_event_map[
        #     "<entityscript.EntityScript object at 0x03470B10>"
        # ]{} -> [
        #     {},
        #     {}
        # ]
        # @zoloypzuo [2020-09-17 13:01:44.028000][Default] dump_event_map[
        #     "<entityscript.EntityScript object at 0x03470AF0>"
        # ]{} -> [
        #     {},
        #     {
        #         "etest": {}
        #     }
        # ]
        :return:
        """

        @logger
        def handle_event_etest(dtest):
            pass

        set_enable_pretty_print(True)
        entA = EntityScript()
        entB = EntityScript()
        entA.listen_for_event('etest', handle_event_etest, entB)
        entA.dump_event_map()
        entB.dump_event_map()
        entB.push_event('etest', Table(a=1, b=2, d='dtest'))
        entA.remove_all_event_callbacks()
        entA.dump_event_map()
        entB.dump_event_map()
        set_enable_pretty_print(False)

    def test_remove_event_callback(self):
        """
        # @zoloypzuo [2020-09-17 13:03:12.172000][Default] dump_event_map[
        #     "<entityscript.EntityScript object at 0x036B1B70>"
        # ]{} -> [
        #     {
        #         "etest": {
        #             "<entityscript.EntityScript object at 0x036B1B50>": [
        #                 "<function handle_event_etest at 0x036A91B0>"
        #             ]
        #         }
        #     },
        #     {}
        # ]
        # @zoloypzuo [2020-09-17 13:03:12.178000][Default] dump_event_map[
        #     "<entityscript.EntityScript object at 0x036B1B50>"
        # ]{} -> [
        #     {},
        #     {
        #         "etest": {
        #             "<entityscript.EntityScript object at 0x036B1B70>": [
        #                 "<function handle_event_etest at 0x036A91B0>"
        #             ]
        #         }
        #     }
        # ]
        # @zoloypzuo [2020-09-17 13:03:12.178000][Default] handle_event_etest[
        #     "Table{'a': 1, 'b': 2, 'd': 'dtest'}"
        # ]{}
        # @zoloypzuo [2020-09-17 13:03:12.178000][Default] dump_event_map[
        #     "<entityscript.EntityScript object at 0x036B1B70>"
        # ]{} -> [
        #     {},
        #     {}
        # ]
        # @zoloypzuo [2020-09-17 13:03:12.178000][Default] dump_event_map[
        #     "<entityscript.EntityScript object at 0x036B1B50>"
        # ]{} -> [
        #     {},
        #     {}
        # ]
        :return:
        """

        @logger
        def handle_event_etest(dtest):
            pass

        set_enable_pretty_print(True)
        entA = EntityScript()
        entB = EntityScript()
        entA.listen_for_event('etest', handle_event_etest, entB)
        entA.dump_event_map()
        entB.dump_event_map()
        entB.push_event('etest', Table(a=1, b=2, d='dtest'))
        entA.remove_event_callback('etest', handle_event_etest, entB)
        entA.dump_event_map()
        entB.dump_event_map()
        set_enable_pretty_print(False)

    def test_simple(self):
        from common.ztable import Table
        # ---------------------------------------------------
        # basic
        # ---------------------------------------------------
        # {'a': 1, 'b': 2}

        def handle_event_c(dataD):
            print dataD

        entA = EntityScript()
        entB = EntityScript()
        # dataD = {'a': 1, 'b': 2}
        dataD = Table(a=1, b=2)
        entA.listen_for_event('event-c', handle_event_c)
        entA.push_event('event-c', dataD)
        # ---------------------------------------------------
        # push to sg
        # ---------------------------------------------------
        # Table{'a': 1, 'b': 2}
        # event_handle_event_c_in_state_none(EntityScript, Table{'a': 1, 'state': 'none', 'b': 2})
        # event_handle_event_c_in_sg(EntityScript, Table{'a': 1, 'state': 'none', 'b': 2})
        entA.set_stategraph('SG_test')
        entA.push_event('event-c', dataD)
        entA.sg.handle_events()


if __name__ == '__main__':
    unittest.main()
