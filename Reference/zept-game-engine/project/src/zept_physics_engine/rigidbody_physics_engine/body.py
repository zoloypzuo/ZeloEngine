from project.src.ZeptUnityEngine.CoreModule import Vector3
from project.src.zept_physics_engine.rigidbody_physics_engine.core import Matrix4, Matrix3


class RigidBody:
    def __init__(self):
        self.inverseMass: float
        self.inverseInertiaTensor: Matrix3
        self.linearDamping: float
        self.angularDamping: float
        self.orientation: Vector3
        self.velocity: Vector3
        self.rotation: Vector3
        self.inverseInertiaTensorWorld: Matrix3
        self.motion: float
        self.isAwake: bool
        self.canSleep: bool
        self.transformMatrix: Matrix4
        self.forceAccum: Vector3
        self.torqueAccum: Vector3
        self.acceleration: Vector3
        self.lastFrameAcceleration: Vector3

    def calculateDerivedData(self):
        pass

    def integrate(self, duration: float):
        pass

    def hasFiniteMass(self) -> bool:
        pass

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
    def inertiaTensor(self):
        return

    @inertiaTensor.setter
    def inertiaTensor(self, inertiaTensor):
        pass

    @property
    def inertiaTensorWorld(self):
        return

    def clearAccumulators(self):
        pass

    @property
    def position(self) -> Vector3:
        return Vector3
