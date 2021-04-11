# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# imgui_test.py
# created on 2020/12/28
# usage: imgui_test
import glfw
import glm
import imgui

from cameras.camera_glfw import CameraGlfw as Camera
from framework.zapp_glfw import App

firstMouse = True
lastX = 0
lastY = 0
camera = Camera(position=glm.vec3(0., 0., 3.))


class ImguiTest(App):
    def initialize(self):
        super(ImguiTest, self).initialize()
        # glfw.set_input_mode(self.window_handle, glfw.CURSOR, glfw.CURSOR_DISABLED)

    def on_gui(self):
        return
        imgui.slider_float3("Translation", 1, 2, 3, 0, 100)
        fps = imgui.get_io().framerate
        imgui.text("Application average {:>.3f} ms/frame {:>.1f} FPS".format(1000. / fps, fps))

    # TODO move to base class
    @property
    def view(self):
        return camera.view_matrix

    @property
    def projection(self):
        return glm.perspective(glm.radians(camera.zoom), float(self.width) / self.height, .1, 100.)

    # ---------------------------------------------------
    # handle input
    # ---------------------------------------------------
    def on_mouse(self, window, xpos, ypos):
        global firstMouse
        global lastX
        global lastY
        if not firstMouse:
            lastX = xpos
            lastY = ypos
            firstMouse = False

        xoffset = xpos - lastX
        yoffset = lastY - ypos

        lastX = xpos
        lastY = ypos
        camera.on_camera_rotate(xoffset, yoffset)

    def on_scroll(self, window, xoffset, yoffset):
        camera.on_camera_zoom(yoffset)

    def on_input(self, window):
        dt = 1. / 30
        KEY_MAP = {
            glfw.KEY_W: "FORWARD",
            glfw.KEY_S: "BACKWARD",
            glfw.KEY_A: "LEFT",
            glfw.KEY_D: "RIGHT"
        }
        for key, op in KEY_MAP.iteritems():
            if glfw.get_key(window, key) == glfw.PRESS:
                camera.on_camera_move(op, dt)


if __name__ == '__main__':
    from main import game_main_from_app

    game_main_from_app(ImguiTest)
