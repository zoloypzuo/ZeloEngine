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

require "AgentCommunications"
require "AgentUtilities"
require "AnimationStateMachine"

Soldier = {};

-- Height in meters.
Soldier.Height = {};
Soldier.Height.Crouch = 1.3;
Soldier.Height.Stand = 1.6;

-- Speed in meters per second.
Soldier.Speed = {};
Soldier.Speed.Crouch = 1;
Soldier.Speed.Stand = 3;

-- All possible soldier animation state machine states.
Soldier.SoldierStates = {
    CROUCH_DEAD =               "crouch_dead",
    CROUCH_FIRE =               "crouch_fire",
    CROUCH_FORWARD =            "crouch_forward",
    CROUCH_IDLE_AIM =           "crouch_idle_aim",
    STAND_DEAD =                "dead",
    STAND_DEAD_HEADSHOT =       "dead_headshot",
    STAND_FALL_DEAD =           "fall_dead",
    STAND_FALL_IDLE =           "fall_idle",
    STAND_FIRE =                "fire",
    STAND_IDLE_AIM =            "idle_aim",
    STAND_JUMP_LAND =           "jump_land",
    STAND_JUMP_UP =             "jump_up",
    STAND_MELEE =               "melee",
    STAND_RELOAD =              "reload",
    STAND_RUN_BACKWARD =        "run_backward",
    STAND_RUN_FORWARD =         "run_forward",
    STAND_SMG_TRANSFORM =       "smg_transform",
    STAND_SNIPER_TRANSFORM =    "sniper_transform"
};

-- All possible weapon animation state machine states.
Soldier.WeaponStates = {
    SMG_IDLE =                  "smg_idle",
    SMG_TRANSFORM =             "smg_transform",
    SNIPER_IDLE =               "sniper_idle",
    SNIPER_RELOAD =             "sniper_reload",
    SNIPER_TRANSFORM =          "sniper_transform"
};

-- Accumulates acceleration to smooth out jerks in movement.
local _agentAccumulators = {};

-- Handles the removal of particles.
local _impactParticles = {};

local function _SendImpactEvent(sandbox, hitPosition)
    local event = { position = hitPosition };

    AgentCommunications_SendMessage(
        sandbox,
        AgentCommunications.EventType.BulletImpact,
        event);
end

local function _SendShootEvent(sandbox, shootPosition)
    local event = { position = shootPosition };
    
    AgentCommunications_SendMessage(
        sandbox,
        AgentCommunications.EventType.BulletShot,
        event);
end

local function _ParticleImpact(sandbox, collision)
    Sandbox.RemoveObject(sandbox, collision.objectA);
    
    local particleImpact = Core.CreateParticle(sandbox, "BulletImpact");
    Core.SetPosition(particleImpact, collision.pointA);
    Core.SetParticleDirection(particleImpact, collision.normalOnB);

    table.insert(_impactParticles, { particle = particleImpact, ttl = 2.0 } );
    
    if (Agent.IsAgent(collision.objectB)) then
        Agent.SetHealth(collision.objectB, Agent.GetHealth(collision.objectB) - 5);
    end
    
    _SendImpactEvent(sandbox, collision.pointA);
end

local function _ShootBullet(sandbox, position, rotation)
    local forward = Vector.Rotate(Vector.new(1, 0, 0), rotation);
    local up = Vector.Rotate(Vector.new(0, 1, 0), rotation);
    local left = Vector.Rotate(Vector.new(0, 0, -1), rotation);

    local bullet = Sandbox.CreatePhysicsCapsule(sandbox, 0.3, 0.01);
    Core.SetMass(bullet, 0.1);
    Core.SetPosition(bullet, position + forward * 0.2);
    Core.SetAxis(bullet, left, -forward, up);
    Core.SetGravity(bullet, Vector.new(0, -0.01, 0));
    
    local bulletParticle = Core.CreateParticle(bullet, "Bullet");
    Core.SetRotation(bulletParticle, Vector.new(-90, 0, 0));
    
    Core.ApplyImpulse(bullet, forward * 750);
    Sandbox.AddCollisionCallback(sandbox, bullet, _ParticleImpact);
    
    _SendShootEvent(sandbox, position);
end

