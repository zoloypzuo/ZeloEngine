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

--[[
userData =
{
    alive, -- terminal flag
    agent, -- Sandbox Agent
    ammo, -- Agent Ammo
    maxAmmo, -- Agent Max Ammo
    controller, -- Agent Controller
    enemy, -- Agent Enemy
    maxHealth, -- Agent Max Health
};
]]

require "Action"
require "DebugUtilities"
require "Soldier"
require "SoldierController"

-- Change Stance
function SoldierActions_ChangeStanceCleanUp(userData)
    -- No cleanup is required for changing stance.
end

function SoldierActions_ChangeStanceInitialize(userData)
    -- Issue a change stance command and immediately terminate.
    userData.controller:QueueCommand(
        userData.agent,
        SoldierController.Commands.CHANGE_STANCE);
    return Action.Status.TERMINATED;
end

function SoldierActions_ChangeStanceUpdate(deltaTimeInMillis, userData)
    return Action.Status.TERMINATED;
end

-- Die Action
function SoldierActions_DieCleanUp(userData)
    -- No cleanup is required for death.
end

function SoldierActions_DieInitialize(userData)
    -- Issue a die command and immediately terminate.
    userData.controller:ImmediateCommand(
        userData.agent,
        SoldierController.Commands.DIE);

    userData.alive = false;
    return Action.Status.TERMINATED;
end

function SoldierActions_DieUpdate(deltaTimeInMillis, userData)
    return Action.Status.TERMINATED;
end

-- Flee Action
function SoldierActions_FleeCleanUp(userData)
    -- No cleanup is required for fleeing.
end

function SoldierActions_FleeInitialize(userData)
    local sandbox = userData.agent:GetSandbox();
    
    if (userData.enemy) then
        local endPoint = Sandbox.RandomPoint(sandbox, "default");
        local path = Sandbox.FindPath(
            sandbox, "default", userData.agent:GetPosition(), endPoint);
        
        -- Find a valid position at least 16 units away from the current
        -- enemy.
        -- Note: Since pathfinding is not affected by the enemy, it is entirely
        -- possible to generate paths that move the Agent into the enemy,
        -- instead of away from the enemy.
        while #path == 0 do
            endPoint = Sandbox.RandomPoint(sandbox, "default");
            while Vector.DistanceSquared(endPoint,
                userData.enemy:GetPosition()) < 16.0 do

                endPoint = Sandbox.RandomPoint(sandbox, "default");
            end
            path = Sandbox.FindPath(
                sandbox, "default", userData.agent:GetPosition(), endPoint);
        end
        
        Soldier_SetPath(userData.agent, path, false);
        userData.agent:SetTarget(endPoint);
        userData.movePosition = endPoint;
    else
        -- Randomly move anywhere if the Agent has no current enemy.
        SoldierActions_RandomMoveInitialize(userData);
    end
    
    userData.controller:QueueCommand(
        userData.agent,
        SoldierController.Commands.MOVE);

    return Action.Status.RUNNING;
end

