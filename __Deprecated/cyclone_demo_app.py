# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# cyclone_demo_app.py
# created on 2021/3/2
# usage: app
from OpenGL.GL import *
from OpenGL.GLU import *
from OpenGL.GLUT import *

from cyclone import CollisionDataEx, ParticleWorld, Particle, GroundContacts
from framework.zmath import Clamp


class Application(object):
    def __init__(self):
        glutInit(sys.argv)
        self.initialize()
        glutInitDisplayMode(GLUT_DOUBLE | GLUT_RGB | GLUT_DEPTH)
        glutInitWindowSize(self.width, self.height)
        glutInitWindowPosition(0, 0)
        glutCreateWindow(self.getTitle())

        glutReshapeFunc(self.resize)
        glutKeyboardFunc(self.key)
        glutDisplayFunc(self.display)
        glutIdleFunc(self.update)
        glutMouseFunc(self.mouse)
        glutMotionFunc(self.mouseDrag)

        self.initGraphics()
        glutMainLoop()

    def initialize(self):
        self.width, self.height = 640, 320

    def getTitle(self):
        return "Cyclone Demo"

    def initGraphics(self):
        glClearColor(0.9, 0.95, 1.0, 1.0)
        glEnable(GL_DEPTH_TEST)
        glShadeModel(GL_SMOOTH)

        self.setView()

    def setView(self):
        glMatrixMode(GL_PROJECTION)
        glLoadIdentity()
        gluPerspective(60.0, float(self.width) / self.height, 1.0, 500.0)
        glMatrixMode(GL_MODELVIEW)

    def display(self):
        # glClear(GL_COLOR_BUFFER_BIT)
        #
        # glBegin(GL_LINES)
        # glVertex2i(1, 1)
        # glVertex2i(639, 319)
        # glEnd()

        glFlush()
        glutSwapBuffers()

    def resize(self, width, height):
        height = 1 if height <= 0 else height
        self.width = width
        self.height = height
        glViewport(0, 0, width, height)
        self.setView()

    def update(self):
        glutPostRedisplay()

    def key(self, key, x, y):
        pass

    def renderText(self, x, y, text, font=None):
        pass  # TODO, 看一下之前测试得代码

    def mouse(self, button, state, x, y):
        pass

    def mouseDrag(self, x, y):
        pass


class MassAggregateApplication(Application):
    def initialize(self):
        super(MassAggregateApplication, self).initialize()
        particleCount = 6
        self.world = ParticleWorld(maxContacts=particleCount * 6)
        self.particleArray = [Particle() for _ in xrange(particleCount)]
        for particle in self.particleArray:
            self.world.appendParticles(particle)
        self.groundContactGenerator = GroundContacts()
        self.groundContactGenerator.init(self.world.getParticles())
        self.world.appendContactGenerator(self.groundContactGenerator)

    def display(self):
        # Clear the view port and set the camera direction
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
        glLoadIdentity()
        gluLookAt(0.0, 3.5, 8.0, 0.0, 3.5, 0.0, 0.0, 1.0, 0.0)
        glColor3f(0, 0, 0)
        for particle in self.world.getParticles():
            pos = particle.getPosition()
            glPushMatrix()
            glTranslatef(pos.x, pos.y, pos.z)
            glutSolidSphere(0.1, 20, 10)
            glPopMatrix()


class RigidBodyApplication(Application):
    maxContacts = 256

    def __init__(self):
        super(RigidBodyApplication, self).__init__()

    def initialize(self):
        super(RigidBodyApplication, self).initialize()
        self.cData = CollisionDataEx(self.maxContacts * 8)
        self.theta = 0.0
        self.phi = 15.0
        self.last_x, self.last_y = 0, 0
        self.renderDebugInfo = False
        self.pauseSimulation = False
        self.autoPauseSimulation = False

    def generateContacts(self):
        pass

    def updateObjects(self, duration):
        pass

    def drawDebug(self):
        pass  # TODO

    def reset(self):
        pass

    def update(self):
        if self.pauseSimulation:
            super(RigidBodyApplication, self).update()
            return
        elif self.autoPauseSimulation:
            self.pauseSimulation = True
            self.autoPauseSimulation = False
        duration = 1 / 30.
        self.updateObjects(duration)
        self.generateContacts()
        self.cData.resolve(duration)

        super(RigidBodyApplication, self).update()

    def display(self):
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
        glLoadIdentity()
        gluLookAt(18.0, 0, 0, 0, 0, 0, 0, 1.0, 0)
        glRotatef(-self.phi, 0, 0, 1)
        glRotatef(self.theta, 0, 1, 0)
        glTranslatef(0, -5.0, 0)

    def mouse(self, button, state, x, y):
        self.last_x = x
        self.last_y = y

    def mouseDrag(self, x, y):
        self.theta += (x - self.last_x) * 0.25
        self.phi += (y - self.last_y) * 0.25

        self.phi = Clamp(self.phi, -20.0, 80.0)

        self.last_x = x
        self.last_y = y

    def key(self, key, x, y):
        if key in ("R", "r"):
            self.reset()
        elif key in ("C", "c"):
            self.renderDebugInfo = not self.renderDebugInfo
        elif key in ("P", "p"):
            self.pauseSimulation = not self.pauseSimulation
        elif key == " ":
            self.autoPauseSimulation = True
            self.pauseSimulation = False

        super(RigidBodyApplication, self).key(key, x, y)
