from project.src.ZeptUnityEngine.CoreModule import Vector3
from project.src.zept_physics_engine.mass_aggregate_physics_engine.particle import Particle

from typing import List


class ParticleContact:
    def __init__(self):
        self.particle0: Particle = None
        self.particle1: Particle = None  # can be None for contacts with the scenery
        self.restitution: float = None
        self.contactNormal: Vector3 = None
        self.penetration: float = None

    def resolve(self, duration: float):
        self._resolveVelocity(duration)
        self._resolveInterpenetration(duration)

    @property
    def separatingVeloctiy(self) -> Vector3:
        relativeVelocity = self.particle0.velocity
        if self.particle1:
            relativeVelocity -= self.particle1.velocity
        else:
            pass
        return relativeVelocity * self.contactNormal

    def _resolveVelocity(self, duration: float) -> None:
        separatingVelocity = self.separatingVeloctiy
        # region
        '''The contact is either separating, or stationary - there's no impulse required.'''
        if separatingVelocity > 0:  # Check if it needs to be resolved
            return
        # endregion
        else:
            newSepVelocity = -separatingVelocity * self.restitution
            # region handle resting contact
            accCausedVelocity = self.particle0.acceleration
            if self.particle0:
                accCausedVelocity -= self.particle1.acceleration
            else:
                pass
            accCausedSepVelocity = accCausedVelocity * self.contactNormal * duration
            if accCausedSepVelocity < 0:
                newSepVelocity += self.restitution * accCausedSepVelocity
                if newSepVelocity < 0:
                    newSepVelocity = 0
                else:
                    pass
            else:
                pass
            # endregion

            deltaVelocity = newSepVelocity - separatingVelocity
            totalInverseMass = self.particle0.inverseMass
            if self.particle1:
                totalInverseMass += self.particle1.inverseMass
            else:
                pass
            if totalInverseMass <= 0:
                return
            else:
                impulse = deltaVelocity / totalInverseMass
                impulsePerIMass = self.contactNormal * impulse
                self.particle0.velocity += impulsePerIMass * self.particle0.inverseMass
                if self.particle0:
                    self.particle1.velocity += impulsePerIMass * self.particle1.inverseMass
                else:
                    pass

    def _resolveInterpenetration(self, duration):
        if self.penetration <= 0:
            return
        else:
            totalInverseMass = self.particle0.inverseMass
            if self.particle1:
                totalInverseMass += self.particle1.inverseMass
            else:
                pass
            if totalInverseMass <= 0:
                return
            else:
                movePerIMass = self.contactNormal * (-self.penetration / totalInverseMass)
                self.particle0.position += movePerIMass * self.particle0.inverseMass
                if self.particle1:
                    self.particle1 += movePerIMass * self.particle1.inverseMass


class ParticleContactResolver:
    def __init__(self, iterations):
        self.iterations: int = iterations  # TODO change name to nIterations
        self._iterationsUsed: int = 0  # TODO change name to nIterationUsed

    def resolveContacts(self, contactArray: List[ParticleContact],
                        duration: float):  # 'numContacts: int,' is no use for python
        self._iterationsUsed = 0
        while self._iterationsUsed < self.iterations:  # TODO why use _iterationsUsed as a field
            min_item = min(contactArray, key=lambda x: x.calculateSeparatingVelocity())
            min_item.resolve(duration)
            self._iterationsUsed += 1


class ParticleContactGenerator:
    def addContact(self, contact: ParticleContact, limit: int) -> int:
        pass
