# coding=utf-8
# app.py
# created on 2020/9/25
# author @zoloypzuo
# usage: app
from OpenGL.GLUT import *

import G
from common.zlogger import logger, logger_tail
from interfaces.runtime import IRuntimeModule


class App(object, IRuntimeModule):
    """
    Attributes:
        title:
        height:
        width:
        dt:
        space_step: 按空格键步进

    Callbacks:
        on_initialize: app init
        on_finalize: app shutdown
        on_update: update game logic
        on_render: render the frame
        on_resize: resize screen
        on_mouse:
        on_keyboard:
        on_motion:
    """

    def __init__(self):
        super(App, self).__init__()

        # ---------------------------------------------------
        # config
        # ---------------------------------------------------
        self.enable_lock_fps = False
        self.title = sys.argv[1] if len(sys.argv) > 1 else sys.argv[0]
        self.width = 640
        self.height = 320
        self.init_window_position = (0, 0)
        self.dt = 1.0 / 30
        self.enable_objgraph = False

        # ---------------------------------------------------
        # graphics
        # ---------------------------------------------------
        # GLUT_RGB
        # GLUT_SINGLE
        self.display_flag = GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH

        # ---------------------------------------------------
        # debug
        # ---------------------------------------------------
        self.space_step = False  # 按空格键步进
        # ---------------------------------------------------
        # singleton
        # ---------------------------------------------------
        assert not G.appm, "duplicate singleton app"
        G.appm = self
        # ---------------------------------------------------
        # callbacks
        # ---------------------------------------------------
        self.on_initialize = getattr(self, 'on_initialize', None)
        self.on_finalize = getattr(self, 'on_finalize', None)
        self.on_update = getattr(self, 'on_update', None)
        self.on_render = getattr(self, 'on_render', None)
        self.on_resize = getattr(self, 'on_resize', None)
        self.on_mouse = getattr(self, 'on_mouse', None)
        self.on_keyboard = getattr(self, 'on_keyboard', None)
        self.on_motion = getattr(self, 'on_motion', None)


    @property
    @logger_tail
    def aspect_ratio(self):
        self.height = self.height if self.height else 1
        return float(self.width) / self.height

    # ---------------------------------------------------
    # init, finalize, update, render
    # ---------------------------------------------------
    @logger
    def main(self):
        """
        main
        :return:
        """

        glutMainLoop()
        raise RuntimeError("unreachable")

    @logger
    def initialize(self):
        def init_():
            if self.enable_objgraph:
                import objgraph
                objgraph.show_growth()
            glutInit(sys.argv)

        @logger
        def init_window():
            # glutInitDisplayMode(self.display_flag)
            glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGBA | GLUT_DEPTH)
            self.log(glutInitDisplayMode=(GLUT_DOUBLE , GLUT_RGBA , GLUT_DEPTH))
            glutInitWindowSize(self.width, self.height)
            glutInitWindowPosition(*self.init_window_position)
            glutCreateWindow(self.title)

        @logger
        def init_callbacks():
            # ---------------------------------------------------
            # glut回调函数 C++ doc
            # ---------------------------------------------------
            #
            # void glutDisplayFunc(void (*func)(void));
            # 注册当前窗口的显示回调函数
            #
            # 参数:  func:形为void func()的函数,完成具体的绘制操作
            # 这个函数告诉GLUT当窗口内容必须被绘制时,那个函数将被调用.当窗口改变大小或者从被覆盖的状态
            # //*******************************************************************************************
            # void glutReshapeFunc(void (*func)(int width, int height));
            # 指定当窗口的大小改变时调用的函数
            #
            # 参数:  func:形如void func(int width, int height)
            # 处理窗口大小改变的函数.
            # width,height:为窗口改变后
            # 这个函数确定一个回调函数,每当窗口的大小或形状改变时(包括窗口第一次创建),GLUT将会调用这个
            # //*******************************************************************************************
            # void glutKeyboardFunc(void (*func)(unsigned char key, int x, int y));
            # 注册当前窗口的键盘回调函数
            #
            # 参数:  func:形如void func(unsigned char key, int x, int y)  key:按键的ASCII码  x,y:当按下键时鼠标的坐标,相对于窗口左上角,以像素为单位
            # 当敲击键盘按键(除了特殊按键,即glutSpecialFunc()中处理的按键,详见glutSpecialFunc())时调用.
            #
            # //******************************************************************************************
            # void glutMouseFunc(void (*func)(int button, int state, int x, int y));
            # 注册当前窗口的鼠标回调函数
            # 参数:  func:形如void func(int button, int state, int x, int y);
            # button:鼠标的按键,为以下定义的常量  GLUT_LEFT_BUTTON:鼠标左键  GLUT_MIDDLE_BUTTON:鼠标中键  GLUT_RIGHT_BUTTON:鼠标右键  state:鼠标按键的动作,为以下定义的常量  GLUT_UP:鼠标释放  GLUT_DOWN:鼠标按下  x,y:鼠标按下式,光标相对于窗口左上角的位置
            # 当点击鼠标时调用.
            #
            # //******************************************************************************************
            # void glutMotionFunc(void (*func)(int x, int y));
            # 当鼠标在窗口中按下并移动时调用glutMotionFunc注册的回调函数
            # void glutPassiveMotionFunc(void (*func)(int x, int y));
            # 当鼠标在窗口中移动时调用glutPassiveMotionFunc注册的回调函数
            # 参数:  func:形如void func(int x, int y);
            # x,y:鼠标按下式,光标相对于窗口左上角的位置,以像素为单位
            #
            # //*******************************************************************************************
            # void glutEntryFunc(void (*func)(int state));
            # 设置鼠标的进出窗口的回调函数
            # 参数:  func:形如void func(int state);注册的鼠标进出回调函数  state:鼠标的进出状态,为以下常量之一  GLUT_LEFT 鼠标离开窗口  GLUT_RIGHT 鼠标进入窗口
            # 当窗口取得焦点或失去焦点时调用这个函数,当鼠标进入窗口区域并点击时,state为GLUT_RIGHT,当鼠标离开窗口区域点击其他窗口时,state为GLUT_LEFT.
            #
            # //******************************************************************************************
            #
            # void glutVisibilityFunc(void (*func)(int state));
            # 设置当前窗口的可视回调函数
            # 参数:  func:形如void func(int state);指定的可视回调函数  state:窗口的可视性,为以下常量  GLUT_NOT_VISIBLE 窗口完全不可见  GLUT_VISIBLE 窗口可见或部分可见
            # 这个函数设置当前窗口的可视回调函数,当窗口的可视性改变时,该窗口的可视回调函数被调用.只要窗口中的任何一个像素是可见的,或者他的任意一个子窗口中任意一个像素是可见的,GLUT则认为窗口是可见的.
            #
            # //*******************************************************************************************
            # void glutIdleFunc(void (*func)(void));
            # 设置空闲回调函数
            # 参数:  func:形如void func(void);
            # 当系统空闲时调用.
            #
            # //*******************************************************************************************
            # void glutTimerFunc(unsigned int millis, void (*func)(int value), int value);
            # 注册一个回调函数,当指定时间值到达后,由GLUT调用注册的函数一次
            # 参数:  millis:等待的时间,以毫秒为单位  unc:形如void func(int value)  value:指定的一个数值,用来传递到回调函数func中
            # 这个函数注册了一个回调函数,当指定的毫秒数到达后,这个函数就调用注册的函数,value参数用来向这个注册的函数中传递参数. 但只能触发一次,若要连续触发,则需在func中重新设置计时函数glutTimerFunc();
            #
            # //*******************************************************************************************
            # void glutMenuStateFunc(void (*func)(int state));
            # 注册菜单状态回调函数
            # 参数:  func:形如void func(int state);  state:  GLUT_MENU_IN_USE:菜单被使用.  GLUT_MENU_NOT_IN_USE:菜单不再被使用,即菜单被关闭.  如果state代入GLUT_MENU_IN_USE,则当菜单被使用时调用该函数;  如果state代入GLUT_MENU_NOT_IN_USE,则当菜单被关闭时调用该函数.
            #
            # //*******************************************************************************************
            # void glutMenuStatusFunc(void (*func)(int status, int x, int y));  设置菜单状态回调函数  参数:  func:形如void func(int status, int x, int y);  status:当前是否使用菜单,为以下定义的常量  GLUT_MENU_IN_USE:菜单正在使用  GLUT_MENU_NOT_IN_USE:菜单未被使用  x,y:鼠标按下时,光标相对于窗口左上角的位置  这个函数调用时glut程序判定是否正在使用菜单,当弹出菜单时,调用注册的菜单状态回调函数,同时status设置为常量GLUT_MENU_IN_USE,当菜单使用完毕时,也调用菜单状态回调函数,此时status变量变为GLUT_MENU_NOT_IN_USE.从已弹出的菜单中再弹出的菜单不产生菜单状态回调过程.每个glut程序只有一个菜单状态回调函数. 此函数与上面一个函数相比,只是多传了一个光标位置,其他相同.
            #
            # //*******************************************************************************************
            # void glutSpecialFunc(void (*func)(int key, int x, int y));
            # 设置当前窗口的特定键的回调函数
            # 参数:  Func:形如void func(int key, int x, int y);  key:按下的特定键,为以下定义的常量  GLUT_KEY_F1:F1功能键  GLUT_KEY_F2:F2功能键  GLUT_KEY_F3:F3功能键  GLUT_KEY_F4:F4功能键  GLUT_KEY_F5:F5功能键  GLUT_KEY_F6:F6功能键  GLUT_KEY_F7:F7功能键  GLUT_KEY_F8:F8功能键  GLUT_KEY_F9:F9功能键  GLUT_KEY_F10:F10功能键  GLUT_KEY_F11:F11功能键  GLUT_KEY_F12:F12功能键  GLUT_KEY_LEFT:左方向键  GLUT_KEY_UP:上方向键  GLUT_KEY_RIGHT:右方向键  GLUT_KEY_DOWN:下方向键  GLUT_KEY_PAGE_UP:PageUp键  GLUT_KEY_PAGE_DOWN:PageDown键  GLUT_KEY_HOME:Home键  GLUT_KEY_END:End键  GLUT_KEY_INSERT:Insert键  x,y:当按下键时鼠标的坐标,相对于窗口左上角,以像素为单位
            # 注意:ESC,回车和delete键由ASCII码产生,即可以用glutKeyboardFunc()处理. 当在键盘上敲击上述按键时调用该函数.注意与glutKeyboardFunc()的区别.
            #
            # //*******************************************************************************************
            # void glutSpaceballMotionFunc(void (*func)(int x, int y, int z));
            # 注册一个当前窗口的spaceball平移的回调函数
            # 参数:  func:形如void func(int x, int y, int z);  x,y,z:spaceball的三维空间坐标.  paceball即一种特殊的带3D滚轮的鼠标,不仅可以前后转动,更可以在三维空间里滚动,具体图片,可以在百度里搜索.
            # 当spaceball在当前注册的窗口内平移时,调用该函数.
            #
            # //*******************************************************************************************
            # void glutSpaceballRotateFunc(void (*func)(int x, int y, int z));
            # 注册一个当前窗口的spaceball转动的回调函数
            # 参数:  func:形如void func(int x, int y, int z);  当spaceball在当前注册的窗口内滚动时调用.
            #
            # //*******************************************************************************************
            # void glutSpaceballButtonFunc(void (*func)(int button, int state));
            # 注册当前窗口的spaceball的按键回调函数.
            # 参数:  func:形如void func(int button, int state);  button:按键编号,从1开始,可用的按键编号可以通过glutDeviceGet(GLUT_NUM_SPACEBALL_BUTTONS)查询.  state:按键状态  GLUT_UP:按键释放  GLUT_DOWN:按键按下
            # 当spaceball在当前窗口中敲击相应的按键时调用.
            #
            # //*******************************************************************************************
            #
            # void glutButtonBoxFunc(void (*func)(int button, int state));   注册当前窗口的拨号按键盒按键回调函数
            # 参数:  func:形如void func(int button, int state);  button:按键编号,从1开始,可用的按键号可通过glutDeviceGet(GLUT_NUM_BUTTON_BOX_BUTTONS)查询  state:按键状态  GLUT_UP:按键释放  GLUT_DOWN:按键按下
            # 当拨号按键盒按键被按下时调用.
            #
            # //*******************************************************************************************
            # void glutDialsFunc(void (*func)(int dial, int value));
            # 注册当前窗口的拨号按键盒拨号回调函数.
            # 参数:  func:形如void func(int dial, value);  dial:dial的编号,从1开始,可通过glutDeviceGet(GLUT_NUM_DIALS)查询可用编号.  value:dial所拨的值,value是每次所拨的值的累加,直到溢出.
            # 当拨号按键盒拨号时被调用.
            #
            # //*******************************************************************************************
            # void glutTabletMotionFunc(void (*func)(int x, int y));
            # 注册图形板移动回调函数
            # 参数:  func:形如void func(int x, int y);  x,y:图形板移动的坐标.
            # 当图形板移动时调用.//******************************************************************************************
            #
            # void glutTabletButtonFunc(void (*func)(int button, int state, int x, int y));
            # 注册当前窗口的图形板按键回调函数
            # 参数:  func:形如void func(int button, int state, int x, int y);  button:按键号,通过glutDeviceGet(GLUT_NUM_TABLET_BUTTONS)查询可用键号.  state:按键状态.  GLUT_UP:按键被按下  GLUT_DOWN:按键被释放
            # x,y:当按键状态改变时,相对于窗口的坐标.//******************************************************************************************
            #
            # void glutOverlayDisplayFunc(void (*func)(void));
            # 注册当前窗口的重叠层的显示回调函数
            # 参数:  func:形如void func(void);指向重叠层的显示回调函数.
            # 这个函数告诉GLUT当窗口内容必须被绘制时,那个函数将被调用.当窗口改变大小或者从被覆盖的状态中恢复,或者由于调用glutPostOverlayRedisplay()函数要求GLUT更新时,执行func参数指定的函数.
            #
            # //*******************************************************************************************
            # void glutWindowStatusFunc(void (*func)(int state));
            # 注册当前窗口状态的回调函数.
            # 参数:  func:形如void func(int state);  state:窗口状态.  GLUT_HIDDEN:窗口不可见  GLUT_FULLY_RETAINED:窗口完全未被遮挡  GLUT_PARTIALLY_RETAINED:窗口部分遮挡  GLUT_FULLY_COVERED:窗口被全部遮挡
            # 当窗口状态发生相应改变时调用.
            #
            # //*******************************************************************************************
            #
            # void glutKeyboardUpFunc(void (*func)(unsigned char key, int x, int y));
            # 注册释放普通按键的回调函数
            # 参数:  func:形如void func(unsigned char key, int x, int y);  key:按键的ASCII码.  x,y:释放按键时鼠标相对于窗口的位置,以像素为单位.
            # 当普通按键被释放时调用.
            #
            # //*******************************************************************************************
            #
            # void glutSpecialUpFunc(void (*func)(int key, int x, int y));
            # 注册释放特殊按键的回调函数
            # 参数:  func:形如void func(int key, int x, int y);  key:特殊按键的标识  GLUT_KEY_F1:F1功能键  GLUT_KEY_F2:F2功能键  GLUT_KEY_F3:F3功能键  GLUT_KEY_F4:F4功能键  GLUT_KEY_F5:F5功能键  GLUT_KEY_F6:F6功能键  GLUT_KEY_F7:F7功能键  GLUT_KEY_F8:F8功能键  GLUT_KEY_F9:F9功能键  GLUT_KEY_F10:F10功能键  GLUT_KEY_F11:F11功能键  GLUT_KEY_F12:F12功能键  GLUT_KEY_LEFT:左方向键  GLUT_KEY_UP:上方向键  GLUT_KEY_RIGHT:右方向键  GLUT_KEY_DOWN:下方向键  GLUT_KEY_PAGE_UP:PageUp键  GLUT_KEY_PAGE_DOWN:PageDown键  GLUT_KEY_HOME:Home键  GLUT_KEY_END:End键  GLUT_KEY_INSERT:Insert键  x,y:释放特殊按键时鼠标相对于窗口的位置,以像素为单位.
            # 当特殊按键被释放时调用.
            #
            # //******************************************************************************************
            #
            # void glutJoystickFunc(void (*func)(unsigned int buttonMask, int x, int y, int z), int pollInterval);
            # 注册操纵杆的回调函数
            # 参数:  buttonMask:操纵杆按键  GLUT_JOYSTICK_BUTTON_A  GLUT_JOYSTICK_BUTTON_B  GLUT_JOYSTICK_BUTTON_C  GLUT_JOYSTICK_BUTTON_D  x,y,z:操纵杆在三维空间内移动的位移量  pollInterval:确定检测操纵杆的间隔时间,其单位为毫秒.
            # 该函数在两种情况下被调用:  1.在pollInterval所规定的时间间隔内调用.  2.在调用glutForceJoystickFunc()函数时调用一次glutJoystickFunc();
            # //*******************************************************************************************
            #
            #
            #
            # ---------------------------------------------------
            # glut callback python doc
            # ---------------------------------------------------
            """
C:\Python27\Lib\site-packages\OpenGL\GLUT\freeglut.py

# /usr/include/GL/freeglut_ext.h 69
##glutMouseWheelFunc = platform.createBaseFunction(
##  'glutMouseWheelFunc', dll=platform.PLATFORM.GLUT, resultType=None,
##  argTypes=[FUNCTION_TYPE(None, c_int, c_int, c_int, c_int)],
##  doc='glutMouseWheelFunc( FUNCTION_TYPE(None, c_int, c_int, c_int, c_int)(callback) ) -> None',
##  argNames=('callback',),
##)
glutMouseWheelFunc = special.GLUTCallback(
    'MouseWheel', (c_int, c_int, c_int, c_int,), ('wheel','direction','x','y'),
)


# /usr/include/GL/freeglut_ext.h 70
##glutCloseFunc = platform.createBaseFunction(
##  'glutCloseFunc', dll=platform.PLATFORM.GLUT, resultType=None,
##  argTypes=[FUNCTION_TYPE(None)],
##  doc='glutCloseFunc( FUNCTION_TYPE(None)(callback) ) -> None',
##  argNames=('callback',),
##)
glutCloseFunc = special.GLUTCallback(
    'Close', (), (),
)

# /usr/include/GL/freeglut_ext.h 71
##glutWMCloseFunc = platform.createBaseFunction(
##  'glutWMCloseFunc', dll=platform.PLATFORM.GLUT, resultType=None,
##  argTypes=[FUNCTION_TYPE(None)],
##  doc='glutWMCloseFunc( FUNCTION_TYPE(None)(callback) ) -> None',
##  argNames=('callback',),
##)
glutWMCloseFunc = special.GLUTCallback(
    'WMClose', (), (),
)

# /usr/include/GL/freeglut_ext.h 73
##glutMenuDestroyFunc = platform.createBaseFunction(
##  'glutMenuDestroyFunc', dll=platform.PLATFORM.GLUT, resultType=None,
##  argTypes=[FUNCTION_TYPE(None)],
##  doc='glutMenuDestroyFunc( FUNCTION_TYPE(None)(callback) ) -> None',
##  argNames=('callback',),
##)
glutMenuDestroyFunc = special.GLUTCallback(
    'MenuDestroy', (), (),
)


C:\Python27\Lib\site-packages\OpenGL\GLUT\special.py


glutButtonBoxFunc = GLUTCallback(
    'ButtonBox', (ctypes.c_int,ctypes.c_int), ('button','state'),
)
glutDialsFunc = GLUTCallback(
    'Dials', (ctypes.c_int,ctypes.c_int), ('dial','value'),
)
glutDisplayFunc = GLUTCallback(
    'Display', (), (),
)
glutEntryFunc = GLUTCallback(
    'Entry', (ctypes.c_int,), ('state',),
)
glutIdleFunc = GLUTCallback(
    'Idle', (), (),
)
glutJoystickFunc = GLUTCallback(
    'Joystick', (ctypes.c_uint,ctypes.c_int,ctypes.c_int,ctypes.c_int), ('buttonMask','x','y','z'),
)
glutKeyboardFunc = GLUTCallback(
    'Keyboard', (ctypes.c_char,ctypes.c_int,ctypes.c_int), ('key','x','y'),
)
glutKeyboardUpFunc = GLUTCallback(
    'KeyboardUp', (ctypes.c_char,ctypes.c_int,ctypes.c_int), ('key','x','y'),
)
glutMenuStatusFunc = GLUTCallback(
    'MenuStatus', (ctypes.c_int,ctypes.c_int,ctypes.c_int), ('status','x','y'),
)
glutMenuStateFunc = GLUTCallback(
    'MenuState', (ctypes.c_int,), ('status',),
)
glutMotionFunc = GLUTCallback(
    'Motion', (ctypes.c_int,ctypes.c_int), ('x','y'),
)
glutMouseFunc = GLUTCallback(
    'Mouse', (ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_int), ('button','state','x','y'),
)
glutOverlayDisplayFunc = GLUTCallback(
    'OverlayDisplay', (), (),
)
glutPassiveMotionFunc = GLUTCallback(
    'PassiveMotion', (ctypes.c_int,ctypes.c_int), ('x','y'),
)
glutReshapeFunc = GLUTCallback(
    'Reshape', (ctypes.c_int,ctypes.c_int), ('width','height'),
)
glutSpaceballButtonFunc = GLUTCallback(
    'SpaceballButton', (ctypes.c_int,ctypes.c_int), ('button','state'),
)
glutSpaceballMotionFunc = GLUTCallback(
    'SpaceballMotion', (ctypes.c_int,ctypes.c_int,ctypes.c_int), ('x','y','z'),
)
glutSpaceballRotateFunc = GLUTCallback(
    'SpaceballRotate', (ctypes.c_int,ctypes.c_int,ctypes.c_int), ('x','y','z'),
)
glutSpecialFunc = GLUTCallback(
    'Special', (ctypes.c_int,ctypes.c_int,ctypes.c_int), ('key','x','y'),
)
glutSpecialUpFunc = GLUTCallback(
    'SpecialUp', (ctypes.c_int,ctypes.c_int,ctypes.c_int), ('key','x','y'),
)
glutTabletButtonFunc = GLUTCallback(
    'TabletButton', (ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_int), ('button','state','x','y',),
)
glutTabletButtonFunc = GLUTCallback(
    'TabletButton', (ctypes.c_int,ctypes.c_int,ctypes.c_int,ctypes.c_int), ('button','state','x','y',),
)
glutTabletMotionFunc = GLUTCallback(
    'TabletMotion', (ctypes.c_int,ctypes.c_int), ('x','y',),
)
glutVisibilityFunc = GLUTCallback(
    'Visibility', (ctypes.c_int,), ('state',),
)
glutWindowStatusFunc = GLUTCallback(
    'WindowStatus', (ctypes.c_int,), ('state',),
)

# glutTimerFunc is unlike any other GLUT callback-registration...
glutTimerFunc = GLUTTimerCallback(
    'Timer', (ctypes.c_int,), ('value',),
)

            """
            glutReshapeFunc(self._reshape_wrapper)
            glutKeyboardFunc(self._keyboard_wrapper)
            glutDisplayFunc(self._display_wrapper)
            glutIdleFunc(self._idle_wrapper)
            glutMouseFunc(self._mouse_wrapper)
            glutMotionFunc(self._motion_wrapper)
            # 这个回调只在关闭窗口时调用，意外结束不会调用，比如从pycharm结束
            glutCloseFunc(self._close_wrapper)

            # 这个也是，目前没法触发
            # import atexit
            # atexit.register(self._close_wrapper)

            glutPassiveMotionFunc(self._passive_motion_wrapper)

        def init_logic():
            self.on_initialize and self.on_initialize()

        init_()
        init_window()
        init_callbacks()
        getattr(self, "initGraphics", lambda :None)()
        # init_logic() NOTE init_logic is moved to zlogic.initialize 

    @logger
    def finalize(self):
        def finalize_logic():
            self.on_finalize and self.on_finalize()

        def finalize_():
            if self.enable_objgraph:
                import objgraph
                objgraph.show_growth()

        finalize_logic()
        finalize_()

    def update(self):
        # @logger
        def _do_update():
            dt = self.dt

            def lock_fps():
                import time
                time.sleep(dt)

            def update_logic():
                self.on_update and self.on_update(self.dt)

            def update_render():
                glutPostRedisplay()

            if self.enable_lock_fps:
                lock_fps()
            update_logic()
            update_render()

        if self.space_step:
            return

        _do_update()

    def _render(self):
        self.on_render and self.on_render()

    # ---------------------------------------------------
    # input
    # ---------------------------------------------------
    @property
    def modifier(self):
        return glutGetModifiers()

    @property
    def is_alt_pressed(self):
        return self.modifier == GLUT_ACTIVE_ALT

    @property
    def is_shift_pressed(self):
        return self.modifier == GLUT_ACTIVE_SHIFT

    # ---------------------------------------------------
    # callbacks
    # ---------------------------------------------------
    '''
    if G.debug:
        def on_initialize(self):
            pass

        def on_finalize(self):
            pass

        def on_update(self, dt):
            pass

        def on_render(self):
            pass

        def on_resize(self, width, height):
            pass

        def on_mouse(self, button, state, x, y):
            pass

        def on_keyboard(self, key):
            pass

        def on_motion(self, x, y):
            pass
    '''

    # @logger
    def _display_wrapper(self):
        self._render()

    # @logger
    def _idle_wrapper(self):
        G.main_update()

    @logger
    def _close_wrapper(self):
        G.main_finalize()

    # @logger
    def _keyboard_wrapper(self, key, x_, y):
        if self.space_step:
            if key == ' ':
                self.update()
        self.on_keyboard and self.on_keyboard(key)

    # @logger
    def _mouse_wrapper(self, button, state, x_, y):
        self.on_mouse and self.on_mouse(button, state, x_, y)

    # @logger
    def _motion_wrapper(self, x_, y):
        self.on_motion and self.on_motion(x_, y)

    # @logger
    def _reshape_wrapper(self, width, height):
        if width <= 400:
            width = 400
        if height <= 300:
            height = 300
        self.width = width
        self.height = height
        G.graphicsm.on_resize(width, height)

    def _passive_motion_wrapper(self, x, y):
        pass

    @logger
    def log(self, *args, **kwargs):
        pass