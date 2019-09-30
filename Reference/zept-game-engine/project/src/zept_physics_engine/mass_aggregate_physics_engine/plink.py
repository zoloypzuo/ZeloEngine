from project.src.zept_physics_engine.mass_aggregate_physics_engine.particle import Particle
from project.src.zept_physics_engine.mass_aggregate_physics_engine.pcontact import ParticleContact, ParticleContactGenerator


class ParticleLink(ParticleContactGenerator):
    def __init__(self):
        self.particle0: Particle = None
        self.particle1: Particle = None

    @property
    def _currentLength(self) -> float:
        return 0

    def fillContact(self, contact: ParticleContact, limit: int) -> int:
        pass


class ParticleCable(ParticleLink):
    def __init__(self):
        super().__init__()
        self.maxLength: float = 0
        self.restitution: float = 0

    @property
    def _currentLength(self) -> float:
        relativePos = self.particle0.position - self.particle1.position
        return relativePos.magnitude

    def fillContact(self, contact: ParticleContact, limit: int) -> int:
        length = self._currentLength
        if length < self.maxLength:
            return 0
        else:
            contact.particle0 = self.particle0
            contact.particle1 = self.particle1
            normal = (self.particle1.position - self.particle0.position).normalized
            contact.contactNormal = normal
            contact.penetration = length - self.maxLength
            contact.restitution = self.restitution
            return 1


class ParticleRod(ParticleLink):
    def __init__(self):
        super().__init__()
        self.length: float = 0

    @property
    def _currentLength(self):
        relativePos = self.particle0.position - self.particle1.position
        return relativePos.magnitude

    def fillContact(self, contact: ParticleContact, limit: int) -> int:
        currentLen = self._currentLength
        if currentLen == self.length:
            return 0
        else:
            contact.particle0 = self.particle0
            contact.particle1 = self.particle1
            normal = (self.particle1.position - self.particle0.position).normalized
            if currentLen > self.length:
                contact.contactNormal = normal
                contact.penetration = currentLen - self.length
            else:
                contact.contactNormal = normal * -1
                contact.penetration = self.length - currentLen
            contact.restitution = 0
            return 1
