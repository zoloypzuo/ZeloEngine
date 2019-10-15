require "DebugUtilities"
require "SandboxUtilities"
require "Soldier/Soldier"
require "MindBodyControl/SoldierController"

local _soldierController;

local function _IsNumKey(key, numKey)
    -- Match both numpad keys and numeric keys.
    return string.find(key, string.format("^[numpad_]*%d_key$", numKey));
end

function Agent_Cleanup(agent)
end

function Agent_HandleEvent(agent, event)
    -- Queue a new command with the soldier controller.
    if (event.source == "keyboard" and event.pressed) then
        if (_IsNumKey(event.key, 1)) then
            _soldierController:QueueCommand(
                    agent, SoldierController.Commands.IDLE);
        elseif (_IsNumKey(event.key, 2)) then
            _soldierController:QueueCommand(
                    agent, SoldierController.Commands.SHOOT);
        elseif (_IsNumKey(event.key, 3)) then
            _soldierController:QueueCommand(
                    agent, SoldierController.Commands.MOVE);
        elseif (_IsNumKey(event.key, 4)) then
            _soldierController:ImmediateCommand(
                    agent, SoldierController.Commands.DIE);
        elseif (_IsNumKey(event.key, 5)) then
            _soldierController:QueueCommand(
                    agent, SoldierController.Commands.CHANGE_STANCE);
        end
    end
end

function Agent_Initialize(agent)
    -- Initialize the soldier and weapon models.
    local soldier = Soldier_CreateSoldier(agent);
    local weapon = Soldier_CreateWeapon(agent);

    -- Create the soldier controller, responsible for handling animation
    -- state machines.
    _soldierController = SoldierController.new(agent, soldier, weapon);

    -- Attach the weapon model after the animation state machines
    -- have been created.
    Soldier_AttachWeapon(soldier, weapon);
    weapon = nil;
end

function Agent_Update(agent, deltaTimeInMillis)
    -- Draw the agent's cyclic path, offset slightly above the level geometry.
    DebugUtilities_DrawPath(
            agent:GetPath(), true, Vector.new(0, 0.02, 0));

    -- Allow the soldier controller to update animations and handle new commands.
    _soldierController:Update(agent, deltaTimeInMillis);
end