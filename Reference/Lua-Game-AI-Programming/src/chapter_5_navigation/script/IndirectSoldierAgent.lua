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

require "DebugUtilities"
require "SandboxUtilities"
require "Soldier"
require "SoldierController"

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
    -- Allow the soldier controller to update animations and handle new commands.
    _soldierController:Update(agent, deltaTimeInMillis);
end