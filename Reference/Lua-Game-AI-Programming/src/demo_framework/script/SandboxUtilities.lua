--[[
  Copyright (c) 2013 David Young dayoung@goliathdesigns.com

  This software is provided 'as-is', without any express or implied
  warranty. In no event will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

   1. The origin of this software must not be misrepresented; you must not
   claim that you wrote the original software. If you use this software
   in a product, an acknowledgment in the product documentation would be
   appreciated but is not required.

   2. Altered source versions must be plainly marked as such, and must not be
   misrepresented as being the original software.

   3. This notice may not be removed or altered from any source
   distribution.
]]

SandboxUtilities = {}

SandboxUtilities.Objects = {};
SandboxUtilities.Objects.modular_block = {
    file = "models/nobiax_modular/modular_block.mesh",
    mass = 15 }
SandboxUtilities.Objects.modular_cooling = {
    file = "models/nobiax_modular/modular_cooling.mesh",
    mass = 15 }
SandboxUtilities.Objects.modular_roof = {
    file = "models/nobiax_modular/modular_roof.mesh",
    mass = 50 }
SandboxUtilities.Objects.modular_pillar_brick_1 = {
    file = "models/nobiax_modular/modular_pillar_brick_1.mesh",
    mass = 40 }
SandboxUtilities.Objects.modular_pillar_brick_2 = {
    file = "models/nobiax_modular/modular_pillar_brick_2.mesh",
    mass = 30 }
SandboxUtilities.Objects.modular_pillar_brick_3 = {
    file = "models/nobiax_modular/modular_pillar_brick_3.mesh",
    mass = 20 }
SandboxUtilities.Objects.modular_brick_door = {
    file = "models/nobiax_modular/modular_brick_door.mesh",
    mass = 80 }
SandboxUtilities.Objects.modular_brick_double_window = {
    file = "models/nobiax_modular/modular_brick_double_window.mesh",
    mass = 80 }
SandboxUtilities.Objects.modular_brick_small_double_window = {
    file = "models/nobiax_modular/modular_brick_small_double_window.mesh",
    mass = 80 }
SandboxUtilities.Objects.modular_brick_small_window_1 = {
    file = "models/nobiax_modular/modular_brick_small_window_1.mesh",
    mass = 80 }
SandboxUtilities.Objects.modular_brick_window_1 = {
    file = "models/nobiax_modular/modular_brick_window_1.mesh",
    mass = 80 }
SandboxUtilities.Objects.modular_brick_small_window_2 = {
    file = "models/nobiax_modular/modular_brick_small_window_2.mesh",
    mass = 40 }
SandboxUtilities.Objects.modular_brick_window_2 = {
    file = "models/nobiax_modular/modular_brick_window_2.mesh",
    mass = 40 }
SandboxUtilities.Objects.modular_wall_brick_1 = {
    file = "models/nobiax_modular/modular_wall_brick_1.mesh",
    mass = 80 }
SandboxUtilities.Objects.modular_wall_brick_2 = {
    file = "models/nobiax_modular/modular_wall_brick_2.mesh",
    mass = 40 }
SandboxUtilities.Objects.modular_wall_brick_3 = {
    file = "models/nobiax_modular/modular_wall_brick_3.mesh",
    mass = 30 }
SandboxUtilities.Objects.modular_wall_brick_4 = {
    file = "models/nobiax_modular/modular_wall_brick_4.mesh",
    mass = 30 }
SandboxUtilities.Objects.modular_wall_brick_5 = {
    file = "models/nobiax_modular/modular_wall_brick_5.mesh",
    mass = 20 }
SandboxUtilities.Objects.modular_pillar_concrete_3 = {
    file = "models/nobiax_modular/modular_pillar_concrete_3.mesh",
    mass = 20 }
SandboxUtilities.Objects.modular_pillar_concrete_2 = {
    file = "models/nobiax_modular/modular_pillar_concrete_2.mesh",
    mass = 30 }
SandboxUtilities.Objects.modular_pillar_concrete_1 = {
    file = "models/nobiax_modular/modular_pillar_concrete_1.mesh",
    mass = 40 }
SandboxUtilities.Objects.modular_concrete_door = {
    file = "models/nobiax_modular/modular_concrete_door.mesh",
    mass = 80 }
SandboxUtilities.Objects.modular_concrete_double_window = {
    file = "models/nobiax_modular/modular_concrete_double_window.mesh",
    mass = 80 }
