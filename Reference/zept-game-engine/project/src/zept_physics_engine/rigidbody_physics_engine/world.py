from typing import List

from project.src.zept_physics_engine.rigidbody_physics_engine.body import RigidBody

from typing import List

from project.src.zept_physics_engine.mass_aggregate_physics_engine.particle import Particle
from project.src.zept_physics_engine.mass_aggregate_physics_engine.pcontact import ParticleContactResolver, \
    ParticleContact, ParticleContactGenerator
from project.src.zept_physics_engine.mass_aggregate_physics_engine.pfgen import ParticleForceRegistry
from project.src.zept_physics_engine.rigidbody_physics_engine.contact import ContactResolver, ContactGenerator, Contact, \
    ContactBuffer
from project.src.zept_physics_engine.rigidbody_physics_engine.fgen import ForceRegistry



class World:
    '''
    example:
    world=World()
    while(True):
        world.startFrame()
        # runGraphicsUpdate()
        world.runPhysics(duration)
    '''

    def __init__(self, maxContacts: int, iterations: int = 0):
        self._rigidBodies: List[RigidBody] = []
        self._force_registry: ForceRegistry = ForceRegistry()
        calculateIterations: bool = (iterations == 0)
        if calculateIterations:
            self._resolver.iterations = self._contact_buffer.n_used * 4
        else:
            pass
        self._resolver: ContactResolver = ContactResolver(iterations)
        self._contactGenerators: List[ContactGenerator] = []
        self._contact_buffer: ContactBuffer = ContactBuffer(capacity=maxContacts)


    def startFrame(self):
        for i in self._rigidBodies:
            i.clearAccumulators()
            i.calculateDerivedData()

    def _genreateContacts(self) -> None:
        for i in self._contactGenerators:
            if not i.generateContact(self._contact_buffer):
                break

    def _integrate(self, duration: float) -> None:
        for p in self._rigidBodies:
            p.integrate(duration)

    def runPhysics(self, duration: float) -> None:
        self._force_registry.updateForces(duration)
        self._integrate(duration)
        self._genreateContacts()
        self._resolver.resolveContacts(self._contact_buffer.used, duration)