function SoldierActions_FleeUpdate(deltaTimeInMillis, userData)
    -- Terminate the Action if the agent is dead.
    if (Agent.GetHealth(userData.agent) <= 0) then
        return Action.Status.TERMINATED;
    end

    path = userData.agent:GetPath();
    DebugUtilities_DrawPath(
        path, false, Vector.new(), DebugUtilities.Blue);
    Core.DrawCircle(
        path[#path], 1.5, DebugUtilities.Blue);

    if (Vector.Distance(
        userData.agent:GetPosition(),
        userData.agent:GetTarget()) < 1.5) then

        Agent.RemovePath(userData.agent);
        return Action.Status.TERMINATED;
    end
    
    return Action.Status.RUNNING;
end

-- Idle Action
function SoldierActions_IdleCleanUp(userData)
    -- No cleanup is required for idling.
end

function SoldierActions_IdleInitialize(userData)
    userData.controller:QueueCommand(
        userData.agent,
        SoldierController.Commands.IDLE);

    -- Since idle is a looping animation, cut off the idle
    -- Action after 2 seconds.
    local sandboxTimeInMillis =
        Sandbox.GetTimeInMillis(userData.agent:GetSandbox());
    userData.idleEndTime = sandboxTimeInMillis + 2000;
end

function SoldierActions_IdleUpdate(deltaTimeInMillis, userData)
    local sandboxTimeInMillis =
        Sandbox.GetTimeInMillis(userData.agent:GetSandbox());
    if (sandboxTimeInMillis >= userData.idleEndTime) then
        userData.idleEndTime = nil;
        return Action.Status.TERMINATED;
    end
    return Action.Status.RUNNING;
end

-- Move Action
function SoldierActions_MoveToCleanUp(userData)
    userData.moveEndTime = nil;
end

function SoldierActions_MoveToInitialize(userData)
    userData.controller:QueueCommand(
        userData.agent,
        SoldierController.Commands.MOVE);
    
    -- Since movement is a looping animation, cut off the move
    -- Action after 0.5 seconds.
    local sandboxTimeInMillis =
        Sandbox.GetTimeInMillis(userData.agent:GetSandbox());
    userData.moveEndTime = sandboxTimeInMillis + 500;

    return Action.Status.RUNNING;
end

function SoldierActions_MoveToUpdate(deltaTimeInMillis, userData)
    -- Terminate the action after the allotted 0.5 seconds.  The
    -- decision structure will simply repath if the Agent needs
    -- to move again.
    local sandboxTimeInMillis =
        Sandbox.GetTimeInMillis(userData.agent:GetSandbox());
    if (sandboxTimeInMillis >= userData.moveEndTime) then
        userData.moveEndTime = nil;
        return Action.Status.TERMINATED;
    end

    path = userData.agent:GetPath();
    if (#path ~= 0) then
        offset = Vector.new(0, 0.05, 0);
        DebugUtilities_DrawPath(
            path, false, offset, DebugUtilities.Orange);
        Core.DrawCircle(
            path[#path] + offset, 1.5, DebugUtilities.Orange);
    end

    -- Terminate movement is the Agent is close enough to the target.
    if (Vector.Distance(userData.agent:GetPosition(),
        userData.agent:GetTarget()) < 1.5) then

        Agent.RemovePath(userData.agent);
        return Action.Status.TERMINATED;
    end

    return Action.Status.RUNNING;
end

-- Pursue Action
function SoldierActions_PursueCleanUp(userData)
    -- No cleanup is required for pursuit.
end

function SoldierActions_PursueInitialize(userData)
    local sandbox = userData.agent:GetSandbox();
    local endPoint = userData.enemy:GetPosition();
    local path = Sandbox.FindPath(
        sandbox, "default", userData.agent:GetPosition(), endPoint);
    
    -- Path to the enemy if possible, otherwise idle and constantly
    -- try to repath to the enemy.
    if (#path ~= 0) then
        Soldier_SetPath(userData.agent, path, false);
        userData.agent:SetTarget(endPoint);
        userData.movePosition = endPoint;
        
        userData.controller:QueueCommand(
            userData.agent,
            SoldierController.Commands.MOVE);
    end
    
    return Action.Status.RUNNING;
end

function SoldierActions_PursueUpdate(deltaTimeInMillis, userData)
    -- Terminate the Action if the agent dies.
    if (Agent.GetHealth(userData.agent) <= 0) then
        return Action.Status.TERMINATED;
    end

    -- Constantly repath to the enemy's new position.
    local sandbox = userData.agent:GetSandbox();
    local endPoint = userData.enemy:GetPosition();
    local path = Sandbox.FindPath(
        sandbox, "default", userData.agent:GetPosition(), endPoint);
    
    if (#path ~= 0) then
        Soldier_SetPath(userData.agent, path, false);
        userData.agent:SetTarget(endPoint);
        userData.movePosition = endPoint;
        
        offset = Vector.new(0, 0.1, 0);
        path = userData.agent:GetPath();
        DebugUtilities_DrawPath(
            path, false, offset, DebugUtilities.Red);
        Core.DrawCircle(
            path[#path] + offset, 3, DebugUtilities.Red);
    end

    -- Terminate the pursuit Action when the Agent is within
    -- shooting distance to the enemy.
    if (Vector.Distance(userData.agent:GetPosition(),
        userData.agent:GetTarget()) < 3) then

        Agent.RemovePath(userData.agent);
        return Action.Status.TERMINATED;
    end
    
    return Action.Status.RUNNING;
end

-- Random Move Action
function SoldierActions_RandomMoveCleanUp(userData)
    -- No cleanup is required for random movement.
end

function SoldierActions_RandomMoveInitialize(userData)
    local sandbox = userData.agent:GetSandbox();

    -- Find a random pathable point for the Agent to move to.
    local endPoint = Sandbox.RandomPoint(sandbox, "default");
    local path = Sandbox.FindPath(
        sandbox, "default", userData.agent:GetPosition(), endPoint);
    
    while #path == 0 do
        endPoint = Sandbox.RandomPoint(sandbox, "default");
        path = Sandbox.FindPath(
            sandbox, "default", userData.agent:GetPosition(), endPoint);
    end
    
    Soldier_SetPath(userData.agent, path, false);
    userData.agent:SetTarget(endPoint);
    userData.movePosition = endPoint;
    
    return Action.Status.TERMINATED;
end

function SoldierActions_RandomMoveUpdate(deltaTimeInMillis, userData)
    return Action.Status.TERMINATED;
end

-- Reload Action
function SoldierActions_ReloadCleanUp(userData)
    userData.ammo = userData.maxAmmo;
end

function SoldierActions_ReloadInitialize(userData)
    userData.controller:QueueCommand(
        userData.agent,
        SoldierController.Commands.RELOAD);
    return Action.Status.RUNNING;
end

function SoldierActions_ReloadUpdate(deltaTimeInMillis, userData)
    if (userData.controller:QueueLength() > 0) then
        return Action.Status.RUNNING;
    end
    
    return Action.Status.TERMINATED;
end

-- Shoot Action
function SoldierActions_ShootCleanUp(userData)
    -- No cleanup is required for shooting.
end

function SoldierActions_ShootInitialize(userData)
    userData.controller:QueueCommand(
        userData.agent,
        SoldierController.Commands.SHOOT);
    userData.controller:QueueCommand(
        userData.agent,
        SoldierController.Commands.IDLE);
    
    return Action.Status.RUNNING;
end

function SoldierActions_ShootUpdate(deltaTimeInMillis, userData)
    -- Point toward the enemy so the Agent's rifle will shoot correctly.
    -- Note: this can cause undesirable tilting of the Agent.
    -- A better fix for this would be to allow a slight amount of bullet
    -- deviation to hit the enemy and zeroing out any change in the y axis
    -- of the forward vector.
    local forwardToEnemy =
        userData.enemy:GetPosition() - userData.agent:GetPosition();
    Agent.SetForward(userData.agent, forwardToEnemy);

    if (userData.controller:QueueLength() > 0) then
        return Action.Status.RUNNING;
    end

    -- Subtract a single bullet per shot.
    userData.ammo = userData.ammo - 1;
    return Action.Status.TERMINATED;
end