function Soldier_ApplySteering(agent, steeringForces, deltaTimeInSeconds)
    local agentId = agent:GetId();

    if (_agentAccumulators[agentId] == nil) then
        _agentAccumulators[agentId] = Vector.new();
    end
    
    AgentUtilities_ApplySteeringForce2(
        agent, steeringForces, _agentAccumulators[agentId], deltaTimeInSeconds);
    AgentUtilities_ClampHorizontalSpeed(agent);
end

function Soldier_AttachWeapon(soldier, weapon)
    Animation.AttachToBone(
        soldier,
        "b_RightHand",
        weapon,
        Vector.new(0.04, 0.05, -0.01),
        Vector.new(98.0, 97.0, 0));
end

function Soldier_CalculateSlowSteering(agent, deltaTimeInSeconds)
    local avoidForce = agent:ForceToAvoidAgents(0.5);
    local avoidObjectForce = agent:ForceToAvoidObjects(0.5);
    local followForce = agent:ForceToFollowPath(0.5);
    local stayForce = agent:ForceToStayOnPath(0.5);
    
    local totalForces = 
        Vector.Normalize(followForce) +
        Vector.Normalize(stayForce) * 0.2 +
        avoidForce * 1 +
        avoidObjectForce * 1;

    local targetSpeed = agent:GetMaxSpeed();
    if (agent:GetSpeed() < targetSpeed) then
        local speedForce = agent:ForceToTargetSpeed(targetSpeed);
        totalForces = totalForces + speedForce * 5;
    end
    
    return totalForces;
end

function Soldier_CalculateSteering(agent, deltaTimeInSeconds)
    local avoidForce = agent:ForceToAvoidAgents(0.5);
    local avoidObjectForce = agent:ForceToAvoidObjects(0.5);
    local followForce = agent:ForceToFollowPath(0.5);
    local stayForce = agent:ForceToStayOnPath(0.5);
    
    local totalForces = 
        followForce * 1.5 +
        stayForce * 0.4 +
        avoidForce * 1 +
        avoidObjectForce * 2;

    totalForces.y = 0;

    local targetSpeed = agent:GetMaxSpeed();

    if (agent:GetSpeed() < targetSpeed) then
        local speedForce = agent:ForceToTargetSpeed(targetSpeed);
        totalForces = totalForces + speedForce * 7;
    end
    
    return totalForces;
end

function Soldier_CreateLightSoldier(agent)
    local soldier = Core.CreateMesh(
        agent, "models/futuristic_soldier/futuristic_soldier_anim.mesh");

    -- Offset the soldier mesh since the origin of the mesh is at the feet
    -- while the origin of the agent is at the center.
    local height = agent:GetHeight();
    Core.SetPosition(soldier, Vector.new(0, -height * 0.5, 0));
    
    return soldier;
end

function Soldier_CreateSoldier(agent)
    local soldier = Core.CreateMesh(
        agent, "models/futuristic_soldier/futuristic_soldier_dark_anim.mesh");

    -- Offset the soldier mesh since the origin of the mesh is at the feet
    -- while the origin of the agent is at the center.
    local height = agent:GetHeight();
    Core.SetPosition(soldier, Vector.new(0, -height * 0.5, 0));
    
    return soldier;
end

