# coding=utf-8
# zinput.py
# created on 2020/9/27
# author @zoloypzuo
# usage: zinput

import inputs

from common.zlogger import logger_tail, logger
from interfaces.runtime import IRuntimeModule

EVENT_ABB = (
    # D-PAD, aka HAT
    ('Absolute-ABS_HAT0X', 'HX'),
    ('Absolute-ABS_HAT0Y', 'HY'),

    # Face Buttons
    ('Key-BTN_NORTH', 'N'),
    ('Key-BTN_EAST', 'E'),
    ('Key-BTN_SOUTH', 'S'),
    ('Key-BTN_WEST', 'W'),

    # Other buttons
    ('Key-BTN_THUMBL', 'THL'),
    ('Key-BTN_THUMBR', 'THR'),
    ('Key-BTN_TL', 'TL'),
    ('Key-BTN_TR', 'TR'),
    ('Key-BTN_TL2', 'TL2'),
    ('Key-BTN_TR2', 'TR3'),
    ('Key-BTN_MODE', 'M'),
    ('Key-BTN_START', 'ST'),

    # PiHUT SNES style controller buttons
    ('Key-BTN_TRIGGER', 'N'),
    ('Key-BTN_THUMB', 'E'),
    ('Key-BTN_THUMB2', 'S'),
    ('Key-BTN_TOP', 'W'),
    ('Key-BTN_BASE3', 'SL'),
    ('Key-BTN_BASE4', 'ST'),
    ('Key-BTN_TOP2', 'TL'),
    ('Key-BTN_PINKIE', 'TR')
)

EVENT_ABB = dict(EVENT_ABB)


class EventHandler(object):
    def __init__(self, event, fn, processor):
        super(EventHandler, self).__init__()
        self.event = event
        self.fn = fn
        self.processor = processor

    def remove(self):
        self.processor.remove_handler(self)


class EventProcessor(object):
    def __init__(self):
        super(EventProcessor, self).__init__()
        self.events = {}

    def add_event_handler(self, event, fn):
        handler = EventHandler(event, fn, self)
        if event not in self.events:
            self.events[event] = set()
        self.events[event].add(handler)
        return handler

    def remove_handler(self, handler):
        if not handler:
            return
        ev = self.events.get(handler.event, None)
        ev.discard(handler)

    def get_handlers_for_event(self, event):
        return self.events.get(event, set())

    def handle_event(self, event, *args, **kwargs):
        handlers = self.events.get(event, None)
        if not handlers:
            return
        for handler in handlers:
            handler.fn(*args, **kwargs)


class Input(object, IRuntimeModule):
    def __init__(self):
        super(Input, self).__init__()
        # TODO
        # self.keyboard = KeyboardInput()
        # self.mouse = MouseInput()
        self.gamepad = GamepadInput()
        self.dump_devices()

        self.on_control = EventProcessor()

    @logger_tail
    def dump_devices(self):
        """
        打印所有输入设备
        :return:
        """
        devices = list(map(str, inputs.devices))
        return "We have detected the following devices:\n%s" % "\n".join(devices)

    # ---------------------------------------------------
    # gamepad
    # ---------------------------------------------------
    @logger_tail
    def is_control_pressed(self, control):
        """
        get digital control
        :param control:
        :return:
        """
        return self.gamepad.get_button_state(control)

    # @logger_tail
    # def get_control_up(self, control):
    #     return self._gamepad.get_button_up(control)
    #
    # @logger_tail
    # def get_control_down(self, control):
    #     return self._gamepad.get_button_down(control)

    @logger_tail
    def get_analog_control_value(self, control):
        """
        get analog control
        :param control:
        :return:
        """

    def add_control_handler(self, control, fn):
        self.gamepad.add_control_handler(control, fn)

    # ---------------------------------------------------
    # IRuntimeModule
    # ---------------------------------------------------
    def initialize(self):
        pass

    def finalize(self):
        pass

    def update(self):
        self.gamepad.update()
        # self.mouse.update()
        # self.keyboard.update()

    # ---------------------------------------------------
    # meta
    # ---------------------------------------------------

    def __str__(self):
        return '<Input>'

    __repr__ = __str__