SandboxUtilities.Objects.modular_concrete_small_double_window = {
    file = "models/nobiax_modular/modular_concrete_small_double_window.mesh",
    mass = 80 }
SandboxUtilities.Objects.modular_concrete_small_window_1 = {
    file = "models/nobiax_modular/modular_concrete_small_window_1.mesh",
    mass = 80 }
SandboxUtilities.Objects.modular_concrete_window_1 = {
    file = "models/nobiax_modular/modular_concrete_window_1.mesh",
    mass = 80 }
SandboxUtilities.Objects.modular_concrete_small_window_2 = {
    file = "models/nobiax_modular/modular_concrete_small_window_2.mesh",
    mass = 40 }
SandboxUtilities.Objects.modular_concrete_window_2 = {
    file = "models/nobiax_modular/modular_concrete_window_2.mesh",
    mass = 40 }
SandboxUtilities.Objects.modular_wall_concrete_1 = {
    file = "models/nobiax_modular/modular_wall_concrete_1.mesh",
    mass = 80 }
SandboxUtilities.Objects.modular_wall_concrete_2 = {
    file = "models/nobiax_modular/modular_wall_concrete_2.mesh",
    mass = 40 }
SandboxUtilities.Objects.modular_wall_concrete_3 = {
    file = "models/nobiax_modular/modular_wall_concrete_3.mesh",
    mass = 30 }
SandboxUtilities.Objects.modular_wall_concrete_4 = {
    file = "models/nobiax_modular/modular_wall_concrete_4.mesh",
    mass = 30 }
SandboxUtilities.Objects.modular_wall_concrete_5 = {
    file = "models/nobiax_modular/modular_wall_concrete_5.mesh",
    mass = 20 }
SandboxUtilities.Objects.modular_hangar_door = {
    file = "models/nobiax_modular/modular_hangar_door.mesh",
    mass = 100 }

local impactParticles = {};

local function ParticleImpact(sandbox, collision)
    Sandbox.RemoveObject(sandbox, collision.objectA);
    
    local particleImpact = Core.CreateParticle(sandbox, "BulletImpact");
    Core.SetPosition(particleImpact, collision.pointA);
    Core.SetParticleDirection(particleImpact, collision.normalOnB);

    table.insert(impactParticles, { particle = particleImpact, ttl = 2.0 } );
end

function SandboxUtilities_CreateBox(sandbox, size, position)
    local box = Sandbox.CreateBox(sandbox, size, size, size, 0.5 * size, 0.5 * size);
    Core.SetPosition(box, position);
    Core.SetMaterial(box, "Ground2");
    Core.SetMass(box, 0);
    
    return box;
end

--[[
  Helper function that creates an object from an Ogre mesh file.  A convex
  physics hull is created for the mesh at runtime for Bullet Physics.
  
  @param sandbox
    Code managed Sandbox data structure to attach the created object to.
  @param objectName
    The object's template name to create.
  @param position
    Optional position vector to initialize the object at.
  @param rotation
    Optional rotation vector to initialize the object with.
  @remarks
    This function is mainly used for creating instances of the modular objects
    provided by the Sandbox.
]]
function SandboxUtilities_CreateObject(sandbox, objectName, position, rotation)
    if SandboxUtilities.Objects[objectName] == nil then
        return;
    end

    local object = Sandbox.CreateObject(
        sandbox, SandboxUtilities.Objects[objectName].file);
    assert(SandboxUtilities.Objects[objectName].mass);
    Core.SetMass(object, SandboxUtilities.Objects[objectName].mass);
    
    if position ~= nil then
        Core.SetPosition(object, position);
    end
    
    if rotation ~= nil then
        Core.SetRotation(object, rotation);
    end
    
    return object;
end

