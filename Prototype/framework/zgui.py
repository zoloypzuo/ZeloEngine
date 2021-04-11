# coding=utf-8
# zgui.py
# created on 2020/10/26
# author @zoloypzuo
# usage: zgui
import imgui
from imgui.integrations.glfw import GlfwRenderer

import G
from common.zlogger import logger
from interfaces.runtime import IRuntimeModule


class Gui(object, IRuntimeModule):
    def __init__(self):
        super(Gui, self).__init__()
        self.impl = None  # type: Optional[GlfwRenderer]
        self.on_gui = None
        self.io = None
        self.on_gui_editor = None

    # ---------------------------------------------------
    # IRuntimeModule
    # ---------------------------------------------------
    @logger
    def initialize(self):
        imgui.create_context()
        self.io = imgui.get_io()
        # TODO 这些枚举搜不到，需要式再说
        # 		io.ConfigFlags |= ImGuiConfigFlags_DockingEnable;           // Enable Docking
        # 		io.ConfigFlags |= ImGuiConfigFlags_ViewportsEnable;         // Enable Multi-Viewport / Platform Windows
        # self.io.config_flags |= imgui.CONFIG_NAV_ENABLE_KEYBOARD  # Enable Keyboard Controls TODO cause error
        window = G.appm.window_handle
        self.impl = GlfwRenderer(window, attach_callbacks=False)  # NOTE otherwise imgui will register glfw callbacks
        imgui.style_colors_dark()
        self.on_gui = G.appm.on_gui
        self.on_gui_editor = G.editorm.on_gui

    @logger
    def finalize(self):
        self.impl.shutdown()
        imgui.destroy_context()

    def update(self):
        self.impl.process_inputs()
        imgui.new_frame()

        self.on_gui and self.on_gui()
        self.on_gui_editor and self.on_gui_editor()

        imgui.render()
        self.impl.render(imgui.get_draw_data())