class GamepadInput(object):
    """
    A1:0.0
    A0:-1.0
    HX:0
    HY:0
    TL2:0
    E:0
    M:0
    TR:0
    S:0
    THR:0
    N:0
    TL:0
    THL:0
    W:0
    SL:0
    TR3:0
    ST:0
    """

    def __init__(self, gamepad=None, abbrevs=None):
        super(GamepadInput, self).__init__()

        self._gamepad_states = {}
        self._btn_state = {}
        self._btn_up = {}
        self._btn_down = {}
        self._abs_state = {}

        self._abbrevs = abbrevs or EVENT_ABB
        for key, value in self._abbrevs.items():
            if key.startswith('Absolute'):
                self._abs_state[value] = 0
            if key.startswith('Key'):
                self._btn_state[value] = 0
        self._other = 0
        try:
            self._gamepad = gamepad or self._get_gamepad()  # type: inputs.GamePad
        except:
            self._gamepad = None

        self._on_control = EventProcessor()

    def add_control_handler(self, control, fn):
        return self._on_control.add_event_handler(control, fn)

    def get_button_state(self, button):
        return self._btn_state.get(button, 0)

    # def get_button_up(self, button):
    #     return self._btn_up.get(button, 0)
    #
    # def get_button_down(self, button):
    #     return self._btn_down.get(button, 0)

    def get_abs_state(self, abs_):
        return self._abs_state.get(abs_, 0)

    def get_gamepad_states(self, code):
        return self._gamepad_states.get(code, 0.)

    def update(self):
        """
        process events
        :return:
        """
        if not self._gamepad:
            return
        # 替代阻塞的read接口
        self._gamepad._GamePad__check_state()
        events = self._gamepad._do_iter()
        # events = self._gamepad.read()
        if not events:
            return
        for event in events:
            self.process_event(event)

    def _get_gamepad(self):
        """Get a gamepad object."""
        try:
            return inputs.devices.gamepads[0]
        except IndexError:
            raise inputs.UnpluggedError("No gamepad found.")

    def handle_unknown_event(self, event, key):
        """Deal with unknown events."""
        if event.ev_type == 'Key':
            new_abbv = 'B' + str(self._other)
            self._btn_state[new_abbv] = 0
        elif event.ev_type == 'Absolute':
            new_abbv = 'A' + str(self._other)
            self._abs_state[new_abbv] = 0
        else:
            return None

        self._abbrevs[key] = new_abbv
        self._other += 1

        return self._abbrevs[key]

    def process_event(self, event):
        """Process the event into a state."""
        if event.ev_type == 'Sync':
            return
        if event.ev_type == 'Misc':
            return
        # print event.ev_type, event.code, event.state
        key = event.ev_type + '-' + event.code
        try:
            abbv = self._abbrevs[key]
        except KeyError:
            abbv = self.handle_unknown_event(event, key)
            if not abbv:
                return

        if event.ev_type == 'Key':
            btn_state = event.state
            # btn_state_old = self._btn_state[abbv]
            # print btn_state, btn_state_old
            self._btn_state[abbv] = btn_state
            if btn_state:
                self._on_control.handle_event('button-down', abbv)
            else:
                self._on_control.handle_event('button-up', abbv)
            # changed = btn_state ^ btn_state_old
            # up = changed & ~btn_state
            # down = changed & btn_state
            # print changed, up, down
            # self._btn_up[abbv] = up
            # self._btn_down[abbv] = down
        if event.ev_type == 'Absolute':
            if event.code.startswith("ABS_R"):
                state = event.state / 32768.
                if event.code == "ABS_RX":
                    # normalized to 1
                    self._on_control.handle_event("rx", state)
                    self._abs_state[abbv] = state
                elif event.code == "ABS_RY":
                    self._on_control.handle_event("ry", state)
                    self._abs_state[abbv] = state
            else:
                self._abs_state[abbv] = event.state
            if event.code in {"ABS_RX", "ABS_RY", "ABS_X", "ABS_Y"}:
                self._gamepad_states[event.code] = event.state / 32768.
            elif event.code in {"ABS_Z", "ABS_RZ"}:
                self._gamepad_states[event.code] = event.state / 255.
        # self.output_state(event.ev_type, abbv)

    # ---------------------------------------------------
    # print
    # ---------------------------------------------------
    def format_state(self):
        """Format the state."""
        output_string = ""
        for key, value in self._abs_state.items():
            output_string += key + ':' + '{:>4}'.format(str(value) + ' ')

        for key, value in self._btn_state.items():
            output_string += key + ':' + str(value) + ' '

        return output_string

    def output_state(self, ev_type, abbv):
        """Print out the output state."""
        if ev_type == 'Key':
            print(self.format_state())
        elif abbv[0] == 'H':
            print(self.format_state())
        else:
            print(self.format_state())

    # ---------------------------------------------------
    # vibrate
    # ---------------------------------------------------
    def vibrate(self, left_motor, right_motor, duration):
        """
        控制手柄的左右两个电机进行震动，持续一段时间
        :param left_motor: 0 (off) ~ 1 (full).
        :param right_motor: 0 (off) ~ 1 (full).
        :param duration: duration is milliseconds, e.g. 1000 for a second.
        :return:
        """
        self._gamepad.set_vibration(left_motor, right_motor, duration)