function SandboxUtilities_CreateLevel(sandbox)
    local level = {
        { 20, Vector.new(0, -10, 0), Vector.new(0, 0, 0) },
        { 20, Vector.new(0, -10, 20), Vector.new(0, 0, 0) },
        { 20, Vector.new(-20, -10, 20), Vector.new(0, 0, 0) },
        { 20, Vector.new(24, -10, 0), Vector.new(0, 0, 0) },
        { 20, Vector.new(24, -10, 20), Vector.new(0, 0, 0) },
        { 20, Vector.new(24, -10, 40), Vector.new(0, 0, 0) },
        { 20, Vector.new(24, -10, 60), Vector.new(0, 0, 0) },
        { 4, Vector.new(12, -2, -4), Vector.new(0, 0, 0) },
        { 4, Vector.new(12, -2, 4), Vector.new(0, 0, 0) },
        { 20, Vector.new(48, -10, 0), Vector.new(0, 0, 0) },
        { 20, Vector.new(48, -10, 20), Vector.new(0, 0, 0) },
        { 4, Vector.new(36, -4, -8), Vector.new(0, 0, 0) },
        { 4, Vector.new(36, -4, -4), Vector.new(0, 0, 0) },
        { 4, Vector.new(36, -4, 0), Vector.new(0, 0, 0) },
        { 4, Vector.new(36, -4, 4), Vector.new(0, 0, 0) },
        { 4, Vector.new(36, -4, 8), Vector.new(0, 0, 0) },
        { 4, Vector.new(36, -4, 12), Vector.new(0, 0, 0) },
        { 4, Vector.new(36, -4, 16), Vector.new(0, 0, 0) },
        { 4, Vector.new(36, -4, 20), Vector.new(0, 0, 0) },
        { 4, Vector.new(36, -4, 24), Vector.new(0, 0, 0) },
        { 4, Vector.new(24, 2, -8), Vector.new(0, 0, 0) },
        { 4, Vector.new(24, 2, -4), Vector.new(0, 0, 0) },
        { 4, Vector.new(24, 2, 0), Vector.new(0, 0, 0) },
        { 4, Vector.new(24, 2, 4), Vector.new(0, 0, 0) },
        { 4, Vector.new(24, 2, 8), Vector.new(0, 0, 0) },
        { 8, Vector.new(24, 0, 16), Vector.new(0, 0, 0) },
        { 8, Vector.new(24, 0, 24), Vector.new(0, 0, 0) },
        { 8, Vector.new(24, 0, 32), Vector.new(0, 0, 0) },
        { 4, Vector.new(24, 1.55, 37.41), Vector.new(15, 0, 0) },
        { 4, Vector.new(24, 0.515, 41.272), Vector.new(15, 0, 0) },
        { 4, Vector.new(24, -0.52, 45.134), Vector.new(15, 0, 0) },
        { 4, Vector.new(24, -1.555, 48.996), Vector.new(15, 0, 0) },
        { 2, Vector.new(20, 1, 15), Vector.new(0, 0, 0) },
        { 2, Vector.new(17, 1, 15), Vector.new(0, 0, 0) },
        { 2, Vector.new(15, 1, 15), Vector.new(0, 0, 0) },
        { 2, Vector.new(19, 3, 15), Vector.new(0, 0, 0) },
        { 2, Vector.new(17, 3, 15), Vector.new(0, 0, 0) },
        { 2, Vector.new(15, 3, 15), Vector.new(0, 0, 0) },
        { 2, Vector.new(17, 0, 19), Vector.new(0, 0, 0) },
        { 2, Vector.new(19, 0, 19), Vector.new(0, 0, 0) },
        { 2, Vector.new(17, 1, 23), Vector.new(0, 0, 0) },
        { 2, Vector.new(15, 1, 23), Vector.new(0, 0, 0) },
        { 2, Vector.new(17, 1, 27), Vector.new(0, 0, 0) },
        { 2, Vector.new(19, 1, 27), Vector.new(0, 0, 0) },
        { 2, Vector.new(9, 3, 27), Vector.new(0, 0, 0) },
        { 2, Vector.new(11, 3, 27), Vector.new(0, 0, 0) },
        { 2, Vector.new(13, 3, 27), Vector.new(0, 0, 0) },
        { 2, Vector.new(15, 3, 27), Vector.new(0, 0, 0) },
        { 2, Vector.new(17, 3, 27), Vector.new(0, 0, 0) },
        { 2, Vector.new(19, 3, 27), Vector.new(0, 0, 0) },
        { 6, Vector.new(5, 1, 25), Vector.new(0, 0, 0) },
        { 6, Vector.new(-1, 1, 25), Vector.new(0, 0, 0) },
        { 6, Vector.new(-7, 1, 25), Vector.new(0, 0, 0) },
        { 2, Vector.new(-10.71, 2.77, 25), Vector.new(0, 0, 15) },
        { 2, Vector.new(-12.64, 2.252, 25), Vector.new(0, 0, 15) },
        { 2, Vector.new(-14.57, 1.734, 25), Vector.new(0, 0, 15) },
        { 2, Vector.new(-16.5, 1.216, 25), Vector.new(0, 0, 15) },
        { 2, Vector.new(-18.43, 0.698, 25), Vector.new(0, 0, 15) },
        { 2, Vector.new(-20.36, 0.18, 25), Vector.new(0, 0, 15) },
        { 2, Vector.new(-22.29, -0.338, 25), Vector.new(0, 0, 15) },
        { 2, Vector.new(-24.22, -0.856, 25), Vector.new(0, 0, 15) },
        { 2, Vector.new(-7, 4, 25), Vector.new(0, 0, 0) },
        { 2, Vector.new(-3, 5, 23), Vector.new(0, 0, 0) },
        { 2, Vector.new(-1, 5, 23), Vector.new(0, 0, 0) },
        { 2, Vector.new(1, 5, 23), Vector.new(0, 0, 0) },
        { 2, Vector.new(5, 4, 25), Vector.new(0, 0, 0) },
        { 2, Vector.new(27, 3, 9), Vector.new(0, 0, 0) },
        { 2, Vector.new(29, 3, 9), Vector.new(0, 0, 0) },
        { 2, Vector.new(31, 3, 9), Vector.new(0, 0, 0) },
        { 2, Vector.new(33, 3, 9), Vector.new(0, 0, 0) },
        { 2, Vector.new(35, 3, 9), Vector.new(0, 0, 0) },
        { 2, Vector.new(37, 3, 9), Vector.new(0, 0, 0) },
        { 2, Vector.new(39, 3, 9), Vector.new(0, 0, 0) },
        { 2, Vector.new(39, 3, 7), Vector.new(0, 0, 0) },
        { 2, Vector.new(39, 3, 11), Vector.new(0, 0, 0) },
        { 2, Vector.new(39, 3, 13), Vector.new(0, 0, 0) },
        { 2, Vector.new(39, 3, 15), Vector.new(0, 0, 0) },
        { 2, Vector.new(39, 3, 17), Vector.new(0, 0, 0) },
        { 2, Vector.new(39, 3, 19), Vector.new(0, 0, 0) },
        { 2, Vector.new(39, 3, 21), Vector.new(0, 0, 0) },
        { 2, Vector.new(39, 3, 23), Vector.new(0, 0, 0) },
        { 2, Vector.new(39, 3, 25), Vector.new(0, 0, 0) },
        { 2, Vector.new(39, 3, 27), Vector.new(0, 0, 0) },
        { 2, Vector.new(39, 5, 17), Vector.new(0, 0, 0) },
        { 2, Vector.new(39, 5, 19), Vector.new(0, 0, 0) },
        { 2, Vector.new(39, 5, 21), Vector.new(0, 0, 0) },
        { 2, Vector.new(43, 5, 13), Vector.new(0, 0, 0) },
        { 2, Vector.new(7, 3, 21), Vector.new(0, 0, 0) },
        { 2, Vector.new(5, 3, 21), Vector.new(0, 0, 0) },
        { 2, Vector.new(-21, -0.5, 19), Vector.new(0, 0, 0) },
        { 2, Vector.new(-22.705, -0.725, 19), Vector.new(0, 0, 15) },
        { 2, Vector.new(-19.295, -0.725, 19), Vector.new(0, 0, -15) },
        { 2, Vector.new(-21, -0.725, 20.705), Vector.new(15, 0, 0) },
        { 2, Vector.new(-21, -0.725, 17.295), Vector.new(-15, 0, 0) },
        { 6, Vector.new(43, 3, 9), Vector.new(0, 0, 0) },
        { 6, Vector.new(49, 3, 9), Vector.new(0, 0, 0) },
        { 8, Vector.new(48, 2, 16), Vector.new(0, 0, 0) },
        { 8, Vector.new(48, 0, 24), Vector.new(0, 0, 0) },
        { 4, Vector.new(42, 2, 14), Vector.new(0, 0, 0) },
        { 4, Vector.new(42, 2, 18), Vector.new(0, 0, 0) },
        { 4, Vector.new(42, 2, 22), Vector.new(0, 0, 0) },
        { 4, Vector.new(42, 2, 26), Vector.new(0, 0, 0) },
        { 4, Vector.new(48, 3.268, 20.731), Vector.new(30, 0, 0) },
        { 2, Vector.new(-13, -0.5, 15), Vector.new(0, 0, 0) },
        { 2, Vector.new(-14.705, -0.725, 15), Vector.new(0, 0, 15) },
        { 2, Vector.new(-11.295, -0.725, 15), Vector.new(0, 0, -15) },
        { 2, Vector.new(-13, -0.725, 16.705), Vector.new(15, 0, 0) },
        { 2, Vector.new(-13, -0.725, 13.295), Vector.new(-15, 0, 0) },
        { 2, Vector.new(45, 6, 9), Vector.new(0, 0, 0) },
        { 2, Vector.new(46.365, 5.635, 9), Vector.new(0, 0, -30) },
        { 2, Vector.new(43.635, 5.635, 9), Vector.new(0, 0, 30) },
        { 2, Vector.new(45, 5.635, 10.365), Vector.new(30, 0, 0) },
        { 2, Vector.new(45, 5.635, 7.635), Vector.new(-30, 0, 0) },
    }
    
    for index = 1, #level do
        local block = level[index];
        local box = SandboxUtilities_CreateBox(sandbox, block[1], block[2]);
        Core.SetRotation(box, block[3]);
    end
    
    Sandbox.CreateSkyBox(
        sandbox, "ThickCloudsWaterSkyBox", Vector.new(0, 180, 0));

    local plane = Sandbox.CreatePlane(sandbox, 200, 200);
    Core.SetPosition(plane, Vector.new(0, -10, 0));
    Core.SetMaterial(plane, "Ground2");
    
    SandboxUtilities_CreateLights(sandbox);
