# coding=utf-8
# tank_app.py
# created on 2020/10/20
# author @zoloypzuo
# usage: tank_app

import G
from cameras.camera_freelook import CameraFreelook
from cameras.camera_god import CameraGod
from common.zlogger import logger
from entityscript import EntityScript
from framework._archived.zapp_glut import App
from main import game_main_from_app
from main_functions import spawn_prefab
from framework.renderer.render_item import TexturedCubeRenderer, DebugPlaneRenderer
from framework.math.vector3 import Vector3


class TankApp(App):
    def __init__(self):
        super(TankApp, self).__init__()
        self.inst = None  # type: EntityScript
        self.x = 0
        self.y = 0
        self.z = 0

        self.speed = 1

        self.motion_x = 0
        self.motion_y = 0

    # ---------------------------------------------------
    # callbacks
    # ---------------------------------------------------
    @logger
    def on_initialize(self):
        # the player
        inst = spawn_prefab("tester")
        G.logicm.add_to_scene(inst)
        G.graphicsm.add_renderable(inst.render_item)
        self.inst = inst

        # scene
        self.create_scene_static()

        # camera
        self.camera_god = CameraGod()
        self.camera_free = CameraFreelook()
        self.camera = self.camera_free

    @logger
    def toggle_camera_mode(self, mode):
        print mode
        if mode == "camera god":
            self.camera = self.camera_god
        elif mode == "camera free":
            self.camera = self.camera_free

    def create_scene_static(self):
        # create texture
        from framework.renderer.texture import Texture
        Texture(r"D:\MiniProj_01\data\container.jpg")

        import random
        def random_xz_vector(n, y):
            x = random.uniform(-n, n)
            z = random.uniform(-n, n)
            return (x, y, z)

        def random_vector3(lower, higher):
            x = random.uniform(lower[0], higher[0])
            y = random.uniform(lower[1], higher[1])
            z = random.uniform(lower[2], higher[2])
            return x, y, z

        # cube_cls = SolidPrimitiveRenderer("cube", 1)
        # cube = cube_cls()
        # G.graphicsm.add_renderable(cube)

        def position_updater(pos):
            return lambda: tuple(pos)

        for i in range(50):
            size = random.uniform(.5, 5)
            # cube_cls = SolidPrimitiveRenderer("cube", size)
            # cube_cls = SolidSphereRenderer
            pos_xz = random_xz_vector(15, 0)
            # print pos_xz
            color = random_vector3((0, 0, 0), (1, 1, 1,))
            # cube = cube_cls(
            #     position_updater=position_updater(pos_xz),
            #     color_updater=position_updater(color))
            # textured_cube = TexturedCubeRenderer("container", position_updater(pos_xz))
            textured_cube = TexturedCubeRenderer("container")

            # G.graphicsm.add_renderable(cube)
            # G.graphicsm.add_renderable(textured_cube)

        G.graphicsm.add_renderable(DebugPlaneRenderer())

    def on_update(self, dt):
        self.inst.components.transform.position = Vector3(self.x, self.y, self.z)
        self.camera.update()

    def on_render(self):
        pass

    def on_mouse(self, button, state, x, y):
        if button == 3:  # mid-up
            self.camera._radius += 1
        elif button == 4:  # mid-down
            self.camera._radius -= 1

    def on_motion(self, _x, _y):
        self.camera.rx = _x / 100.
        self.camera.ry = _y / 100.

    def on_keyboard(self, key):
        if key == "a":
            self.z -= 1 * self.speed
        elif key == "d":
            self.z += 1 * self.speed
        elif key == "w":
            self.x += 1 * self.speed
        elif key == "s":
            self.x -= 1 * self.speed

        # HINT handle priority here
        if self.is_shift_pressed and key == " ":
            self.y -= self.speed
        elif key == " ":
            self.y += self.speed
        self.inst.components.transform.position = Vector3(self.x, self.y, self.z)

        # ---------------------------------------------------
        # shortcut
        # ---------------------------------------------------
        if key == "1":
            self.toggle_camera_mode("camera free")
        elif key == "2":
            self.toggle_camera_mode("camera god")
        elif ord(key) == 27:
            exit(0)

    # ---------------------------------------------------
    # meta methods
    # ---------------------------------------------------
    def __str__(self):
        return "<TankApp>"

    __repr__ = __str__

if __name__ == '__main__':
    game_main_from_app(TankApp, use_glut=True)