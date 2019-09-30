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

require "AnimationStateMachine"
require "Soldier"

local _stance;
local _soldierMesh;

SoldierController = {};

-- Supported commands that can be requested.
SoldierController.Commands = {
    CHANGE_STANCE =     "CHANGE_STANCE",
    DIE =               "DIE",
    IDLE =              "IDLE",
    MOVE =              "MOVE",
    SHOOT =             "SHOOT"
};

-- Supported soldier stances.
SoldierController.Stances = {
    CROUCH =    "CROUCH",
    STAND =     "STAND"
};

-- Additional supported commands that cannot be requested.
SoldierController.PrivateCommands = {
    FALLING = "FALLING"
};

local function _AddCommandCallback(self, commandName, callback)
    assert(type(commandName) == "string");
    assert(type(callback) == "function");

    self.commandCallbacks[commandName] = callback;
end

local function _AdvanceExecutingCommand(self)
    -- Moves the first queued command into execution if the previous command
    -- has finished.
    if (#self.commands > 0 and not self.executingCommand) then
        local command = self.commands[1];
        self.executingCommand = command;
        table.remove(self.commands, 1);
    end
end

local function _ClearExecutingCommand(self)
    -- Stores the previously executing command before clearing the command.
    self.previousCommand = self.executingCommand;
    self.executingCommand = nil;
end

local function _ExecuteChangeStanceCommand(self, agent, deltaTimeInMillis)
    -- Requeues the previous command since change stance isn't a state the
    -- soldier can stay in.
    if (#self.commands == 0) then
        self:ImmediateCommand(agent, self.previousCommand);
    end

    -- Immediately changes the stance of the agent.  The requeued command
    -- is responsible for actually transitioning the agent to the correct
    -- stance visually.
    if (_stance == SoldierController.Stances.CROUCH) then
        _stance = SoldierController.Stances.STAND;
        Soldier_SetHeight(agent, _soldierMesh, Soldier.Height.Stand);
    else
        _stance = SoldierController.Stances.CROUCH;
        Soldier_SetHeight(agent, _soldierMesh, Soldier.Height.Crouch);
    end

    -- Remove the change stance command since it finishes immediately.
    _ClearExecutingCommand(self);
end

local function _ExecuteCommand(self, agent, deltaTimeInMillis)
    local callback = self.commandCallbacks[self.executingCommand];

    -- Handle any callback that is associated with an executing command.
    if (callback) then
        callback(self, agent, deltaTimeInMillis);
    end
end

local function _ExecuteDieCommand(self, agent, deltaTimeInMillis)
    local currentState = self.asms["soldier"]:GetCurrentStateName();

    if (Soldier_IsMoving(agent)) then
        -- Slow movement at twice the rate to blend to a death pose.
        Soldier_SlowMovement(agent, deltaTimeInMillis, 2);
    end

    -- Request the appropriate stance death and immediately remove physics
    -- to prevent other agents from colliding with the agent's physics capsule.
    if (_stance == SoldierController.Stances.STAND) then
        if (currentState ~= Soldier.SoldierStates.STAND_DEAD) then
            self.asms["soldier"]:RequestState(
                Soldier.SoldierStates.STAND_DEAD);
            agent:RemovePhysics();
            agent:SetHealth(0);
        end
    else
        if (currentState ~= Soldier.SoldierStates.CROUCH_DEAD) then
            self.asms["soldier"]:RequestState(
                Soldier.SoldierStates.CROUCH_DEAD);
            agent:RemovePhysics();
            agent:SetHealth(0);
        end
    end
    
    -- Never clears the executing command since this is a terminal state.
end

local function _ExecuteFallingCommand(self, agent, deltaTimeInMillis)
    local currentState = self.asms["soldier"]:GetCurrentStateName();
    
    -- Since there's no falling animation, move the soldier into an idle
    -- animation.
    if (currentState ~= Soldier.SoldierStates.STAND_FALL_IDLE and
        currentState ~= Soldier.SoldierStates.STAND_FALL_DEAD) then
        self.asms["soldier"]:RequestState(
            Soldier.SoldierStates.STAND_FALL_IDLE);
    end
    
    -- Once the soldier is no longer falling, play a death animation.
    if (not Soldier_IsFalling(agent)) then
        if (currentState ~= Soldier.SoldierStates.STAND_FALL_DEAD) then
            self.asms["soldier"]:RequestState(
                Soldier.SoldierStates.STAND_FALL_DEAD);
            -- Remove the soldier from physics once the death animation
            -- starts playing.
            agent:RemovePhysics();
            agent:SetHealth(0);
        end
    end
    
    -- Never clears the executing command since this is a terminal state.
end

local function _ExecuteIdleCommand(self, agent, deltaTimeInMillis)
    local currentState = self.asms["soldier"]:GetCurrentStateName();

    if (_stance == SoldierController.Stances.STAND) then
        if (Soldier_IsMoving(agent)) then
            -- Slow movement to blend to an idle pose.
            Soldier_SlowMovement(agent, deltaTimeInMillis);
        end
    
        if (currentState ~= Soldier.SoldierStates.STAND_IDLE_AIM) then
            -- Only request the STAND_IDLE_AIM state if not currently playing.
            self.asms["soldier"]:RequestState(
                Soldier.SoldierStates.STAND_IDLE_AIM);
        elseif (#self.commands > 0) then
            -- Continue executing till a new command is queued.
            _ClearExecutingCommand(self);
        end
    else
        if (Soldier_IsMoving(agent)) then
            -- Slow movement at twice the rate to blend to an idle pose.
            Soldier_SlowMovement(agent, deltaTimeInMillis, 2);
        end
    
        if (currentState ~= Soldier.SoldierStates.CROUCH_IDLE_AIM) then
            -- Only request the CROUCH_IDLE_AIM state if not currently playing.
            self.asms["soldier"]:RequestState(
            Soldier.SoldierStates.CROUCH_IDLE_AIM);
        elseif (#self.commands > 0) then
            -- Continue executing till a new command is queued.
            _ClearExecutingCommand(self);
        end
    end
end

local function _ExecuteMoveCommand(self, agent, deltaTimeInMillis)
    local currentState = self.asms["soldier"]:GetCurrentStateName();
    local deltaTimeInSeconds = deltaTimeInMillis / 1000;
    local steeringForces = nil

    if (_stance == SoldierController.Stances.STAND) then
        -- Only request the STAND_RUN_FORWARD state if not currently playing.
        if (currentState ~= Soldier.SoldierStates.STAND_RUN_FORWARD) then
            -- Change the agent's desired speed for quick movement.
            agent:SetMaxSpeed(Soldier.Speed.Stand);
            self.asms["soldier"]:RequestState(
                Soldier.SoldierStates.STAND_RUN_FORWARD);
        elseif (#self.commands > 0) then
            -- Continue executing till a new command is queued.
            _ClearExecutingCommand(self);
        end
        
        -- Calculate steering forces tuned for quick movement.
        steeringForces = Soldier_CalculateSteering(agent, deltaTimeInSeconds);
    else
        -- Only request the CROUCH_FORWARD state if not currently playing.
        if (currentState ~= Soldier.SoldierStates.CROUCH_FORWARD) then
            -- Change the agent's desired speed for slow movement.
            agent:SetMaxSpeed(Soldier.Speed.Crouch);
            self.asms["soldier"]:RequestState(
                Soldier.SoldierStates.CROUCH_FORWARD);
        elseif (#self.commands > 0) then
            -- Continue executing till a new command is queued.
            _ClearExecutingCommand(self);
        end
        
        -- Calculate steering forces tuned for slow movement.
        steeringForces =
            Soldier_CalculateSlowSteering(agent, deltaTimeInSeconds);
    end

    Soldier_ApplySteering(agent, steeringForces, deltaTimeInSeconds);
end

local function _ExecuteShootCommand(self, agent, deltaTimeInMillis)
    local currentState = self.asms["soldier"]:GetCurrentStateName();

    if (_stance == SoldierController.Stances.STAND) then
        -- Slow movement to blend to a shooting pose.
        if (Soldier_IsMoving(agent)) then
            Soldier_SlowMovement(agent, deltaTimeInMillis);
        end
    
        -- Only request the STAND_FIRE state if not currently playing.
        if (currentState ~= Soldier.SoldierStates.STAND_FIRE) then
            self.asms["soldier"]:RequestState(
                Soldier.SoldierStates.STAND_FIRE);
        elseif (#self.commands > 0) then
            -- Continue executing till a new command is queued.
            _ClearExecutingCommand(self);
        end
    else
        -- Slow movement at twice the rate to blend to a shooting pose.
        if (Soldier_IsMoving(agent)) then
            Soldier_SlowMovement(agent, deltaTimeInMillis, 2);
        end
    
        -- Only request the CROUCH_FIRE state if not currently playing.
        if (currentState ~= Soldier.SoldierStates.CROUCH_FIRE) then
            self.asms["soldier"]:RequestState(
                Soldier.SoldierStates.CROUCH_FIRE);
        elseif (#self.commands > 0) then
            -- Continue executing till a new command is queued.
            _ClearExecutingCommand(self);
        end
    end
end

local function _IsDead(self)
    return self.executingCommand == SoldierController.Commands.DIE;
end

local function _UpdateAsms(self, deltaTimeInMillis, sandboxTimeInMillis)
    for key, value in pairs(self.asms) do
        value:Update(deltaTimeInMillis, sandboxTimeInMillis);
    end
end

function SoldierController.ClearCommands(self, agent)
    self.commands = {};
end

function SoldierController.CurrentCommand(self)
    return self.executingCommand;
end

function SoldierController.ImmediateCommand(self, agent, command)
    -- Adds the command to the beginning of the queue.
    table.insert(self.commands, 1, command);
end

function SoldierController.Initialize(self, agent, soldier, weapon)
    self.asms["soldier"] = Soldier_CreateSoldierStateMachine(soldier);
    self.asms["weapon"] = Soldier_CreateWeaponStateMachine(weapon);

    -- Data that is passed into Soldier_Shoot, expects an agent, and soldier
    -- attribute.
    local callbackData = {
        agent = agent,
        soldier = soldier
    };

    -- Add callbacks to shoot a bullet each time the shooting animation is
    -- played.
    self.asms["soldier"]:AddStateCallback(
        Soldier.SoldierStates.STAND_FIRE, Soldier_Shoot, callbackData );
    self.asms["soldier"]:AddStateCallback(
        Soldier.SoldierStates.CROUCH_FIRE, Soldier_Shoot, callbackData );

    _soldierMesh = soldier;

    -- Sets the default state and stance of the controller.
    self:QueueCommand(agent, SoldierController.Commands.IDLE);
    _stance = SoldierController.Stances.STAND;

    -- Associate a callback function to handle each command.
    _AddCommandCallback(
        self, SoldierController.Commands.CHANGE_STANCE, _ExecuteChangeStanceCommand);
    _AddCommandCallback(
        self, SoldierController.Commands.DIE, _ExecuteDieCommand);
    _AddCommandCallback(
        self, SoldierController.Commands.IDLE, _ExecuteIdleCommand);
    _AddCommandCallback(
        self, SoldierController.Commands.MOVE, _ExecuteMoveCommand);
    _AddCommandCallback(
        self, SoldierController.Commands.SHOOT, _ExecuteShootCommand);
    _AddCommandCallback(
        self, SoldierController.PrivateCommands.FALLING, _ExecuteFallingCommand);
end

function SoldierController.QueueCommand(self, agent, command)
    -- Add the new command to the back of the queue.
    table.insert(self.commands, command);
end

function SoldierController.QueueLength(self, agent, command)
    return #self.commands;
end

function SoldierController.Update(self, agent, deltaTimeInMillis)
    -- Returns the amount of time that has passed in the sandbox,
    -- this is not the same as lua's os.time();
    local sandboxTimeInMillis = Sandbox.GetTimeInMillis(agent:GetSandbox());

    -- Allow the soldier to update any soldier's specific data.
    Soldier_Update(agent, deltaTimeInMillis);
    
    -- Update the animation state machines to process animation requests.
    _UpdateAsms(self, deltaTimeInMillis, sandboxTimeInMillis);

    -- Ignore all state requests once the agent is dead.
    if (_IsDead(self)) then
        return;
    end
    
    -- Force the soldier into falling, this overrides all other requests.
    if (Soldier_IsFalling(agent)) then
        self:ImmediateCommand(agent, SoldierController.PrivateCommands.FALLING);
        _ClearExecutingCommand(self);
    end

    -- Select a new command to execute if the current command has finished and
    -- a new command is queued.
    _AdvanceExecutingCommand(self);
    
    -- Process the current command.
    _ExecuteCommand(self, agent, deltaTimeInMillis);
end

function SoldierController.new(agent, soldier, weapon)
    local controller = {};
    
    -- The SoldierController's data members.
    controller.commands = {};
    controller.commandCallbacks = {};
    controller.asms = {};
    controller.executingCommand = nil;
    controller.previousCommand = nil;
    
    -- The SoldierController's accessor functions.
    controller.ClearCommands = SoldierController.ClearCommands;
    controller.CurrentCommand = SoldierController.CurrentCommand;
    controller.ImmediateCommand = SoldierController.ImmediateCommand;
    controller.QueueCommand = SoldierController.QueueCommand;
    controller.QueueLength = SoldierController.QueueLength;
    controller.Update = SoldierController.Update;
    
    SoldierController.Initialize(controller, agent, soldier, weapon);
    
    return controller;
end