class KeyboardInput(object):
    """
    KEYS_AND_BUTTONS = (
    (0, "KEY_RESERVED"),
    (1, "KEY_ESC"),
    (2, "KEY_1"),
    (3, "KEY_2"),
    (4, "KEY_3"),
    (5, "KEY_4"),
    (6, "KEY_5"),
    (7, "KEY_6"),
    (8, "KEY_7"),
    (9, "KEY_8"),
    (10, "KEY_9"),
    (11, "KEY_0"),
    (12, "KEY_MINUS"),
    (13, "KEY_EQUAL"),
    (14, "KEY_BACKSPACE"),
    (15, "KEY_TAB"),
    (16, "KEY_Q"),
    (17, "KEY_W"),
    (18, "KEY_E"),
    (19, "KEY_R"),
    (20, "KEY_T"),
    (21, "KEY_Y"),
    (22, "KEY_U"),
    (23, "KEY_I"),
    (24, "KEY_O"),
    (25, "KEY_P"),
    (26, "KEY_LEFTBRACE"),
    (27, "KEY_RIGHTBRACE"),
    (28, "KEY_ENTER"),
    (29, "KEY_LEFTCTRL"),
    (30, "KEY_A"),
    (31, "KEY_S"),
    (32, "KEY_D"),
    (33, "KEY_F"),
    (34, "KEY_G"),
    (35, "KEY_H"),
    (36, "KEY_J"),
    (37, "KEY_K"),
    (38, "KEY_L"),
    (39, "KEY_SEMICOLON"),
    (40, "KEY_APOSTROPHE"),
    (41, "KEY_GRAVE"),
    (42, "KEY_LEFTSHIFT"),
    (43, "KEY_BACKSLASH"),
    (44, "KEY_Z"),
    (45, "KEY_X"),
    (46, "KEY_C"),
    (47, "KEY_V"),
    (48, "KEY_B"),
    (49, "KEY_N"),
    (50, "KEY_M"),
    (51, "KEY_COMMA"),
    (52, "KEY_DOT"),
    (53, "KEY_SLASH"),
    (54, "KEY_RIGHTSHIFT"),
    (55, "KEY_KPASTERISK"),
    (56, "KEY_LEFTALT"),
    (57, "KEY_SPACE"),
    (58, "KEY_CAPSLOCK"),
    (59, "KEY_F1"),
    (60, "KEY_F2"),
    (61, "KEY_F3"),
    (62, "KEY_F4"),
    (63, "KEY_F5"),
    (64, "KEY_F6"),
    (65, "KEY_F7"),
    (66, "KEY_F8"),
    (67, "KEY_F9"),
    (68, "KEY_F10"),
    (69, "KEY_NUMLOCK"),
    (70, "KEY_SCROLLLOCK"),
    (71, "KEY_KP7"),
    (72, "KEY_KP8"),
    (73, "KEY_KP9"),
    (74, "KEY_KPMINUS"),
    (75, "KEY_KP4"),
    (76, "KEY_KP5"),
    (77, "KEY_KP6"),
    (78, "KEY_KPPLUS"),
    (79, "KEY_KP1"),
    (80, "KEY_KP2"),
    (81, "KEY_KP3"),
    (82, "KEY_KP0"),
    (83, "KEY_KPDOT"),
    (85, "KEY_ZENKAKUHANKAKU"),
    (86, "KEY_102ND"),
    (87, "KEY_F11"),
    (88, "KEY_F12"),
    (89, "KEY_RO"),
    (90, "KEY_KATAKANA"),
    (91, "KEY_HIRAGANA"),
    (92, "KEY_HENKAN"),
    (93, "KEY_KATAKANAHIRAGANA"),
    (94, "KEY_MUHENKAN"),
    (95, "KEY_KPJPCOMMA"),
    (96, "KEY_KPENTER"),
    (97, "KEY_RIGHTCTRL"),
    (98, "KEY_KPSLASH"),
    (99, "KEY_SYSRQ"),
    (100, "KEY_RIGHTALT"),
    (101, "KEY_LINEFEED"),
    (102, "KEY_HOME"),
    (103, "KEY_UP"),
    (104, "KEY_PAGEUP"),
    (105, "KEY_LEFT"),
    (106, "KEY_RIGHT"),
    (107, "KEY_END"),
    (108, "KEY_DOWN"),
    (109, "KEY_PAGEDOWN"),
    (110, "KEY_INSERT"),
    (111, "KEY_DELETE"),
    (112, "KEY_MACRO"),
    (113, "KEY_MUTE"),
    (114, "KEY_VOLUMEDOWN"),
    (115, "KEY_VOLUMEUP"),
    (116, "KEY_POWER"),  # SC System Power Down
    (117, "KEY_KPEQUAL"),
    (118, "KEY_KPPLUSMINUS"),
    (119, "KEY_PAUSE"),
    (120, "KEY_SCALE"),  # AL Compiz Scale (Expose)
    (121, "KEY_KPCOMMA"),
    (122, "KEY_HANGEUL"),
    (123, "KEY_HANJA"),
    (124, "KEY_YEN"),
    (125, "KEY_LEFTMETA"),
    (126, "KEY_RIGHTMETA"),
    (127, "KEY_COMPOSE"),
    (128, "KEY_STOP"),  # AC Stop
    (129, "KEY_AGAIN"),
    (130, "KEY_PROPS"),  # AC Properties
    (131, "KEY_UNDO"),  # AC Undo
    (132, "KEY_FRONT"),
    (133, "KEY_COPY"),  # AC Copy
    (134, "KEY_OPEN"),  # AC Open
    (135, "KEY_PASTE"),  # AC Paste
    (136, "KEY_FIND"),  # AC Search
    (137, "KEY_CUT"),  # AC Cut
    (138, "KEY_HELP"),  # AL Integrated Help Center
    (139, "KEY_MENU"),  # Menu (show menu)
    (140, "KEY_CALC"),  # AL Calculator
    (141, "KEY_SETUP"),
    (142, "KEY_SLEEP"),  # SC System Sleep
    (143, "KEY_WAKEUP"),  # System Wake Up
    (144, "KEY_FILE"),  # AL Local Machine Browser
    (145, "KEY_SENDFILE"),
    (146, "KEY_DELETEFILE"),
    (147, "KEY_XFER"),
    (148, "KEY_PROG1"),
    (149, "KEY_PROG2"),
    (150, "KEY_WWW"),  # AL Internet Browser
    (151, "KEY_MSDOS"),
    (152, "KEY_COFFEE"),  # AL Terminal Lock/Screensaver
    (153, "KEY_ROTATE_DISPLAY"),  # Display orientation for e.g. tablets
    (154, "KEY_CYCLEWINDOWS"),
    (155, "KEY_MAIL"),
    (156, "KEY_BOOKMARKS"),  # AC Bookmarks
    (157, "KEY_COMPUTER"),
    (158, "KEY_BACK"),  # AC Back
    (159, "KEY_FORWARD"),  # AC Forward
    (160, "KEY_CLOSECD"),
    (161, "KEY_EJECTCD"),
    (162, "KEY_EJECTCLOSECD"),
    (163, "KEY_NEXTSONG"),
    (164, "KEY_PLAYPAUSE"),
    (165, "KEY_PREVIOUSSONG"),
    (166, "KEY_STOPCD"),
    (167, "KEY_RECORD"),
    (168, "KEY_REWIND"),
    (169, "KEY_PHONE"),  # Media Select Telephone
    (170, "KEY_ISO"),
    (171, "KEY_CONFIG"),  # AL Consumer Control Configuration
    (172, "KEY_HOMEPAGE"),  # AC Home
    (173, "KEY_REFRESH"),  # AC Refresh
    (174, "KEY_EXIT"),  # AC Exit
    (175, "KEY_MOVE"),
    (176, "KEY_EDIT"),
    (177, "KEY_SCROLLUP"),
    (178, "KEY_SCROLLDOWN"),
    (179, "KEY_KPLEFTPAREN"),
    (180, "KEY_KPRIGHTPAREN"),
    (181, "KEY_NEW"),  # AC New
    (182, "KEY_REDO"),  # AC Redo/Repeat
    (183, "KEY_F13"),
    (184, "KEY_F14"),
    (185, "KEY_F15"),
    (186, "KEY_F16"),
    (187, "KEY_F17"),
    (188, "KEY_F18"),
    (189, "KEY_F19"),
    (190, "KEY_F20"),
    (191, "KEY_F21"),
    (192, "KEY_F22"),
    (193, "KEY_F23"),
    (194, "KEY_F24"),
    (200, "KEY_PLAYCD"),
    (201, "KEY_PAUSECD"),
    (202, "KEY_PROG3"),
    (203, "KEY_PROG4"),
    (204, "KEY_DASHBOARD"),  # AL Dashboard
    (205, "KEY_SUSPEND"),
    (206, "KEY_CLOSE"),  # AC Close
    (207, "KEY_PLAY"),
    (208, "KEY_FASTFORWARD"),
    (209, "KEY_BASSBOOST"),
    (210, "KEY_PRINT"),  # AC Print
    (211, "KEY_HP"),
    (212, "KEY_CAMERA"),
    (213, "KEY_SOUND"),
    (214, "KEY_QUESTION"),
    (215, "KEY_EMAIL"),
    (216, "KEY_CHAT"),
    (217, "KEY_SEARCH"),
    (218, "KEY_CONNECT"),
    (219, "KEY_FINANCE"),  # AL Checkbook/Finance
    (220, "KEY_SPORT"),
    (221, "KEY_SHOP"),
    (222, "KEY_ALTERASE"),
    (223, "KEY_CANCEL"),  # AC Cancel
    (224, "KEY_BRIGHTNESSDOWN"),
    (225, "KEY_BRIGHTNESSUP"),
    (226, "KEY_MEDIA"),
    (227, "KEY_SWITCHVIDEOMODE"),  # Cycle between available video
    (228, "KEY_KBDILLUMTOGGLE"),
    (229, "KEY_KBDILLUMDOWN"),
    (230, "KEY_KBDILLUMUP"),
    (231, "KEY_SEND"),  # AC Send
    (232, "KEY_REPLY"),  # AC Reply
    (233, "KEY_FORWARDMAIL"),  # AC Forward Msg
    (234, "KEY_SAVE"),  # AC Save
    (235, "KEY_DOCUMENTS"),
    (236, "KEY_BATTERY"),
    (237, "KEY_BLUETOOTH"),
    (238, "KEY_WLAN"),
    (239, "KEY_UWB"),
    (240, "KEY_UNKNOWN"),
    (241, "KEY_VIDEO_NEXT"),  # drive next video source
    (242, "KEY_VIDEO_PREV"),  # drive previous video source
    (243, "KEY_BRIGHTNESS_CYCLE"),  # brightness up, after max is min
    (244, "KEY_BRIGHTNESS_AUTO"),  # Set Auto Brightness: manual
    (245, "KEY_DISPLAY_OFF"),  # display device to off state
    (246, "KEY_WWAN"),  # Wireless WAN (LTE, UMTS, GSM, etc.)
    (247, "KEY_RFKILL"),  # Key that controls all radios
    (248, "KEY_MICMUTE"),  # Mute / unmute the microphone
    """
    def __init__(self):
        super(KeyboardInput, self).__init__()
        self._keyboard = inputs.devices.keyboards[0] # type: inputs.Keyboard
        self.key_states = {}

    def update(self):
        if not self._keyboard:
            return
        try:
            events = self._keyboard._do_iter()
        except EOFError:
            print "EOFError"
            events = []
        for event in events:
            self.process_event(event)

    def process_event(self, event):
        if event.ev_type == "Key":
            # print event.ev_type, event.code, event.state
            self.key_states[event.code] = event.state


