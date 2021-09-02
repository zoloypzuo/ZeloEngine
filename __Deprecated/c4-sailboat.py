# coding=utf-8
# sailboat.py
# created on 2021/3/6
# author @zoloypzuo
# usage: sailboat
from cyclone_demo_app import Application
from cyclone_demo_common import *


def drawBoat():
    # Left Hull
    glPushMatrix()
    glTranslatef(0, 0, -1.0)
    glScalef(2.0, 0.4, 0.4)
    glutSolidCube(1.0)
    glPopMatrix()

    # Right Hull
    glPushMatrix()
    glTranslatef(0, 0, 1.0)
    glScalef(2.0, 0.4, 0.4)
    glutSolidCube(1.0)
    glPopMatrix()

    # Deck
    glPushMatrix()
    glTranslatef(0, 0.3, 0)
    glScalef(1.0, 0.1, 2.0)
    glutSolidCube(1.0)
    glPopMatrix()

    # Mast
    glPushMatrix()
    glTranslatef(0, 1.8, 0)
    glScalef(0.1, 3.0, 0.1)
    glutSolidCube(1.0)
    glPopMatrix()


class SailboatDemo(Application):
    r = Random()

    def initialize(self):
        super(SailboatDemo, self).initialize()
        self.windspeed = Vector3(0, 0, 0)
        self.sail = AeroEx(
            Matrix3(
                0, 0, 0,
                0, 0, 0,
                0, 0, -1.0),
            Vector3(2.0, 0, 0),
            self.windspeed
        )
        self.buoyancy = Buoyancy(Vector3(0.0, 0.5, 0.0), 1.0, 3.0, 1.6)
        self.sail_control = 0

        self.sailboat = sailboat = RigidBody()

        # Set up the boat's rigid body.
        sailboat.setPosition(0, 1.6, 0)
        sailboat.setOrientation(1, 0, 0, 0)

        sailboat.setVelocity(0, 0, 0)
        sailboat.setRotation(0, 0, 0)

        sailboat.setMass(200.0)
        it = Matrix3()
        it.setBlockInertiaTensor(Vector3(2, 1, 1), 100.0)
        sailboat.setInertiaTensor(it)

        sailboat.setDamping(0.8, 0.8)

        sailboat.calculateDerivedData()

        sailboat.setAwake()
        sailboat.setCanSleep(False)

        self.registry = ForceRegistry()
        self.registry.add(self.sailboat, self.sail)
        self.registry.add(self.sailboat, self.buoyancy)

    def update(self):
        duration = 1 / 30.

        # Start with no forces or acceleration.
        self.sailboat.clearAccumulators()

        # Add the forces acting on the boat.
        self.registry.updateForces(duration)

        # Update the boat's physics.
        self.sailboat.integrate(duration)

        # Change the wind speed.
        self.windspeed = self.windspeed * 0.9 + self.r.randomXZVector(1.0)
        self.sail.updateWindspeed(self.windspeed)

        super(SailboatDemo, self).update()

    def display(self):
        # Clear the view port and set the camera direction
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
        glLoadIdentity()

        sailboat = self.sailboat
        pos = sailboat.getPosition()
        offset = Vector3(4.0, 0, 0)
        offset = sailboat.getTransform().transformDirection(offset)
        gluLookAt(pos.x + offset.x, pos.y + 5.0, pos.z + offset.z,
                  pos.x, pos.y, pos.z,
                  0.0, 1.0, 0.0)

        glColor3f(0.6, 0.6, 0.6)
        bx = int(pos.x)
        bz = int(pos.z)
        glBegin(GL_QUADS)
        for x in xrange(-20, 20):
            for z in xrange(-20, 20):
                glVertex3f(bx + x - 0.1, 0, bz + z - 0.1)
                glVertex3f(bx + x - 0.1, 0, bz + z + 0.1)
                glVertex3f(bx + x + 0.1, 0, bz + z + 0.1)
                glVertex3f(bx + x + 0.1, 0, bz + z - 0.1)
        glEnd()

        # Set the transform matrix for the aircraft
        gl_transform = GLArray(sailboat.getTransform().data)
        glPushMatrix()
        glMultMatrixf(gl_transform)

        # Draw the boat
        glColor3f(0, 0, 0)
        drawBoat()
        glPopMatrix()

        # char buffer[256]
        # sprintf(
        #     buffer,
        #     "Speed %.1",
        #     sailboat.getVelocity().magnitude()
        #     )
        # glColor3f(0,0,0)
        # renderText(10.0, 24.0, buffer)

        # sprintf(
        #     buffer,
        #     "Sail Control: %.1",
        #     sail_control
        #     )
        # renderText(10.0, 10.0, buffer)
        super(SailboatDemo, self).display()


if __name__ == '__main__':
    SailboatDemo()
