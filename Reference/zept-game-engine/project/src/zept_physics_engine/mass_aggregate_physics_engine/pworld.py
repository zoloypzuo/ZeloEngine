from typing import List

from project.src.zept_physics_engine.mass_aggregate_physics_engine.particle import Particle
from project.src.zept_physics_engine.mass_aggregate_physics_engine.pcontact import ParticleContactResolver, \
    ParticleContact, ParticleContactGenerator
from project.src.zept_physics_engine.mass_aggregate_physics_engine.pfgen import ParticleForceRegistry


class ParticleWorld:
    '''
    '''

    def __init__(self, maxContacts: int, iterations: int = 0):
        self._particles: List[Particle] = None
        self._registry: ParticleForceRegistry = ParticleForceRegistry()
        self._resolver: ParticleContactResolver = None
        self._contactGenerators: List[ParticleContactGenerator] = None
        self._contacts: List[ParticleContact] = [ParticleContact() for i in range(maxContacts)]
        self._maxContacts: int = maxContacts  # size of _contacts
        self.calculateIterations: bool = iterations == 0

    def _startFrame(self):
        for i in self._particles:
            pass  # TODO clear p force acc

    def _genreateContacts(self) -> int:
        limit = self._maxContacts
        nextContactIndex = 0
        for i in self._contactGenerators:
            used = i.addContact(self._contacts[nextContactIndex], limit)
            limit -= used
            nextContactIndex += used
            if limit <= 0:
                break
        return self._maxContacts - limit

    def _integrate(self, duration: float) -> None:
        for p in self._particles:
            p.integrate(duration)

    def runPhysics(self, duration: float) -> None:
        self._registry.updateForces(duration)
        self._integrate(duration)
        usedContacts = self._genreateContacts()
        if usedContacts != 0:
            if self.calculateIterations:
                self._resolver.iterations = usedContacts * 2
            else:
                pass
            self._resolver.resolveContacts(self._contacts, duration)
        else:
            pass

    @property
    def particles(self):
        return self._particles

    @property
    def contactGenerator(self):
        return self._contactGenerators

    @property
    def forceRegistry(self):
        return self._resolver
