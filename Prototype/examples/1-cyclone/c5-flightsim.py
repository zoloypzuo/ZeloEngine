# coding=utf-8
# flightsim.py
# created on 2021/3/6
# author @zoloypzuo
# usage: flightsim
from cyclone_demo_app import Application
from cyclone_demo_common import *


def drawAircraft():
    # Fuselage
    glPushMatrix()
    glTranslatef(-0.5, 0, 0)
    glScalef(2.0, 0.8, 1.0)
    glutSolidCube(1.0)
    glPopMatrix()

    # Rear Fuselage
    glPushMatrix()
    glTranslatef(1.0, 0.15, 0)
    glScalef(2.75, 0.5, 0.5)
    glutSolidCube(1.0)
    glPopMatrix()

    # Wings
    glPushMatrix()
    glTranslatef(0, 0.3, 0)
    glScalef(0.8, 0.1, 6.0)
    glutSolidCube(1.0)
    glPopMatrix()

    # Rudder
    glPushMatrix()
    glTranslatef(2.0, 0.775, 0)
    glScalef(0.75, 1.15, 0.1)
    glutSolidCube(1.0)
    glPopMatrix()

    # Tail-plane
    glPushMatrix()
    glTranslatef(1.9, 0, 0)
    glScalef(0.85, 0.1, 2.0)
    glutSolidCube(1.0)
    glPopMatrix()


class FlightSimDemo(Application):
    def initialize(self):
        super(FlightSimDemo, self).initialize()
        self.windspeed = Vector3(0, 0, 0)
        self.right_wing = AeroControl(Matrix3(0, 0, 0, -1, -0.5, 0, 0, 0, 0),
                                      Matrix3(0, 0, 0, -0.995, -0.5, 0, 0, 0, 0),
                                      Matrix3(0, 0, 0, -1.005, -0.5, 0, 0, 0, 0),
                                      Vector3(-1.0, 0.0, 2.0), self.windspeed)

        self.left_wing = AeroControl(Matrix3(0, 0, 0, -1, -0.5, 0, 0, 0, 0),
                                     Matrix3(0, 0, 0, -0.995, -0.5, 0, 0, 0, 0),
                                     Matrix3(0, 0, 0, -1.005, -0.5, 0, 0, 0, 0),
                                     Vector3(-1.0, 0.0, -2.0), self.windspeed)

        self.rudder = AeroControl(Matrix3(0, 0, 0, 0, 0, 0, 0, 0, 0),
                                  Matrix3(0, 0, 0, 0, 0, 0, 0.01, 0, 0),
                                  Matrix3(0, 0, 0, 0, 0, 0, -0.01, 0, 0),
                                  Vector3(2.0, 0.5, 0), self.windspeed)

        self.tail = AeroEx(Matrix3(0, 0, 0, -1, -0.5, 0, 0, 0, -0.1),
                           Vector3(2.0, 0, 0), self.windspeed)

        self.left_wing_control, right_wing_control, rudder_control = 0, 0, 0

        self.aircraft = aircraft = RigidBody()
        self.resetPlane()

        aircraft.setMass(2.5)
        it = Matrix3()
        it.setBlockInertiaTensor(Vector3(2, 1, 1), 1)
        aircraft.setInertiaTensor(it)

        aircraft.setDamping(0.8, 0.8)

        aircraft.calculateDerivedData()

        aircraft.setAwake()
        aircraft.setCanSleep(False)

        self.registry = registry = ForceRegistry()
        registry.add(self.aircraft, self.tail)

        registry.add(self.aircraft, self.left_wing)
        registry.add(self.aircraft, self.right_wing)
        registry.add(self.aircraft, self.rudder)

    def update(self):
        # Find the duration of the last frame in seconds
        # float duration = (float)TimingData::get().lastFrameDuration * 0.001
        # if (duration <= 0.0) return
        duration = 1. / 30

        aircraft = self.aircraft
        # Start with no forces or acceleration.
        aircraft.clearAccumulators()

        # Add the propeller force
        propulsion = Vector3(-10.0, 0, 0)
        propulsion = aircraft.getTransform().transformDirection(propulsion)
        aircraft.addForce(propulsion)

        # Add the forces acting on the aircraft.
        self.registry.updateForces(duration)

        # Update the aircraft's physics.
        aircraft.integrate(duration)

        # Do a very basic collision detection and response with the ground.
        pos = aircraft.getPosition()

        if (pos.y < 0.0):
            pos.y = 0.0
            aircraft.setPosition(pos)

            if (aircraft.getVelocity().y < -10.0):
                self.resetPlane()

        super(FlightSimDemo, self).update()

    def display(self):
        # Clear the view port and set the camera direction
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT)
        glLoadIdentity()

        pos = self.aircraft.getPosition()
        offset = Vector3(4.0 + self.aircraft.getVelocity().magnitude(), 0, 0)
        offset = self.aircraft.getTransform().transformDirection(offset)
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
        gl_transform = GLArray(self.aircraft.getTransform().data)
        glPushMatrix()
        glMultMatrixf(gl_transform)

        # Draw the aircraft
        glColor3f(0, 0, 0)
        drawAircraft()
        glPopMatrix()

        glColor3f(0.8, 0.8, 0.8)
        glPushMatrix()
        glTranslatef(0, -1.0 - pos.y, 0)
        glScalef(1.0, 0.001, 1.0)
        glMultMatrixf(gl_transform)
        drawAircraft()
        glPopMatrix()

        # char buffer[256]
        # sprintf(
        #     buffer,
        #     "Altitude: %.1 | Speed %.1",
        #     aircraft.getPosition().y,
        #     aircraft.getVelocity().magnitude()
        #     )
        # glColor3f(0,0,0)
        # renderText(10.0, 24.0, buffer)

        # sprintf(
        #     buffer,
        #     "Left Wing: %.1 | Right Wing: %.1 | Rudder %.1",
        #     left_wing_control, right_wing_control, rudder_control
        #     )
        # renderText(10.0, 10.0, buffer)
        super(FlightSimDemo, self).display()

    def resetPlane(self):
        self.aircraft.setPosition(0, 0, 0)
        self.aircraft.setOrientation(1, 0, 0, 0)

        self.aircraft.setVelocity(0, 0, 0)
        self.aircraft.setRotation(0, 0, 0)

    def getTitle(self):
        return "Cyclone > Flight Sim Demo"


