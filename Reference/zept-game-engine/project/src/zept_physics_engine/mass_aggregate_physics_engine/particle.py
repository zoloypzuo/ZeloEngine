from project.src.ZeptUnityEngine.CoreModule.Vector3 import Vector3


class Particle:
    '''point mass'''

    def __init__(self, mass, damping, position, velocity, acceleration):
        self.inverseMass: float = 1 / mass
        self.damping: float = damping
        self.position: Vector3 = position
        self.velocity: Vector3 = velocity
        self._forceAccum: Vector3 = None
        self.acceleration: Vector3 = acceleration

    def integrate(self, duration: float) -> None:
        '''called every frame to update position and velocity
        formula 3.1
        We don't _integrate things with zero mass.
        '''
        assert duration > 0
        # region  We don't _integrate things with zero mass.
        if self.inverseMass <= 0:
            return
        # endregion
        else:
            self.position += duration * self.velocity
            resultingAcc = self.acceleration
            resultingAcc += self.inverseMass * self._forceAccum
            self.velocity += duration * resultingAcc
            self.velocity *= self.damping ** duration
            self._forceAccum = Vector3.zero

    @property
    def mass(self):
        if self.inverseMass == 0:
            return 1.7976931348623157e+308  # sys.float_info.max, while source code use DBL_MAX in <float.h> NEVER MIND
        else:
            return 1.0 / self.inverseMass

    @mass.setter
    def mass(self, mass):
        assert mass != 0
        self.inverseMass = 1.0 / mass

    @property
    def hasFiniteMass(self) -> bool:
        return self.inverseMass >= 0.0

    def addForce(self,force:Vector3):
        self._forceAccum+=force