end

function SandboxUtilities_CreateLights(sandbox)
    Sandbox.SetAmbientLight(sandbox, Vector.new(0.3));

    local directional =
        Core.CreateDirectionalLight(sandbox, Vector.new(1, -1, 1));
    Core.SetLightDiffuse(directional, Vector.new(1.8, 1.4, 0.9));
    Core.SetLightSpecular(directional, Vector.new(1.8, 1.4, 0.9));
end

function SandboxUtilities_GetLevelPath()
    local path = {
        Vector.new(-5, 0, 13),
        Vector.new(5, 0, 4),
        Vector.new(18.5, 0, 4),
        Vector.new(18.5, 0, 17),
        Vector.new(15, 0, 17),
        Vector.new(15, 0, 21),
        Vector.new(19, 0, 21),
        Vector.new(19, 0, 25),
        Vector.new(15, 0, 25),
        Vector.new(15, 0, 29),
        Vector.new(20, 0, 52),
        Vector.new(24, 0, 52),
        Vector.new(24, 0, 51),
        Vector.new(24, 4, 36),
        Vector.new(24, 4, 27),
        Vector.new(7, 4, 27),
        Vector.new(-9, 4, 27),
        Vector.new(-9, 4, 25),
        Vector.new(-10, 4, 25),
        Vector.new(-26, 0, 25),
        Vector.new(-26, 0, 19)};

    return path;