function Soldier_CreateSoldierStateMachine(soldier)
    local soldierAsm = AnimationStateMachine.new();
    
    local crouchIdleAim = Animation.GetAnimation(soldier, "crouch_idle_aim");
    local crouchIdleAimLength = Animation.GetLength(crouchIdleAim);
    local crouchForward = Animation.GetAnimation(soldier, "crouch_forward_aim");
    local crouchForwardLength = Animation.GetLength(crouchForward);
    local idleAim = Animation.GetAnimation(soldier, "stand_idle_aim");
    local idleAimLength = Animation.GetLength(idleAim);
    local runForward = Animation.GetAnimation(soldier, "stand_run_forward_aim");
    local runForwardLength = Animation.GetLength(runForward);

    soldierAsm:AddState("idle_aim", Animation.GetAnimation(soldier, "stand_idle_aim"), true);
    soldierAsm:AddState("crouch_idle_aim", Animation.GetAnimation(soldier, "crouch_idle_aim"), true);
    soldierAsm:AddState("crouch_dead", Animation.GetAnimation(soldier, "stand_dead_2"), nil, 0.8);
    soldierAsm:AddState("crouch_fire", Animation.GetAnimation(soldier, "crouch_fire_one_shot"), true);
    soldierAsm:AddState("crouch_forward", Animation.GetAnimation(soldier, "crouch_forward_aim"), true);
    soldierAsm:AddState("dead", Animation.GetAnimation(soldier, "stand_dead_2"));
    soldierAsm:AddState("dead_headshot", Animation.GetAnimation(soldier, "stand_dead_headshot"));
    soldierAsm:AddState("fall_dead", Animation.GetAnimation(soldier, "stand_dead_2"));
    soldierAsm:AddState("fall_idle", Animation.GetAnimation(soldier, "stand_idle_aim"), true);
    soldierAsm:AddState("fire", Animation.GetAnimation(soldier, "stand_fire_one_shot"), true);
    soldierAsm:AddState("jump_land", Animation.GetAnimation(soldier, "stand_jump_land"));
    soldierAsm:AddState("jump_up", Animation.GetAnimation(soldier, "stand_jump_up"));
    soldierAsm:AddState("melee", Animation.GetAnimation(soldier, "stand_melee_1_with_weapon"));
    soldierAsm:AddState("reload", Animation.GetAnimation(soldier, "stand_reload"));
    soldierAsm:AddState("run_backward", Animation.GetAnimation(soldier, "stand_run_backward_aim"), true);
    soldierAsm:AddState("run_forward", Animation.GetAnimation(soldier, "stand_run_forward_aim"), true);
    soldierAsm:AddState("smg_transform", Animation.GetAnimation(soldier, "stand_smg_transform"));
    soldierAsm:AddState("sniper_transform", Animation.GetAnimation(soldier, "stand_sniper_transform"));

    soldierAsm:AddTransition("idle_aim", "crouch_idle_aim", idleAimLength, 0.3);
    soldierAsm:AddTransition("idle_aim", "dead", idleAimLength, 0.1);
    soldierAsm:AddTransition("idle_aim", "fall_dead", idleAimLength, 0.15, 1.0);
    soldierAsm:AddTransition("idle_aim", "dead_headshot", idleAimLength, 0.2);
    soldierAsm:AddTransition("idle_aim", "fire", idleAimLength, 0.1);
    soldierAsm:AddTransition("idle_aim", "melee", idleAimLength, 0.2);
    soldierAsm:AddTransition("idle_aim", "reload", idleAimLength, 0.2);
    soldierAsm:AddTransition("idle_aim", "run_backward", idleAimLength, 0.2);
    soldierAsm:AddTransition("idle_aim", "run_forward", idleAimLength, 0.5);
    soldierAsm:AddTransition("idle_aim", "smg_transform", idleAimLength, 0.2);
    soldierAsm:AddTransition("idle_aim", "sniper_transform", idleAimLength, 0.2);
    
    soldierAsm:AddTransition("crouch_idle_aim", "idle_aim", crouchIdleAimLength, 0.3);
    soldierAsm:AddTransition("crouch_idle_aim", "crouch_dead", crouchIdleAimLength, 0.2, 0.5);
    soldierAsm:AddTransition("crouch_idle_aim", "crouch_fire", crouchIdleAimLength, 0.1);
    soldierAsm:AddTransition("crouch_idle_aim", "crouch_forward", crouchIdleAimLength, 0.5);
    soldierAsm:AddTransition("crouch_idle_aim", "fire", crouchIdleAimLength, 0.5);
    soldierAsm:AddTransition("crouch_idle_aim", "reload", crouchIdleAimLength, 0.3);
    soldierAsm:AddTransition("crouch_idle_aim", "run_forward", crouchIdleAimLength, 0.5);
    
    soldierAsm:AddTransition("crouch_fire", "crouch_dead", 0.2, 0.2, 0.5);
    soldierAsm:AddTransition("crouch_fire", "crouch_forward", 0.5, 0.5);
    soldierAsm:AddTransition("crouch_fire", "crouch_idle_aim", 0.1, 0.1);
    soldierAsm:AddTransition("crouch_fire", "fire", 0.3, 0.3);
    soldierAsm:AddTransition("crouch_fire", "idle_aim", 0.3, 0.3);
    soldierAsm:AddTransition("crouch_fire", "reload", 0.3, 0.3);
    soldierAsm:AddTransition("crouch_fire", "run_forward", 0.5, 0.5);
    
    soldierAsm:AddTransition("crouch_forward", "crouch_dead", crouchForwardLength, 0.2, 0.5);
    soldierAsm:AddTransition("crouch_forward", "crouch_fire", crouchForwardLength, 0.2);
    soldierAsm:AddTransition("crouch_forward", "crouch_idle_aim", crouchForwardLength, 0.2);
    soldierAsm:AddTransition("crouch_forward", "fall_idle", crouchForwardLength, 0.2);
    soldierAsm:AddTransition("crouch_forward", "fire", crouchForwardLength, 0.5);
    soldierAsm:AddTransition("crouch_forward", "idle_aim", crouchForwardLength, 0.5);
    soldierAsm:AddTransition("crouch_forward", "reload", crouchForwardLength, 0.5);
    soldierAsm:AddTransition("crouch_forward", "run_forward", crouchForwardLength, 0.4);
    
    soldierAsm:AddTransition("run_forward", "crouch_fire", runForwardLength, 0.5);
    soldierAsm:AddTransition("run_forward", "crouch_forward", runForwardLength, 0.2);
    soldierAsm:AddTransition("run_forward", "crouch_idle_aim", runForwardLength, 0.5);
    soldierAsm:AddTransition("run_forward", "dead", runForwardLength, 0.2);
    soldierAsm:AddTransition("run_forward", "fall_idle", runForwardLength, 0.1);
    soldierAsm:AddTransition("run_forward", "fire", runForwardLength, 0.5);
    soldierAsm:AddTransition("run_forward", "idle_aim", runForwardLength, 0.5);
    soldierAsm:AddTransition("run_forward", "reload", runForwardLength, 0.5);
    
    soldierAsm:AddTransition("fall_idle", "fall_dead", idleAimLength, 0.15, 1.0);
    
    soldierAsm:AddTransition("fire", "idle_aim", 0.1, 0.1);
    soldierAsm:AddTransition("fire", "reload", 0.1, 0.1);
    soldierAsm:AddTransition("fire", "run_forward", 0.5, 0.5);
    soldierAsm:AddTransition("fire", "run_backward", 0.5, 0.5);
    soldierAsm:AddTransition("fire", "crouch_idle_aim", 0.5, 0.5);
    soldierAsm:AddTransition("fire", "crouch_fire", 0.3, 0.3);
    soldierAsm:AddTransition("fire", "crouch_forward", 0.5, 0.5);
    
    soldierAsm:AddTransition("melee", "idle_aim", 0.2, 0.2);
    soldierAsm:AddTransition("reload", "idle_aim", 0.2, 0.2);
    soldierAsm:AddTransition("run_backward", "idle_aim", 0.2, 0.2);
    soldierAsm:AddTransition("smg_transform", "idle_aim", 0.2, 0.2);
    soldierAsm:AddTransition("sniper_transform", "idle_aim", 0.2, 0.2);
    
    soldierAsm:RequestState("idle_aim");
    
    return soldierAsm;
