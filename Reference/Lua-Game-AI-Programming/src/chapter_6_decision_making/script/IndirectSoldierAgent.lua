require "DebugUtilities"
require "SandboxUtilities"
require "Soldier/Soldier"
require "MindBodyControl/SoldierController"
require "Soldier/SoldierLogic"

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