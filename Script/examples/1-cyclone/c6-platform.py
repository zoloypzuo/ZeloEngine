# coding=utf-8
# c6-platform.py
# created on 2021/3/7
# author @zoloypzuo
# usage: c6-platform
from cyclone_demo_app import MassAggregateApplication
from cyclone_demo_common import *
from framework.zmath import Clamp

ROD_COUNT = 15
BASE_MASS = 1
EXTRA_MASS = 10


class PlatformDemo(MassAggregateApplication):
    ROD_COUNT = 15
    BASE_MASS = 1
    EXTRA_MASS = 10

    def initialize(self):
        super(PlatformDemo, self).initialize()
        self.rods = [ParticleRod() for _ in xrange(self.ROD_COUNT)]
        self.massPos = Vector3(0, 0, 0.5)
        self.massDisplayPos = Vector3()
        # Create the masses and connections.
        self.particleArray[0].setPosition(0, 0, 1)
        self.particleArray[1].setPosition(0, 0, -1)
        self.particleArray[2].setPosition(-3, 2, 1)
        self.particleArray[3].setPosition(-3, 2, -1)
        self.particleArray[4].setPosition(4, 2, 1)
        self.particleArray[5].setPosition(4, 2, -1)
        for i in xrange(6):
            self.particleArray[i].setMass(self.BASE_MASS)
            self.particleArray[i].setVelocity(0, 0, 0)
            self.particleArray[i].setDamping(0.9)
            self.particleArray[i].clearAccumulator()

        self.rods[0].setParticle0(self.particleArray[0])
        self.rods[0].setParticle1(self.particleArray[1])
        self.rods[0].length = 2
        self.rods[1].setParticle0(self.particleArray[2])
        self.rods[1].setParticle1(self.particleArray[3])
        self.rods[1].length = 2
        self.rods[2].setParticle0(self.particleArray[4])
        self.rods[2].setParticle1(self.particleArray[5])
        self.rods[2].length = 2

        self.rods[3].setParticle0(self.particleArray[2])
        self.rods[3].setParticle1(self.particleArray[4])
        self.rods[3].length = 7
        self.rods[4].setParticle0(self.particleArray[3])
        self.rods[4].setParticle1(self.particleArray[5])
        self.rods[4].length = 7

        self.rods[5].setParticle0(self.particleArray[0])
        self.rods[5].setParticle1(self.particleArray[2])
        self.rods[5].length = 3.606
        self.rods[6].setParticle0(self.particleArray[1])
        self.rods[6].setParticle1(self.particleArray[3])
        self.rods[6].length = 3.606

        self.rods[7].setParticle0(self.particleArray[0])
        self.rods[7].setParticle1(self.particleArray[4])
        self.rods[7].length = 4.472
        self.rods[8].setParticle0(self.particleArray[1])
        self.rods[8].setParticle1(self.particleArray[5])
        self.rods[8].length = 4.472

        self.rods[9].setParticle0(self.particleArray[0])
        self.rods[9].setParticle1(self.particleArray[3])
        self.rods[9].length = 4.123
        self.rods[10].setParticle0(self.particleArray[2])
        self.rods[10].setParticle1(self.particleArray[5])
        self.rods[10].length = 7.28
        self.rods[11].setParticle0(self.particleArray[4])
        self.rods[11].setParticle1(self.particleArray[1])
        self.rods[11].length = 4.899
        self.rods[12].setParticle0(self.particleArray[1])
        self.rods[12].setParticle1(self.particleArray[2])
        self.rods[12].length = 4.123
        self.rods[13].setParticle0(self.particleArray[3])
        self.rods[13].setParticle1(self.particleArray[4])
        self.rods[13].length = 7.28
        self.rods[14].setParticle0(self.particleArray[5])
        self.rods[14].setParticle1(self.particleArray[0])
        self.rods[14].length = 4.899

        for rod in self.rods:
            self.world.appendContactGenerator(rod)

        self.updateAdditionalMass()

    def update(self):
        super(PlatformDemo, self).update()
        self.updateAdditionalMass()

    def updateAdditionalMass(self):
        for i in xrange(2, 6):
            self.particleArray[i].setMass(self.BASE_MASS)

        xp = self.massPos.x
        xp = Clamp(xp, 0, 1)
        zp = self.massPos.z
        zp = Clamp(zp, 0, 1)
        self.massDisplayPos.clear()

        self.particleArray[2].setMass(self.BASE_MASS + self.EXTRA_MASS * (1 - xp) * (1 - zp))
        # Add the proportion to the correct masses
        self.particleArray[2].setMass(BASE_MASS + EXTRA_MASS * (1 - xp) * (1 - zp))
        self.massDisplayPos.addScaledVector(
            self.particleArray[2].getPosition(), (1 - xp) * (1 - zp)
        )

        if (xp > 0):
            self.particleArray[4].setMass(BASE_MASS + EXTRA_MASS * xp * (1 - zp))
            self.massDisplayPos.addScaledVector(
                self.particleArray[4].getPosition(), xp * (1 - zp)
            )

            if (zp > 0):
                self.particleArray[5].setMass(BASE_MASS + EXTRA_MASS * xp * zp)
                self.massDisplayPos.addScaledVector(
                    self.particleArray[5].getPosition(), xp * zp
                )
        if (zp > 0):
            self.particleArray[3].setMass(BASE_MASS + EXTRA_MASS * (1 - xp) * zp)
            self.massDisplayPos.addScaledVector(
                self.particleArray[3].getPosition(), (1 - xp) * zp
            )

    def display(self):
        super(PlatformDemo, self).display()

        glBegin(GL_LINES)
        glColor3f(0, 0, 1)
        for i in xrange(self.ROD_COUNT):
            rod = self.rods[i]
            p0 = rod.getParticle0().getPosition()
            p1 = rod.getParticle1().getPosition()
            glVertex3f(p0.x, p0.y, p0.z)
            glVertex3f(p1.x, p1.y, p1.z)
        glEnd()

        glColor3f(1, 0, 0)
        glPushMatrix()
        glTranslatef \
            (self.massDisplayPos.x,
             self.massDisplayPos.y + 0.25,
             self.massDisplayPos.z)
        glutSolidSphere(0.25, 20, 10)
        glPopMatrix()
        glutSwapBuffers()

    def getTitle(self):
        return "Cyclone > Platform Demo"

    def key(self, key, x, y):
        key = key.lower()
        if key == 'w':
            self.massPos.z += 0.1
        elif key == 's':
            self.massPos.z -= 0.1
        elif key == 'a':
            self.massPos.x -= 0.1
        elif key == 'd':
            self.massPos.x += 0.1
        else:
            super(PlatformDemo, self).key()
        self.massPos.z = Clamp(self.massPos.z, 0.0, 1.0)
        self.massPos.x = Clamp(self.massPos.x, 0.0, 1.0)


if __name__ == '__main__':
    PlatformDemo()