# TODO
# void FlightSimDemo::key(unsigned char key)
# {
#     switch(key)
#     {
#     case 'q': case 'Q':
#         rudder_control += 0.1
#         break

#     case 'e': case 'E':
#         rudder_control -= 0.1
#         break

#     case 'w': case 'W':
#         left_wing_control -= 0.1
#         right_wing_control -= 0.1
#         break

#     case 's': case 'S':
#         left_wing_control += 0.1
#         right_wing_control += 0.1
#         break

#     case 'd': case 'D':
#         left_wing_control -= 0.1
#         right_wing_control += 0.1
#         break

#     case 'a': case 'A':
#         left_wing_control += 0.1
#         right_wing_control -= 0.1
#         break

#     case 'x': case 'X':
#         left_wing_control = 0.0
#         right_wing_control = 0.0
#         rudder_control = 0.0
#         break

#     case 'r': case 'R':
#         resetPlane()
#         break

#     default:
#         Application::key(key)
#     }

#     # Make sure the controls are in range
#     if (left_wing_control < -1.0) left_wing_control = -1.0
#     else if (left_wing_control > 1.0) left_wing_control = 1.0
#     if (right_wing_control < -1.0) right_wing_control = -1.0
#     else if (right_wing_control > 1.0) right_wing_control = 1.0
#     if (rudder_control < -1.0) rudder_control = -1.0
#     else if (rudder_control > 1.0) rudder_control = 1.0

#     # Update the control surfaces
#     left_wing.setControl(left_wing_control)
#     right_wing.setControl(right_wing_control)
#     rudder.setControl(rudder_control)
# }


if __name__ == '__main__':
    FlightSimDemo()
