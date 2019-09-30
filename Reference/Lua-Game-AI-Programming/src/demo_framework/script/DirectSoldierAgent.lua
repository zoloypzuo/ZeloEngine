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

require "AgentUtilities"
require "AnimationStateMachine"
require "DebugUtilities"
require "SandboxUtilities"
require "Soldier"

local _soldier;
local _soldierAsm;
local _soldierStance;
local _soldierState;
local _weaponAsm;

-- Supported soldier stances.
local _soldierStances = {
    CROUCH = "CROUCH",
    STAND = "STAND"
};

-- Supported soldier states.
local _soldierStates = {
    DEATH = "DEATH",
    FALLING = "FALLING",
    IDLE = "IDLE",
    MOVING = "MOVING",
    SHOOTING = "SHOOTING"
}

local function _IsNumKey(key, numKey)
    -- Match both numpad keys and numeric keys.
    return string.find(key, string.format("^[numpad_]*%d_key$", numKey));
end

function Agent_Cleanup(agent)
end

function Agent_DeathState(agent, deltaTimeInMillis)
    local currentState = _soldierAsm:GetCurrentStateName();

    if (Soldier_IsMoving(agent)) then
        -- Slow movement at twice the rate to blend to a death pose.
        Soldier_SlowMovement(agent, deltaTimeInMillis, 2);
    end

    -- Only request a death state if not currently playing.
    if (_soldierStance == _soldierStances.STAND) then
        if (currentState ~= Soldier.SoldierStates.STAND_DEAD) then
            _soldierAsm:RequestState(Soldier.SoldierStates.STAND_DEAD);
        end
    else
        if (currentState ~= Soldier.SoldierStates.CROUCH_DEAD) then
            _soldierAsm:RequestState(Soldier.SoldierStates.CROUCH_DEAD);
        end
    end

    -- Remove the soldier from physics once the death animation
    -- starts playing to prevent other agents from colliding with
    -- the agent's physics capsule.
    if (currentState == Soldier.SoldierStates.STAND_DEAD or
        currentState == Soldier.SoldierStates.CROUCH_DEAD) then
        agent:RemovePhysics();
        agent:SetHealth(0);
    end
end

function Agent_FallingState(agent, deltaTimeInMillis)
    local currentState = _soldierAsm:GetCurrentStateName();

    -- Since there's no falling animation, move the soldier into an idle
    -- animation.
    if (currentState ~= Soldier.SoldierStates.STAND_IDLE_AIM and
        currentState ~= Soldier.SoldierStates.STAND_FALL_DEAD) then
        _soldierAsm:RequestState(Soldier.SoldierStates.STAND_IDLE_AIM);
    end

    -- Once the soldier is no longer falling, kill the soldier.
    if (not Soldier_IsFalling(agent)) then
        if (currentState ~= Soldier.SoldierStates.STAND_FALL_DEAD) then
            -- Play a death animation once the soldier stops falling.
            _soldierAsm:RequestState(Soldier.SoldierStates.STAND_FALL_DEAD);
        elseif (currentState == Soldier.SoldierStates.STAND_FALL_DEAD) then
            -- Remove the soldier from physics once the death animation
            -- starts playing.
            agent:RemovePhysics();
            agent:SetHealth(0);
        end
    end
end

function Agent_HandleEvent(agent, event)
    if (event.source == "keyboard" and event.pressed) then
        -- Ignore new state requests if the agent is dead or about to die.
        if (_soldierState == _soldierStates.DEATH or
            _soldierState == _soldierStates.FALLING) then
            return;
        end

        -- Immediately switch the current state of the soldier.
        if (_IsNumKey(event.key, 1)) then
            _soldierState = _soldierStates.IDLE;
        elseif (_IsNumKey(event.key, 2)) then
            _soldierState = _soldierStates.SHOOTING;
        elseif (_IsNumKey(event.key, 3)) then
            _soldierState = _soldierStates.MOVING;
        elseif (_IsNumKey(event.key, 4)) then
            _soldierState = _soldierStates.DEATH;
        elseif (_IsNumKey(event.key, 5)) then
            -- Immediately switch the stance of the soldier, does not
            -- switch the current state of the soldier. Doing this assumes
            -- all possible states can transitions to both stances.
            if (_soldierStance == _soldierStances.CROUCH) then
                _soldierStance = _soldierStances.STAND;
                Soldier_SetHeight(agent, _soldier, Soldier.Height.Stand);
            else
                _soldierStance = _soldierStances.CROUCH;
                Soldier_SetHeight(agent, _soldier, Soldier.Height.Crouch);
            end
        end
    end
end

function Agent_IdleState(agent, deltaTimeInMillis)
    local currentState = _soldierAsm:GetCurrentStateName();

    if (_soldierStance == _soldierStances.STAND) then
        if (Soldier_IsMoving(agent)) then
            -- Slow movement to blend to an idle pose.
            Soldier_SlowMovement(agent, deltaTimeInMillis);
        end

        -- Only request the STAND_IDLE_AIM state if not currently playing.
        if (currentState ~= Soldier.SoldierStates.STAND_IDLE_AIM) then
            _soldierAsm:RequestState(Soldier.SoldierStates.STAND_IDLE_AIM);
        end
    else
        if (Soldier_IsMoving(agent)) then
            -- Slow movement at twice the rate to blend to an idle pose.
            Soldier_SlowMovement(agent, deltaTimeInMillis, 2);
        end

        -- Only request the CROUCH_IDLE_AIM state if not currently playing.
        if (currentState ~= Soldier.SoldierStates.CROUCH_IDLE_AIM) then
            _soldierAsm:RequestState(Soldier.SoldierStates.CROUCH_IDLE_AIM);
        end
    end
