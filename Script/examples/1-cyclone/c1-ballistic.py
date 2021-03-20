# coding=utf-8
# ballistic.py
# created on 2020/9/25
# author @zoloypzuo
# usage: ballistic

import G
from cyclone_demo_common import *
from framework._archived.zapp_glut import App
from game_timer import now
# from text_renderer import TextRenderer
from main import game_main_from_app


class BallisticDemo(App):
    # ---------------------------------------------------
    # callbacks
    # ---------------------------------------------------
    def on_initialize(self):
        self.ammoRounds = 16
        self.ammo = [AmmoRoundParticle() for _ in xrange(self.ammoRounds)]
        self.currentShotType = ShotType.LASER
        # self.text = TextRenderer()
        # G.graphicsm.add_renderable(self.text)
        G.graphicsm.add_renderable(SceneLines())
        G.graphicsm.add_renderable(FirePoint())
        for shot in self.ammo:
            G.graphicsm.add_renderable(shot)

    def on_update(self, dt):
        duration = dt
        for ammo in self.ammo:
            if ammo.type == ShotType.UNUSED:
                continue
            ammo.particle.integrate(duration)
            if ammo.particle.getPosition().y < 0.0 or \
                    ammo.particle.getPosition().z > 200.0 or \
                    ammo.lifetime() > 5.0:
                ammo.type = ShotType.UNUSED
        # self.text.text = str(datetime.now())

    def on_mouse(self, button, state, x, y):
        if state == GLUT_DOWN:
            self.fire()

    def on_keyboard(self, key):
        KEY_MAP = {
            '1': ShotType.PISTOL,
            '2': ShotType.ARTILLERY,
            '3': ShotType.FIREBALL,
            '4': ShotType.LASER
        }

        self.change_shot_type(KEY_MAP[key]) if key in KEY_MAP else None

    # ---------------------------------------------------
    # other functions
    # ---------------------------------------------------
    def fire(self):
        shot = None
        for ammo in self.ammo:
            if ammo.type == ShotType.UNUSED:
                shot = ammo
                break
        if not shot:
            return
        fn = getattr(self, self.currentShotType.lower())
        fn and fn(shot)
        shot.particle.setPosition(0.0, 1.5, 0.0)
        shot.startTime = now()
        shot.type = self.currentShotType

    def pistol(self, shot):
        shot.particle.setMass(2.0)
        shot.particle.setVelocity(0.0, 0.0, 35.0)
        shot.particle.setAcceleration(0.0, -1.0, 0.0)
        shot.particle.setDamping(0.99)

    def artillery(self, shot):
        shot.particle.setMass(200.0)
        shot.particle.setVelocity(0.0, 30.0, 40.0)
        shot.particle.setAcceleration(0.0, -20.0, 0.0)
        shot.particle.setDamping(0.99)

    def fireball(self, shot):
        shot.particle.setMass(1.0)
        shot.particle.setVelocity(0.0, 0.0, 10.0)
        shot.particle.setAcceleration(0.0, 0.6, 0.0)
        shot.particle.setDamping(0.9)

    def laser(self, shot):
        shot.particle.setMass(0.1)
        shot.particle.setVelocity(0.0, 0.0, 100.0)
        shot.particle.setAcceleration(0.0, 0.0, 0.0)
        shot.particle.setDamping(0.99)

    def change_shot_type(self, _type):
        self.currentShotType = _type


if __name__ == '__main__':
    game_main_from_app(BallisticDemo, use_glut=True)
