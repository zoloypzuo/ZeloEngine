# coding=utf-8
# cyclone_demo_common.py
# created on 2021/3/2
# author @zoloypzuo
# usage: cyclone_demo_common
from OpenGL.GL import *
from OpenGL.GLU import *  # noqa
from OpenGL.GLUT import *

from cyclone import *
from game_timer import now


# ShotType = Table(
#     UNUSED='UNUSED',
#     PISTOL='PISTOL',
#     ARTILLERY='ARTILLERY',
#     FIREBALL='FIREBALL',
#     LASER='LASER'
# )

class ShotType:
    UNUSED = 'UNUSED'
    PISTOL = 'PISTOL'
    ARTILLERY = 'ARTILLERY'
    FIREBALL = 'FIREBALL'
    LASER = 'LASER'


class FirePoint:
    def render(self):
        glColor3f(0.0, 0.0, 0.0)
        glPushMatrix()
        glTranslatef(0.0, 1.5, 0.0)
        glutSolidSphere(0.1, 5, 5)
        glTranslatef(0.0, -1.5, 0.0)
        glColor3f(0.75, 0.75, 0.75)
        glScalef(1.0, 0.1, 1.0)
        glutSolidSphere(0.1, 5, 5)
        glPopMatrix()


class SceneLines:
    def render(self):
        glColor3f(0.75, 0.75, 0.75)
        glBegin(GL_LINES)

        for i in xrange(1, 200, 10):
            glVertex3f(-5.0, 0.0, i)
            glVertex3f(5.0, 0.0, i)

        glEnd()


class AmmoRoundParticle:
    def __init__(self, shotType=None):
        self.particle = Particle()
        self.type = shotType or ShotType.UNUSED
        self.startTime = 0

    def lifetime(self):
        return now() - self.startTime

    def render(self):
        if self.type == ShotType.UNUSED:
            return
        position = self.particle.getPosition()
        glColor3f(0, 0, 0)
        glPushMatrix()
        glTranslatef(position.x, position.y, position.z)
        glutSolidSphere(0.3, 5, 4)
        glPopMatrix()

        glColor3f(0.75, 0.75, 0.75)
        glPushMatrix()
        glTranslatef(position.x, 0, position.z)
        glScalef(1.0, 0.1, 1.0)
        glutSolidSphere(0.6, 5, 4)
        glPopMatrix()


def GLArray(data):
    data = [realArray_getitem(data, index) for index in xrange(12)]
    import numpy
    array = [0.0 for _ in xrange(16)]
    array[0] = data[0]
    array[1] = data[4]
    array[2] = data[8]
    array[3] = 0

    array[4] = data[1]
    array[5] = data[5]
    array[6] = data[9]
    array[7] = 0

    array[8] = data[2]
    array[9] = data[6]
    array[10] = data[10]
    array[11] = 0

    array[12] = data[3]
    array[13] = data[7]
    array[14] = data[11]
    array[15] = 1
    return numpy.array(array, dtype="float32")


class AmmoRoundRb(CollisionSphere):
    def __init__(self):
        super(AmmoRoundRb, self).__init__()
        self.body = RigidBody()  # TODO may cause mem leak
        self.type = ShotType.UNUSED
        self.start_time = 0.

    def render(self):
        glPushMatrix()
        glMultMatrixf(GLArray(self.body.getTransform().data))
        glutSolidSphere(self.radius, 20, 20)
        glPopMatrix()

    def setState(self, shotType):
        self.type = shotType
        if shotType == ShotType.PISTOL:
            self.body.setMass(1.5)
            self.body.setVelocity(0.0, 0.0, 20.0)
            self.body.setAcceleration(0.0, -0.5, 0.0)
            self.body.setDamping(0.99, 0.8)
            self.radius = 0.2

        elif shotType == ShotType.ARTILLERY:
            self.body.setMass(200.0)  # 200.0kg
            self.body.setVelocity(0.0, 30.0, 40.0)  # 50m/s
            self.body.setAcceleration(0.0, -21.0, 0.0)
            self.body.setDamping(0.99, 0.8)
            self.radius = 0.4

        elif shotType == ShotType.FIREBALL:
            self.body.setMass(4.0)  # 4.0kg - mostly blast damage
            self.body.setVelocity(0.0, -0.5, 10.0)  # 10m/s
            self.body.setAcceleration(0.0, 0.3, 0.0)  # Floats up
            self.body.setDamping(0.9, 0.8)
            self.radius = 0.6

        elif shotType == ShotType.LASER:
            # Note that this is the kind of laser bolt seen in films,
            # not a realistic laser beam!
            self.body.setMass(0.1)  # 0.1kg - almost no weight
            self.body.setVelocity(0.0, 0.0, 100.0)  # 100m/s
            self.body.setAcceleration(0.0, 0.0, 0.0)  # No gravity
            self.body.setDamping(0.99, 0.8)
            self.radius = 0.2

        self.body.setCanSleep(False)
        self.body.setAwake()

        tensor = Matrix3()
        coeff = 0.4 * self.body.getMass() * self.radius * self.radius
        tensor.setInertiaTensorCoeffs(coeff, coeff, coeff)
        self.body.setInertiaTensor(tensor)

        self.body.setPosition(0.0, 1.5, 0.0)
        # self.start_time = TODO last frame time

        self.body.calculateDerivedData()
        self.calculateInternals()


class Box(CollisionBox):
    def __init__(self):
        super(Box, self).__init__()
        self.body = RigidBody()

    def render(self):
        glPushMatrix()
        gl_array = GLArray(self.body.getTransform().data)
        # gl_array[13] = 1
        glMultMatrixf(gl_array)
        glScalef(self.halfSize.x * 2, self.halfSize.y * 2, self.halfSize.z * 2)
        glutSolidCube(1.)
        glPopMatrix()

    def setState(self, z):
        self.body.setPosition(0, 3, z)
        self.body.setOrientation(1, 0, 0, 0)
        self.body.setVelocity(0, 0, 0)
        self.body.setRotation(Vector3(0, 0, 0))
        self.halfSize = halfSize = Vector3(1, 1, 1)

        mass = halfSize.x * halfSize.y * halfSize.z * 8.0
        self.body.setMass(mass)

        tensor = Matrix3()
        tensor.setBlockInertiaTensor(halfSize, mass)
        self.body.setInertiaTensor(tensor)

        self.body.setLinearDamping(0.95)
        self.body.setAngularDamping(0.8)
        self.body.clearAccumulators()
        self.body.setAcceleration(0, -10.0, 0)

        self.body.setCanSleep(False)
        self.body.setAwake()

        self.body.calculateDerivedData()
        self.calculateInternals()
