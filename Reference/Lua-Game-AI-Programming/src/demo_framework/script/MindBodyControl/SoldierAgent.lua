require "DebugUtilities"
require "SandboxUtilities"
require "Soldier"

local _soldier;
local _soldierAsm;
local _weaponAsm;

local function _ParticleImpact(sandbox, collision)
    -- Remove the bullet particle.
    Sandbox.RemoveObject(sandbox, collision.objectA);

    -- Create an impact particle where the bullet collided with another object.
    local particleImpact = Core.CreateParticle(sandbox, "BulletImpact");
    Core.SetPosition(particleImpact, collision.pointA);
    Core.SetParticleDirection(particleImpact, collision.normalOnB);
end

local function _ShootBullet(sandbox, position, rotation)
    local forward = Vector.Rotate(Vector.new(1, 0, 0), rotation);
    local up = Vector.Rotate(Vector.new(0, 1, 0), rotation);
    local left = Vector.Rotate(Vector.new(0, 0, -1), rotation);

    -- Create a capsule shaped bullet to launch forward given the
    -- weapons muzzle orientation.
    local bullet = Sandbox.CreatePhysicsCapsule(sandbox, 0.3, 0.01);
    Core.SetMass(bullet, 0.1);
    Core.SetPosition(bullet, position + forward * 0.2);
    Core.SetAxis(bullet, left, -forward, up);

    -- Create a particle to visibly show the bullet.
    local bulletParticle = Core.CreateParticle(bullet, "Bullet");
    Core.SetRotation(bulletParticle, Vector.new(-90, 0, 0));

    -- Instantaneously apply a force in the forward direction. 
    Core.ApplyImpulse(bullet, forward * 750);

    -- Add a particle impact callback to remove the bullet and create
    -- an impact particle effect.
    Sandbox.AddCollisionCallback(sandbox, bullet, _ParticleImpact);

    return bullet;
end

local function _Shoot(stateName, callbackData)
    local agent = callbackData.agent;
    local sandbox = agent:GetSandbox();
    local soldier = callbackData.soldier;
    local position = Animation.GetBonePosition(soldier, "b_muzzle");
    local rotation = Animation.GetBoneRotation(soldier, "b_muzzle");

    _ShootBullet(sandbox, position, rotation);
end

function Agent_Cleanup(agent)
end

function Agent_HandleEvent(agent, event)
    if (event.source == "keyboard" and event.pressed) then
        if (event.key == "f2_key") then
            _soldierAsm:RequestState(Soldier.SoldierStates.STAND_FIRE);
            -- Disable moving while shooting.
            agent:SetMaxSpeed(0);
        end
    end
end

function Agent_Initialize(agent)
    -- Initialize the soldier and weapon models.
    _soldier = Soldier_CreateSoldier(agent);
    local weapon = Soldier_CreateWeapon(agent);

    -- Create the soldier and weapon animation state machines.
    _soldierAsm = Soldier_CreateSoldierStateMachine(_soldier);
    _weaponAsm = Soldier_CreateWeaponStateMachine(weapon);

    -- Request a default looping state in both animation state machines.
    _soldierAsm:RequestState(Soldier.SoldierStates.STAND_RUN_FORWARD);
    _weaponAsm:RequestState(Soldier.WeaponStates.SMG_IDLE);

    -- Attach the weapon model after the animation state machines
    -- have been created.
    Soldier_AttachWeapon(_soldier, weapon);
    weapon = nil;

    -- Data that is passed into _Shoot, expects an agent, and soldier
    -- attribute.
    local callbackData = {
        agent = agent,
        soldier = _soldier
    };

    -- Add the shoot callback to handle bullet creation.
    _soldierAsm:AddStateCallback(
            Soldier.SoldierStates.STAND_FIRE, _Shoot, callbackData);

    -- Assign the default level path and adjust the agent's speed to
    -- match the soldier's steering scalars.
    agent:SetPath(SandboxUtilities_GetLevelPath());
    agent:SetMaxSpeed(agent:GetMaxSpeed() * 0.5);
end

function Agent_Update(agent, deltaTimeInMillis)
    -- Returns the amount of time that has passed in the sandbox,
    -- this is not the same as lua's os.time();
    local sandboxTimeInMillis = Sandbox.GetTimeInMillis(agent:GetSandbox());
    local deltaTimeInSeconds = deltaTimeInMillis / 1000;

    -- Allow the soldier to update any soldier's specific data.
    Soldier_Update(agent, deltaTimeInMillis);

    -- Update the animation state machines to process animation requests.
    _soldierAsm:Update(deltaTimeInMillis, sandboxTimeInMillis);
    _weaponAsm:Update(deltaTimeInMillis, sandboxTimeInMillis);

    -- Draw the agent's cyclic path, offset slightly above the level geometry.
    DebugUtilities_DrawPath(agent:GetPath(), true, Vector.new(0, 0.02, 0));

    -- Apply a steering force to move the agent along the path.
    if (agent:HasPath()) then
        local steeringForces = Soldier_CalculateSteering(
                agent, deltaTimeInSeconds);
        Soldier_ApplySteering(
                agent, steeringForces, deltaTimeInSeconds);
    end
end
