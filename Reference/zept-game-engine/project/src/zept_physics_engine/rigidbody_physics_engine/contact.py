from project.src.ZeptUnityEngine.CoreModule import Vector3

from typing import List

from project.src.zept_physics_engine.rigidbody_physics_engine.body import RigidBody
from project.src.zept_physics_engine.rigidbody_physics_engine.core import Matrix3


class Contact:
    def __init__(self):
        self.rb0: RigidBody = None
        self.rb1: RigidBody = None  # can be None for contacts with the scenery

        self.restitution: float = None
        self.friction: float = 0

        self.contactNormal: Vector3 = None
        self.penetration: float = None
        self.contactPoint: Vector3 = None

    def setData(self, rb0, rb1,
                friction, restitution,
                contactNormal, penetration, contactPoint):
        self.rb0: RigidBody = rb0
        self.rb1: RigidBody = rb1  # can be None for contacts with the scenery

        self.restitution: float = restitution
        self.friction: float = friction

        self.contactNormal: Vector3 = contactNormal
        self.penetration: float = penetration
        self.contactPoint: Vector3 = contactPoint


class ContactResolver:
    def resolveContacts(self, contactArray: List[Contact],
                        duration: float):  # 'numContacts: int,' is no use for python
        Epsilon = 0.01
        nIterations = len(contactArray) * 4
        nIterationsUsed: int

        # min_item = min(contactArray, key=lambda x: x.calculateSeparatingVelocity())
        # min_item.resolve(duration)

        # region prepare

        # endregion
        # #region position
        nIterationsUsed = 0
        while nIterationsUsed < nIterations:
            nIterationsUsed += 1
        # endregion
        # #region velocity
        nIterationsUsed = 0
        while nIterationsUsed < nIterations:
            nIterationsUsed += 1
        # endregion


class ContactBuffer:

    def __init__(self, capacity):
        self._buffer = [Contact() for i in range(capacity)]
        self._mark = 0  # next unused item index

    def allocate(self, size=0):
        '''allocate one item by default, if allocation fails, return None, if size>0, return an array of items'''
        if not self.can_allocate(size):
            return None
        else:
            if size == 0:
                item = self._buffer[self._mark]
                self._mark += 1
                return item
            else:
                items = self._buffer[self._mark:self._mark + size]
                self._mark += size
                return items

    def clear(self):
        '''mark all items in pool as unused'''
        self._mark = 0

    def can_allocate(self, size=0) -> bool:
        return self._mark + size >= len(self._buffer)

    @property
    def n_unused(self):
        return len(self._buffer) - self._mark  # TODO check it

    @property
    def n_used(self):
        return self._mark

    @property
    def used(self):
        '''return a slice of used items'''
        return self._buffer[:self._mark]


class ContactGenerator:
    def generateContact(self, contact_buffer: ContactBuffer) -> bool:
        '''inject a /contact_buffer/, write to buffer if there is enough n_unused and return True'''
        pass


class CollisionPrimitive:
    def __init__(self):
        self.rb: RigidBody = None


class CollisionSphere(CollisionPrimitive):
    def __init__(self):
        super().__init__()
        self.radius: float = None


class CollisionPlane:
    def __init__(self):
        self.direction: Vector3
        self.offset: float


class CollisionBox(CollisionPrimitive):
    def __init__(self):
        super().__init__()
        self.halfSize: Vector3


class SphereAndSphereIntersection(ContactGenerator):
    def __init__(self, s1: CollisionSphere, s2: CollisionSphere, friction, restitution):
        self.s2 = s1
        self.s2 = s2
        self.friction = friction
        self.restitution = restitution

    def generateContact(self, contact_buffer: ContactBuffer) -> bool:
        if not contact_buffer.can_allocate():
            return False
        else:
            s1 = self.s2
            s2 = self.s2

            p1 = s1.rb.position
            mid_line: Vector3 = p1 - s2.rb.position
            size = mid_line.magnitude
            if size <= 0.0 or size >= s1.radius + s2.radius:
                return False
            else:
                contact = contact_buffer.allocate()
                contact.setData(s1.rb, s2.rb, self.friction, self.restitution,
                                contactNormal=mid_line * (1.0 / size),
                                contactPoint=p1 + mid_line * 0.5,
                                penetration=s1.radius + s2.radius - size)
                return True