class MouseInput(object):
    """
    鼠标移动
    xy分开，记录屏幕坐标
    Absolute ABS_X 1708
    Absolute ABS_Y 43

    鼠标滚轮
    Relative REL_WHEEL -1

    鼠标按钮
    Key BTN_LEFT 1
    Key BTN_RIGHT 1
    Key BTN_MIDDLE 1
    """
    def __init__(self):
        super(MouseInput, self).__init__()
        self._mouse = inputs.devices.mice[0] # type: inputs.Mouse
        self.mouse_states = {}

    def update(self):
        if not self._mouse:
            return
        try:
            events = self._mouse.read()
        except EOFError:
            events = []
        for event in events:
            self.process_event(event)

    def process_event(self, event):
        if event.ev_type in {"Absolute", "Relative", "Key"}:
            # print event.ev_type, event.code, event.state
            self.mouse_states[event.code] = event.state


def test_input():
    inputm = Input()


    @logger
    def handle_up(btn):
        pass


    inputm.add_control_handler('button-up', handle_up)
    while True:
        inputm.update()

    # sleep to avoid thread problem
    # Unhandled exception in thread started by
    # sys.excepthook is missing
    # lost sys.stderr
    # time.sleep(30)

def test_keyboard():
    keyboard_input = KeyboardInput()
    while True:
        keyboard_input.update()

def test_gamepad():
    gamepad_input = GamepadInput()
    import time
    while True:
        gamepad_input.update()
        time.sleep(1./1)

if __name__ == '__main__':
    # test_keyboard()
    test_gamepad()

