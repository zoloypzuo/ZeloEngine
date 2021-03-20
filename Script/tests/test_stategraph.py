import unittest
from unittest import TestCase

from entityscript import EntityScript


class TestStateGraphInstance(unittest.TestCase):
    def setUp(self):
        from framework.zmain import add_to_scene
        self.ent = EntityScript()
        self.ent.set_stategraph('SG_test')
        add_to_scene(self.ent)

    def tearDown(self):
        from framework.zmain import main
        main()

    def test_tag(self):
        ent = EntityScript()
        ent.set_stategraph('SG_test')
        ent.sg.add_state_tag('tag_test')
        ent.sg.has_state_tag('tag_test')
        ent.sg.remove_stat_tag('tag_test')
        ent.sg.has_state_tag('tag_test')

    def test_go_to_state(self):
        """
        # [12:02:51][Default] add_instance(<stategraph.StateGraphWrangler object at 0x03193B50>, StateGraphInstance(51881264, 'room', 'un_init', 1600660971.61, []))
        # [12:02:51][Default] go_to_state(StateGraphInstance(51881264, 'room', 'un_init', 1600660971.61, []), 'none')
        # [12:02:51][Default] on_enter(EntityScript(51880432,), ())
        # [12:02:51][Default] push_event(EntityScript(51880432,), 'new_state', Table{'state_name': 'none'})
        # [12:02:51][Default] is_listening_for_event(StateGraphInstance(51881264, 'room', 'none', 1600660971.61, []), 'new_state') -> False
        # [12:02:51][Default] on_enter_new_state(<stategraph.StateGraphWrangler object at 0x03193B50>, StateGraphInstance(51881264, 'room', 'none', 0.0, []))
        # [12:02:51][Default] add_instance(<stategraph.StateGraphWrangler object at 0x03193B50>, StateGraphInstance(51882864, 'room', 'un_init', 1600660971.61, []))
        # [12:02:51][Default] go_to_state(StateGraphInstance(51882864, 'room', 'un_init', 1600660971.61, []), 'none')
        # [12:02:51][Default] on_enter(EntityScript(51882800,), ())
        # [12:02:51][Default] push_event(EntityScript(51882800,), 'new_state', Table{'state_name': 'none'})
        # [12:02:51][Default] is_listening_for_event(StateGraphInstance(51882864, 'room', 'none', 1600660971.62, []), 'new_state') -> False
        # [12:02:51][Default] on_enter_new_state(<stategraph.StateGraphWrangler object at 0x03193B50>, StateGraphInstance(51882864, 'room', 'none', 0.0, []))
        # [12:02:51][Default] push_event(EntityScript(51882800,), 'go_to_run')
        # [12:02:51][Default] is_listening_for_event(StateGraphInstance(51882864, 'room', 'none', 0.0, []), 'go_to_run') -> True
        # [12:02:51][Default] on_push_event(<stategraph.StateGraphWrangler object at 0x03193B50>, StateGraphInstance(51882864, 'room', 'none', 0.0, [])) -> True
        # [12:02:51][Default] push_event(StateGraphInstance(51882864, 'room', 'none', 0.0, []), 'go_to_run', None)
        # [12:02:51][Default] handle_event(none, StateGraphInstance(51882864, 'room', 'none', 0.0, []), 'go_to_run', Table{'state': 'none'}) -> False
        # [12:02:51][Default] test(EntityScript(51882800,), Table{'state': 'none'})
        # [12:02:51][Default] go_to_state(StateGraphInstance(51882864, 'room', 'none', 0.0, []), 'run')
        # [12:02:51][Default] on_exit(EntityScript(51882800,), 'run')
        # [12:02:51][Default] push_event(EntityScript(51882800,), 'new_state', Table{'state_name': 'run'})
        # [12:02:51][Default] is_listening_for_event(StateGraphInstance(51882864, 'room', 'run', 0.0, []), 'new_state') -> False
        # [12:02:51][Default] on_enter_new_state(<stategraph.StateGraphWrangler object at 0x03193B50>, StateGraphInstance(51882864, 'room', 'run', 0.0, []))
        # [12:02:51][Default] return_to_scene(EntityScript(51880432,))
        # [12:02:51][Default] start(StateGraphInstance(51881264, 'room', 'none', 0.01, []))
        # [12:02:51][Default] add_instance(<stategraph.StateGraphWrangler object at 0x03193B50>, StateGraphInstance(51881264, 'room', 'none', 0.01, []))
        :return:
        """
        self.ent.push_event('go_to_run')

    def test_start_stop_update(self):
        """

# [12:34:28][Default] add_instance(<stategraph.StateGraphWrangler object at 0x02E03B50>, StateGraphInstance(48141616, 'room', 'un_init', 1600662868.34, []))
# [12:34:28][Default] go_to_state(StateGraphInstance(48141616, 'room', 'un_init', 1600662868.34, []), 'none')
# [12:34:28][Default] on_enter(EntityScript(48140784,), ())
# [12:34:28][Default] push_event(EntityScript(48140784,), 'new_state', Table{'state_name': 'none'})
# [12:34:28][Default] is_listening_for_event(StateGraphInstance(48141616, 'room', 'none', 1600662868.34, []), 'new_state') -> False
# [12:34:28][Default] on_enter_new_state(<stategraph.StateGraphWrangler object at 0x02E03B50>, StateGraphInstance(48141616, 'room', 'none', 0.0, []))
# [12:34:28][Default] return_to_scene(EntityScript(48140784,))
# [12:34:28][Default] start(StateGraphInstance(48141616, 'room', 'none', 0.0, []))
# [12:34:28][Default] add_instance(<stategraph.StateGraphWrangler object at 0x02E03B50>, StateGraphInstance(48141616, 'room', 'none', 0.0, []))
# [12:34:28][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:28][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:28][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:28][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:28][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:28][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:28][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:28][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:28][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:28][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:28][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:28][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:28][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:28][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:28][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:28][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:28][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:28][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:28][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:28][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:29][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:29][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:29][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:29][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:29][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:29][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:29][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:29][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:29][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:29][Default] on_update(EntityScript(48140784,), 0.03333333333333333)
# [12:34:29][Default] remove_from_scene(EntityScript(48140784,))
# [12:34:29][Default] stop(StateGraphInstance(48141616, 'room', 'none', 1.01, []))
# [12:34:29][Default] remove_instance(<stategraph.StateGraphWrangler object at 0x02E03B50>, StateGraphInstance(48141616, 'room', 'none', 1.01, []))
# [12:34:29][Default] remove_instance(<stategraph.StateGraphWrangler object at 0x02E03B50>, StateGraphInstance(48141616, 'room', 'none', 1.01, []))
# [12:34:29][Default] on_remove_entity(<stategraph.StateGraphWrangler object at 0x02E03B50>, EntityScript(48140784,))
# [12:34:29][Default] remove_instance(<stategraph.StateGraphWrangler object at 0x02E03B50>, None)
        :return:
        """
        pass


class TestTimeEvent(TestCase):
    pass


if __name__ == '__main__':
    unittest.main()