end

function Soldier_CreateWeapon(agent)
    local weapon = Core.CreateMesh(
        agent, "models/futuristic_soldier/soldier_weapon.mesh");

    return weapon;
end

function Soldier_CreateWeaponStateMachine(weapon)
    local weaponAsm = AnimationStateMachine.new();

    local sniperIdle = Animation.GetAnimation(weapon, "sniper_idle");
    local smgIdle = Animation.GetAnimation(weapon, "smg_idle");

    weaponAsm:AddState("smg_idle", Animation.GetAnimation(weapon, "smg_idle"), true);
    weaponAsm:AddState("smg_transform", Animation.GetAnimation(weapon, "smg_transform"));
    weaponAsm:AddState("sniper_idle", sniperIdle, true);
    weaponAsm:AddState("sniper_reload", Animation.GetAnimation(weapon, "sniper_reload"));
    weaponAsm:AddState("sniper_transform", Animation.GetAnimation(weapon, "sniper_transform"));
    
    weaponAsm:AddTransition("sniper_idle", "sniper_reload", Animation.GetLength(sniperIdle), 0.2);
    weaponAsm:AddTransition("sniper_idle", "sniper_transform", Animation.GetLength(sniperIdle), 0.2);
    weaponAsm:AddTransition("sniper_reload", "sniper_idle", 0.2, 0.2);
    weaponAsm:AddTransition("sniper_transform", "sniper_idle", 0.2, 0.2);
    weaponAsm:AddTransition("smg_idle", "smg_transform", Animation.GetLength(smgIdle), 0.2);
    weaponAsm:AddTransition("smg_transform", "smg_idle", 0.2, 0.2);
    
    weaponAsm:RequestState("sniper_idle");
    
    return weaponAsm;