end

function SandboxUtilities_ShootBox(sandbox)
    local object = SandboxUtilities_CreateObject(sandbox, "modular_block");
    
    local cameraPosition = Sandbox.GetCameraPosition(sandbox);
    local cameraForward = Sandbox.GetCameraForward(sandbox);
    local blockPosition = cameraPosition + cameraForward * 2;
    local rotation = Sandbox.GetCameraOrientation(sandbox);
    
    Core.SetRotation(object, rotation);
    Core.SetPosition(object, blockPosition);
    
    Core.ApplyImpulse(object, Vector.new(cameraForward * 15000));
    Core.ApplyAngularImpulse(object, Sandbox.GetCameraLeft(sandbox) * 10);
    
    return object;
end

function SandboxUtilities_ShootBullet(sandbox)
    local cameraForward = Sandbox.GetCameraForward(sandbox);
        
    local particle = Sandbox.CreatePhysicsCapsule(sandbox, 0.3, 0.01);
    Core.SetMass(particle, 0.1);
    Core.SetPosition(particle, Sandbox.GetCameraPosition(sandbox));
    Core.SetAxis(
        particle,
        Sandbox.GetCameraLeft(sandbox),
        -cameraForward,
        Sandbox.GetCameraUp(sandbox));
    Core.SetGravity(particle, Vector.new(0, -0.01, 0));
    
    local bulletParticle = Core.CreateParticle(particle, "Bullet");
    Core.SetRotation(bulletParticle, Vector.new(-90, 0, 0));
    
    Core.ApplyImpulse(particle, cameraForward * 750);
    Sandbox.AddCollisionCallback(sandbox, particle, ParticleImpact);
end
