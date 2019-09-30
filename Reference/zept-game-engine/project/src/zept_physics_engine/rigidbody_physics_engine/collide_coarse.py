import math

from project.src.ZeptUnityEngine.CoreModule import Vector3
from project.src.zept_physics_engine.rigidbody_physics_engine.body import RigidBody


class BoundingSphere:
    def __init__(self, center, radius):
        self.center: Vector3 = center
        self.radius: float = radius

    @property
    def volume(self):
        return 4 / 3 * math.pi * (self.radius ** 3)


def create_enclosing_bounding_sphere(s0: BoundingSphere, s1: BoundingSphere) -> BoundingSphere:
    pass


def overlap(s0: BoundingSphere, s1: BoundingSphere) -> bool:
    pass

class PotentialContact:
    def __init__(self):
        self.rb0:RigidBody
        self.rb1:RigidBody


class Node:
    def __init__(self):
        self.child0:Node
        self.child1:Node
        self.parent:Node

        self.rb:RigidBody
