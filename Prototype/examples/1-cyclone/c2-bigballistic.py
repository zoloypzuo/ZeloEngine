# coding=utf-8
# bigballistic.py
# created on 2020/10/20
# author @zoloypzuo
# usage: bigballistic
from cyclone_demo_app import *
from cyclone_demo_common import *


class BigBallisticDemo(RigidBodyApplication):
    ammoRounds = 256
    boxes = 2

    def __init__(self):
        super(BigBallisticDemo, self).__init__()

    def initialize(self):
        super(BigBallisticDemo, self).initialize()
        self.ammo = [AmmoRoundRb() for _ in xrange(self.ammoRounds)]
        self.boxData = [Box() for _ in xrange(self.boxes)]
        self.currentShotType = ShotType.LASER
        self.pauseSimulation = False
        self.reset()

    def fire(self):
        for shot in self.ammo:
            if shot.type == ShotType.UNUSED:
                shot.setState(self.currentShotType)
                break

    def initGraphics(self):
        lightAmbient = [0.8, 0.8, 0.8, 1.0]
        lightDiffuse = [0.9, 0.95, 1.0, 1.0]

        glLightfv(GL_LIGHT0, GL_AMBIENT, lightAmbient)
        glLightfv(GL_LIGHT0, GL_DIFFUSE, lightDiffuse)

        glEnable(GL_LIGHT0)
        super(BigBallisticDemo, self).initGraphics()

    def reset(self):
        for shot in self.ammo:
            shot.type = ShotType.UNUSED

        z = 20.0
        for box in self.boxData:
            box.setState(z)
            z += 90.0

    def getTitle(self):
        return "Cyclone > Big Ballistic Demo"

    def updateObjects(self, duration):
        for shot in self.ammo:
            if shot.type != ShotType.UNUSED:
                shot.body.integrate(duration)
                shot.calculateInternals()

                pass  # TODO

        for box in self.boxData:
            box.body.integrate(duration)
            box.calculateInternals()

    def display(self):
        glClearColor(.9, .95, 1.0, 1.0)
        # Clear the viewport and set the camera direction
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
        glMatrixMode(GL_MODELVIEW)
        glLoadIdentity()
        gluLookAt(-25.0, 8.0, 5.0, 0.0, 5.0, 22.0, 0.0, 1.0, 0.0)

        # Draw a sphere at the firing point, and add a shadow projected
        # onto the ground plane.
        glColor3f(0.0, 0.0, 0.0)
        glPushMatrix()
        glTranslatef(0.0, 1.5, 0.0)
        glutSolidSphere(0.1, 5, 5)
        glTranslatef(0.0, -1.5, 0.0)
        glColor3f(0.75, 0.75, 0.75)
        glScalef(1.0, 0.1, 1.0)
        glutSolidSphere(0.1, 5, 5)
        glPopMatrix()

        # Draw some scale lines
        glColor3f(0.75, 0.75, 0.75)
        glBegin(GL_LINES)
        for i in xrange(0, 200, 10):
            glVertex3f(-5.0, 0.0, i)
            glVertex3f(5.0, 0.0, i)
        glEnd()

        # Render each particle in turn
        glColor3f(1, 0, 0)
        for shot in self.ammo:
            if shot.type != ShotType.UNUSED:
                shot.render()

        # Render the box
        glEnable(GL_DEPTH_TEST)
        glEnable(GL_LIGHTING)
        glLightfv(GL_LIGHT0, GL_POSITION, [-1, 1, 0, 0])
        glColorMaterial(GL_FRONT_AND_BACK, GL_DIFFUSE)
        glEnable(GL_COLOR_MATERIAL)
        glColor3f(1, 0, 0)
        for box in self.boxData:
            box.render()
        glDisable(GL_COLOR_MATERIAL)
        glDisable(GL_LIGHTING)
        glDisable(GL_DEPTH_TEST)

        # Render the description
        glColor3f(0.0, 0.0, 0.0)
        self.renderText(10.0, 34.0, "Click: Fire\n1-4: Select Ammo")

        # Render the name of the current shot type
        # switch(currentShotType)
        # {
        # case PISTOL: renderText(10.0, 10.0, "Current Ammo: Pistol") break
        # case ARTILLERY: renderText(10.0, 10.0, "Current Ammo: Artillery") break
        # case FIREBALL: renderText(10.0, 10.0, "Current Ammo: Fireball") break
        # case LASER: renderText(10.0, 10.0, "Current Ammo: Laser") break
        # }
        glutSwapBuffers()

    def mouse(self, button, state, x, y):
        if state == GLUT_DOWN:
            self.fire()

    def key(self, key, x, y):
        KEY_MAP = {
            '1': ShotType.PISTOL,
            '2': ShotType.ARTILLERY,
            '3': ShotType.FIREBALL,
            '4': ShotType.LASER
        }
        self.currentShotType = KEY_MAP[key]

    def generateContacts(self):
        plane = CollisionPlane()
        plane.direction = Vector3(0, 1, 0)
        plane.offset = 0

        cData = self.cData
        cData.reset(self.maxContacts)
        cData.friction = 0.9
        cData.restitution = 0.1
        cData.tolerance = 0.1

        for box in self.boxData:
            if not self.cData.hasMoreContacts():
                return
            CollisionDetector.boxAndHalfSpace(box, plane, self.cData)
            for shot in self.ammo:
                if shot.type != ShotType.UNUSED:
                    if not self.cData.hasMoreContacts():
                        return
                    if CollisionDetector.boxAndSphere(box, shot, self.cData):
                        shot.type = ShotType.UNUSED


if __name__ == '__main__':
    BigBallisticDemo()
