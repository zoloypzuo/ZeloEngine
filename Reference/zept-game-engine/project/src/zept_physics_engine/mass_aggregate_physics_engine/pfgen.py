from project.src.ZeptUnityEngine.CoreModule import Vector3
from project.src.ZeptUnityEngine.CoreModule.Mathf import Mathf
from project.src.zept_physics_engine.mass_aggregate_physics_engine.particle import Particle


class ParticleForceGenerator:
    def updateForce(self, particle: Particle, duration: float) -> None:
        pass


class ParticleForceRegistry:
    def __init__(self):
        self.registry = set()

    def add(self, particle: Particle, fg: ParticleForceGenerator) -> None:
        self.registry.add((particle, fg))

    def remove(self, particle: Particle, fg: ParticleForceGenerator) -> None:
        self.registry.remove((particle, fg))

    def clear(self) -> None:
        self.registry.clear()

    def updateForces(self, duration: float) -> None:
        for i in self.registry:
            particle, fg = i
            fg.updateForce(particle, duration)


class ParticleGravity(ParticleForceGenerator):
    '''formula 3.4'''

    def __init__(self, gravity):
        self.gravity: Vector3 = gravity

    def updateForce(self, particle: Particle, duration: float) -> None:
        '''formula 3.4'''
        if not particle.hasFiniteMass:  # Check that we do not have infinite mass
            return
        else:
            particle.addForce(self.gravity * particle.mass)


class ParticleDrag(ParticleForceGenerator):
    '''formula 5.1'''

    def __init__(self, k1, k2):
        self.k1 = k1
        self.k2 = k2

    def updateForce(self, particle: Particle, duration: float) -> None:
        '''formula 5.1'''
        force = particle.velocity
        dragCoeff = force.magnitude
        dragCoeff = self.k1 * dragCoeff + self.k2 * (dragCoeff ** 2)
        force = force.normalized * (-dragCoeff)
        particle.addForce(force)


class ParticleSpring(ParticleForceGenerator):
    '''formula 6.1'''

    def __init__(self, other, springConstant, restLength):
        self.other: Particle = other
        self.springConstant: float = springConstant
        self.restLength: float = restLength

    def updateForce(self, particle: Particle, duration: float) -> None:
        '''formula 6.1

        >>> a,b=Particle(),Particle()
        >>> registry=ParticleForceRegistry()
        >>> psA=ParticleSpring(b,1.0,2.0)
        >>> registry.add(a,psA)
        >>> psB=ParticleSpring(a,1.0,2.0)
        >>> registry.add(b,psB)
        '''
        force = particle.position
        force -= self.other.position
        magnitude = force.magnitude
        magnitude *= self.springConstant
        force = force.normalized
        force *= -magnitude
        particle.addForce(force)


class ParticleAnchoredSpring(ParticleForceGenerator):
    def __init__(self, anchor, springConstant, restLength):
        self.anchor: Vector3 = anchor
        self.springConstant: float = springConstant
        self.restLength: float = restLength

    def updateForce(self, particle: Particle, duration: float) -> None:
        force = particle.position
        force -= self.anchor
        magnitude = force.magnitude
        magnitude = abs(magnitude - self.restLength)
        magnitude *= self.springConstant
        force = force.normalized
        force *= -magnitude
        particle.addForce(force)


class ParticleBungee(ParticleForceGenerator):
    def __init__(self, other, springConstant, restLength):
        self.other: Particle = other
        self.springConstant: float = springConstant
        self.restLength: float = restLength

    def updateForce(self, particle: Particle, duration: float) -> None:
        force = particle.position
        force -= self.other.position
        magnitude = force.magnitude
        if magnitude <= self.restLength:
            return
        else:
            magnitude = self.springConstant * (self.restLength - magnitude)
            force = force.normalized
            force *= -magnitude
            particle.addForce(force)


class ParticleBuoyancy(ParticleForceGenerator):
    def __init__(self, maxDepth, volume, waterHeight, liquidDensity):
        self.maxDepth: float = maxDepth
        self.volume: float = volume
        self.waterHeight: float = waterHeight
        self.liquidDensity: float = liquidDensity

    def updateForce(self, particle: Particle, duration: float) -> None:
        depth = particle.position.y
        if depth <= self.waterHeight + self.maxDepth:  # Check if we're out of the water
            return
        else:
            force = Vector3.zero
            if depth <= self.waterHeight - self.maxDepth:  # Check if we're at maximum depth
                force.y = self.liquidDensity * self.volume
            else:  # Otherwise we are partly submerged
                d = (depth - self.maxDepth - self.waterHeight) / 2 * self.maxDepth
                force.y = self.liquidDensity * self.volume * d
            particle.addForce(force)


class ParticleFakeSpring(ParticleForceGenerator):
    def __init__(self, anchor, springConstant, damping):
        self.anchor: Vector3 = anchor
        self.springConstant: float = springConstant
        self.damping: float = damping
        self._gamma = 0.5 * Mathf.Sqrt(4 * springConstant - damping ** 2)

    def updateForce(self, particle: Particle, duration: float) -> None:
        if not particle.hasFiniteMass:
            return
        else:
            position = particle.position
            position -= self.anchor
            gamma = self._gamma
            c = position * (self.damping / (2.0 * gamma)) + particle.velocity * (1.0 / gamma)
            target = position * Mathf.Cos(gamma * duration) + c * Mathf.Sin(gamma * duration)
            target *= Mathf.Exp(-0.5 * duration * self.damping)
            accel = (target - position) * (1.0 / duration ** 2) - particle.velocity * duration
            particle.addForce(accel * particle.mass)