end

function Agent_Initialize(agent)
    -- Initialize the soldier and weapon models.
    _soldier = Soldier_CreateLightSoldier(agent);
    local weapon = Soldier_CreateWeapon(agent);

    -- Create the soldier and weapon animation state machines.
    _soldierAsm = Soldier_CreateSoldierStateMachine(_soldier);
    _weaponAsm = Soldier_CreateWeaponStateMachine(weapon);

    -- Data that is passed into Soldier_Shoot, expects an agent, and soldier
    -- attribute.
    local callbackData = {
        agent = agent;
        soldier = _soldier
    };

    -- Add callbacks to shoot a bullet each time the shooting animation is
    -- played.
    _soldierAsm:AddStateCallback(
        Soldier.SoldierStates.STAND_FIRE, Soldier_Shoot, callbackData);
    _soldierAsm:AddStateCallback(
        Soldier.SoldierStates.CROUCH_FIRE, Soldier_Shoot, callbackData);

    -- Attach the weapon model after the animation state machines
    -- have been created.
    Soldier_AttachWeapon(_soldier, weapon);
    weapon = nil;

    -- Set the default state and stance.
    _soldierState = _soldierStates.IDLE;
    _soldierStance = _soldierStances.STAND;
end

function Agent_MovingState(agent, deltaTimeInMillis)
    local currentState = _soldierAsm:GetCurrentStateName();
    local deltaTimeInSeconds = deltaTimeInMillis / 1000;
    local steeringForces;

    if (_soldierStance == _soldierStances.STAND) then
        -- Only request the STAND_RUN_FORWARD state if not currently playing.
        if (currentState ~= Soldier.SoldierStates.STAND_RUN_FORWARD) then
            -- Change the agent's desired speed for quick movement.
            agent:SetMaxSpeed(Soldier.Speed.Stand);
            _soldierAsm:RequestState(Soldier.SoldierStates.STAND_RUN_FORWARD);
        end

        -- Calculate steering forces tuned for quick movement.
        steeringForces = Soldier_CalculateSteering(agent, deltaTimeInSeconds);
    else
        -- Only request the CROUCH_FORWARD state if not currently playing.
        if (currentState ~= Soldier.SoldierStates.CROUCH_FORWARD) then
            -- Change the agent's desired speed for slow movement.
            agent:SetMaxSpeed(Soldier.Speed.Crouch);
            _soldierAsm:RequestState(Soldier.SoldierStates.CROUCH_FORWARD);
        end

        -- Calculate steering forces tuned for slow movement.
        steeringForces =
            Soldier_CalculateSlowSteering(agent, deltaTimeInSeconds);
    end

    Soldier_ApplySteering(agent, steeringForces, deltaTimeInSeconds);
end

function Agent_ShootState(agent, deltaTimeInMillis)
    local currentState = _soldierAsm:GetCurrentStateName();

    if (_soldierStance == _soldierStances.STAND) then
        -- Slow movement to blend to a shooting pose.
        if (Soldier_IsMoving(agent)) then
            Soldier_SlowMovement(agent, deltaTimeInMillis);
        end

        -- Only request the STAND_FIRE state if not currently playing.
        if (currentState ~= Soldier.SoldierStates.STAND_FIRE) then
            _soldierAsm:RequestState(Soldier.SoldierStates.STAND_FIRE);
        end
    else
        -- Slow movement at twice the rate to blend to a shooting pose.
        if (Soldier_IsMoving(agent)) then
            Soldier_SlowMovement(agent, deltaTimeInMillis, 2);
        end

        -- Only request the CROUCH_FIRE state if not currently playing.
        if (currentState ~= Soldier.SoldierStates.CROUCH_FIRE) then
            _soldierAsm:RequestState(Soldier.SoldierStates.CROUCH_FIRE);
        end
    end
end

function Agent_Update(agent, deltaTimeInMillis)
    -- Returns the amount of time that has passed in the sandbox,
    -- this is not the same as lua's os.time();
    local sandboxTimeInMillis = Sandbox.GetTimeInMillis(agent:GetSandbox());

    -- Allow the soldier to update any soldier's specific data.
    Soldier_Update(agent, deltaTimeInMillis);

    -- Update the animation state machines to process animation requests.
    _soldierAsm:Update(deltaTimeInMillis, sandboxTimeInMillis);
    _weaponAsm:Update(deltaTimeInMillis, sandboxTimeInMillis);

    -- Draw the agent's cyclic path, offset slightly above the level geometry.
    DebugUtilities_DrawPath(
        agent:GetPath(), true, Vector.new(0, 0.02, 0));

    -- Ignore all state requests once the agent is dead.
    if (agent:GetHealth() <= 0) then
        return;
    end

    -- Force the soldier into falling, this overrides all other requests.
    if (Soldier_IsFalling(agent)) then
        _soldierState = _soldierStates.FALLING;
    end

    -- Handle the current soldier's requested state.
    if (_soldierState == _soldierStates.IDLE) then
        Agent_IdleState(agent, deltaTimeInMillis);
    elseif (_soldierState == _soldierStates.SHOOTING) then
        Agent_ShootState(agent, deltaTimeInMillis);
    elseif (_soldierState == _soldierStates.MOVING) then
        Agent_MovingState(agent, deltaTimeInMillis);
    elseif (_soldierState == _soldierStates.FALLING) then
        Agent_FallingState(agent, deltaTimeInMillis);
    elseif (_soldierState == _soldierStates.DEATH) then
        Agent_DeathState(agent, deltaTimeInMillis);
    end
end