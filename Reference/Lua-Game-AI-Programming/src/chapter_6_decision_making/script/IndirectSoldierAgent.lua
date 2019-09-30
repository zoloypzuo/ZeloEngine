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
require "SoldierLogic"

local soldier;
local soldierController;
local soldierLogic;
local soldierUserData;

function Agent_Cleanup(agent)
end

function Agent_HandleEvent(agent, event)
end

function Agent_Initialize(agent)
    soldier = Soldier_CreateSoldier(agent);
    weapon = Soldier_CreateWeapon(agent);

    soldierController = SoldierController.new(agent, soldier, weapon);

    Soldier_AttachWeapon(soldier, weapon);
    weapon = nil;

    -- Data passed into evaluators and actions.
    soldierUserData = {};
    soldierUserData.agent = agent;
    soldierUserData.controller = soldierController;
    soldierUserData.maxHealth = Agent.GetHealth(agent);
    soldierUserData.alive = true;
    soldierUserData.ammo = 10;
    soldierUserData.maxAmmo = 10;
    
    -- soldierLogic = SoldierLogic_DecisionTree(soldierUserData);
    -- soldierLogic = SoldierLogic_FiniteStateMachine(soldierUserData);
    soldierLogic = SoldierLogic_BehaviorTree(soldierUserData);
end

function Agent_Update(agent, deltaTimeInMillis)
    if (soldierUserData.alive) then
        soldierLogic:Update(deltaTimeInMillis);
    end

    soldierController:Update(agent, deltaTimeInMillis);
end