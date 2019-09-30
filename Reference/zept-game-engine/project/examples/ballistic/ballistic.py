from project.src.zept_physics_engine.mass_aggregate_physics_engine.particle import Particle


class AmmoRound:
    def __init__(self):
        self.particle: Particle = None
        self.type = ''
        self.startTime = 0

    def render(self):
        pass  # TODO gl* render by position


data = {
    "pistol": [2, [0, 0, 35], [0, -2, 0], 0.99],
    "artillery": [200, [0, 30, 40], [0, -20, 0], 0.99],
    "fireball": [1, [0, 0, 10], [0, 0.6, 0], 0.9],
    "laser": [0.1, [0, 0, 100], [0, 0, 0], 0.99]
}


def particle_factory(data):
    mass, velocity, acceleration, damping = data
    return Particle(mass, velocity, acceleration, damping)


def update():
    duration = 0  # TODO TimingData
    # for shot
