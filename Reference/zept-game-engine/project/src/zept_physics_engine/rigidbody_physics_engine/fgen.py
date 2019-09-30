from project.src.zept_physics_engine.rigidbody_physics_engine.Registry import Registry
from project.src.zept_physics_engine.rigidbody_physics_engine.body import RigidBody


class ForceGenerator:
    def updateForce(self, body: RigidBody, duration: float):
        pass


class ForceRegistry:
    def __init__(self):
        self.registry = set()

    def add(self, rb: RigidBody, fg: ForceGenerator) -> None:
        self.registry.add((rb, fg))

    def remove(self, rb: RigidBody, fg: ForceGenerator) -> None:
        self.registry.remove((rb, fg))

    def clear(self) -> None:
        self.registry.clear()

    def updateForces(self, duration: float) -> None:
        for i in self.registry:
            rb, fg = i
            fg.updateForce(rb, duration)
