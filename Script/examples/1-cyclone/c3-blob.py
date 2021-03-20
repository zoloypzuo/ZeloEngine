# -*- coding: utf-8 -*-
# @author: zoloypzuo
# @contact: zuoyiping01@corp.netease.com
# blob.py
# created on 2021/3/5
# usage: blob
from cyclone_demo_app import Application
from cyclone_demo_common import *

BLOB_COUNT = 5
PLATFORM_COUNT = 10
BLOB_RADIUS = 0.4


class Platform(ParticleContactGenerator):
    restitution = 0.0

    def __init__(self):  # noqa
        super(Platform, self).__init__()
        self.start = Vector3()
        self.end = Vector3()
        self.particles = []

    def addContact(self, contact, limit):
        return 0  # TODO


class BlobForceGenerator(ParticleForceGenerator):
    def __init__(self):
        super(BlobForceGenerator, self).__init__()
        self.particles = []
        self.maxReplusion = 0
        self.maxAttraction = 0
        self.minNaturalDistance, maxNaturalDistance = 0, 0
        self.floatHead = 0
        self.maxFloat = 0
        self.maxDistance = 0

    def updateForce(self, particle, duration):
        pass  # TODO


class BlobDemo(Application):
    def initialize(self):
        super(BlobDemo, self).initialize()
        self.blobs = [Particle() for _ in xrange(BLOB_COUNT)]
        self.platforms = [Platform() for _ in xrange(PLATFORM_COUNT)]
        self.world = ParticleWorld(PLATFORM_COUNT + BLOB_COUNT, PLATFORM_COUNT)
        self.blobForceGenerator = BlobForceGenerator()
        self.xAxis = 0
        self.yAxis = 0

        self.blobForceGenerator.particles = self.blobs
        self.blobForceGenerator.maxAttraction = 20.0
        self.blobForceGenerator.maxReplusion = 10.0
        self.blobForceGenerator.minNaturalDistance = BLOB_RADIUS * 0.75
        self.blobForceGenerator.maxNaturalDistance = BLOB_RADIUS * 1.5
        self.blobForceGenerator.maxDistance = BLOB_RADIUS * 2.5
        self.blobForceGenerator.maxFloat = 2
        self.blobForceGenerator.floatHead = 8.0

        r = Random()
        for i, platform in enumerate(self.platforms):
            platform.start = Vector3(
                (i % 2) * 10.0 - 5.0 + r.randomBinomial(2.0),
                i * 4.0 + 0.0 if i % 2 else 2.0 + r.randomBinomial(2.0),
                0
            )

            platform.end = Vector3(
                (i % 2) * 10.0 + 5.0 + r.randomBinomial(2.0),
                i * 4.0 + 0.0 if not i % 2 else 2.0 + r.randomBinomial(2.0),
                0
            )
            platform.particles = self.blobs
            self.world.appendContactGenerator(platform)

        p = self.platforms[PLATFORM_COUNT - 2]
        fraction = 1.0 / BLOB_COUNT
        delta = p.end - p.start
        for i, blob in enumerate(self.blobs):
            me = (i + BLOB_COUNT / 2) % BLOB_COUNT
            blob.setPosition(
                p.start + delta * (me * 0.8 * fraction + 0.1) + Vector3(0, 1.0 + r.randomReal(), 0)
            )
            blob.setVelocity(0, 0, 0)
            blob.setDamping(0.2)
            blob.setMass(1.0)
            self.world.appendParticles(blob)
            self.world.getForceRegistry().add(blob, self.blobForceGenerator)

    def reset(self):
        pass  # TODO

    def update(self):
        self.world.startFrame()
        duration = 1 / 30.
        self.xAxis *= pow(0.1, duration)
        self.yAxis *= pow(0.1, duration)

        self.blobs[0].addForce(Vector3(self.xAxis, self.yAxis, 0) * 10.0)

        self.world.runPhysics(duration)

        for i in xrange(BLOB_COUNT):
            pos = self.blobs[i].getPosition()
            pos.z = 0.0
            self.blobs[i].setPosition(pos)
        super(BlobDemo, self).update()

    def display(self):
        pos = self.blobs[0].getPosition()

        # Clear the view port and set the camera direction
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
        glLoadIdentity()
        gluLookAt(pos.x, pos.y, 6.0, pos.x, pos.y, 0.0, 0.0, 1.0, 0.0)

        glColor3f(0, 0, 0)

        glBegin(GL_LINES)
        glColor3f(0, 0, 1)
        for platform in self.platforms:
            p0 = platform.start
            p1 = platform.end
            glVertex3f(p0.x, p0.y, p0.z)
            glVertex3f(p1.x, p1.y, p1.z)
        glEnd()

        glColor3f(1, 0, 0)

        for blob in self.blobs:
            p = blob.getPosition()
            glPushMatrix()
            glTranslatef(p.x, p.y, p.z)
            glutSolidSphere(BLOB_RADIUS, 12, 12)
            glPopMatrix()

        p = self.blobs[0].getPosition()
        v = self.blobs[0].getVelocity() * 0.05
        v.trim(BLOB_RADIUS * 0.5)
        p = p + v
        glPushMatrix()
        glTranslatef(p.x - BLOB_RADIUS * 0.2, p.y, BLOB_RADIUS)
        glColor3f(1, 1, 1)
        glutSolidSphere(BLOB_RADIUS * 0.2, 8, 8)
        glTranslatef(0, 0, BLOB_RADIUS * 0.2)
        glColor3f(0, 0, 0)
        glutSolidSphere(BLOB_RADIUS * 0.1, 8, 8)
        glTranslatef(BLOB_RADIUS * 0.4, 0, -BLOB_RADIUS * 0.2)
        glColor3f(1, 1, 1)
        glutSolidSphere(BLOB_RADIUS * 0.2, 8, 8)
        glTranslatef(0, 0, BLOB_RADIUS * 0.2)
        glColor3f(0, 0, 0)
        glutSolidSphere(BLOB_RADIUS * 0.1, 8, 8)
        glPopMatrix()

        super(BlobDemo, self).display()

    def getTitle(self):
        return "Cyclone > Blob Demo"

    def key(self, key, x, y):
        if key.lower() == 'w':
            self.yAxis = 1.0
        elif key.lower() == 's':
            self.yAxis = -1.0
        elif key.lower() == 'a':
            self.xAxis = -1.0
        elif key.lower() == 'd':
            self.xAxis = 1.0
        elif key.lower() == 'r':
            self.reset()


if __name__ == '__main__':
    BlobDemo()