end

function Soldier_PathToRandomPoint(agent)
    local sandbox = agent:GetSandbox();

    local endPoint = Sandbox.RandomPoint(sandbox, "default");
    local path = Sandbox.FindPath(sandbox, "default", agent:GetPosition(), endPoint);
    
    while #path == 0 do
        endPoint = Sandbox.RandomPoint(sandbox, "default");
        path = Sandbox.FindPath(sandbox, "default", agent:GetPosition(), endPoint);
    end
    
    return path;
end

function Soldier_IsFalling(agent)
    -- Agents must fall for at least half a second to be considered falling.
    return (agent:GetVelocity().y < (-9.8 * 0.5));
end

function Soldier_IsMoving(agent)
    return Vector.LengthSquared(agent:GetVelocity()) > 2;
end

function Soldier_OnGround(agent)
    return (agent:GetVelocity().y > (-9.8 * 0.1));
end

function Soldier_SetHeight(agent, soldierMesh, newHeight)
    assert(type(agent) == "userdata");
    assert(type(soldierMesh) == "userdata");
    assert(type(newHeight) == "number");

    local height = agent:GetHeight();

    Core.SetPosition(soldierMesh, Vector.new(0, -newHeight/2, 0));

    agent:SetPosition(
        agent:GetPosition() - Vector.new(0, (height - newHeight)/2, 0));
    agent:SetHeight(newHeight);
end

function Soldier_SetPath(agent, path, cyclic)
    agent:SetPath(path, cyclic);

    -- Find a future position on the path based on the closest point on the path.
    local nearest = Agent.GetNearestPointOnPath(agent, agent:GetPosition());
    local distance = Agent.GetDistanceAlongPath(agent, nearest);
    local pointOnPath = Agent.GetPointOnPath(agent, distance + 2);

    local forward = pointOnPath - agent:GetPosition();
    forward.y = 0;
    
    -- Orient the soldier directly toward the path if the beginning 
    -- of the path is great than 90 degrees from the soldier's current
    -- forward vector.
    -- Typically you would want to play a turn animation here so soldiers won't
    -- steer off the environment to their death.  Since the soldier doesn't
    -- have turn animations we directly set the agent's forward.
    if ( Vector.DotProduct(forward, agent:GetForward()) < 0 ) then
        agent:SetVelocity(forward * agent:GetSpeed());
        agent:SetForward(forward);
    end
end

function Soldier_SlowMovement(agent, deltaTimeInMillis, rate)
    rate = rate or 1;

    local horizontalVelocity = agent:GetVelocity();
    local yMovement = horizontalVelocity.y;
    
    horizontalVelocity.y = 0;
    horizontalVelocity = horizontalVelocity * 0.91 * (1 / rate);
    horizontalVelocity.y = yMovement;
    
    agent:SetVelocity(horizontalVelocity);
end

function Soldier_Shoot(stateName, callbackData)
    assert(callbackData.agent);
    assert(callbackData.soldier);

    local agent = callbackData.agent;
    local sandbox = agent:GetSandbox();
    local soldier = callbackData.soldier;
    local position = Animation.GetBonePosition(soldier, "b_muzzle");
    local rotation = Animation.GetBoneRotation(soldier, "b_muzzle");
    
    _ShootBullet(sandbox, position, rotation);
end

function Soldier_Update(agent, deltaTimeInMillis)
    -- Clean up particles after their Time to Live has passed
    if (_impactParticles and #_impactParticles > 0) then
        local index = 1;
        while (index <= #_impactParticles) do
            local impactParticle = _impactParticles[index];
            
            impactParticle.ttl = impactParticle.ttl - deltaTimeInMillis / 1000;
            
            if (impactParticle.ttl <= 0) then
                table.remove(_impactParticles, index);
                Core.Remove(impactParticle.particle);
            else
                index = index + 1;
            end
        end
    end
end